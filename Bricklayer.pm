#-------------------------------------------------------------------------------
#
# File: BrickLayer.pm
# Version: 0.6
# Author: Jeremy Wall
# Definition: This is the Bricklayer Bundle Package.\
#
# Documentation: docs/BKManual.tex
#-------------------------------------------------------------------------------
package Bricklayer;
#Internal Libs
#External Libs
use Benchmark qw(:all);

use base qw(Bricklayer::Core Bricklayer::Mapper Bricklayer::Access Bricklayer::Publisher Bricklayer::Bench Bricklayer::Workflow);

$Bricklayer::VERSION = '0.7';

sub default_db_driver {
	#$_[0]->errors("entered default_db_driver method", "log");
	my $dbHandler = $_[0]->plugins()->load($_[0]->config()->dbhandler, "data")
		or $_[0]->errors("failed loading default db handler", "fatal"); # set up our database connection
	#$_[0]->errors("our driver is: ".$dbHandler, "log");
	
	return $dbHandler;
}

sub db_conn { 
	#$_[0]->errors("entering db_conn method of bricklayer object", "log");
	return $_[0]->{DBCONN} 
		if exists($_[0]->{DBCONN});
	return $_[0]->{DBCONN} 
		if $_[0]->{DBCONN};	
	#$_[0]->errors("No DB Connection object cached", "log");
	$_[0]->{DBCONN} = $_[0]->default_db_driver();
	return $_[0]->{DBCONN};
}

sub new_file_obj {
	my $FileObj = Bricklayer::Object::File->new();
	$FileObj->ch_dir($_[1])
		if $_[1];
	return $FileObj;
	
}

# Internal Tool Functions

sub execute {
	my $publishType = $_[1];
	my $tagID = "BK";
	my $tempTag = $_[2];
	$tagID = $tempTag
		if $tempTag;
	$_[0]->env->pass_env($_[3]);
	#$_[0]->errors("running execute method", "log");
	
	#$_[0]->errors("Starting Flow Switch area", "log");	
	$_[0]->publish_header($publishType);
  Flow: {
		#Process action requests first
		if ($_[0]->env()->Action ) {
			my $Plugin = $_[0]->plugins()->load($_[0]->env()->Action, "action")
				or $_[0]->errors("Failed loading plugin ".$_[0]->env()->Action, "fatal");
			eval {
				$_[0]->env()->set("Result", $Plugin->run());
				
			};
			$_[0]->errors("Aaaaaaaaaaahhhh!!!! Strange Action Request: $@", "fatal")
				if $@;
		}
		#Process Page(template) requests next
		if ($_[0]->env()->Page) {
			if ( $_[0]->env()->Page eq "start" ) {
				$_[0]->start_page("$publishType", $tagID);
				last Flow;
			}
			else {
			  	my $parsedPage = $_[0]->run_templater($_[0]->env()->Page, $tagID);
			  	#$_[0]->publish($parsedPage, "$publishType");
			  	last Flow;
			}
		}
		else {
			#$_[0]->errors("running default start page", "log");
			$_[0]->start_page("$publishType", $tagID);
			last Flow;
		}
		return 1;
	}
}

sub execute_web {
	$_[0]->get_time;
	my $publishType = $_[1] || "web";
	my $tagID = "BK";
	my $tempTag = $_[2];
	$tagID = $tempTag
		if $tempTag;
	my $publisher = $_[0]->plugins()->load("$publishType", "publish");
	my $cgi = $publisher->get_env()
		or $_[0]->errors("No Http Environment", "fatal");
	my %AKEnv = %$cgi;
	my $Cookies = $publisher->get_cookies();
	$_[0]->errors("running execute_web method", "log");	
	$_[0]->{Cookies} = $Cookies;
	$AKEnv{Cookies} = $Cookies;
	$_[0]->env()->pass_env(\%AKEnv);
	$_[0]->env()->pass_env($_[0]->access()->{Session});
	$_[0]->check_session unless ($_[0]->config->bksetup eq "yes");
	Flow: {
		#Process action requests first
		if ($_[0]->env->Action) {
			my $Plugin = $_[0]->plugins()->load($_[0]->env()->Action, "action")
				or $_[0]->errors("Failed loading plugin ".$_[0]->env()->Action, "fatal");
			eval {
				$_[0]->env()->set("Result", $Plugin->run());
				
			};
			$_[0]->errors("Aaaaaaaaaaahhhh!!!! Strange Action Request: ".$_[0]->env()->Action."->|$@|<-", "fatal")
				if $@;
		}
		#Process Page(template) requests next
		if ($_[0]->env()->Page ) {
			if ( $_[0]->env()->Page eq "start" ) {
				$_[0]->start_page("$publishType");
				last Flow;
			}
			else {
			  	my $parsedPage = $_[0]->run_templater($_[0]->env()->Page, $tagID);
			  	#$_[0]->publish($parsedPage, "$publishType");
			  	last Flow;
			}
		}
		else {
			#$_[0]->errors("running default start page", "log");
			$_[0]->start_page("$publishType", $tagID);
			last Flow;
		}
		return 1;
	}
}

1;
