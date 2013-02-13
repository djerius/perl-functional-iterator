perl-functional-iterator
========================

NAME
====

Functional::Iterator - A generic iterator

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

A slightly more interesting example is to turn a paginated set of
results from some web API into a seemingly unlimited stream of data. In
one module you might write this:

```perl

    use REST::Consumer;
    use Functional::Iterator;

    sub fetch_popular_results {
        my @records;
        my $page = 0;

        my $client = REST::Consumer->new(host => 'somewhere-over-the-rainbow.com');

        my $generator = sub {
            if (!@records) {
                @records = $client->get(
                    path => '/search/popular',
                    params => [
                        page => $page++,
                        page_size => 100,
                    ],
                );
            }
            return shift @records;
        };

        return iterator(generator => $generator);
    }
```

And then elsewhere you might write this:

```perl
    my $fetcher = fetcher();
    while (my $record = $fetcher->next) {
        ...
    }
```

CREATING AN ITERATOR
====================

Iterators are set up either with a set of records, or with a generator.
When a set of records is provided, calling ->next on the iterator will
simply walk through the set from beginning to end, returning one value
at a time. When a generator is provided, it will be called to produce
values. Generators signal they are finished by returning undef.

An iterator may encapsulate other iterators. The outer iterator may get
its iterators either as records, or by having a generator which produces
iterators.

```perl
    my $inner = 5;
    my $limit = 10;

    my $container = iterator(
        generator => sub {
            if ($inner--) {
                return iterator(records => [1..$limit--]);
            }
        },
    );

    while (my $number = $container->next) {
        print $number . "\n";
    }
```

MUTATORS: CHANGE IT UP
======================

Iterators may have a mutator as well. When a mutator is provided,
calling `->next' on the iterator will first select the next value
(either by selecting the next item from a given list of records, or by
asking the generator to produce one) and will then pass the value into
the mutator. The caller of `->next' gets the mutator's return value.

You can combine these qualities to slightly interesting effect:

```perl
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
    of their records. ->reset is meaningless to iterators built around
    generators.

  * ->new()
    If you really want to create your iterators like this, you certainly
    may:

```perl
    # see C<iterator()> for the full set of arguments you may pass to ->new
    my $iterator = Functional::Iterator->new(records => \@records);
```

BUGS AND LIMITATIONS
====================

Please report any bugs or feature requests to this project's Github
page: http://github.com/belden/perl-functional-iterator/issues.

PROJECT HOME
============

This project is housed on Github, at
http://github.com/belden/perl-functional-iterator. You may submit pull
requests via Github.

COPYRIGHT AND LICENSE
=====================

    (c) 2013 Belden Lyman E<lt>belden@cpan.orgE<gt>

This library is free software: you may redistribute it and/or modify it
under the same terms as Perl itself; either Perl version 5.8.8 or, at
your option, any later version of Perl 5 you may have available.

