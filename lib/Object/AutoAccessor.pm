package Object::AutoAccessor;

require 5.004;
use strict;
use Carp;		# require 5.004

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $AUTOLOAD %default_options);

require Exporter;
@ISA			= qw(Exporter);
@EXPORT			= qw(param as_hashref);
%EXPORT_TAGS	= ();
@EXPORT_OK		= ( map { @{$EXPORT_TAGS{$_}} } keys %EXPORT_TAGS );
{
	my %seen;
	push @{$EXPORT_TAGS{all}}, grep {!$seen{$_}++} @{$EXPORT_TAGS{$_}} for keys %EXPORT_TAGS;
}

$VERSION = '0.02';

%default_options = (
	params			=> undef,
	autoload		=> 1,			# default: 1(use AUTOLOAD) or 0(or '' or undef)
	bindstyle		=> 'normal',	# default: 'normal'(undef), or 'sql'
);

sub new {
	my $obj = CORE::shift;
	my $class = CORE::ref($obj) || $obj || __PACKAGE__;
	
	unless (@_ % 2 == 0) {
		croak "Odd number of argumentes for $class->new()";
	}
	
	my %args = @_;
	my %options = ();
	$options{$_} = $default_options{$_} for keys %default_options;
	$options{$_} = $args{$_}            for keys %args;
	
	my $self = bless {%options}, $class;
	$self->_initialize();
	$self;
}

# abstract
sub _initialize { shift }

sub renew {
	my $obj = CORE::shift;
	my $class = CORE::ref($obj) || $obj || __PACKAGE__;
	
	unless (@_ % 2 == 0) {
		croak "Odd number of argumentes for $class->renew()";
	}
	
	my %options = @_;
	if (CORE::ref($obj) and UNIVERSAL::isa($obj, __PACKAGE__)) {
		%options = map { $_ => $obj->{$_} } grep !/^params$/, keys %$obj;
	}
	
	my $self = $class->new(%options);
	$self;
}

sub is_hashref {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->is_hashref()";
	
	return CORE::ref($self->{params}->{$label}) eq 'HASH';
}

sub is_arrayref {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->is_arrayref()";
	
	return CORE::ref($self->{params}->{$label}) eq 'ARRAY';
}

sub is_coderef {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->is_coderef()";
	
	return CORE::ref($self->{params}->{$label}) eq 'CODE';
}

sub is_globref {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->is_globref()";
	
	return CORE::ref($self->{params}->{$label}) eq 'GLOB';
}

sub is_scalar {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->is_globref()";
	
	return !CORE::ref($self->{params}->{$label});
}

sub is_child {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->is_child()";
	
	return (CORE::ref($self->{params}->{$label}) and UNIVERSAL::isa($self->{params}->{$label}, __PACKAGE__));
}

sub ref {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->ref()";
	
	return CORE::ref($self->{params}->{$label});
}

sub chomp {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->chomp()";
	
	if ($self->is_arrayref($label)) {
		return CORE::chomp(@{ $self->{params}->{$label} });
	}
	elsif ($self->is_scalar($label)) {
		return CORE::chomp($self->{params}->{$label});
	}
	else {
		;
	}
}

sub chop {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->chop()";
	
	if ($self->is_arrayref($label)) {
		return CORE::chop(@{ $self->{params}->{$label} });
	}
	elsif ($self->is_scalar($label)) {
		return CORE::chop($self->{params}->{$label});
	}
	else {
		;
	}
}

sub lc {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->lc()";
	
	return CORE::lc($self->{params}->{$label});
}

sub lcfirst {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->lcfirst()";
	
	return CORE::lcfirst($self->{params}->{$label});
}

sub uc {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->uc()";
	
	return CORE::uc($self->{params}->{$label});
}

sub ucfirst {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->ucfirst()";
	
	return CORE::ucfirst($self->{params}->{$label});
}

sub join {
	my $self = CORE::shift;
	my $joinstr = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->join()";
	
	return CORE::join($joinstr, @{ $self->{params}->{$label} });
}

sub keys {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->keys()";
	
	return CORE::keys %{ $self->{params}->{$label} };
}

sub values {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->values()";
	
	return CORE::values %{ $self->{params}->{$label} };
}

sub each {
	my $self = CORE::shift;
	my $label = CORE::shift or croak "Not enough arguments for " . CORE::ref($self) . "->each()";
	
	return CORE::each %{ $self->{params}->{$label} };
}

sub bindstyle {
	my $self = shift;
	$self->{bindstyle} = shift if (@_ > 0);
	$self->{bindstyle};
}

