package Bricklayer::Templater::Handler::common::arrayitem;
use Bricklayer::Templater::Handler;
use base qw(Bricklayer::Templater::Handler);

sub run {
	my $Token = $_[0]->{Token};
	my $App =  $_[0]->{App};
	my $Data = $_[0]->{data};
	my $select = $Token->{attributes}{"index"};
	$select = $#$Data if ($Data->[$select] eq "last");
	return undef unless $Data->[$select];
	my $test = "|".ref($Data->[$select]);
	return $Data->[$select] if $test eq "|";
	$_[0]->app()->env()->pass_env({$_[0]->{Token}{attributes}{export} => $Data->[$select]}) if ($_[0]->{Token}{attributes}{export});
	my $contents = $_[0]->app()->run_sequencer($_[0]->{Token}{block}, undef, $Data->{$select}) if $Data->{$select};
	return;
}

return 1;
