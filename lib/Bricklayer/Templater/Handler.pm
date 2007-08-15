# Bricklayer Plugin SuperClass
package Bricklayer::Templater::Handler;

#use base qw{Bricklayer::Class::Dynamic::Core};
use Carp;

# Initialization
sub load {
	my $PluginObj = {Token => $_[1],
					 App => $_[2],
					 err => undef
					 };
	
    croak "ahhh didn't get passed the Token object" unless $_[1];
    croak "ahhh didn't get passed the context object" unless $_[2];
    $PluginObj = bless($PluginObj, $_[0]);

	$PluginObj->load_extra()
        if $PluginObj->can('load_extra'); # optional method for handlers
	
	return $PluginObj;
}

sub attributes {
	return $_[0]->{Token}{attributes};
}

sub block {
	return $_[0]->{Token}{block};
}

sub type {
	return $_[0]->{Token}{type};
}

sub tagname {
	return $_[0]->{Token}{tagname};
}

sub data {
	return $_[0]->{data} if $_[0]->{data};
}

sub tagid {
	return $_[0]->app()->identifier();
}

sub app {
    return $_[0]->{App};
}

sub parse_block {
	$_[0]->app->run_sequencer($_[0]->block(), $_[2]);
	return ;
}

sub run_handler {
	my $result = $_[0]->run($_[1]);
	#$_[0]->errors( "Running: ".$_[0]->tagname()." tag handler", "log");
	#$_[0]->errors( "Sending: |$result| to publish from block: >|".$_[0]->block()."|<", "log");	
	#$_[0]->errors( $_[0]->tagname()." had the marker: ".$_[0]->block(), "log") if ($result =~ /^ .* $/);
	$_[0]->app()->publish($result);
}

return 1;
