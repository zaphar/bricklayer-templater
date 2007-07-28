# Bricklayer Plugin SuperClass
package Bricklayer::Templater::Handler;

use Bricklayer::Class::Dynamic::Core;
use base qw{Bricklayer::Class::Dynamic::Core};

# Initialization
sub load {
	my $PluginObj = {Token => $_[1],
					 App => $_[2],
					 err => undef
					 };
	$PluginObj = bless($PluginObj, ref($_[0]) || $_[0]);
	die "ahhh didn't get passed the bricklayer object" unless $_[2];
	#$_[2]->errors("loading handler: ".$PluginObj->package_name, "log");
	if (exists($_[1]->{attributes}{action})) {
		#$_[2]->errors("processing handler action: ".$_[1]->{attributes}{action}, "log");
		my $Action = $_[2]->plugins()->load($_[1]->{attributes}{action}, "action", undef)
			or $_[2]->errors("processed handler action: ".$_[1]->{attributes}{action}, "fatal");;
		$PluginObj->{data} = $Action->run();
		$PluginObj->{action} = $Action; # NEW store a reference to our action plugin for later use.
		#$_[2]->errors("processed handler action: ".$_[1]->{attributes}{action}, "log");
	}
	
	eval {
		$PluginObj->load_extra(); # optional method for handlers
	};
	#$_[2]->errors("finished loading handler: ".$PluginObj->package_name, "log");
	
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
	return $_[0]->{tagid};
}

sub parse_block {
	$_[0]->app->run_sequencer($_[0]->block(), $_[1] || $_[0]->tagid, $_[2]);
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
