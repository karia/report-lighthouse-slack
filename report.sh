#!/usr/bin/env bash

set -eu

if !(type lighthouse > /dev/null 2>&1);then
  echo "please install lighthouse command."
  exit 1
fi

cd `dirname $0`

URL=$1

lighthouse ${URL} --quiet --chrome-flags="--headless" --emulated-form-factor mobile --output=json --output-path=./report.json
SCORE_MOBILE=`ruby report.rb`
lighthouse ${URL} --quiet --chrome-flags="--headless" --emulated-form-factor desktop --output=json --output-path=./report.json
SCORE_DESKTOP=`ruby report.rb`

MESSAGE='```'${URL}' のspeed index\nモバイル: '${SCORE_MOBILE}'\nパソコン: '${SCORE_DESKTOP}'```'

PAYLOAD="payload={\"username\": \"result\", \"text\": \"${MESSAGE}\", \"icon_emoji\": \":glitch_crab:\"}"

curl -s -S -X POST --data-urlencode "${PAYLOAD}" ${WEBHOOK_URL}
