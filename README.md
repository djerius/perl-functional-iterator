perl-Functional-Iterator
========================

Functional::Iterator - a generic iterator

SYNOPSIS
========

A naive example is just to turn a list into an iterable:

```perl
  use Functional::Iterator;

  my $iterator = iterator(records => [1..10]);

  while (my $rec = $iterator->next) {
    print "$rec\n";
  }
```

Iterators are set up either with a set of records, or with a generator.
When a set of records is provided, calling ->next on the iterator will
simply walk through the set from beginning to end, returning one value
at a time. When a generator is provided, it will be called to produce
values. Generators signal they are finished by returning undef.

An iterator may encapsulate other iterators. The outer iterator may get
its iterators either as records, or by having a generator which pro-
duces iterators.

Iterators may have a mutator as well. When a mutator is provided, call-
ing ->next on the iterator will first select the next value (either by
walking the given list of records, or by asking the generator to pro-
duce one) and will then pass the value into the mutator. The caller of
$iterator->next gets the mutator’s return value.

You can combine these qualities to slightly interesting effect:

```perl
  use Functional::Iterator;

  my $numbers = iterator(
    records => [1..10],
    mutator => sub { shift() + 100 },
  );

  my $letter = ’a’;
  my $letters = iterator(
    generator => sub {
      my $ret = $letter++;
      $ret = undef if $ret eq ’z’;
      return $ret;
    }
  );

  my $numbers_and_letters = iterator(
    records => [$numbers, $letters],
  );

  while (my $rec = $numbers_and_letters->next) {
    print "$rec\n";
  }
```

EXPORTS
=======

  * iterator (records => \@records)
  * iterator (records => \@records, mutator => \&mutator)
  * iterator (generator => \&generator)
  * iterator (generator => \&generator, mutator => \&mutator)
      Helper function for creating iterator objects. If both a generator
      and records are provided, only the generator is considered.

METHODS
=======

  * ->next()
      Return the next value in this iterator.

  * ->reset()
      Rewind this iterator, and any sub-iterators, back to the beginning
      of their records. ->reset is currently meaningless to iterators
      built around generators.

  * ->new()
      If you really want to create your iterators like this, you cer-
      tainly may:

```perl
  # see iterator() for the full set of arguments you may pass to ->new
  my $iterator = Functional::Iterator->new(records => \@records);
```

LIMITATIONS
===========

Currently the iterators are assumed to be consumed in a while loop.
There’s no technical reason not to allow iteration via a C-style "for"
loop; I simply haven’t needed that yet.

AUTHOR
======

Belden Lyman <belden@shutterstock.com>

LICENSE AND COPYRIGHT
=====================

(c) 2012 Shutterstock.com

This is free software; you may modify, use, and redistribute it under
the same terms as Perl itself.

BUGS
====

Please report to the author.
