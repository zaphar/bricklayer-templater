package Bricklayer::Config;
use Bricklayer::Config::Store;

sub config {
	return $_[0]->{Config} if ref($_[0]->{Config}) eq "Bricklayer::Config::Store";
	$_[0]->{Config} = Bricklayer::Config::Store->new($_[0], $_[0]->{WD});
	return $_[0]->{Config};
}

sub load_conf {
	$_[0]->config()->load();	
}

return 1;