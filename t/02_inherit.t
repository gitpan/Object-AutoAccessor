use strict;
use Test::More tests => 8;

use lib 't/lib';
use Foo;

my $foo = Foo->new;

BEGIN { use_ok('Foo'); }

can_ok($foo, qw(param as_hashref));

ok($foo->isa('Object::AutoAccessor'));

$foo->test('abc123');

is($foo->test, 'abc123');

$foo->renew();

ok($foo->isa('Object::AutoAccessor'));

$foo->test('def456');

is($foo->test, 'def456');

$foo->test(Object::AutoAccessor->new);

ok($foo->is_child('test'));

$foo->test(Foo->new);

ok($foo->is_child('test'));
