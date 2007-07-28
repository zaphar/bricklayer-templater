#------------------------------------------------------------------------------- 
# 
# File: parser.pm
# Version: 0.9.1
# Author: Jason Wall and Jeremy Wall
# Definition: The parser package has a simple and single job to do, and that
#             is to take a block of text and turn it into an ordered array of
#             tokens containing either a text block or a tag/tag block.
#             Each token will contain both the block and a flag noting what
#             kind of token it is (text or tag).  The package then returns the
#             array.
#
#             Revised by Jeremy Wall to fix errors when parsing undefined Tag
#             Start definitions.
#-------------------------------------------------------------------------------
package Bricklayer::Templater::Parser;

require Exporter;
use strict;

our @ISA = qw(Exporter);
our @EXPORT = qw(parse_text parse_attributes);

# Global Variables
my $DefaultTagID = 'BK';


# Package Methods
sub parse_text {
	# Function wide variables
	my $textblock = shift; 	#this variable contains the block of text to be parsed.
	my $tagID = shift || $DefaultTagID;		# this variable contains the ID of the tag it is optional
	my $TagStartText = "<$tagID"; # Start tag prefix (it gets passed in)
	my $TagEndText = "</$tagID"; # End tag prefix (it also gets passed in)
	my @tokens = ();				#this variable will contain the tokenized text.
	 
	# loop through the string tokenizing as you go.  Since you are actually removing
	#  the pieces of text as you go, when you are finished, the string should be empty.
	while (defined $textblock and $textblock ne "") {
		# it becomes necessary to define these here, as each iteration through
		#   the loop will redefine them.
		
		my %token;
		my $tagname;
		my $block;
		my %attributes;

		my $endpos; # this variable is used variously throughout the process.		

		# check to see if the first part of the string is not a tag, ie doesn't start with the Start Tag Prefix..
		if (substr($textblock, 0, length($TagStartText)) ne $TagStartText) {
		
			# find the begining of the tag.
			$endpos = index($textblock, $TagStartText);
			# populate the text block
			if ($endpos == -1) {
				# if there are no more template tags, put the remaining text into the block 
				$block = substr($textblock, 0);
				#remove the text block from $textblock.
				$textblock = "";
			} else {
				# if there are tags remaining, put the text that is in front of tag into the block
				$block = substr($textblock, 0, $endpos);
				#remove the text block from $textblock.
				$textblock = substr($textblock, $endpos);
			}			

			# create and populate the token
			%token = (
				type => "text", 
				tagname => "text_block", 
				block => $block,
			        tagid => $tagID
			);

			#put the token at the bottom of the stack.
			push @tokens, \%token; 
		} 
		# check to see if the first part of the string is a tag
		elsif (substr($textblock, 0, length($TagStartText)) eq $TagStartText) {
			my $tag;
			
			# get the tag from the string.
			$tag = substr($textblock,0,index($textblock, '>') +1);
			
			# This is where we determine if the tag is a block or a single tag.
			#  We do this by looking for the forward slash, if it doesn't find one
			#  then it means the tag is a block.
			if (index($tag, '/>') == -1) { 
				
				# Get the tag name.
				$tagname = substr($tag, length($TagStartText), index($tag, '>')-length($TagStartText));
				if (index($tagname, ' ') != -1) {
					$tagname = substr($tagname, 0, index($tagname, ' '));
				}
							
				# Get the tag block.
				# But first remove the opening tag from $textblock.
				$textblock = substr($textblock, index($textblock, '>')+1);
				
			
				# before going on, you must check for nested tags identical to the current tag.
				my $open_tag = $TagStartText.$tagname;
				my $close_tag = $TagEndText.$tagname;
				my $open_len = length($open_tag);
				my $close_len = length($close_tag);
				my $ignore = 0;
				my $found_end = 0;
				my $idx_open_tag = index($textblock,$open_tag);
				my $idx_close_tag = index($textblock,$close_tag);
				
				while (not $found_end) {
  					
				if ($idx_open_tag == -1 or $idx_open_tag > $idx_close_tag) {
						# This is a possible end tag, check to see if it is what 
						# we are looking for
						if ($ignore > 0 ) {
							# this is not the end tag you are looking for...
							$ignore--;
							$idx_close_tag = index($textblock, $close_tag, $idx_close_tag+$close_len)
						
						} else {
	  						# This is the end tag you are looking for.
							$found_end = 1;
						}
  					} else {
						# this is a nested open tag, it needs to be checked 
						# to see if it is self closing.
  						my $nested_tag = 
							substr($textblock,$idx_open_tag,
								index($textblock, '>', $idx_open_tag)-$idx_open_tag+1);
  						if (index($nested_tag, '/>') == -1) { 
							# this is a nested block tag
							$ignore += 1;
  						}
						# find the next open tag.
						$idx_open_tag = index($textblock, $open_tag, $idx_open_tag+$open_len)
  					}
				}				
				
				$block = substr($textblock, 0, $idx_close_tag);				

				# and remove the block of text from $textblock.
				$textblock = substr($textblock, $idx_close_tag);
				# remove the closing tag from $textblock.
				$textblock = substr($textblock, index($textblock, '>')+1);
				
				# get the attributes.
				$tag = substr($tag,length($TagStartText));
				$tag = substr($tag, 0, index($tag, '>'));

				%attributes = parse_attributes($tag);
		
				# populate the token			
				%token = (
					type => "container",
					tagname => $tagname,
					block => $block,
					attributes => \%attributes,
					tagid => $tagID
				);
				
				
			} else {
				# this parses a single tag out.

				# Get the tag name.
				$tagname = substr($tag, length($TagStartText), index($tag, '>')-(length($TagStartText)+1));
				if (index($tagname, ' ') != -1) {
					$tagname = substr($tagname, 0, index($tagname, ' '));
				}
				
				# remove the tag from $textblock.
				$textblock = substr($textblock, index($textblock, '>')+1);
			
				# get the attributes.
				$tag = substr($tag,length($TagStartText));
				$tag = substr($tag, 0, index($tag, '/>'));
				%attributes = parse_attributes($tag);
		
				# populate the token
				%token = (
					type => "single", 
					tagname => $tagname,
					block => undef,
					attributes => \%attributes,
					tagid => $tagID
				);
			}
			
			# put the token on the bottom of the stack.
			push @tokens, \%token;
		}
	} 
			
		
	return @tokens;
}


