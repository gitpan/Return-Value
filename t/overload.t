use Test::More qw[no_plan];
use strict;
$^W = 1;

BEGIN { use_ok 'Return::Value' };

my $success = success;
ok $success, 'good';

my $failure = failure;
ok ! $failure, 'bad';

is ''.success("Good"), "Good", 'stringified good is good';

ok failure() < 1 && failure() > -1 && failure() == 0, 'failure is zero';

my $fail = failure;$fail++;
ok $fail, 'failure to success';
