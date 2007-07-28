package default;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
    my $Token = $_[0]->{Token};
	my $App =  $_[0]->{App};
	my $Data = $_[0]->{data};
	$_[0]->errors("bad template tag: $$Token{tagname}}", "log");
	return "bad template tag: $$Token{tagname}}";  
}


return 1;