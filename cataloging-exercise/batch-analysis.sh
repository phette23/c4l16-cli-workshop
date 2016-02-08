#!/usr/bin/env bash
echo 'Processing MARC file...'
# run the pymarc script
./pm-script.py example.mrc batch-output.mrc
# count 856$u fields with the proxy prefix in the output file
num=$(./MARCgrep.pl -e '856,,,u,https://proxy.example.com/login?' -c batch-output.mrc)
echo "$num records contain the proxy server prefix"
# write all Library of Congress URLs to a separate text file
./MARCgrep.pl -e '856,,,u,loc.gov' -f '856' batch-output.mrc > LoC-URLs.txt
# delete blank lines from the text file, "-i" option edits file in place
sed -e '/^$/d' LoC-URLs.txt > tmp
# overwrite old file with temp one, sed doesn't like to edit in place
mv tmp LoC-URLs.txt
