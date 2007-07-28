package Bricklayer::Core;

use base qw{Bricklayer::Config Bricklayer::Plugins Bricklayer::Templater Bricklayer::Log Bricklayer::Environs};

sub new {
	my $class = ref($_[0]) || $_[0];
	#my $confFile = $_[1];
	my %DataPlugins;
	my %ContentPlugins;
	my %ActionPlugins;
	my %AccessPlugins;
	my %ErrorPlugins;
	# Initialize our environment
	#die $_[1];
	# Create our Application Object
	my $Obj = {
		Log		   => "",
		WD		   => $_[1]
	};
	
	
	$Obj = bless($Obj, $class);
	# Load our configuration values
	$Obj->load_conf();
	# load our plugins
	$Obj->load_plugins;
	# and hand it off for use
	$Obj->{Loaded} = 1;
	#$Obj->errors("finsihed loading bricklayer", "log");
	return $Obj;
}

return 1;