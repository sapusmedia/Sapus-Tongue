#!/bin/sh

# issue #
for i in `find . -name \*.png`
do
mv $i $i.old
convert $i.old -scale %200 $i
done
