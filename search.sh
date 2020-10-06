#!/bin/bash

query="$1"
PATH="$PATH:/usr/local/bin"
JQ_BIN=$(which jq)
ALGOLIA_HOST="https://dl2c5qx6xb-dsn.algolia.net"
ALGOLIA_API_KEY="9a89b2831ea7014e98ec4a0f477d2de5"
DOC_SITE="https://docs.launchdarkly.com"

if [ -f "/usr/local/bin/jq" ]; then
    JQ_COMMAND="/usr/local/bin/jq"
elif [ -f "/usr/bin/jq" ]; then
    JQ_COMMAND="/usr/bin/jq"
elif [ -f "$HOME/bin/jq" ]; then
    JQ_COMMAND="$HOME/bin/jq"
fi

if [[ -z "${JQPATH}" ]]; then
    JQ_COMMAND=$(which jq)
elif [ -z "$JQ_COMMAND" ]; then
    export PATH=$JQPATH:$PATH
    JQ_COMMAND="jq"
fi

uriencode() {
  s="${1//'%'/%25}"
  s="${s//' '/%20}"
  s="${s//'"'/%22}"
  s="${s//'#'/%23}"
  s="${s//'$'/%24}"
  s="${s//'&'/%26}"
  s="${s//'+'/%2B}"
  s="${s//','/%2C}"
  s="${s//'/'/%2F}"
  s="${s//':'/%3A}"
  s="${s//';'/%3B}"
  s="${s//'='/%3D}"
  s="${s//'?'/%3F}"
  s="${s//'@'/%40}"
  s="${s//'['/%5B}"
  s="${s//']'/%5D}"
  printf %s "$s"
}

curl "${ALGOLIA_HOST}/1/indexes/*/queries?x-algolia-agent=Alfred&x-algolia-application-id=DL2C5QX6XB&x-algolia-api-key=${ALGOLIA_API_KEY}" \
  -H 'Connection: keep-alive' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  --data-raw '{"requests":[{"indexName":"Docs_production","params":"query='"$(uriencode "$query")"'&facets=%5B%5D&tagFilters="}]}' \
  --compressed | ${JQ_BIN} ".results[].hits | {items: map({type: 'url', title: .title, uid: (${DOC_SITE} + .path), arg: (${DOC_SITE} + .path), subtitle: .description, quicklookurl: (${DOC_SITE} + .path) }) }"
