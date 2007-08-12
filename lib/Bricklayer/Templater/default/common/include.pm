#------------------------------------------------------------------------------- 
# 
# File: include.pm
# Version: 0.1
# Author: Jeremy Wall
# Definition: This is the handler for plain text blocks in a template.
#             It basically just returns the text unchanged. I made it a
#             handler just in case we needed to do something to plain text
#             later on. 
#
#--------------------------------------------------------------------------
package common::include;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
    my $Token = $_[0]->{Token};
    my $App = $_[0]->{App};
    my $tagID;
    my $file = $Token->{attributes}{file}
    	if exists($Token->{attributes}{file});
    
    $tagID = $Token->{attributes}{tagid}
    	if exists($Token->{attributes}{tagid});
    
    $contents = $App->load_template_file($file)
    	unless $_[0]->{FileCache}{$file};
    $_[0]->{FileCache}{$file} = $contents
    	unless $_[0]->{FileCache}{$file};
    $App->run_sequencer($_[0]->{FileCache}{$file}$_[1]);
    return;
}


return 1;
