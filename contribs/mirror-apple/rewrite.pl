#!/usr/bin/env perl
$|=1;
while (<>) {
s@http://swscan.apple.com@http://sw.technimac.eu/swscan.apple.com@;
s@http://swcdn.apple.com@http://sw.technimac.eu/swcdn.apple.com@;
s@http://swquery.apple.com@http://sw.technimac.eu/swquery.apple.com@;
print;
}
