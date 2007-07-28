package Bricklayer::Access;

sub get_access_plugin {
	if ($_[0]->{PluginList}{Access}) {
		return $_[0]->{PluginList}{Access};
	}
	return undef;
}


sub check_session {
	$_[0]->{access} = $_[0]->plugins()->load($_[0]->config()->access, "access");
	#return $_[0]->{access}->session();
	$_[0]->{access}->run();
	$_[0]->{Session} = $_[0]->access()->session();
	$_[0]->{SessionID} = $_[0]->access()->SessionID;
	return $_[0]->{Session};
}

sub access {
	return $_[0]->{access} if $_[0]->{access};
	$_[0]->{access} = $_[0]->plugins()->load($_[0]->config()->access, "access");
	return $_[0]->{access};
}

return 1;