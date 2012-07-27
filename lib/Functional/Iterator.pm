package Functional::Iterator;
use base qw(Exporter);

use strict;
use warnings;

our @EXPORT = qw(iterator);

our $VERSION = 1.04;

sub iterator { __PACKAGE__->new(@_) }

sub new {
	my ($class, %args) = @_;
	return bless +{
		%args,
		index => 0,
	}, $class;
}

sub next {
	my ($self) = @_;

	my $record;
	my $index = $self->{index};

	if (exists $self->{generator}) {
		$record = $self->{generator}->();
	} else {
		$record = $self->{records}[$index];
	}

	if (UNIVERSAL::isa($record, ref($self))) {
		$record = $record->next;
		if (! defined($record)) {
			if (exists $self->{records}[$index + 1]) {
				$self->{index}++;
				return $self->next;
			} else {
				return undef;
			}
		}
	} else {
		$self->{index}++;
	}
	return undef unless defined $record;

	return $self->{mutator}
		?	$self->{mutator}->($record)
		: $record;
}

sub reset {
	my ($self) = @_;
	$self->{index} = 0;
	foreach (grep { UNIVERSAL::isa($_, __PACKAGE__) } @{$self->{records}}) {
		$_->reset;
	}
}

1;

__END__

=pod

=head1

Functional::Iterator - A generic iterator

=head1 SYNOPSIS

A naive example is just to turn a list into an iterable:

  use Functional::Iterator;

  my $iterator = iterator(records => [1..10]);

  while (my $rec = $iterator->next) {
    print "$rec\n";
  }

Iterators are set up either with a set of records, or with a generator. When a set of records
is provided, calling ->next on the iterator will simply walk through the set from beginning
to end, returning one value at a time. When a generator is provided, it will be called to
produce values. Generators signal they are finished by returning undef.

An iterator may encapsulate other iterators. The outer iterator may get its iterators either
as records, or by having a generator which produces iterators.

Iterators may have a mutator as well. When a mutator is provided, calling ->next on the iterator
will first select the next value (either by walking the given list of records, or by asking
the generator to produce one) and will then pass the value into the mutator. The caller of
$iterator->next gets the mutator's return value.

You can combine these qualities to slightly interesting effect:

  use Functional::Iterator;

  my $numbers = iterator(
    records => [1..10],
    mutator => sub { shift() + 100 },
  );

  my $letter = 'a';
  my $letters = iterator(
    generator => sub {
      my $ret = $letter++;
      $ret = undef if $ret eq 'z';
      return $ret;
    }
  );

  my $numbers_and_letters = iterator(
    records => [$numbers, $letters],
  );

  while (my $rec = $numbers_and_letters->next) {
    print "$rec\n";
  }

=head1 EXPORTS

=over 4

=item * iterator (records => \@records)

=item * iterator (records => \@records, mutator => \&mutator)

=item * iterator (generator => \&generator)

=item * iterator (generator => \&generator, mutator => \&mutator)

Helper function for creating iterator objects. If both a generator and records are provided,
only the generator is considered.

=back

=head1 METHODS

=over 4

=item * ->next()

Return the next value in this iterator.

=item * ->reset()

Rewind this iterator, and any sub-iterators, back to the beginning of their records. ->reset is
currently meaningless to iterators built around generators.

=item * ->new()

If you really want to create your iterators like this, you certainly may:

  # see C<iterator()> for the full set of arguments you may pass to ->new
  my $iterator = Functional::Iterator->new(records => \@records);

=back

=head1 LIMITATIONS

Currently the iterators are assumed to be consumed in a while loop. There's no technical reason
not to allow iteration via a C-style C<for> loop; I simply haven't needed that yet.

=head1 AUTHOR

Belden Lyman <belden@shutterstock.com>

=head1 LICENSE AND COPYRIGHT

(c) 2012 Shutterstock.com

This is free software; you may modify, use, and redistribute it under the same terms as Perl itself.

=head1 BUGS

Please report to the author.

=cut
