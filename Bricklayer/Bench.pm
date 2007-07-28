package Bricklayer::Bench;

use Bricklayer::Object::Time;

sub get_time {
	my $timekeeper = Bricklayer::Object::Time->GMT();
	$_[0]->{t0} = $timekeeper->string_hi_res unless $_[0]->{t0};
	$_[0]->{interval} = $_[0]->{t0} unless $_[0]->{t0};
	my $t1 = $timekeeper->string_hi_res; #current time
	$_[0]->{tTotal} = $t1 - $_[0]->{t0}; #time since started
	my $td2 = $t1 - $_[0]->{interval}; #time since last interval
	$_[0]->{interval} = $t1; #set our new interval time
	my ($return) = $td2 =~ m/([0-9]+\.[0-9]{0,4})/; #limit to our precision this is not following rounding rules
	return $return;
}

sub get_total {
	my ($return) = $_[0]->{tTotal} =~ m/([0-9]+\.[0-9]{0,4})/; #limit to our precision this is not following rounding rules
	return $return;
}

return 1;