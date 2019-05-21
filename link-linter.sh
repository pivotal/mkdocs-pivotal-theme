#!/usr/bin/env bash

url=$1
whitelist=$2

if [ -z "$url" ]; then
  echo "URL is required for running the linter."
  echo "Please provide a URL and run again"
  exit 1
fi

if [ -z "$whitelist" ]; then
  echo "running muffet without a whitelist..."
  muffet $url
else
  echo "running muffet with a regex whitelist..."
  muffet --exclude "$whitelist" "$url"
fi

# find site/ -type f -name '*.html' | xargs -n 1 cat | grep -e '\[.*\]\[.*\]'

allHtmlLines() {
  for htmlFile in $(find site/ -type f -name '*.html'); do
    local i=0
    while IFS= read -r line; do
      ((i++))
      echo "$htmlFile:$i $line"
    done < "$htmlFile"
  done
}

brokenLinkLines=$(allHtmlLines | grep -e '\[.*\]\[.*\]')

if [ ! -z "$brokenLinkLines" ]; then
  echo 'Generated HTML contains broken links'
  echo 'Please fix in the corresponding ".md" and rerun "mkdocs build"'
  echo "$brokenLinkLines"
  exit 1
fi
