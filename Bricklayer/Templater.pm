package Bricklayer::Templater;

use base qw{Bricklayer::Class::Builder Bricklayer::Config};
use Bricklayer::Templater::Sequencer;
use Carp;

sub new {
    my $obj = shift->SUPER::new(@_)
        or return;
    $obj->ext('txml');
    $obj->start_bracket('<');
    $obj->end_bracket('>');
    $obj->identifier('BK');
    return $obj;
}

sub load_template_file {
	my $extension = $_[0]->config()->{template_ext} || 'txml';
	my $TemplateFile = $_[0]->{WD}."/templates/".$_[1];
	$TemplateFile .= ".$extension";
	$TemplateFile =~ s/::/\//g; # use double colon to indicate template directory seperators
	#confess("the template file is: $TemplateFile", "log");
	my $TemplateObj;
	my $Template;
	open( TEMPLATE, $TemplateFile )
	  or croak("Cannot open Template File: $TemplateFile ");
	
	while ( read( TEMPLATE, my $line, 1000 ) ) {
		$Template .= $line;
	}
	chomp $Template;
	close TEMPLATE;
	return $Template;
}

sub run_templater {
	my $extension = $_[0]->config()->{template_ext} || 'txml';
	my $TemplateFile = $_[0]->{WD}."/templates/".$_[1];
	$TemplateFile .= ".$extension";
	$TemplateFile =~ s/::/\//g; # use double colon to indicate template directory seperators
	#confess("the template file is: $TemplateFile");
	my $tagID 		 =  $_[2];
	#confess("the tag identifier is: $tagID");
	my $Params       = $_[3];
	my $TemplateObj;
	my $Template;
	open( TEMPLATE, $TemplateFile )
	  or croak("Cannot open Template File: $TemplateFile ");
	
	while ( read( TEMPLATE, my $line, 1000 ) ) {
		$Template .= $line;
	}
	close TEMPLATE;
	my $ParsedPage = $_[0]->run_sequencer($Template, $tagID, $Params, $_[0]->{WD});	
	#return $ParsedPage;
	return 1;
}

sub run_sequencer {
	my $Template = $_[1];
	my $tagID = $_[2];
	my $Params = $_[3];
	my $handler_loc = $_[4] || $_[0]->{WD};
	my $TemplateObj = Bricklayer::Templater::Sequencer->new_sequencer($Template, $tagID);
	my $ParsedPage = $TemplateObj->return_parsed($_[0], $Params, $handler_loc);
	#return $ParsedPage;
}

sub publish {
	$self = shift;
    warn "called with ".scalar @_." args [", join('|', @_)."]";
	$self->{_page} .= join('', @_);
} 

sub clear {
    $self = shift;
    $self->{_page} = undef;
}

sub start_bracket {
   my $self = shift;
   my $var = shift;
   $self->{start_bracket} = $var if $var;
   return $self->{start_bracket};
}

sub end_bracket {
   my $self = shift;
   my $var = shift;
   $self->{end_bracket} = $var if $var;
   return $self->{end_bracket};
}

sub ext {
   my $self = shift;
   my $var = shift;
   $self->{ext} = $var if $var;
   return $self->{ext};
}

sub identifier {
   my $self = shift;
   my $var = shift;
   $self->{identifier} = $var if $var;
   return $self->{identifier};
}

sub _template {
   my $self = shift;
   my $var = shift;
   $self->{template} = $var if $var;
   return $self->{template};
}

sub _page {
   my $self = shift;
   my $var = shift;
   $self->{_page} = $var if $var;
   return $self->{_page};
}

return 1;
