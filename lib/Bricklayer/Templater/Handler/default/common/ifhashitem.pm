package Bricklayer::Templater::Handler::default::common::ifhashitem;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
	my $select = $_[0]->{Token}{attributes}{key};
	my $contents;
	$_[0]->{App}->run_sequencer($_[0]->{Token}{block}, undef, $_[1]) if $_[1]->{$select};
	if ($_[0]->{Token}{attributes}{"else"}) {
		$contents = $_[0]->{Token}{attributes}{"else"} unless ($_[1]->{$select});
	}
	return $contents;
}

return 1;
