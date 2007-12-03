use strict;
use ExtUtils::MakeMaker;

WriteMakefile (
  AUTHOR        => 'Ricardo SIGNES <rjbs@cpan.org>',
  ABSTRACT      => "produce RFC 8822 date strings",
  NAME          => 'Email::Date::Format',
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM     => {
    'Test::More'  => '0.47',  # core
    'Time::Local' => '0.000', # core
  },
  VERSION_FROM  => 'lib/Email/Date/Format.pm',
);
