package Bricklayer::Class::Dynamic::Core;


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
#
#sub check_auth {
#	return undef unless $_[0]->get_type() eq "action";
#	$_[0]->{App}->errors("plugin type in check_auth is: ".$_[0]->get_type(), "log");
#	$_[0]->{Session} = $_[0]->{App}->check_session();
#	$_[0]->{access} = $_[0]->{App}->access();
#}

sub package_name {
	return ref($_[0]);
}

return 1;