#!/bin/bash
# [[file:index.org::*getmetadataname][getmetadataname:1]]
function getmetadataname {
    # echo "Looking for document name in $1"
    grep visibleName $1 | sed -e 's/.*": "\?//' -e 's/"\?,*$//'
    ## grep visibleName $1 | sed -e 's/.*": "//' -e 's/",*$//' -e 's/ /./g'
}
# getmetadataname:1 ends here

# [[file:index.org::*getfullname][getfullname:1]]
function getfullname {
    xochitl=${1}
    uuid=${2}
    meta="${xochitl}/${uuid}.metadata"
    documentname=$(getmetadataname ${meta})
    # echo Document name is $documentname
    # the document may be in a folder.  Use the recursive function defined
    # above to extra a full path to the destination folder
    folders=""
    parentuuid=$(grep parent $meta \
                     | sed -e 's/.*": "\?//' \
                           -e 's/"\?,*$//' \
                           -e 's/null,*$// ')
    ## | sed -e 's/.*": "\?//' -e 's/"\?,*$//' -e 's/ /./g' )
    while [[ "$parentuuid" != "" && "$parentuuid" != "null" ]] 
    do
        if [ "$parentuuid" != "trash" ]
        then
            # echo ".. found folder uuid = $parentuuid"
            directoryname=$(getmetadataname ${xochitl}/${parentuuid}.metadata)
            # echo ".. with name $documentname"
            folders="${directoryname}/${folders}"
            # move up a folder
            parentuuid=$(grep parent "${xochitl}/${parentuuid}.metadata" \
                             | sed -e 's/.*": "\?//' \
                                   -e 's/"\?,*$//'  \
                                   -e 's/null,*$// ')
            ## | sed -e 's/.*": "//' -e 's/",*$//' -e 's/ /./g' )
        else
            folders="trash/${folders}"
            parentuuid=""
        fi
    done  
    # echo "back in main, folders = $folders"
    destination="${destdir}/${folders}"
    echo ${destination}${documentname}
}
# getfullname:1 ends here

# [[file:index.org::*main block][main block:1]]
xochitl=${1}
for metadata in $(find ${xochitl} -name '*.metadata')
do
    uuid=$(basename ${metadata} .metadata)
    # check to see if this is a file or a directory (Collection)
    type=$(grep type ${metadata} | sed -e 's/^.*": "//' -e 's/",.*$//' )
    # echo 'Checking type of file: ' ${metadata} 'is of type' ${type}
    if [ "${type}" == "DocumentType" ]
    then
        fullname=$(getfullname ${xochitl} ${uuid})
        lastchange=$(grep lastModified ${metadata} | sed  's/^.*"\([0-9]\{10\}\).*$/\1/')
        date=$(date --date="@${lastchange}" +%Y%m%d-%H:%M:%S)
        echo ${uuid} ${date} ${fullname}
    fi
done
# main block:1 ends here
