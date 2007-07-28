package default;

use base qw(Bricklayer::Plugins::Core);
our %MetaData = (Name => "default",
				Type => "action",
				Author => "Jeremy Wall",
				Version => "0.1",
				URI => "http://data.seniorhealthadvantage.com/action/default/",
				);

sub run {
#	$_[0]->app()->Publisher()->content_type("txt");
#	$_[0]->app()->Publisher()->run( );
	return "Using Default Handler from shared repository\n ".$_[0]->app()->log();
}

return 1;