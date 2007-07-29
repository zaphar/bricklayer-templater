use strict;
use warnings;
use Test::More;
use Test::MockObject;
use lib '..';

plan tests =>  1    # test that module can be loaded
              +1   # test that we can create a new Bricklayer Object
        ;
{
	use_ok('Bricklayer::Core');
	ok(Bricklayer::Core->new(), 'We got a new Bricklayer Object');
}

