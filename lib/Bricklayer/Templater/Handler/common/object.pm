#------------------------------------------------------------------------------- 
# 
# File: object.pm
# Version: 0.1
# Author: Jeremy Wall
# Definition: allows us to dereference objects in the template
#
# Note: This tags functionality has been shamelessly ripped off / inspired
# from Template Toolkit. Many thanks Andy Wardly for the ideas.
#--------------------------------------------------------------------------
package Bricklayer::Templater::Handler::common::object;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);


sub run {
	my ($self, $object) = @_;
	my $retrieve = $self->attributes()->{call};
	my $passthrough = $self->attributes()->{nest};
	my $negate = $self->attributes()->{"not"};
	#my $foreach = $self->attributes()->{"for"} || $self->attributes()->{"foreach"};
	if (ref($object) ne "") {
		my $return;
		$retrieve =~ s/\./->/g;
		my $call = '$return = $object->'.$retrieve;
		eval $call;
		my $arg;
		if ($self->block) {
			$self->errors("there was a block", "info");
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
				$self->parse_block(undef, $arg);
			}
			return;
		}
		if ($self->attributes->{embed}) {
			return &$return();
		} else {
			return $return unless $negate;
		}
		return;
	} 
	return;
}


return 1;
