use Test::More qw[no_plan];
use strict;
$^W = 1;

use_ok 'Return::Value';

my $ret = Return::Value->new;
isa_ok $ret, 'Return::Value';
ok ! $ret->bool, 'false';
is $ret->errno, 0, 'errno 0';
is $ret->string, "", 'empty string';
ok ! $ret->data, 'no data';
is scalar(keys %{$ret->prop}), 0, 'no properties';

$ret = Return::Value->new(
    bool   => 1,
    errno  => 128,
    string => 'string',
    data   => [ 'one' ],
    prop   => { one => 1 },
);

isa_ok $ret, 'Return::Value';
ok $ret->bool, 'true';
is $ret->errno, 128, 'errno 128';
is $ret->string, 'string', 'string is string';
is ref($ret->data), 'ARRAY', 'data array ref';
is scalar(@{$ret->data}), 1, 'one element in data';
is ref($ret->prop), 'HASH', 'hash in prop';
is $ret->prop->{one}, 1, 'one prop set';

$ret->bool(0);
ok ! $ret->bool, 'now false';
is $ret->prop('one'), 1, 'object access for one';
is $ret->prop(two => 2), 2, 'prop create for two';
