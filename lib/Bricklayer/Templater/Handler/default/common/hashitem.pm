package Bricklayer::Templater::Handler::default::common::hashitem;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
	my $select = $_[0]->{Token}{attributes}{key};
	return undef unless ref($_[1]) eq "HASH";
	my $test = "|".ref($_[1]->{$select});
	return $_[1]->{$select} if $test eq "|";
	$_[0]->{App}->run_sequencer($_[0]->{Token}{block}, undef, $_[1]->{$select}) if $_[1]->{$select};
	return;
}

return 1;
