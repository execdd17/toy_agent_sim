#!/bin/bash

EXPECTED_ARGS=1

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "usage: $0 [path_to_shoes_binary]"
  echo
  echo "For Example: $0 ../shoes/dist/shoes"
  echo "             $0 shoes   #when it's already in your path"
else
  $1 driver.rb
fi