sub bind {
	my $self = CORE::shift;
	my $label = CORE::shift;
	
	croak CORE::ref($self) . "->bind('$label', ...) is not a scalar variable" if $self->ref($label);
	
	if (@_ >= 1) {
		my @binds = @_;
		my $binds_num = scalar @binds;
		my $value = $self->param($label);
		
		# placeholder match
		my @q_num = ($value =~ /(?<!\\)(\?)/g);
		my $q_num = scalar @q_num;
		croak CORE::ref($self) . "->bind('$label', ...) placeholder missmatch ($q_num placeholders, $binds_num binds)" unless ($q_num == $binds_num);
		
		# closure
		my $_shift = sub {
			my $q = shift;
			if ($q eq '\?') {
				return '?';
			}
			elsif ($q eq '?') {
				if ($self->{bindstyle} =~ /^sql$/i) {
					my $val = CORE::shift @binds;
					if ($val =~ /^[+-]?\d+(?:\.\d+)?$/) {
						return $val;
					}
					else {
						$val =~ s/'/''/g;
						return "'$val'";
					}
				}
				else {
					return CORE::shift @binds;
				}
			}
			else {
				# never comes here
				return $q;
			}
		};
		
		{
			local($^W) = 0;
			$value =~ s/(\\?\?)/$_shift->($1)/eg;
		}
		return $value;
	}
	else {
		return $self->param($label);
	}
}

sub sprintf {
	my $self = CORE::shift;
	my $label = CORE::shift;
	
	croak CORE::ref($self) . "->sprintf('$label', ...) is not a scalar variable" if $self->ref($label);
	
	if (@_ >= 1) {
		return CORE::sprintf($self->param($label), @_);
	}
	else {
		return $self->param($label);
	}
}

sub defined {
	my $self = CORE::shift;
	my $param = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->defined()";
	
	return CORE::defined($self->{params}->{$param});
}

sub exists {
	my $self = CORE::shift;
	my $param = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->exists()";
	
	return CORE::exists($self->{params}->{$param});
}

sub shift {
	my $self = CORE::shift;
	my $param = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->shift()";
	
	return CORE::shift(@{ $self->{params}->{$param} });
}

sub unshift {
	my $self = CORE::shift;
	my $param = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->unshift()";
	my $value = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->unshift()";
	
	return CORE::unshift(@{ $self->{params}->{$param} } => $value);
}

sub pop {
	my $self = CORE::shift;
	my $param = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->pop()";
	
	return CORE::pop(@{ $self->{params}->{$param} });
}

sub push {
	my $self = CORE::shift;
	my $param = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->push()";
	my $value = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->push()";
	
	return CORE::push(@{ $self->{params}->{$param} } => $value);
}

sub delete {
	my $self = CORE::shift;
	my $param = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->delete()";
	
	return CORE::delete($self->{params}->{$param});
}

sub undef {
	my $self = CORE::shift;
	my $param = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->undef()";
	
	return CORE::undef($self->{params}->{$param});
}

sub length {
	my $self = CORE::shift;
	my $param = CORE::shift || croak "Not enough arguments for " . CORE::ref($self) . "->length()";
	
	return CORE::length($self->{params}->{$param});
}

sub param {
	my $self = CORE::shift;
	
	if (@_ == 0) {
		return
			grep {
				!(
					CORE::ref($self->{params}->{$_})
					and UNIVERSAL::isa($self->{params}->{$_}, __PACKAGE__)
				)
			}
			CORE::keys(%{ $self->{params} });
	}
	
	my $first = CORE::shift;
	
	if (@_ > 0) {
		croak "Odd number of argumentes for " . CORE::ref($self) . "->param()" unless ((@_ % 2) == 1);
		
		my %hash = ($first,@_);
		
		for my $key (CORE::keys %hash) {
			my $ref = ( CORE::ref $hash{$key} );
			
			if ($ref eq 'HASH') {
				%{ $self->{params}->{$key} } = %{ $hash{$key} };
			}
			elsif ($ref eq 'ARRAY') {
				@{ $self->{params}->{$key} } = @{ $hash{$key} };
			}
			elsif ($ref eq 'SCALAR') {
				$self->{params}->{$key} = $hash{$key};
			}
			else {
				$self->{params}->{$key} = $hash{$key};
			}
		}
		
	}
	else {
		if (CORE::ref($self->{params}->{$first}) and UNIVERSAL::isa($self->{params}->{$first}, __PACKAGE__)) {
			return undef;
		}
		
		my $type = ( CORE::ref $self->{params}->{$first} );
		
		if ($type eq 'HASH') {
			return \%{ $self->{params}->{$first} };
		}
		elsif ($type eq 'ARRAY') {
			return \@{ $self->{params}->{$first} };
		}
		elsif ($type eq 'SCALAR') {
			return $self->{params}->{$first};
		}
		else { # CODEREF, IO, GLOB, OBJECT
			return $self->{params}->{$first};
		}
	}
}

sub as_hashref {
	my $self = CORE::shift;
	return $self->{params};
}

