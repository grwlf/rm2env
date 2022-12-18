#!/bin/bash

F="$1"

. $(dirname $0)/rmcommon.sh

if ! test -f "$F" ; then
  rmdie "File ($F) not found"
fi

set -e -x

rmcheck

set +e -x

pdf="$F"
n=$(pdfinfo "${pdf}" | grep '^Pages' | awk '{print $2}')
name=$(basename "${pdf}" .pdf)
date="$(date +%s)000"
echo Uploading PDF document ${name} with ${n} pages, date ${date}
temp=$(mktemp --directory rm.XXXXX)
trap "rm -rf $temp" 0 1 2 3 9
echo Resulting documents in ${temp}

uuid=$(uuidgen)
echo Creating $uuid document directories.
dest=${temp}/${uuid}
mkdir ${dest}
mkdir ${dest}.{cache,highlights,textconversion,thumbnails}
cp "${pdf}" ${dest}.pdf

cat > ${dest}.content <<EOF
{
    "extraMetadata": {
    },
    "fileType": "pdf",
    "fontName": "",
    "lastOpenedPage": 0,
    "lineHeight": -1,
    "margins": 100,
    "orientation": "portrait",
EOF
echo '    "pageCount":' ${n}',' >> ${dest}.content
echo '    "pages": [' >> ${dest}.content
page=1
while [ ${page} -le ${n} ]; do
  pageuuid=$(uuidgen)
  if [ ${page} -ne ${n} ]
  then
    echo '        "'${pageuuid}'",' >> ${dest}.content
  else
    echo '        "'${pageuuid}'"' >> ${dest}.content
  fi
  ((page++))
done
cat >> ${dest}.content <<EOF
],
    "textScale": 1,
    "transform": {
        "m11": 1,
        "m12": 0,
        "m13": 0,
        "m21": 0,
        "m22": 1,
        "m23": 0,
        "m31": 0,
        "m32": 0,
        "m33": 1
    }
}
EOF

cat > ${dest}.metadata <<EOF
{
    "deleted": false,
EOF
echo '    "lastModified": "'${date}'",' >> ${dest}.metadata
cat >> ${dest}.metadata <<EOF
    "metadatamodified": false,
    "modified": false,
    "parent": "",
    "pinned": false,
    "synced": false,
    "type": "DocumentType",
    "version": 1,
EOF
echo '    "visibleName": "'${name}'"' >> ${dest}.metadata
echo '}' >> ${dest}.metadata

page=1
touch ${dest}.pagedata
while [ ${page} -le ${n} ]; do
  echo Blank >> ${dest}.pagedata
  ((page++))
done

pdfseparate "${pdf}" ${dest}.thumbnails/%d.pdf
page=0
while [ ${page} -lt ${n} ]; do
  convert ${dest}.thumbnails/$((page+1)).pdf -monochrome -scale 362x512 ${dest}.thumbnails/${page}.jpg
  rm ${dest}.thumbnails/$((page+1)).pdf
  ((page++))
done

( cd ${temp} ; tar cf - . | (cd "$RM_XOCHITL" ; tar xvf - ))
