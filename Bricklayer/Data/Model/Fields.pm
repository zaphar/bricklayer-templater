package Bricklayer::Data::Model::Fields;

sub new {
	return bless([] || $_[1], ref($_[0]) || $_[0]);
}

sub bindto { #expects an array of field names as an argument either hashes or names
	push @{$_[0]}, (@_[1 .. $#_]);
	return $_[0];
}

sub field_names {
	my @names = map { field_name($_) } @{$_[0]};
	return @names;
}

sub field_types {
	my @types = map { field_type($_) } @{$_[0]};
	return @types;
}

sub field_name {
	my @keylist = keys(%{$_[0]}) if ref($_[0]) eq 'HASH';
	return $keylist[0] if ref($_[0]) eq 'HASH';
	return $_[0];
}

sub field_type {
	my @valuelist = values(%{$_[0]}) if ref($_[0]) eq 'HASH';
	return $valuelist[0] if ref($_[0]) eq 'HASH';
	return undef;
}

return 1;