sub AUTOLOAD {
	my $self = CORE::shift;
	
	return if $AUTOLOAD =~ /::DESTROY$/;
	
	my ($method) = ($AUTOLOAD =~ /.*::(.*?)$/);
	
	if ( $self->{autoload} ) {
		if ( $self->can( $method ) ) {
			return $self->$method( @_ );
		}
		elsif ($method =~ /^([sg]et_)(.*)$/) {
			my($prefix, $name) = ($1, $2);
			if ($prefix eq 'set_') {
				return $self->param($name => @_);
			}
			else {
				carp "Too many arguments for " . CORE::ref($self) . "->get_$name\()" if @_ > 0;
				return $self->param($name);
			}
		}
		else {
			return $self->param($method => @_);
		}
	}
	else {
		croak "ERROR: " . CORE::ref($self) . "->$method\() : this method is not implimented";
	}
	
	return;
}

sub DESTROY {}

1;
__END__

=head1 NAME

Object::AutoAccessor - Accessor class by using AUTOLOAD

=head1 SYNOPSIS

  use Object::AutoAccessor;
  
  my $obj = Object::AutoAccessor->new();
  
  # setter methods
  $obj->foo('bar');
  $obj->set_foo('bar');
  $obj->param(foo => 'bar');
  
  # getter methods
  $obj->foo();
  $obj->get_foo();
  $obj->param('foo');
  
  # set/get array
  $obj->array([qw(foo bar)]);
  $obj->push(array => 'baz');
  my $baz = $obj->pop('array');
  my $foobar = $obj->join(',', 'array'); # got 'foo,bar'
  
  # set/get hash
  $obj->hash(+{ foo => 'fooval', bar => 'barval' });
  my $hashref = $obj->hash;
  my @keys = $obj->keys('hash');
  my @values = $obj->values('hash');
  my ($key, $val) = $obj->each('hash');
  
  # set/get coderef
  $obj->code(sub { print "CODEREF\n" });
  my $code = $obj->code;
  $code->();
  
  # set/get globref
  $obj->glob(\*STDOUT);
  my $glob = $obj->glob;
  print $glob "Hello\n";
  
  # is_hashref/arrayref/coderef/globref/scalar
  $obj->is_hashref('hash');
  $obj->is_arrayref('array');
  $obj->is_coderef('code');
  $obj->is_globref('glob');
  $obj->is_scalar('foo');
  
  # $obj->param() is compatible with HTML::Template->param()
  my @keywords = $obj->param();
  my $val = $obj->param('hash');
  $obj->param(key => 'val');

=head1 DESCRIPTION

Object::AutoAccessor is a Accessor class to get/set values by
AUTOLOADed method automatically, and also can use various methods of
the same name as built-in functions such as push() , pop() , each() ,
join() , length() , sprintf() and so on.
Moreover, param() is compatible with C<HTML::Template> module,
so you can use Object::AutoAccessor object for C<HTML::Template>'s
C<associate> option.

=head1 METHODS

=over 4

=item new ( [ OPTIONS ] )

Create a new Object::AutoAccessor object. Then you can use several options to
control object's behavior.

=over 4

=item * autoload

If set to 0, the object cannot use the AUTOLOADed-accessor-method such as
foo() , set_foo() and get_foo() but param() .
Defaults to 1.

=item * bindstyle

If set to 'sql', behavior of bind() method changes into SQL-style-quoting.
Defaults to 'normal' or undef.

=back

=item renew ( [ OPTIONS ] )

Create a new Object::AutoAccessor object to remaining current options.

=item KEY ( [ VALUE ] )

This method provides an accessor that methodname is same as keyname
by using AUTOLOAD mechanism.

  # setter methods
  $obj->foo('bar');
  $obj->set_foo('bar');
  $obj->param(foo => 'bar');
  
  # getter methods
  $obj->foo();
  $obj->get_foo();
  $obj->param('foo');

=item param ( [ KEY => VALUE, ... ] )

This method is compatible with param() method of HTML::Template module.

  # set value
  $obj->param(foo => 'bar');
  $obj->param(
    foo => 'bar',
    bar => [qw(1 2 3)],
    baz => { one => 1, two => 2, three => 3 }
  );
  
  # get value
  $obj->param('foo'); # got 'bar'
  
  # get list keys of parameters
  @keys = $obj->param();

=item bind ( KEY, BIND )

This method provides a simple replacing mechanism that changes I<placeholder>
to bindings just looks like execute() method of DBI.

  $obj->sentence(q{What is the ? ? in ?\?});
  
  # $result is "What is the highest mountain in Japan?"
  $result = $obj->bind(sentence => qw(highest mountain Japan));

=item bindstyle ( STYLE )

If you want SQL-style-quoting, use bindstyle() and set value 'sql'.

  @binds = ('bar' "It's OK" '-0.123');
  $obj->bindstyle('sql');
  $obj->statement(q{SELECT * FROM foo WHERE BAR = ? AND BAZ = ? AND DECIMAL = ?});
  
  # $result is "SELECT * FROM foo WHERE BAR = 'bar' AND BAZ = 'It''s OK' AND DECIMAL = -0.123"
  $result = $obj->bind(statement => @binds);

=item as_hashref ()

As shown in name. :)

=back

=head1 AUTHOR

Copyright 2005 Michiya Honda, E<lt>pia@cpan.orgE<gt> All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTML::Template>.

=cut
