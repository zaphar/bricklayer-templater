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
	
    $PluginObj = bless($PluginObj, ref($_[0]) || $_[0]);
    croak "ahhh didn't get passed the context object" unless $_[2];

	if (exists($_[1]->{attributes}{action})) {
		my $Action = $_[2]->plugins()->load($_[1]->{attributes}{action}, "action", undef)
			or $_[2]->errors("processed handler action: ".$_[1]->{attributes}{action}, "fatal");;
		$PluginObj->{data} = $Action->run(); # TODO is this really useful?? 
		$PluginObj->{action} = $Action; # NEW store a reference to our action plugin for later use.
	}
	
	eval {
		$PluginObj->load_extra(); # optional method for handlers
	};
	
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

sub app {
    return $_[0]->{App};
}

sub conn {
    $_[0]->{conn} = $_[0]->app()->db_conn() unless $_[0]->{conn};
    return $_[0]->{conn};
}

sub errors {
    $_[0]->{errmsg} = $_[1] . " Type: $_[2]" . "\n";
    $_[0]->{err} = 1
        if $_[2] eq "fatal" or $_[2] eq "bad";
    $_[0]->app()->errors($_[1], $_[2]);
    return $_[0]->{errmsg};
}

sub message {
    #$_[1] message $_[2] type;
    $_[0]->app()->env->add("action_message", $_[0]->{App}->env()->action_message()." \n ".$_[1])
        if $_[2] eq "message";
    $_[0]->app()->env->add("action_error", $_[0]->{App}->env()->action_error()." \n ".$_[1])
        if $_[2] eq "error";
    $_[0]->errors($_[1], "bad") if $_[2] eq "error";
    $_[0]->errors($_[1], "log") if $_[2] eq "message";
    return {action_message => $_[0]->{App}->env()->action_message(), action_error => $_[0]->{App}->env()->action_error()};
    
}

sub check_errors {
    return $_[0]->{errmsg}
        if $_[0]->{err};
    $_[0]->{err} = undef;
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
