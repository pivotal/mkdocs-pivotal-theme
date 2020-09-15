#!/usr/bin/env bash

build_source=$1
url=$2
whitelist=$3

exit_status=0

# how to use
if [ -z "$build_source" ]; then
  echo -e '\033[1;32mThank you for using link-linter!\033[0m'
  echo -e 'To use, please provide:
   - a built mkdocs site,
   - a url where your docs site is running,
   - an optional whitelist to exclude certain links from causing errors.'
  echo 'Example: ./ci/linter/link-linter.sh docs-for-product http://127.0.0.1:8000 https://google.com'
  echo -e '\033[1;93mNOTE: Links defined by single brackets are not checked by this tool.
      Please use either [title][link] or [title](link) to guarantee the linter will check it.\033[0m'
  exit 1
fi

# missing required URL
if [ -z "$url" ]; then
  echo -e '\033[1;31mURL is required for running the linter\033[0m'
  echo -e '\033[1;31mPlease provide a URL and run again\033[0m'
  exit 1
fi

if [ -z "$whitelist" ]; then
  echo -e '\033[1;32mrunning muffet without a whitelist...\033[0m'
  muffet -t 30 "$url" -c 5
  if [[ $? -ne 0 ]]; then
    echo -e '\033[1;31mmuffet returned with errors.\033[0m'
    exit_status=1
  fi
else
  echo -e '\033[1;32mrunning muffet with a regex whitelist...\033[0m'
  muffet -t 30 --exclude "$whitelist" "$url" -c 5
  if [[ $? -ne 0 ]]; then
    echo -e '\033[1;31mmuffet returned with errors!\033[0m'
    exit_status=1
  fi
fi

allHtmlLines() {
  for htmlFile in $(find . -type f -name '*.html'); do
    local i=0
    while IFS= read -r line; do
      ((i++))
      echo "$htmlFile:$i $line"
    done < "$htmlFile"
  done
}

pushd "$build_source"
    echo -e '\n\033[1;32mRunning a check for undefined reference-style links...\033[0m'
    brokenLinkLines=$(allHtmlLines | grep -e '\[.*\]\[.*\]')

    if [ -n "$brokenLinkLines" ]; then
      echo "$brokenLinkLines"
      echo -e '\033[1;31mGenerated HTML contains undefined links!\033[0m'
      exit_status=1
    fi

    echo -e '\n\033[1;32mRunning a check for undefined code blocks (```)...\033[0m'
    brokenLinkLines=$(allHtmlLines | grep -e '```')

    if [ -n "$brokenLinkLines" ]; then
      echo "$brokenLinkLines"
      echo -e '\033[1;31mGenerated HTML contains undefined code blocks!\033[0m'
      exit_status=1
    fi
popd

if [[ "$exit_status" -ne 0 ]]; then
  echo -e '\033[1;31mlink-linter returned with errors!\033[0m'
  echo -e '\033[1;31mPlease fix in the corresponding ".md" and rerun "mkdocs build"\033[0m'
else
  echo -e '\n\033[1;32mNo errors found in documentation links! \033[0m'
fi

exit "$exit_status"
