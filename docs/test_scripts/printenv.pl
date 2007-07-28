#!/usr/bin/perl
##
##  printenv -- demo CGI program which just prints its environment
##
use Cwd;

print "Content-type: text/plain\n\n";
foreach $var (sort(keys(%ENV))) {
    $val = $ENV{$var};
    $val =~ s|\n|\\n|g;
    $val =~ s|"|\\"|g;
    print "${var}=\"${val}\"\n";
}
print "our working directory is: " . cwd();

my $directory;

if (exists($ENV{SCRIPT_FILENAME})) {
	($directory) = $ENV{SCRIPT_FILENAME} =~ m/^(.*)(?:\/|\\)(?:.*)$/g;
}

chdir($directory);

print "\nour working directory is now: " . cwd();
