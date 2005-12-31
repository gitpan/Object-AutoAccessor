use strict;
use Test::More qw(no_plan);
use Object::AutoAccessor;

#-------------------------------------------------------------------------------

my $obj = Object::AutoAccessor->new();
$obj->foo('FOO');
$obj->bar('BAR');

is($obj->has_child, 0);

$obj->new_child('test')->value('VALUE');

is($obj->has_child, 1);
is($obj->child('test')->value, 'VALUE');
is($obj->test->value, 'VALUE');
is_deeply([sort $obj->param], ['bar','foo']);
is_deeply([sort $obj->child], ['test']);

$obj->new_child('test2')->value('VALUE2');

is($obj->has_child, 2);
is($obj->child('test2')->value, 'VALUE2');
is($obj->test2->value, 'VALUE2');
is_deeply([sort $obj->param], ['bar','foo']);
is_deeply([sort $obj->child], ['test','test2']);

$obj->test('overwriting');
is($obj->has_child, 1);
is($obj->test, 'overwriting');
is_deeply([sort $obj->param], ['bar','foo','test']);
is_deeply([sort $obj->child], ['test2']);

$obj->test2('overwriting');
is($obj->has_child, 0);
is($obj->test2, 'overwriting');
is_deeply([sort $obj->param], ['bar','foo','test','test2']);

$obj->new_child('test')->param(foo => 'bar', bar => 'baz');
is($obj->has_child, 1);
is_deeply([sort $obj->param], ['bar','foo','test2']);
is_deeply([sort $obj->child], ['test']);

$obj->new_child('test2')->param(bar => 'foo', baz => 'bar');
is($obj->has_child, 2);
is_deeply([sort $obj->param], ['bar','foo']);
is_deeply([sort $obj->child], ['test','test2']);

my($o1, $o2) = $obj->children('test','test2');
is($o1->foo, 'bar');
is($o1->bar, 'baz');
is($o2->bar, 'foo');
is($o2->baz, 'bar');

my $children = $obj->children('test2','test');
is($children->[0]->bar, 'foo');
is($children->[0]->baz, 'bar');
is($children->[1]->foo, 'bar');
is($children->[1]->bar, 'baz');

$obj->new_child('foo')->new_child('bar')->baz('test');
is($obj->has_child, 3);
is($obj->foo->has_child, 1);
is($obj->foo->bar->has_child, 0);
is($obj->foo->bar->baz, 'test');
is($obj->foo->bar->uc('baz'), 'TEST');

#-------------------------------------------------------------------------------

