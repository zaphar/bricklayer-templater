package Bricklayer::Mapper;

sub MapPluginURI { #$_[1] URI | returns the result of the mapped Plugins run method
	$_[0]->{URI_STRING} = $_[1];
	my $base = $_[0]->config()->BaseURI;
	#if the config specifies a base URI then we need to strip that from the front of the URI
	if ($base) { $_[1] =~ s/$base// if ($_[1] =~ /^$base/); }
	
	$_[1] = "/".$_[1] if $_[1] !~ /(^\/)/;
	#first split the URI along the /'s
	my @URI = split('\/', lc($_[1]));
	$_[0]->errors("Mapping Plugin for URI: $_[1]", "log");
	# The first URI entry is guaranteed to be empty so we shift it off
	shift @URI;
	$_[0]->{URI} = \@URI;
	my $name = $_[0]->shift_URI();
	# if the config file defines a base uri then we account for that
	#Default uri name in case the uri is missing
	$name = "default" unless $name;
	$_[0]->errors("Searching for Plugin name: $name", "log");
	my $plugin = $_[0]->plugins->load($name, 'action', @URI[1..$#URI]);
	$_[0]->Publisher->run($plugin->run()) if $plugin;
#	$action = 'action' unless $_[0]->AllowedMappings($action);#default plugin mapping
	# some kind of error happened here so we need to handle it
	unless ($plugin) { #default error template should be run here
		$_[0]->Publisher->content_type("txt");
		$_[0]->Publisher->run("No Handler for this URI: $_[1]\n@{[scalar @URI]}\n $_[0]->{Log}");
#		$_[0]->errors("No handler for this URI", "fatal");	
	}
	
}

sub MapTemplateURI { #$_[1] URI | runs a template file
	$_[0]->run_templater($_[1], $_[0]->config()->TagID);
}

sub AllowedMappings {
	unless ($_[0]->{Maps}) {
		$_[0]->{Maps} = ['action']; 	
	}
	if ($_[1]) {
		foreach (@{$_[0]->{Maps}}) {
			return 1 if $_[1] eq $_;
		}
		return undef;	 
	}
	return $_[0]->{Maps}
}

sub shift_URI  {
	return shift @{$_[0]->{URI}}; 
}

sub pop_URI {
	return pop @{$_[0]->{URI}}; 
}

return 1;