# this function knows how to parse the attributes out of a textblock 
#   and returns them in a hash.
sub parse_attributes {
		
	#variable declarations
	my $atag = shift;
	my %attributes;
	my $key;
	my $value;

	#remove the tagname and closing carat.
	return undef unless $atag =~ / /;
	$atag = substr($atag, index($atag, ' ')+1);

#	while (mytrim($atag) ne "") {
#		$atag  = mytrim($atag);
#		$key   = mytrim(substr($atag, 0, index($atag, '=')));
#		$atag  = mytrim(substr($atag, index($atag, '=')+1));
#		my $quote = substr($atag,0,1);
#		$atag = substr($atag,1);
#		$value = substr($atag, 0, index($atag, $quote));
#		$atag  = substr($atag, index($atag, $quote) + 1 );		
#	
#		$attributes{$key} = $value;
#	}
	my @attribs = split(/\s+/, $atag);
	foreach my $attrib (@attribs) {
		my ($key, $value) = $attrib =~ /(.+)="(.*)"/;
		$key = $attrib unless $key;
		$attributes{lc($key)} = $value || 1; 
#		die "$attrib: $key = $value";
	}
	#return the hash.
	return %attributes;
}


sub mytrim {
 	my $var = shift;
	$var =~ s/^\s+|\s+$//g;
	return $var;
}

return 1;


=head1 NAME

Template::Parser - A generic parsing module.

=head1 SYNOPSIS

use Template::Parser;

my $template_text;
my $start_tag_prefix;
my $end_tag_prefix;

my @tokens = Parser::parse_text($template_text,$start_tag_prefix,$end_tag_prefix);

=head1 REQUIRES

Perl 5.8
Exporter

=head1 DESCRIPTION

The parser package has a simple and single job to do, and that is to take a block 
of text and turn it into an ordered array of tokens containing either a text block 
or a single tag or tag block. Each token will contain both the block and a flag 
noting what kind of token it is (text, tag_block or tag).  The package then returns 
the array.


=head1 METHODS

=item parse_text()

The parse_text() function takes the template text, a start tag prefix, and an end
tag prefix, parses the appropriate tags and returns a token tree in the form of an
array of hashes, each hash with a variable number of elements, depending on its type.

For Example:
 
%text_token = (
				type => "text", 
				block => $block,	
			);

%block_tag_token = (
				type => "block_tag", 
				tagname => $tagname,
				block => $block,
				attributes => \%attributes,
			);	

%tag_token = (
				type => "tag", 
				tagname => $tagname,
				attributes => \%attributes,
			);

The attributes value is a reference to an attributes hash in the form of:

%attributes = (
				"attribute_name" => "attribute_value",
			);

Further Notes: The token tree returned by parse_text is not iterative, thus the 
  tags inside a tag_block will not be processed, and you will need to call the 
	parse_text() function again when dealing with those tags.
	
	To build a complete tree, call the parse_text() function iteratively like so:
	
	sub parse {
		my $template_text = shift;
		my $start_tag_prefix = shift;
		my $end_tag_prefix = shift;
		my @token_tree;
	
    my @tokens = Parser::parse_text($template_text,$start_tag_prefix,$end_tag_prefix);
	
    foreach my $token (@tokens) {
        if ($token->{type} eq 'block_tag') {
            my @sub_tokens;
            @sub_tokens = parse($token->{block},$start_tag_prefix,$end_tag_prefix);
            $token->{block} = \@sub_tokens;
        }
        push @token_tree, $token;
    }
    return @token_tree;
	}

=head1 AUTHOR

(c) 2004 Jason Wall, <jason@walljm.com>, www.walljm.com

=cut



