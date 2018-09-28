#!/bin/bash

function migrate {
  echo Migrating image from ${SRC_PREFIX}/$1 to ${DEST_PREFIX}/$1
  skopeo --insecure-policy copy --src-creds=${SRC_USER}:"${SRC_PWD}" --dest-creds=${DEST_USER}:"${DEST_PWD}" docker://${SRC_PREFIX}/$1 docker://${DEST_PREFIX}/$1
}

cat /images | while read -r line; do migrate $line; done
