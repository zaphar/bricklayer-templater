use Test::More;
use Test::MockObject;
use Test::MockObject::Extends;
use Cwd;

use lib '..';
my @coremethods = qw{new app WD};
my @tmethods = qw{handlers load_template_file run_templater run_sequencer _page publish};
my $TEMPLATE = '<BKcommon::row attrib="1"><BKutil::bench></BKutil::bench></BKcommon::row><BKutil::tester></BKutil::tester>';
my @cmp2 = ({type => 'container', tagname => 'common::row', attributes => {attrib => 1}, block => '<BKutil::bench></BKutil::bench>', tagid => 'BK'}, {type => 'container', tagname => 'util::tester', attributes => {undef}, block => '', tagid => 'BK'});
my $t;
my $app = bless({}, 'Some::Class');
my $cwd = cwd();
my $ep = 'tester was here :-)';
plan tests =>  1 # test that module can be loaded
              +5 # test instance creation
	      +1 # test that the core and templater BK methods exist
	      +2 # test that the app and wd methods return correct values
	      +2 # test that Templater correctly loads templates
	      +2 # test that sequencer returns correctly parsed page
	      ;

{    
    use_ok('Bricklayer::Templater');
}

{
    ok(!($t = Bricklayer::Templater->new()), 'failed to create a Templater instance without a working directory and context');
    ok(!($t = Bricklayer::Templater->new($app, undef)), 'failed to create a Templater instance without a context');
    ok(!($t = Bricklayer::Templater->new(undef, $cwd)), 'failed to create a Templater instance without a working directory');
    ok($t = Bricklayer::Templater->new($app, $cwd), 'successfully created a Templater instance with a working directory and context');
    isa_ok($t, 'Bricklayer::Templater');
}

{
    can_ok('Bricklayer::Templater', @coremethods, @tmethods);
    isa_ok($t->app(), 'Some::Class');
    ok($t->WD() eq $cwd, 'WD method equals cwd');
}

{
    is($TEMPLATE, $t->load_template_file('test'), 'successfully loaded template');
    is($TEMPLATE, $t->load_template_file('tmpl::test'), 'successfully loaded template with :: syntax');
}
my $p;
# TODO need to mock the publish method?
{
    $t->run_sequencer($TEMPLATE);
    ok($p = $t->_page(), 'Successfully Called publish Callback');
    is($p, $ep, 'template text matches expected result');
    
}
