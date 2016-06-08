use 5.008005;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME           => 'URI::Encode::XS',
    VERSION_FROM   => 'lib/URI/Encode/XS.pm',
    PREREQ_PM      => { 'Test::More' => 0, 'Exporter' => '5.57' },
    ABSTRACT_FROM  => 'lib/URI/Encode/XS.pm',
    AUTHOR         => 'David Farrell',
    LIBS           => [''],
    DEFINE         => '',
    INC            => '-I.',
    LICENSE        => 'freebsd',
);
