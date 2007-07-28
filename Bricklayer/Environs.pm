package Bricklayer::Environs;

use Bricklayer::Environs::Store;

sub env {
	$_[0]->{Env} = Bricklayer::Environs::Store->new() unless ref($_[0]->{Env}) eq "Bricklayer::Environs::Store";
	return $_[0]->{Env};
}

sub Gather {
	#default is to get the publisher from the config unless I specify it here
	$_[0]->{Environizer} = $_[0]->plugins->load($_[0]->config->Environizer || "web", "publish")
		unless $_[1];
	$_[0]->{Environizer} = $_[0]->plugins->load($_[1], "environs", @_[2..$#_])
		if $_[1];
	$_[0]->{Environizer}->run($_[2]);
}

return 1