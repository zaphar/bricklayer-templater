package Bricklayer::Class::Util;
use Bricklayer::Object::File;

sub attribute {
	my $self = $_[0];
	my $type = $_[1];
	my $attribute = $_[2];
	my $value = $_[3];
	my $subtype = $_[4];
	if ($value) {
		#check the main type for validity
		unless ($_[0]->_TYPE_TEST($value, $type)) {
			$_[0]->err("Not a $type value for $attribute");
			return undef
		}
		#handle Container types with subtypes	
		if ($_[0]->_CONTAINER($type) && $subtype) {
			# Collect our values
			if ($type eq "HASH") {
				my @values = values(%$value);
			} elsif ($type eq "ARRAY") {
				my @values = @$value;
			}
			#test our values against subtype;
			if ($values) {
				foreach (@values) {
					$_[0]->err("Invalid element in $type. element must be of type: $subtype")
						unless $_[0]->_TYPE_TEST($_, $subtype);
					return undef unless $_[0]->_TYPE_TEST($_, $subtype);
				}			
			}
		}			
	} else { #handle the case where we just want the attribute
		return $_[0]->{$attribute};
#		$_[0]->err("No value passed for $attribute in ".ref($_[0]));
	}
	#OK now to store the attribute and return it.
	$_[0]->{$attribute} = $value;
	return $_[0]->{$attribute};
}

sub _INT {
	my $value = $_[1];
	if ($value =~ /^[0-9]+$/) {
		$_[0]->{$attribute} = $_[3];
		return 1;
	}
	return undef;
}

sub _FLOAT {
	my $value = $_[1];
	if ($value =~ /^[0-9]+\.?[0-9]*$/) {
		$_[0]->{$attribute} = $_[3];
		return 1;
	}
	return undef
}

sub _CONTAINER {
	my $type = $_[1];
	if ($type =~ /^(HASH|ARRAY)$/) {
		return $1;
	}
	return undef
}

sub _SCALAR {
	
}

sub _TYPE_TEST {
	my $value = $_[1];
	my $type = $_[2];
	if ($type eq "INT") {
		unless ($_[0]->_INT($value)) {
			return undef;
		}
	} elsif ($type eq "FLOAT") {
		unless ($_[0]->_FLOAT($value)) {
			return undef;
		}
	} elsif ($type eq "SCALAR") {
		return 1;
	} elsif (ref($value) eq $type) {
		return 1
	} else {
		return undef;
	}
	return 1;
}

return 1;
