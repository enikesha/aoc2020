#!/bin/bash

# ./day3_1.sh 3 1 day3_input.txt

slope=$1
down=$2
x=0
y=0
trees=0
while read line; do
    cur=${line:$x:1}
    if [ $y -eq 0 ] ; then
        if [ $cur = "#" ] ; then
            (( trees++ ))
        fi
        (( x += $slope ))
        x=$(( $x % ${#line} ))
    fi
    (( y++ ))
    y=$(( $y % $down ))
    #printf 'Line %s, cur %s x %d y %d, trees %d\n' "$line" $cur $x $y $trees
done <"${3:-/dev/stdin}"
echo $trees
