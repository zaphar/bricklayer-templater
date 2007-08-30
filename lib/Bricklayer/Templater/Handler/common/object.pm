#--------------------------------------------------------------------------
# 
# File: object.pm
# Version: 0.1
# Author: Jeremy Wall
# Definition: allows us to dereference objects in the template
#
# Note: This tags functionality has been shamelessly ripped off / inspired-
# from Template Toolkit. Many thanks Andy Wardly for the ideas.
#--------------------------------------------------------------------------
package Bricklayer::Templater::Handler::common::object;
use Carp;
use base qw(Bricklayer::Templater::Handler);


sub run {
	my ($self, $object) = @_;
	my $retrieve = $self->attributes()->{call};

    my $passthrough = $self->attributes()->{nest};
	my $negate = $self->attributes()->{"not"};
	if (ref($object) ne "") {
		my $return;
		$retrieve =~ s/\./->/g;
		my $call = '$return = $object->'.$retrieve;
		eval $call;

		my $arg;
		if ($self->block) {

			$arg = $return if $passthrough;
			$arg = $object unless $passthrough;

			if ($return || $negate) {
				return if $negate && $return;
			} else {
				return;
			}
			if ($self->attributes->{embed}) {
				return &$arg();
			} else {
				$self->parse_block($arg);
			}
			return;
		}
		if ($self->attributes->{embed}) {
			return &$return();
		} else {
			return $return if !$negate;
		}
		return;
	} 
	return;
}

return 1;
