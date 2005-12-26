use strict;
use Test::More qw(no_plan);
use Object::AutoAccessor;

#-------------------------------------------------------------------------------

my $obj = Object::AutoAccessor->new();

$obj->test($obj->renew);
$obj->foo('FOO');
$obj->bar('BAR');

$obj->test->value('VALUE');

is($obj->test->value, 'VALUE', 'child accessor');
is_deeply([sort $obj->param], ['bar','foo']);

$obj->test('overwriting');
is_deeply([sort $obj->param], ['bar','foo','test']);

$obj->test($obj->renew);
is_deeply([sort $obj->param], ['bar','foo']);

#-------------------------------------------------------------------------------

