package Bricklayer::Log;

use Bricklayer::Object::Time;

sub errors {
	$_[0]->{safe_to_log} = 1
		if $_[3];	
	my $msg = $_[1];
	#print STDERR $msg."\n";
	$msg =~ s/\n//g;
	#$msg =~ s/('|")//g;
	my $type = $_[2];
	#print STDERR "$type: ".$msg."\n";
	my $timekeeper = Bricklayer::Object::Time->GMT();
	my $time = $timekeeper->string_simple();
	my $hires = $timekeeper->string_hi_res();
	my @ErrorPlugins = values(%{$_[0]->{PluginList}{error}});
	$i=0;
	my $packagetrace;
	if ($type eq "fatal") {
		$_[0]->{safe_to_log} = 1;
		$_[0]->Publisher->content_type("txt");
		while (my ($packagename, $filename1, $line1, $subroutinename) = caller($i)) {
			$i++;
			$packagetrace = "$packagename::$subroutinename() at $filename1 Line: $line1\n->".$packagetrace;
		}		
	} else {
		my ($packagename, $filename1, $line1, $subroutinename) = caller(1);
		$packagetrace = "$packagename::$subroutinename() at $filename1 Line: $line1";
		($packagename, $filename1, $line1, $subroutinename) = caller(2);
		$packagetrace = "$packagename::$subroutinename() at $filename1 Line: $line1";
	}
	#$_[0]->{Log} .= "entering errors method\n";
	$_[0]->{Log} .= "$time | $hires | $msg | $type |$packagetrace\n";
	$_[0]->{LastLog} = "$msg | $type |$packagetrace\n";
	if ($ErrorPlugins[0]) {
		#$_[0]->{Log} .= "There are error plugins\n";
		foreach my $handler (@ErrorPlugins) {
			#$_[0]->{Log} .= "running error plugin: $handler->{Name}\n";
			$handler->run($msg, $type, "$time"); # each of our error plugins does 
										 # whatever it is supposed to with 
										 # the error
		}
		if ($type eq "fatal") {
			die $_[0]->{LastLog};			
		}
	} else {
		if ($type eq "fatal") {
			die $_[0]->{LastLog};			
		}
	}	
}

sub log {
	return $_[0]->{Log};
}

sub last_msg {
	return $_[0]->{LastLog};
}

return 1;