package mp;
use strict;
use Bricklayer::Plugins::Core;
use MIME::Types;
use base qw(Bricklayer::Plugins::Core);

use Apache2::RequestIO ();
use Apache2::Cookie;
use Apache2::Const -compile => qw(DECLINED OK REDIRECT);

# For changing file mapping for static files
use APR::Finfo ();
use APR::Const -compile => qw(FINFO_NORM);  

our %MetaData = (Name => "mp",
				Type => "publish",
				Author => "Jeremy Wall",
				Version => "0.1",
				URI => "http://data.seniorhealthadvantage.com/publish/mp/",
				);

sub load_extra {
	my $self = shift;
	my $apache = shift;
	$self->app()->errors("Recieved a: ".ref($apache)." Object", "log");
	$self->{Apache} = $apache;
#	$self->{HeadersSent} = 0;
	$self->check();
}

sub run {
#	$_[0]->check();
	my $Apache = $_[0]->{Apache};
#	$_[0]->errors("We made into the modperl handler!!", "fatal");
	#publish headers;
	$_[0]->publish_headers;
#	$_[0]->errors("We made into the modperl handler!!", "fatal");
	#publish page;
	$_[0]->publish_page($_[1]);
#	$_[0]->errors("We made into the modperl handler!!", "fatal");
	#return;
}

sub publish_page {
#	$_[0]->check();
	my $Apache = $_[0]->{Apache};
#	$_[0]->errors("We made into the modperl handler!!", "fatal");
#	$_[0]->{HeadersSent} = 1;
	$Apache->print($_[1]);
}

sub publish_headers {
#	$_[0]->check();
	my $Apache = $_[0]->{Apache};
#	$_[0]->errors("We made into the modperl handler!!".ref($Apache), "fatal");
	#have we already published our headers?
	$_[0]->errors("Attempt to RePublish Headers after Content has been sent during Publish Cycle", "fatal")
		if $_[0]->{HeadersSent};
#	$_[0]->errors("We made into the modperl handler!!".ref($_[0]), "log");
	#publish the headers
#	$_[0]->{HeadersSent} = "1";
#	$_[0]->errors("We made into the modperl handler!! Headers send is: ".$_[0]->{HeadersSent}, "fatal");
	return;
	$Apache->print();
}

sub add_cookie {
#	$_[0]->check();
	my $Apache = $_[0]->{Apache};
	#have we already published headers?
	$_[0]->errors("Attempt to Add Cookie after Content has been sent during Publish Cycle", "fatal")
		if $_[0]->{HeadersSent};	
	#add cookie header
	$_[0]->errors("Not a HASH reference passed as cookie", "fatal")
		unless ref($_[1]) eq 'HASH';
	return undef unless ref($_[1]) eq 'HASH';
	my $cookiehash = $_[1];
	return undef unless $cookiehash->{name};
	return undef unless $cookiehash->{value};
	
	my $cookie = Apache2::Cookie->new($Apache,
                             -name    =>  $cookiehash->{name},
                             -value   =>  $cookiehash->{value},
#                             -expires =>  $cookiehash->{expires},
                             -domain  =>  $cookiehash->{domain},
                             -path    =>  $cookiehash->{path} || '/',
                             -secure  =>  $cookiehash->{secure} || 0
                            );
	$cookie->expires($cookiehash->{expires})
		if $cookiehash->{expires};
	$cookie->bake($Apache);
}

sub add_header {
#	$_[0]->check();
	my $Apache = $_[0]->{Apache};
	#have we already published headers?
	$_[0]->errors("Attempt to Add Header after Content has been sent during Publish Cycle", "fatal")
		if $_[0]->{HeadersSent};
	#add header
	return unless $_[1] && $_[2];
	$Apache->headers_out->add($_[1], $_[2]);
}

sub content_type {
#	$_[0]->check();
	my $Apache = $_[0]->{Apache};
	#have we already published headers?
	$_[0]->errors("Attempt to Change content_type header after Content has been sent during Publish Cycle", "fatal")
		if $_[0]->{HeadersSent};
	#examine content type for validity;
	my $content_type = MIME::Types->new()->mimeTypeOf($_[1]) if $_[1];
	$content_type = 'text/html' unless $content_type; #default content type as a fallback
	
	#set our content type
	$Apache->content_type($content_type);
}

sub redirect {
#	$_[0]->check();
	my $Apache = $_[0]->{Apache};
	#have already published?
	$_[0]->errors("Attempt to redirect during Publish Cycle", "fatal")
		if $_[0]->published();
	#handle a redirect
	$Apache->headers_out->add("Location", $_[1]);
	$Apache->status(Apache2::Const::REDIRECT);
	return Apache2::Const::REDIRECT;	
}

sub map_file {
#	$_[0]->check();
	$_[0]->errors("Attempt to map to file after Content has been sent during Publish Cycle", "fatal")
		if $_[0]->{HeadersSent} || $_[0]->{Published};
	# set our headers out flag
#	$_[0]->{HeadersSent} = 1;
	my $Apache = $_[0]->{Apache};
	$_[0]->content_type($_[1]);
	$Apache->sendfile($_[1]);
	return Apache2::Const::DECLINED;
}

sub published {
	$_[0]->{Published} = $_[1] if $_[1];
	return $_[0]->{Published};
}

sub check {
	$_[0]->errors("Not a ModPerl2 Environment: ".ref($_[0]->{Apache}), "fatal") unless ref($_[0]->{Apache}) eq 'Apache2::RequestRec'; #need to bail with fatal error here;
}

return 1;