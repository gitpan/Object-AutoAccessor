use strict;
use Test::More qw(no_plan);
use lib qw(/_projects/Object-AutoAccessor/lib);
use Object::AutoAccessor;

#-------------------------------------------------------------------------------
# new

my $obj = Object::AutoAccessor->new();

is(ref($obj), 'Object::AutoAccessor', 'new()');

#-------------------------------------------------------------------------------
# EXPORT

can_ok($obj, qw(param as_hashref));

#-------------------------------------------------------------------------------
# scalar setter/getter / length

$obj->scalartest('test1');

is($obj->scalartest(), 'test1');
is($obj->get_scalartest(), 'test1');

$obj->set_scalartest('test2');

is($obj->scalartest(), 'test2');
is($obj->get_scalartest(), 'test2');

is($obj->length('scalartest'), 5);

#-------------------------------------------------------------------------------
# array setter/getter

$obj->arraytest([qw(test3 test4 test5)]);

is_deeply($obj->arraytest, [qw(test3 test4 test5)]);
is_deeply($obj->get_arraytest, [qw(test3 test4 test5)]);

$obj->set_arraytest([qw(test6 test7 test8)]);

is_deeply($obj->arraytest, [qw(test6 test7 test8)]);
is_deeply($obj->get_arraytest, [qw(test6 test7 test8)]);

#-------------------------------------------------------------------------------
# hash setter/getter / keys / values

$obj->hashtest({ testkey1 => 'test9', testkey2 => 'test10' });

is_deeply($obj->hashtest, { testkey1 => 'test9', testkey2 => 'test10' });
is_deeply($obj->get_hashtest, { testkey1 => 'test9', testkey2 => 'test10' });

$obj->set_hashtest({ testkey1 => 'test9', testkey2 => 'test10' });

is_deeply($obj->hashtest, { testkey1 => 'test9', testkey2 => 'test10' });
is_deeply($obj->get_hashtest, { testkey1 => 'test9', testkey2 => 'test10' });

is_deeply([sort $obj->keys('hashtest')], [qw(testkey1 testkey2)]);
is_deeply([sort $obj->values('hashtest')], [qw(test10 test9)]);

like($obj->each('hashtest'), qr/^testkey[12]$/);

my($key,$val) = $obj->each('hashtest');
like($key, qr/^testkey[12]$/);
like($val, qr/^test(9|10)$/);

#-------------------------------------------------------------------------------
# as_hashref

is_deeply(
	$obj->as_hashref,
	{
		scalartest => 'test2',
		arraytest  => [qw(test6 test7 test8)],
		hashtest   => { testkey1 => 'test9', testkey2 => 'test10' },
	}
);

#-------------------------------------------------------------------------------
# glob setter/getter

$obj->globtest(\*STDOUT);

#-------------------------------------------------------------------------------
# code setter/getter

$obj->codetest(sub { "CODETEST" });

is($obj->codetest->(), "CODETEST");

#-------------------------------------------------------------------------------
# is_(hash|array|code|glob)ref / ref

ok(!$obj->is_hashref('scalartest'));
ok(!$obj->is_arrayref('scalartest'));
ok(!$obj->is_coderef('scalartest'));
ok(!$obj->is_globref('scalartest'));
ok($obj->is_scalar('scalartest'));
ok(!$obj->ref('scalartest'));

ok(!$obj->is_hashref('arraytest'));
ok($obj->is_arrayref('arraytest'));
ok(!$obj->is_coderef('arraytest'));
ok(!$obj->is_globref('arraytest'));
ok(!$obj->is_scalar('arraytest'));
is($obj->ref('arraytest'), 'ARRAY');

ok($obj->is_hashref('hashtest'));
ok(!$obj->is_arrayref('hashtest'));
ok(!$obj->is_coderef('hashtest'));
ok(!$obj->is_globref('hashtest'));
ok(!$obj->is_scalar('hashtest'));
is($obj->ref('hashtest'), 'HASH');

ok(!$obj->is_hashref('codetest'));
ok(!$obj->is_arrayref('codetest'));
ok($obj->is_coderef('codetest'));
ok(!$obj->is_globref('codetest'));
ok(!$obj->is_scalar('codetest'));
is($obj->ref('codetest'), 'CODE');

ok(!$obj->is_hashref('globtest'));
ok(!$obj->is_arrayref('globtest'));
ok(!$obj->is_coderef('globtest'));
ok($obj->is_globref('globtest'));
ok(!$obj->is_scalar('globtest'));
is($obj->ref('globtest'), 'GLOB');

#-------------------------------------------------------------------------------
# renew / is_child / undef / delete / exists / defined

$obj->childtest($obj->renew);

ok($obj->is_child('childtest'));

$obj->undef('childtest');

ok(!$obj->is_child('childtest'));
ok($obj->exists('childtest'));
ok(!$obj->defined('childtest'));

$obj->delete('childtest');

ok(!$obj->exists('childtest'));

