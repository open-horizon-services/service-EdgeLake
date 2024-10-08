#!/bin/bash
IDS=$(curl -X GET 45.79.74.39:32049  -H 'command: blockchain get * where company="Open Horizon" bring [*][id] separator=" "')
for ID in ${IDS} ; do
  echo ${ID}
  curl -X POST 45.79.74.39:32049 -H "command: blockchain drop policy where id=${ID}" -H "User-Agent": AnyLog/1.23"
done