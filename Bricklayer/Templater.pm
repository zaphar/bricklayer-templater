package Bricklayer::Templater;

use Bricklayer::Templater::Sequencer;
use Carp;

sub new {
    do {carp($_[0]." Requires a working directory"); return; } unless defined $_[2];
    do {carp($_[0]." Requires a context"); return; } unless defined $_[1];
    my $obj = bless({App => $_[1], WD => $_[2]}, $_[0]);
    
    $obj->ext('txml');
    $obj->start_bracket('<');
    $obj->end_bracket('>');
    $obj->identifier('BK');
    return $obj;
}

sub load_template_file {
    my $self = shift;
    my $filename = shift;
	my $extension = $self->ext() || 'txml';
	my $TemplateFile = $self->{WD}."/templates/".$filename;
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
	$self->_template($Template);
    return $Template;
}

sub run_templater {
	my $self = shift;
    my $filename = shift;
    $self->load_template_file($filename)
        or croak('Failed to loadi ['. $filename. '] template');
    my $ParsedPage = $self->run_sequencer($self->_template, $tagID, $Params, $self->{WD});	
	return 1;
}

sub run_sequencer {
    my $self = shift;
	my $Template = shift;
	my $tagID = shift;
	my $Params = shift;
	my $handler_loc = shift || $self->{WD};
	my $TemplateObj = Bricklayer::Templater::Sequencer->new_sequencer($Template, $tagID);
	my $ParsedPage = $TemplateObj->return_parsed($self, $Params, $handler_loc);
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

sub app {
	return $_[0]->{App};
}

sub WD {
	return $_[0]->{WD};	
}
return 1;
