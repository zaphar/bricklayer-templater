package Bricklayer::Templater::Handler::common::row;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
	my $Token = $_[0]->{Token};
	my $App =  $_[0]->{App};
	my $block = $Token->{block};
	my $loop = $_[1];
	my $contents;
	# start our loop sequence
	if (ref($loop) eq "ARRAY") {
		foreach my $item (@{$loop}) {
			$contents .= $App->run_sequencer($block, undef, $item);
		}	
	}
	return;
}

return 1;
