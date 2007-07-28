#!C:\Perl\bin\perl -w
use cgi::ak_cgi;

my %cgi_Env = ak_cgi::cgi_request();
my $buffer = $cgi_Env{buffer};
my $boundary = $cgi_Env{boundary};
my $contenttype = $cgi_Env{'CONTENT_TYPE'};
my $filecontents = $cgi_Env{name}{file};
print "Content-type: text/plain\n\n
seperator = |$boundary|

content type = |$contenttype|


|$buffer|


file contents = 
|$filecontents|
";