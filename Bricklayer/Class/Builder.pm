package Bricklayer::Class::Builder;
use base qw{Bricklayer::Class::Util};
use Carp;

sub new {
    do {carp($_[0]." Requires a working directory"); return; } unless defined $_[2];
    do {carp($_[0]." Requires a context"); return; } unless defined $_[1];
	return bless({App => $_[1], WD => $_[2]}, ref($_[0]) || $_[0]);
}

sub app {
	return $_[0]->{App};
}

sub WD {
	return $_[0]->{WD};	
}

sub req_key {
	my $methodname = $_[1];
	my $packagename = ref($_[0])."::";
	my ($confkey) = $methodname =~ /$packagename([^:]*)/;
	return $confkey;
}
return 1;
