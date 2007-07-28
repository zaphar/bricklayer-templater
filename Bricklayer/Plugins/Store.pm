package Bricklayer::Plugins::Store;

use Bricklayer::Class::Builder;
use base qw{Bricklayer::Class::Builder};

sub add {
	my $ref = $_[1];
	my $type = $ref->get_type();
	my $name = $ref->package_name();
	$_[0]->{Cache}{$type}{$name} = $ref;
}

sub get {#expects name then type of plugin to load;
	return $_[0]->{Cache}{$_[2]}{$_[1]};
}

sub unload {#expects name then type of plugin to delete;
	delete $_[0]->{Cache}{$_[2]}{$_[1]};
}

sub load {
	my $PluginName = $_[1];
	my $PluginType = $_[2];
	my $params = $_[3];
	my $app = $_[0]->app;
	my $PluginObj;
	$PluginName =~ s/\.pm//;
	$PluginName =~ s/::/\//g;
	$PluginName =~ s/:/\//g;
	my $PackageName = $_[1];
	$PluginObj = $_[0]->get($_[1], $PluginType);
	return $PluginObj if $PluginObj;
	#first try to load the personal copy
	my $FileObj = Bricklayer::Object::File->new();
	$FileObj->ch_dir($_[0]->WD."/plugins"); # go to the plugins directory	
	$FileObj->ch_dir("$PluginType"); # go to the type directory for that plugin	
	my $PluginFile = $FileObj->current_dir() . "/$PluginName.pm";
	$app->errors("Attempting to Load Plugin: $PluginFile from local repository", "log");
	$FileObj->close_object;
	eval {
		require $PluginFile;$PluginObj = $PackageName->load($app, $params)
		  or $app->errors("$PluginName plugin failed to initialize", "log");
		$_[0]->add($PluginObj);		
	};
	$app->errors("$@", "log")
			if $@;
	#if that didn't work try to load a default copy
	unless ($PluginObj) {
		my $DefaultPluginName = "Bricklayer/Plugins/Default/$PluginType/$PluginName.pm";
		$app->errors("Attempting to Load Plugin: $DefaultPluginName from shared repository", "log");	
		eval {
			require $DefaultPluginName;
			$PluginObj = $PackageName->load($app, $params)
			  or $app->errors("$PluginName plugin failed to initialize", "fatal");
			$_[0]->add($PluginObj);
		};
		$app->errors("$@", "log")
			if $@;
	}
	return $PluginObj;
}

return 1;