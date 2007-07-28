package modperl_env;
use Bricklayer::Plugins::Core;
use MIME::Types;
use base qw(Bricklayer::Plugins::Core);

use Apache2::Request;
use Apache2::Upload;
use Apache2::Cookie;

our %MetaData = (Name => "modperl_env",
				Type => "publish",
				Author => "Jeremy Wall",
				Version => "0.1",
				URI => "http://data.seniorhealthadvantage.com/env/modperl_env/",
				);

sub run { 
	my $self = shift;
	my $env = $self->app()->env();
	my $Apache = shift; #the Apache2::RequestRec object for our Apache2::Request calls;
	$self->cookie_guard($Apache->headers_in);
	my $pool = $Apache->pool();
	my $PostSize = $self->app()->config()->PostSize || "5M";
	my $TempDir = $self->app()->config()->TempDir || "/tmp/";
	# now we gather all our environment stuff here
	my $request = Apache2::Request->new($Apache, POST_MAX => $PostSize);
	#grab our params from GET
	foreach ($request->param) {
		#handle array parameters
		my @params = $request->param($_);
#		$env->hashref()->{$_} = (scalar(@params) == 1) ? $params[0] : \@params;
		$env->$_ = (scalar(@params) == 1) ? $params[0] : \@params;
		
	}
	# or POST
	foreach ($request->body) {
		#handle array parameters
		my @params = $request->body($_);
#		$env->hashref()->{$_} = (scalar(@params) == 1) ? $params[0] : \@params;
		$env->$_ = (scalar(@params) == 1) ? $params[0] : \@params;
		
		
	}
	# or Uploads
	foreach ($request->upload) {
		#handle array parameters
		my @Files;
		my @params = $request->upload($_); 
		foreach my $upload (@params) {
			my $contents;
			my $size = $upload->slurp($contents);
			push @Files, {Contents => $contents, FileName => $upload->filename(), 
						  Size => $size, Type => $upload->type()};
		}
		$env->hashref()->{UPLOADS}{$_} = (scalar(@Files) == 1) ? $Files[0] : \@Files;
		
	}
	
	# or Cookies
	my $jar = Apache2::Cookie::Jar->new($Apache);
	foreach ($jar->cookies) {
		#handle array parameters
		my @cookies;
		my @params = $jar->cookies($_);
		foreach my $cookie (@params) {
			push @cookies, $cookie->value();
		}
		$env->hashref()->{COOKIES}{$_} = (scalar(@cookies) == 1) ? $cookies[0] : \@cookies;
		
	}
	return;
}

sub cookie_guard { #APReq chokes on certain malformed cookies. So lets sanitize them before we try to retrieve anything
	my $header_table = $_[1];
	my $cookie_text = $header_table->get('Cookie');
	$cookie_text =~ s/,/_/g;
	$header_table->set('Cookie', $cookie_text);

}

return 1;