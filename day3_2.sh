#!/bin/bash

# bash day3_2.sh day3_input.txt

input=$1
slopes='1-1 3-1 5-1 7-1 1-2'
mul_trees=1

for slope in $slopes ; do
    IFS='-' read -ra ADDR <<< "$slope"
    trees=$( ./day3_1.sh ${ADDR[0]} ${ADDR[1]} $input )
    let mul_trees=$mul_trees*$trees
done

echo $mul_trees
