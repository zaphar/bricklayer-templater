package util::bench_total;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
	return $_[0]->app()->get_total;
}

return 1;