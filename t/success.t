
use Test::More 'no_plan';
use strict;
use warnings;

my $class;

BEGIN { $class = 'Return::Value'; use_ok($class); }

{
	my $message = "Feelin' fine.";
	my $value = success $message;

	isa_ok($value, $class,   "success value");

	ok($value,               "success value is true");
	ok($value == 1,          "success value is 1");
	ok($value eq $message,   "success value is feelin' fine");
	is($value->errno, undef, "success value errno is default (undef)");
}

{
	my $message = "Feelin' fine.";
	my $value = success $message, errno => 200, data => { cause => 'sunshine' };

	isa_ok($value, $class, "success value");

	ok($value,               "success value is true");
	ok($value == 1,          "success value is 0");
	ok($value eq $message,   "success value has a bad feelin'");
	is($value->errno, 200,   "success value has 501 errno");

	is(ref $value->data,   'HASH',     "success value includes hashref");
	is(${$value}->{cause}, 'sunshine', "success value derefs correctly");
}
