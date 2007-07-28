package mod_perl_report;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Filter ();

use Apache2::Const -compile => qw(OK);

use constant IOBUFSIZE => 8192;

sub handler {
  my $r = shift;
  my $report;
  
  $r->content_type('text/plain');
  $report .= "server: ".$r->server()."\n\n";
  $report .= "hostname: ".$r->hostname()."\n";
  $report .= "user: ".$r->user()."\n";
  $report .= "unparsed uri: ".$r->unparsed_uri()."\n";
  $report .= "uri: ".$r->uri()."\n";
  $report .= "filename: ".$r->filename()."\n";
  $report .= "pathinfo: ".$r->path_info()."\n";
  $report .= "request time: ".$r->request_time()."\n";
  $report .= "request method: ".$r->method()."\n";
  $report .= "request string: ".$r->args()."\n\n";
  $report .= "cookies: ".$r->headers_in->{Cookie}."\n";
  $report .= "status: ".$r->status()."\n";
  $report .= "status line: ".$r->status_line()."\n";
  $report .= "notes: ".$r->notes()."\n";
  $report .= "\n\npost data: ->|".read_post($r)."|<-";
#  $report .= "\n\nmodifying variables now: \n\n"; 


  print "mod_perl 2.0 Debugging output:\n\n";
  print $report;

  return Apache2::Const::OK;
}

sub process_notes {
    my $notes;
    for (keys(%{$_[1]})) {
        $notes .= " | ".$_;
    }
    return "notes are: ".$notes;
}

sub read_post {
    my $r = shift;
    my $buffer;
    my $data;
    while ($r->read($buffer, 1000)) {
        $data .= $buffer;
    }
    return $data;
}

1;

