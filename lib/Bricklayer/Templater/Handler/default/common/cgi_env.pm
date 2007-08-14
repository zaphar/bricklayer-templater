#------------------------------------------------------------------------------- 
# 
# File: tester.pm
# Version: 0.1
# Author: Jeremy Wall
# Definition: This is the handler for plain text blocks in a template.
#             It basically just returns the text unchanged. I made it a
#             handler just in case we needed to do something to plain text
#             later on. 
#
#--------------------------------------------------------------------------
package common::cgi_env;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
	my $content;
	
	for (keys(%{$_[0]->{App}->env()->hashref()})) {
		$content .= $_." = ".$_[0]->{App}->env()->hashref()->{$_}."<br />";
	}
	for (keys(%{$_[0]->{App}->env()->hashref()->{Cookies}})) {
		my $Cookie = $_[0]->{App}->env()->hashref()->{Cookies}->{$_};
		$content .= $_." Cookie contains:<br /> ->|";
		for (keys(%$Cookie)) {
			$content .= $_." = ".$Cookie->{$_};
		}
		$content .= "|<-<br />";
	}
	return $content;
}

return 1;