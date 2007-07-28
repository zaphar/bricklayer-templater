package Bricklayer::Data::Model::Table;

sub new {
	return bless([] || $_[1], ref($_[0]) || $_[0]);
}

sub bindto { #expects an array of field names as an argument
	push @{$_[0]}, (@_[1 .. $#_]);
	return $_[0];
}

return 1;