package Return::Value;
# $Id: Value.pm,v 1.1 2004/07/15 18:04:48 cwest Exp $
use strict;

use vars qw[$VERSION @EXPORT];
$VERSION = (qw$Revision: 1.1 $)[1];
@EXPORT  = qw[success failure];

use base qw[Exporter];

=head1 NAME

Return::Value - Polymorphic Return Values

=head1 SYNOPSIS

  use Return::Value;
  
  sub send_over_network {
      my ($net, $send) = @_:
      if ( $net->transport( $send ) ) {
          return success;
      } else {
          return failure "Was not able to transport info.";
      }
  }
  
  my $result = $net->send_over_network(  "Data" );
  
  # boolean
  unless ( $result ) {
      # string
      print $result;
  }
  
  sub build_up_return {
      my $return = failure;
      
      if ( ! foo() ) {
          $return->string("Can't foo!");
          return $return;
      }
      
      if ( ! bar() ) {
          $return->string("Can't bar");
          $return->prop(failures => \@bars);
          return $return;
      }
      
      # we're okay if we made it this far.
      $return++;
      return $return; # success!
  }

=head1 DESCRIPTION

Polymorphic return values are really useful. Often, we just want to know
if something worked or not. Other times, we'd like to know what the error
text was. Still others, we may want to know what the error code was, and
what the error properties were. We don't want to handle objects or
data structures for every single return value, but we do want to check
error conditions in our code because that's what good programmers do.

When functions are successful they may return true, or perhaps some useful
data. In the quest to provide consistent return values, this gets confusing
between complex, informational errors and successful return values.

This module provides these features with a simple API that should get you
what you're looking for in each contex a return value is used in.

=head2 Functions

The functional interface is highly recommended for use within functions
that are using C<Return::Value>s.

=over 4

=item success

=cut

sub success {
    my ($string, @args) = @_;
    return __PACKAGE__->new(string => $string, bool => 1, @args);
}

=pod

=item failure

=cut

sub failure {
    my ($string, @args) = @_;
    return __PACKAGE__->new(string => $string, bool => 0, @args);
}

=pod

=back

=head2 Methods

The object API is useful in code that is catching C<Return::Value> objects.

=over 4

=item new

  my $return = Return::Value->new(
      bool   => 0,
      string => "YOU FAIL",
      prop   => {
          failed_objects => \@objects,
      },
  );

Creates a new C<Return::Value> object. You can set the following
options.

C<bool>, the boolean representation of the result. Defaults to
false.

C<errno>, the error number. Defaults to C<1> or C<0> based on the
value of C<bool>.

C<string>, the string representation of the result.

C<data>, data associated with the result, usually for success.

C<prop>, properties assigned to the result.

=cut

sub new {
    my ($class, %args) = @_;
    my $self = {};
    $self->{bool}   = ($args{bool} ? 1 : 0 );
    $self->{errno}  = $args{errno} || ($self->{bool} ? 1 : 0);
    $self->{string} = (defined $args{string} ? $args{string} : '');
    $self->{data}   = $args{data};
    $self->{prop}   = $args{prop} || {};
    return bless $self, $class;
}

=pod

=item bool

  print "it worked" if $result->bool;

Returns a boolean describing the result as success or failure.

=item errno

  print "it worked" if $result->errno == 0;

Returns an errno for the result.

=item string

  print $result->string unless $result->bool;

Returns a boolean describing the result as success or failure.

=item data

  if ( $result->bool ) {
      my $data = $result->data;
      print foreach @{$data};
  }

Returns the data structure passed to it.

=item prop

  printf "%s: %s',
    $result->string, join ' ', @{$result->prop('strings')}
      unless $result->bool;

Returns the return value's properties. Accepts the name of
a property retured, or returns the properties hash reference
if given no name.

=cut

foreach my $name ( qw[bool errno string data] ) {
    no strict 'refs';
    *{$name} = sub {
        my ($self, $value) = @_;
        return $self->{$name} unless @_ > 1;
        return $self->{$name} = $value;
    };
}
sub prop   {
    my ($self, $name, $value) = @_;
    return $self->{prop}          unless $name;
    return $self->{prop}->{$name} unless @_ > 2;
    return $self->{prop}->{$name} = $value;
}

=pod

=back

=head2 Overloading

Several operators are overloaded for C<Return::Value> objects. They are
listed here.

=over 4

=item Stringify

  print "$result\n";

Stringifies to the C<string> representation.

=item Boolean

  print $result unless $result;

Returns the C<bool> representation.

=item Numeric

Also returns the C<bool> value.

=cut

use overload '""'   => sub { shift->string },
             'bool' => sub { shift->bool ? 1 : undef },
             '=='   => sub { shift->bool   == shift },
             '!='   => sub { shift->bool   != shift },
             '>'    => sub { shift->bool   >  shift },
             '<'    => sub { shift->bool   <  shift },
             'eq'   => sub { shift->string == shift },
             'ne'   => sub { shift->string != shift },
             'gt'   => sub { shift->string >  shift },
             'lt'   => sub { shift->string <  shift },
             '++'   => sub { shift->bool(1) },
             '--'   => sub { shift->bool(0) },
             fallback => 1;

=pod

=back

=cut

1;

__END__
