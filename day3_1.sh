#!/bin/bash

# ./day3_1.sh day3_input.txt

trees=0
offset=0
while read line; do
    cur=${line:$offset:1}
    length=${#line}
    let offset=$offset+3
    let offset=$offset%$length
    if [ $cur = "#" ] ; then
        let trees++
    fi
    #printf 'Line %s, length %d cur %s offset %d\n' "$line" $length $cur $offset
done <"${1:-/dev/stdin}"
printf 'Total trees: %d\n' $trees
