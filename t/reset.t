#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use lib grep { -d } qw(./lib ../lib ./t/lib);

use Functional::Iterator;

subtest 'record' => sub {

    my $container = iterator( records => [1] );

    is( $container->next, 1,     "iterator value" );
    is( $container->next, undef, "exhausted" );
    $container->reset;
    is( $container->next, 1, "iterator reset properly" );

};

subtest 'generator' => sub {

    my $value = 1;

    my $container = iterator(
        generator => sub {
            return $value > 1 ? undef : $value++;
        },
        reset => sub {
            $value = 1;
        } );

    is( $container->next, 1,     "iterator value" );
    is( $container->next, undef, "exhausted" );
    $container->reset;
    is( $container->next, 1, "iterator reset properly" );

};

done_testing;
