package Bricklayer::Plugins;

use Bricklayer::Class::Util;
use Bricklayer::Plugins::Store;
use base qw{Bricklayer::Class::Util};

sub load_plugins {
	my @PluginList;
	my $FileObj;
	#$_[0]->errors("loading default plugins", "log");
	
	# load ContentPlugins
	$FileObj = Bricklayer::Object::File->new();
	$FileObj->ch_dir($_[0]->{WD}."/plugins"); # go to the plugins directory	
	$FileObj->ch_dir("content");
	@PluginList = $FileObj->view_files_of_type("pm");
	$FileObj->close_object();
	foreach my $file (@PluginList) {
		$_[0]->plugins()->load($file, "content");
	}
	
	
	# load the Error Plugins
	$FileObj = Bricklayer::Object::File->new();
	$FileObj->ch_dir($_[0]->{WD}."/plugins"); # go to the plugins directory	
	$FileObj->ch_dir("error");
	@PluginList = $FileObj->view_files_of_type("pm");
	$FileObj->close_object();
	foreach my $file (@PluginList) {
		$_[0]->plugins()->load($file, "content");
		
	}
	
}

sub plugins {
	$_[0]->{PluginList} = Bricklayer::Plugins::Store->new($_[0], $_[0]->{WD}) unless ref($_[0]->{PluginList}) eq 'Bricklayer::Plugins::Store';
	return $_[0]->{PluginList};	
}

return 1;