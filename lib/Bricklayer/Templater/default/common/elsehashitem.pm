package common::elsehashitem;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
	my $select = $_[0]->{Token}{attributes}{key};
	my $contents = $_[0]->{App}->run_sequencer($_[0]->{Token}{block}, undef, $_[1]) unless $_[1]->{$select};
	return;
}

return 1;
