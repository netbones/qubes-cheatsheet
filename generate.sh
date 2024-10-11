#! /usr/bin/env bash

# This BASH script generates different output files by calling pandoc

# check if pandoc is installed
if [[ `command -v pandoc` ]]
then
  # outputs the qubes cheat sheet as PDF file
  pandoc metadata.yaml qubes-cheatsheet.md -s -o qubes-cheatsheet.pdf

  # outputs the qubes cheat sheet as HTML (HTML5) file
  pandoc metadata.yaml qubes-cheatsheet.md -s -t html5+smart -o qubes-cheatsheet.html

  # outputs the qubes cheat sheet as plain text
  pandoc qubes-cheatsheet.md -s -t plain+smart -o qubes-cheatsheet.txt
else
  # pandoc is not installed inform the user
  echo "The command pandoc could not be found in the PATH!\n"
fi
