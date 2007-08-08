use Test::More;
use Test::MockObject;
use Test::MockObject::Extends;
use Cwd;

use lib '..';
my @coremethods = qw{new};
my @tmethods = qw{load_template_file run_templater run_sequencer _page publish clear};
my @attribs = qw{app WD start_bracket end_bracket ext identifier _page _template};
my $TEMPLATE = '<BKcommon::row attrib="1"><BKutil::bench></BKutil::bench></BKcommon::row><BKutil::tester></BKutil::tester>';
my @cmp2 = ({type => 'container', tagname => 'common::row', attributes => {attrib => 1}, block => '<BKutil::bench></BKutil::bench>', tagid => 'BK'}, {type => 'container', tagname => 'util::tester', attributes => {undef}, block => '', tagid => 'BK'});
my $t;
my $app = bless({}, 'Some::Class');
my $cwd = cwd();
my $ep = 'tester was here :-)';
plan tests =>  1 # test that module can be loaded
              +4 # test instance creation
              +1 # test that the core and templater BK methods exist
              +1 # test that the attribute accessors exist
              +4 # test the defaults are set for the accessors correctly
              +2 # test that the app and wd methods return correct values
              +2 # test that Templater correctly loads templates files
              +1 # test that publish callback is called
              +1 # test that Sequencer stores parsed page
	      ;

{    
    use_ok('Bricklayer::Templater');
}

{
    ok(!($t = Bricklayer::Templater->new($app, undef)), 'failed to create a Templater instance without a context');
    ok(!($t = Bricklayer::Templater->new(undef, $cwd)), 'failed to create a Templater instance without a working directory');
    ok($t = Bricklayer::Templater->new($app, $cwd), 'successfully created a Templater instance with a working directory and context');
    isa_ok($t, 'Bricklayer::Templater');
}

{
    can_ok('Bricklayer::Templater', @coremethods, @tmethods);
    can_ok($t, @attribs);
    ok($t->WD() eq $cwd, 'WD attrib equals cwd');
    isa_ok($t->app(), 'Some::Class');
    is($t->ext(), 'txml', 'ext attribute is the correct default');
    is($t->start_bracket(), '<', 'ext attribute is the correct default');
    is($t->end_bracket(), '>', 'ext attribute is the correct default');
    is($t->identifier(), 'BK', 'ext attribute is the correct default');

}

{
    is($t->load_template_file('test'), $TEMPLATE, 'successfully loaded template');
    is($t->load_template_file('tmpl::test'), $TEMPLATE,'successfully loaded template with :: syntax');
}

my $p;
{
    $t->clear();
    $t->run_sequencer($TEMPLATE);
    ok($p = $t->_page(), 'Successfully Called publish Callback');
    is($p, $ep, 'template text matches expected result');
    $t->clear();
    is($t->_page, undef, 'page attribute has been cleared');
}

