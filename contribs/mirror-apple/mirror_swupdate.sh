#!/bin/sh

location=$1 # This is the root of our Software Update tree
mkdir -p $1
cd $1

wget --mirror --tries=3 http://swscan.apple.com/content/meta/mirror-config-1.plist &&
wget --mirror --tries=3 http://swscan.apple.com/content/catalogs/Deprecations.plist &&
wget --mirror --tries=3 http://swscan.apple.com/content/catalogs/index.sucatalog

for index in index-leopard-snowleopard.merged-1.sucatalog index-leopard.merged-1.sucatalog index-lion-snowleopard-leopard.merged-1.sucatalog index-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog index-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog
do
wget --mirror --tries=3 http://swscan.apple.com/content/catalogs/others/$index

for swfile in `cat swscan.apple.com/content/catalogs/others/$index | grep "http://" | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }'`
do
echo $swfile
wget --mirror --tries=3 "$swfile"
done
done
