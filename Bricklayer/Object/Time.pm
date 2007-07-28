package Bricklayer::Object::Time;
use Date::Calc qw(:all); 
use Time::HiRes qw(gettimeofday);

my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
use constant SECOND => 0; 
use constant MINUTE => 1; 
use constant HOUR => 2; 
use constant MONTHDAY => 3; 
use constant MONTH => 4;
use constant YEAR => 5;
use constant WEEKDAY => 6;
use constant YEARDAY => 7;
use constant DST => 8;
use constant HRSECOMD => 9;
use constant HRMSECOND => 10;

use overload '""' => 'string'
		 	 ;


sub GMT {
	my @HRT = gettimeofday();
	($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings, $hresSecond, $hresMicrosecond) = (gmtime(), @HRT);
	$year = 1900 + $yearOffset;
	@theGMTime = ($second, $minute, $hour, $dayOfMonth, $month+1, $year, $dayOfWeek, $dayOfYear, $daylightSavings, "GMT", $hresSecond, $hresMicrosecond);
	return bless(\@theGMTime, ref($_[0]) || $_[0]);
}

sub LOCAL {
	my @HRT = gettimeofday();
	my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings, $hresSecond, $hresMicrosecond) = (localtime(), , @HRT);
	my $year = 1900 + $yearOffset;
	@thetime = ($second, $minute, $hour, $dayOfMonth, $month+1, $year, $dayOfWeek, $dayOfYear, $daylightSavings, "", $hresSecond, $hresMicrosecond);
	return bless(\@thetime, ref($_[0]) || $_[0]);
}

sub string {
	my ($second, $minute, $hour, $dayOfMonth, $month, $year, $dayOfWeek, $dayOfYear, $daylightSavings, $TZ, $hresSecond, $hresMicrosecond) = @{$_[0]};
	my $theTime = "$weekDays[$dayOfWeek] $dayOfMonth/$months[$month]/$year $hour:$minute:$second $TZ";
	return $theTime;
}

sub string_us {
	my ($second, $minute, $hour, $dayOfMonth, $month, $year, $dayOfWeek, $dayOfYear, $daylightSavings, $TZ, $hresSecond, $hresMicrosecond) = @{$_[0]};
	my $theTime = "$weekDays[$dayOfWeek] $month/$dayOfMonth/$year $hour:$minute:$second $TZ";
	return $theTime;
}

sub string_hi_res {
	my ($second, $minute, $hour, $dayOfMonth, $month, $year, $dayOfWeek, $dayOfYear, $daylightSavings, $TZ, $hresSecond, $hresMicrosecond) = @{$_[0]};
	my $theHiRes = "$hresSecond.$hresMicrosecond";
	return $theHiRes;
}
sub string_date_mdy {
	my ($second, $minute, $hour, $dayOfMonth, $month, $year, $dayOfWeek, $dayOfYear, $daylightSavings, $TZ, $hresSecond, $hresMicrosecond) = @{$_[0]};
	my $theTime = "$month/$dayOfMonth/$year";
	return $theTime;
}

sub string_simple {
	my ($second, $minute, $hour, $dayOfMonth, $month, $year, $dayOfWeek, $dayOfYear, $daylightSavings, $TZ, $hresSecond, $hresMicrosecond) = @{$_[0]};
	my $theTime = "$months[$month]-$dayOfMonth-$year $hour:$minute:$second";
	return $theTime;
}

sub string_simple2 {
	my ($second, $minute, $hour, $dayOfMonth, $month, $year, $dayOfWeek, $dayOfYear, $daylightSavings, $TZ, $hresSecond, $hresMicrosecond) = @{$_[0]};
	my $theTime = "$months[$month]/$dayOfMonth/$year $hour:$minute:$second";
	return $theTime;
}

sub add_hours {
	my ($year,$month,$day, $hour,$min,$sec) = Date::Calc::Add_Delta_DHMS($_[0]->[YEAR], $_[0]->[MONTH], $_[0]->[MONTHDAY],
															 $_[0]->[HOUR], $_[0]->[MINUTE], $_[0]->[SECOND], 0, $_[1], 0, 0 );
	$_[0]->[YEAR] = $year;
	$_[0]->[MONTH] = $month;
	$_[0]->[MONTHDAY] = $day;
	$_[0]->[YEARDAY] = Date::Calc::Day_of_Year($year, $month, $day);
	$_[0]->[WEEKDAY] = Date::Calc::Day_of_Week($year, $month, $day);
	$_[0]->[HOUR] = $hour;
	$_[0]->[MINUTE] = $min;
	$_[0]->[SECOND] = $sec;
	
	return $_[0];
}

sub add_minutes {
	my ($year,$month,$day, $hour,$min,$sec) = Date::Calc::Add_Delta_DHMS($_[0]->[YEAR], $_[0]->[MONTH], $_[0]->[MONTHDAY],
															 $_[0]->[HOUR], $_[0]->[MINUTE], $_[0]->[SECOND], 0, 0, $_[1], 0 );
	$_[0]->[YEAR] = $year;
	$_[0]->[MONTH] = $month;
	$_[0]->[MONTHDAY] = $day;
	$_[0]->[YEARDAY] = Date::Calc::Day_of_Year($year, $month, $day);
	$_[0]->[WEEKDAY] = Date::Calc::Day_of_Week($year, $month, $day);
	$_[0]->[HOUR] = $hour;
	$_[0]->[MINUTE] = $min;
	$_[0]->[SECOND] = $sec;
	
	return $_[0];
}

sub add_seconds {
	my ($year,$month,$day, $hour,$min,$sec) = Date::Calc::Add_Delta_DHMS($_[0]->[YEAR], $_[0]->[MONTH]+1, $_[0]->[MONTHDAY],
															 $_[0]->[HOUR], $_[0]->[MINUTE], $_[0]->[SECOND], 0, 0, 0, $_[1] );
	$_[0]->[YEAR] = $year;
	$_[0]->[MONTH] = $month-1;
	$_[0]->[MONTHDAY] = $day;
	$_[0]->[YEARDAY] = Date::Calc::Day_of_Year($year, $month, $day);
	$_[0]->[WEEKDAY] = Date::Calc::Day_of_Week($year, $month, $day);
	$_[0]->[HOUR] = $hour;
	$_[0]->[MINUTE] = $min;
	$_[0]->[SECOND] = $sec;
	
	return $_[0];
}

sub add_days {
	my ($year, $month, $day) = Date::Calc::Add_Delta_Days($_[0]->[YEAR], $_[0]->[MONTH]+1, $_[0]->[MONTHDAY], $_[1]);
	$_[0]->[YEAR] = $year;
	$_[0]->[MONTH] = $month-1;
	$_[0]->[MONTHDAY] = $day;
	$_[0]->[YEARDAY] = Date::Calc::Day_of_Year($year, $month, $day);
	$_[0]->[WEEKDAY] = Date::Calc::Day_of_Week($year, $month, $day);
	
	return $_[0];
}

