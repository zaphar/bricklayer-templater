#------------------------------------------------------------------------------- 
# 
# File: bk_log.pm
# Version: 0.1
# Author: Jeremy Wall
# Definition: This is the handler for plain text blocks in a template.
#             It basically just returns the text unchanged. I made it a
#             handler just in case we needed to do something to plain text
#             later on. 
#
#--------------------------------------------------------------------------
package util::bk_log;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
    my $Token = $_[0]->{Token};
    my $App = $_[0]->{App};
    my $result = $_[0]->app()->{Log};
    my $contents = "<pre>" . $result . "</pre>"
    	if $result;
    
	return $contents;   
}


return 1;