package Bricklayer::Publisher;

use Bricklayer::Object::File;

# Helper Functions

sub publish {
	my $ParsedPage = $_[1];
	my $publishType = $_[2];
	# @_[3 .. $#_] extra publishing arguments?
	$publishType = "web" unless $publishType;
	my $contentType = undef;
	$contentType = $_[0]->env()->contenttype
		if $_[0]->env()->contenttype;
	
	#$_[0]->errors("running publish routine: content type is: ".$_[0]->{P}->{ContentType}, "log");
	
	my @Plugins = values(%{$_[0]->{PluginList}{Content}}); # force our content plugins into array form.
	if ($Plugins[0]) {
		#$_[0]->errors("found content plugins to run", "log");
		foreach my $ContentPlugin (@Plugins) {
			$ParsedPage = $ContentPlugin->run($ParsedPage);
			#$_[0]->errors("running content plugin: $ContentPlugin->get_name()", "log");
		}
	}
	
	my $publisher = $_[0]->Publisher;	
	$publisher->run($ParsedPage);
	
	return 1;
}

sub LoadPublisher {
	return $_[0]->{Publisher} if $_[0]->{Publisher};
	#$_[0]->errors("Recieved request to load publisher: ".$_[1]." Passing it a: ".ref($_[2]), "log");
	#default is to get the publisher from the config unless I specify it here
#	$_[0]->{Publisher} = $_[0]->plugins->load($_[0]->config->Publisher || "web", "publish")
#		unless $_[1];
	$_[0]->{Publisher} = $_[0]->plugins->load($_[1], "publish", @_[2..$#_])
		if $_[1];
	return $_[0]->{Publisher};
}

sub Publisher {
	return $_[0]->LoadPublisher();
}
return 1;