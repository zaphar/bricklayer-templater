# Bricklayer Plugin SuperClass
package Bricklayer::Plugins::Core;

use Bricklayer::Class::Dynamic::Core;
use base qw{Bricklayer::Class::Dynamic::Core};

# Initialization
sub load {
	my $PluginObj = {App => $_[1],
					 Meta=> {Name => "",
					 		 Type => "",
					 		 Author => "",
					 		 Version => "",
					 		 URI => ""},
					 err => undef
					 };
	$PluginObj = bless($PluginObj, ref($_[0]) || $_[0]);	
	$PluginObj->load_meta(); # a required method for plugins to have
	eval { #handle any initialization the plugin requires;
		$_[1]->errors("Calling load_extra: $_[2]", "log");
		$PluginObj->load_extra(@_[2..$#_]); # optional method for plugins to have
	};
	if ($@) {
		$_[1]->errors("encountered an error: $@", "log");
	}
#	$PluginObj->check_auth();
	return $PluginObj;
}
			
sub get_type {
	return lc($_[0]->{Meta}{Type});
}

sub get_meta_data {
	return %{$_[0]->{Meta}};
}

sub load_meta {
	local *MetaData = *{ref($_[0])."::MetaData"};
	$_[0]->{Meta} = \%MetaData;
}

return 1;