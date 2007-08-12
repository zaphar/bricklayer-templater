package util::bench;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
	return $_[0]->app()->get_time();
}

return 1;