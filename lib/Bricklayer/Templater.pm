package Bricklayer::Templater;

use Bricklayer::Templater::Sequencer;
use Carp;
=head1 NAME 

Bricklayer::Templater - yet another templating system. Pure perl, highly flexible
with very few dependincies.

=head1 SYNOPSIS

    use Bricklayer::Templater::Sequencer;
    use Cwd;
    
    my $cwd = cwd();
    
    # create a new templater with a context object and a working directory
    my $t = Bricklayer::Templater::Sequencer->new($context, $cwd);
    
    # run the templater on a named template
    $t->run_templater('name_of_template');
    
    # retrieve the page after running templater on it.
    my $page = $t->_page();
    
=head1 DESCRIPTION

Bricklayer::Templater began as a way to make a simple easy to use flexible 
templating engine. It has evolved over time but still retains that flexibility,
simplicity, and ease of use.

It is based on template tags and is completely configurable as far as how those
tags are identified. The default is <BKtagname attrib="something" ></BKtagname>
you can specify different start and end brackets and identifiers (the BK in the above tags)

=head2 Configuring Templater options

Changing start_bracket for the template objects tags
$t->start_bracket('['); #default is <

Change the end_bracket for the template objects tags
$t->end_bracket(']'); #default is >

Change the identifier for the templater objects tags
$t->identifier('?'); #default is BK

Change the template extension
$t->ext('tmpl'); #default is txml

There are two primary purposes for this configurability. One is to for aesthetic
reasons, the other is for multipass templating. Multipass templating is possible
by running the template once for one configuration of tags then again on the results
with a different configuration of tags.

=head2 Running a Template

There are two ways you can run a template. The first and easiest is to call
$t->run_templater('template_name');  This will look in your working directory
for a template by that name and with the configured extension and then run it.

The template will be stored in $t->_page() or be published with the publish hook 
provided by you if you sub classed the engine.

=head2 The publish method.

There is one method you probably want to override if you subclass this engine.
publish() This method will be called by handlers with their results. If you
don't override it then the default is to append those results to the _page attribute
of the template object.

=head2 The rest of the API

=cut

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

=head3 my $file = $t->load_template_file('template_name')

load_template_file loads a template file from the working directory
there are two ways to specify the template name.

=head4 path/name syntax

$t->load_template_file('relative/path/template_name')

=head4 name::space syntax (perl like)

$t->load_template_file('name::space::template_name')

=cut

sub load_template_file {
    my $self = shift;
    my $filename = shift;
	my $extension = $self->ext() || 'txml';
	my $TemplateFile = $self->{WD}."/templates/".$filename;
	$TemplateFile .= ".$extension";
	$TemplateFile =~ s/::/\//g; # use double colon to indicate template directory seperators
    warn "the template file is: $TemplateFile";
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
    $self->run_sequencer($self->_template, $Params);	
	return 1;
}

=head3 $t->run_sequencer($file)

run_sequencer runs the sequencer on the text in $file. The results 
of the template run will be stored wherever publish() puts it.

=cut

sub run_sequencer {
    my $self = shift;
	my $Template = shift;
	my $tagID = $self->identifier();
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

=head3 $t->clear()

Clears the contents of _page() it's a convenience method. If you override
the publish method you might want to override this one too if you need it.

=cut

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

=head1 Authors

    Jeremy A. Wall <Jeremy@MarzhillStudios.com>

=head1 BUGS

    Like any Module of sufficient complexity there are probably some things I missed.
    See http://rt.cpan.org to report and view bugs

=head1 COPYRIGHT
    (C) Copywright 2007 Jeremy Wall <Jeremy@Marzhillstudios.com>

    This program is free software you can redistribute it and/or modify it under the same terms as Perl itself.

    See http://www.Perl.com/perl/misc/Artistic.html

=cut
