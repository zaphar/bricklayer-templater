#------------------------------------------------------------------------------- 
# 
# File: sequencer.pm
# Version: 0.2
# Author: Jeremy Wall
# Definition: This is the templating engine for template files. It uses the
#             parser engine to parse a file or string into tokens and then
#             uses object methods to look at the tokens or return a parsed file
#             file using the handlers in the handle library and based on the
#             current environment the object is running in.
#
#-------------------------------------------------------------------------------
package Bricklayer::Templater::Sequencer;
require Exporter;
use strict;
use Carp;

use Bricklayer::Templater::Parser;

=head1 NAME

Bricklayer::Templater::Sequencer - Internal Module used by L<Bricklayer::Templater>;

=head1 Description

=head1 SEE ALSO

L<Bricklayer::Templater>

=cut

my %handlerCache;

our @ISA = qw(Exporter);
our @EXPORT = qw(new_sequencer return_parsed);

sub new_sequencer {
    my $Proto = shift;
    my $TemplateText = shift or confess("No template specified");
    my $tagID = shift;
    my $Class = ref($Proto) || $Proto;
    my @TokenList = parse($TemplateText, $tagID);
    #die "this many tokens found ".scalar(@TokenList);
    return bless(\@TokenList, $Class); 
    
}

sub parse {
    my $TemplateText = shift;
    my $tagID = shift;
    #die $tagID;
    my @Tokens =  Bricklayer::Templater::Parser::parse_text($TemplateText, $tagID);
    return @Tokens;
}

# returns a string with the replacement text for the parsed token
sub return_parsed($$$$) {
    my $Self = shift;
    my $Env = shift;
    my $Parameters = shift;
    my $handler_loc = shift;
    
    parse_tokens($Self, $Env, $Parameters, $handler_loc);
    return; 
}

sub parse_tokens($$$$) {
    my $TokenList = shift;
    my $App = shift;
    my $Parameters = shift;
    my $handler_loc = shift;
    my $ParsedText;
    my $tokenCount = scalar(@$TokenList);
    my $loopCount = 0;
    foreach my $Token (@$TokenList) {
        # we are dynamically loading our handlers here
        # using symbolic references and a little perl magic
        # Seperate handlers with :: to denote directories
        # in the handler directory.
        my $handler;
        my $tagname = 'Bricklayer::Templater::Handler::'.$Token->{tagname};
        my $Seperator = "/";
        my $SymbolicRef = $tagname;
#        $tagname =~ s/::/$Seperator/g;
        if (exists($handlerCache{$Token->{tagname}})) {
        	$handler = $handlerCache{$Token->{tagname}}->load($Token, $App);
            $handler->run_handler($Parameters);
            
        } else {
            eval "use $tagname";
        	if (!$@) {	            
	            $handler = $SymbolicRef->load($Token, $App);
	        } else {
	            carp("grrr no such handler: $Token->{tagname} at $tagname.pm");
	            next;
	        }
	        $handlerCache{$Token->{tagname}} = $SymbolicRef;
	        $handler->run_handler($Parameters);      	
        }
    }
    return;
}

return 1;
