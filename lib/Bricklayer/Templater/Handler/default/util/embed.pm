#------------------------------------------------------------------------------- 
# 
# File: embed.pm
# Version: 0.1
# Author: Jeremy Wall
# Definition: allows us to embed code in the containing template
#
#--------------------------------------------------------------------------
package Bricklayer::Templater::Handler::default::util::embed;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);


sub run {
	my ($self, $embed) = @_;
	
	if (ref($embed) eq 'CODE') {
		return &$embed();
	} else {
		return $embed;
	}
	return;
}

return 1;