use Test::More;
use Test::MockObject;

use lib '..';
my @coremethods = qw{new app WD};
my @tmethods = qw{handlers load_template_file run_templater run_sequencer};
my $TEMPLATE = '<BKcommon::row><BKutil::bench></BKutil::bench></BKcommon::row><BKutil::tester></BKutil::tester>';
my $TEMPLATE2 = '<BKcommon::row attrib="1"><BKutil::bench></BKutil::bench></BKcommon::row><BKutil::tester></BKutil::tester>';

plan tests =>  1 # test that parser module can be loaded
	      +3 # test for simple template parsing
	      +2 # test that template attributes are parsed correctly
	      ;

my @cmp = ({type => 'container', tagname => 'common::row', attributes => {undef}, block => '<BKutil::bench></BKutil::bench>', tagid => 'BK'}, {type => 'container', tagname => 'util::tester', attributes => {undef}, block => '', tagid => 'BK'});
my @cmp2 = ({type => 'container', tagname => 'common::row', attributes => {attrib => 1}, block => '<BKutil::bench></BKutil::bench>', tagid => 'BK'}, {type => 'container', tagname => 'util::tester', attributes => {undef}, block => '', tagid => 'BK'});
{ 
    use_ok('Bricklayer::Templater::Parser');
    
    my @tokens;
    ok(@tokens = Bricklayer::Templater::Parser::parse_text($TEMPLATE), 'Succeeded in parsing simple template');
    ok(scalar @tokens == 2, 'There were two tokens');
    is_deeply(\@tokens, \@cmp, 'Token Structure is correct');
    ok(@tokens = Bricklayer::Templater::Parser::parse_text($TEMPLATE2), 'Succeeded in parsing simple template with attributes');
    is_deeply(\@tokens, \@cmp2, 'Token Structure with attributes is correct');
}
