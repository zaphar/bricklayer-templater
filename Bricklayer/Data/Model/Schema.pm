package Bricklayer::Data::Model::Schema;

sub new {
	return bless({Name => ""}, ref($_[0]) || $_[0]);
}

sub name {
	return $_[0]->{Name};
}

sub bindto($) {
	$_[0]->{Name} = $_[1];
	return $_[0];
}

return 1;