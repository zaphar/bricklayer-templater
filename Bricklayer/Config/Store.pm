package Bricklayer::Config::Store;

use Bricklayer::Class::Builder;
use base qw{Bricklayer::Class::Builder};

sub load {
	return $_[0]->{Config} if $_[0]->{Config};
	my %Conf;
	my $FileName = $_[0]->WD."/App.conf";
	$_[0]->app()->errors("opening config file: $FileName", "log");
	open FILEHANDLE, $FileName
	  or $_[0]->app()->errors("Failed opening config file: $FileName", "log");
	while ( $Line = <FILEHANDLE> ) {
		$Line =~ m/^([^=]*)=(.*)$/;
		$Conf{$1} = $2;
		$_[0]->app()->errors("Setting $1 to $2", "log");
	}
	$_[0]->{Config} = \%Conf;
	return %Conf;
}

sub mod {
	my $key = $_[1];
	my $val = $_[2];
	my $file;
	$filename = $_[0]->WD."/App.conf";
	open FILEHANDLE, $filename
	  or $_[0]->app()->errors("Failed opening config file: ".$filename, "log");
	while ( $Line = <FILEHANDLE> ) {
		$file .= $Line;
	}
	# is the value there?
	if ($file =~ /$key=[^\n]*\n/g) {
		# change the config value
		$file =~ s/$key=[^\n]*\n/$key=$val\n/g;
	} else {
		# add the config value
		$file .= "$key=$val";
	}
	$_[0]->{Config}{$key} = $val;
	close FILEHANDLE;
	open FILEHANDLE, ">$filename"
	  or $_[0]->app()->errors("Failed opening config file: ".$_[1]->{WD}."/App.conf", "log");
	 
	print FILEHANDLE $file;
	close FILEHANDLE;
	
}

sub AUTOLOAD {
	return $_[0]->{Config}{$_[0]->req_key($AUTOLOAD)};
	
}

return 1;