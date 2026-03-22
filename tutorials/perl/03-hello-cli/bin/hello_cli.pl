#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use HelloCli;

my $opts = HelloCli::parse_args(\@ARGV);
print HelloCli::format($opts), "\n";
