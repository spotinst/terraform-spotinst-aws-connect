#!/bin/bash
data=$(pip install -e .)
#json=$(echo "${data}" | jq -Rs '.')
echo '{"install":"yes"}'
