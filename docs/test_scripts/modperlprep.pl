#!/usr/bin/perl
# example code to prep the the script for running in mod-perl environments
use Cwd;
my $directory;

if (exists($ENV{SCRIPT_FILENAME})) {
	($directory) = $ENV{SCRIPT_FILENAME} =~ m/^(.*)(?:\/|\\)(?:.*)$/g;
}

chdir($directory);
