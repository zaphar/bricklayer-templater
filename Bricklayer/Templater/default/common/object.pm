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
package common::object;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);


sub run {
	my ($self, $object) = @_;
	my $retrieve = $self->attributes()->{call};
	my $passthrough = $self->attributes()->{nest};
	my $negate = $self->attributes()->{"not"};
	#my $foreach = $self->attributes()->{"for"} || $self->attributes()->{"foreach"};
	$self->errors("negating result", "info")
		if $negate;
	$self->errors("recieved a ".ref($object));
	if (ref($object) ne "") {
		my $return;
		$retrieve =~ s/\./->/g;
		my $call = '$return = $object->'.$retrieve;
		$self->errors("call was $call", "info");
		eval $call;
		$self->errors("result of call was: $return: ".ref($return), "info");
		my $arg;
		if ($self->block) {
			$self->errors("there was a block", "info");
			$arg = $return if $passthrough;
			$arg = $object unless $passthrough;

			if ($return || $negate) {
				return if $negate && $return;
				$self->errors('nest was defined', 'info')
					if $passthrough;
				$self->errors("passing: ".ref($return), 'info')
					if $passthrough;
				
				$self->errors('nest was not defined', 'info')
					unless $passthrough;
				$self->errors("passing: ".ref($object), 'info')
					unless $passthrough;
				
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
	} else {
		$self->errors('Not an Object in template', 'info');
	}
	return;
}


return 1;
