package Bricklayer::Environs::Store;

use Bricklayer::Class::Builder;
use base qw{Bricklayer::Class::Builder};

sub pass_env {
	#$_[0]->errors("adding $_[1] in  environment", "log");
	my $Env = $_[1];
	my %TempHash;
	%TempHash = (%$Env, %{$_[0]->{Env}});
	$_[0]->{Env} = \%TempHash;
}

sub add {
	$_[0]->{Env}{$_[1]} = $_[2];
}

sub set {
	$_[0]->{Env}{$_[1]} = $_[2];
}

sub delete {
	delete $_[0]->{Env}{$_[1]};
}

sub hashref {
	$_[0]->{Env} = {} unless $_[0]->{Env};
	return $_[0]->{Env}
}

sub AUTOLOAD : lvalue {
	return $_[0]->{Env}{$_[0]->req_key($AUTOLOAD)};	
}

return 1;