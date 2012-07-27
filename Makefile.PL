use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME                => 'Functional::Iterator',
	AUTHOR              => q{Belden Lyman <belden@shutterstock.com>},
	VERSION_FROM        => 'lib/Functional/Iterator.pm',
	ABSTRACT            => 'Generic iterator object for functional programming',
	LICENSE => 'perl',
	PL_FILES            => {},
	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