#-------------------------------------------------------------------------------
# chomp/chop

$obj->choptest("test\n");
$obj->chomp('choptest');
my $choptest = $obj->choptest;
is($obj->{params}->{choptest}, 'test');
is($choptest, 'test');
$obj->chop('choptest');
$choptest = $obj->choptest;
is($obj->{params}->{choptest}, 'tes');
is($choptest, 'tes');

#-------------------------------------------------------------------------------
# lc/lcfirst/uc/ucfirst

$obj->lctest('FOO');
my $lctest = $obj->lc('lctest');
is($obj->{params}->{lctest}, 'FOO');
is($lctest, 'foo');

$obj->lctest('FOO');
$lctest = $obj->lcfirst('lctest');
is($obj->{params}->{lctest}, 'FOO');
is($lctest, 'fOO');

$obj->uctest('foo');
my $uctest = $obj->uc('uctest');
is($obj->{params}->{uctest}, 'foo');
is($uctest, 'FOO');

$obj->uctest('foo');
$uctest = $obj->ucfirst('uctest');
is($obj->{params}->{uctest}, 'foo');
is($uctest, 'Foo');

#-------------------------------------------------------------------------------
# join

$obj->arraytest([qw(test1 test2 test3 test4 test5)]);

is($obj->join('/', 'arraytest'), 'test1/test2/test3/test4/test5');

#-------------------------------------------------------------------------------
# bind

$obj->scalartest('select * from FOO where BAR = \'?\?\' and BAZ = ?');
is($obj->bind(scalartest => (1,2)), 'select * from FOO where BAR = \'1?\' and BAZ = 2');

$obj->scalartest(q{SELECT * FROM foo WHERE BAR = ? AND BAZ = ? AND ID = ?});
$obj->bindstyle('sql');
is($obj->bind(scalartest => qw(bar baz -0.12)), q{SELECT * FROM foo WHERE BAR = 'bar' AND BAZ = 'baz' AND ID = -0.12});
is($obj->bind(scalartest => ('It\'s OK', 'baz', 0)), q{SELECT * FROM foo WHERE BAR = 'It''s OK' AND BAZ = 'baz' AND ID = 0});

$obj->bindstyle('normal');
$obj->scalartest('select * from FOO where BAR = \'?\?\' and BAZ = ?');
is($obj->bind(scalartest => (1,2)), 'select * from FOO where BAR = \'1?\' and BAZ = 2');

#-------------------------------------------------------------------------------
# sprintf

$obj->scalartest('%04d/%02d/%02d %s %.3f');

is($obj->sprintf('scalartest', 2005, 8, 20, 'test', 0.123456), '2005/08/20 test 0.123');

#-------------------------------------------------------------------------------
# pop / push

$obj->push('poppush', 'foo');
$obj->push('poppush', 'bar');
$obj->push('poppush', 'baz');

is_deeply($obj->poppush, [qw(foo bar baz)]);

is($obj->pop('poppush'), 'baz');

is_deeply($obj->poppush, [qw(foo bar)]);

is($obj->pop('poppush'), 'bar');

is_deeply($obj->poppush, [qw(foo)]);

is($obj->pop('poppush'), 'foo');

is_deeply($obj->poppush, []);

#-------------------------------------------------------------------------------
# shift / unshift

$obj->unshift('poppush', 'foo');
$obj->unshift('poppush', 'bar');
$obj->unshift('poppush', 'baz');

is_deeply($obj->poppush, [qw(baz bar foo)]);

is($obj->shift('poppush'), 'baz');

is_deeply($obj->poppush, [qw(bar foo)]);

is($obj->shift('poppush'), 'bar');

is_deeply($obj->poppush, [qw(foo)]);

is($obj->shift('poppush'), 'foo');

is_deeply($obj->poppush, []);

#-------------------------------------------------------------------------------
# param

undef $obj;

$obj = Object::AutoAccessor->new();

$obj->testhash({ key1 => 'val1', key2 => 'val2' });
$obj->testarray(['array1','array2']);
$obj->testscalar('scalarval');

is_deeply([sort $obj->param], ['testarray','testhash','testscalar']);

is($obj->param('testscalar'), 'scalarval');

$obj->param(testscalar => 'foo');

is($obj->param('testscalar'), 'foo');

$obj->param(childtest => $obj->renew());

# cannot access - valid
is($obj->param('childtest'), undef);

is_deeply([sort $obj->param], ['testarray','testhash','testscalar']);

#-------------------------------------------------------------------------------
# new with 'noautoload'

undef $obj;

$obj = Object::AutoAccessor->new(autoload => 0);

eval { $obj->test('!!!'); };

ok(!$obj->defined('test'));

#-------------------------------------------------------------------------------
# renew with 'noautoload'

$obj = Object::AutoAccessor->renew(autoload => 0);

eval { $obj->retest('???'); };

ok(!$obj->defined('retest'));

#-------------------------------------------------------------------------------
