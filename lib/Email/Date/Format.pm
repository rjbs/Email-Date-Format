use v5.12.0;
use warnings;
package Email::Date::Format;
# ABSTRACT: produce RFC 2822 date strings

our @EXPORT_OK = qw[email_date email_gmdate];

use Exporter 5.57 'import';
use Time::Local 1.27 ();

=head1 SYNOPSIS

  use Email::Date::Format qw(email_date);

  my $header = email_date($date->epoch);

  Email::Simple->create(
    header => [
      Date => $header,
    ],
    body => '...',
  );

=head1 DESCRIPTION

This module provides a simple means for generating an RFC 2822 compliant
datetime string.  (In case you care, they're not RFC 822 dates, because they
use a four digit year, which is not allowed in RFC 822.)

=func email_date

  my $date = email_date; # now
  my $date = email_date( time - 60*60 ); # one hour ago

C<email_date> accepts an epoch value, such as the one returned by C<time>.
It returns a string representing the date and time of the input, as
specified in RFC 2822. If no input value is provided, the current value
of C<time> is used.

C<email_date> is exported only if requested.

=func email_gmdate

  my $date = email_gmdate;

C<email_gmdate> is identical to C<email_date>, but it will return a string
indicating the time in Greenwich Mean Time, rather than local time.

C<email_gmdate> is exported only if requested.

=cut

sub _tz_diff {
  my ($time) = @_;

  my @localtime = localtime $time;
  my @gmtime    = gmtime    $time;
  $localtime[5] += 1900;
  $gmtime[5]    += 1900;
  my $diff  =   Time::Local::timegm_modern(@localtime)
              - Time::Local::timegm_modern(@gmtime);

  my $direc = $diff < 0 ? '-' : '+';
  $diff  = abs $diff;
  my $tz_hr = int( $diff / 3600 );
  my $tz_mi = int( $diff / 60 - $tz_hr * 60 );

  return ($direc, $tz_hr, $tz_mi);
}

sub _format_date {
  my ($local) = @_;

  sub {
    my ($time) = @_;
    $time //= time;

    my ($sec, $min, $hour, $mday, $mon, $year, $wday)
      = $local ? (localtime $time) : (gmtime $time);

    my $day   = (qw[Sun Mon Tue Wed Thu Fri Sat])[$wday];
    my $month = (qw[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec])[$mon];
    $year += 1900;

    my ($direc, $tz_hr, $tz_mi) = $local ? _tz_diff($time)
      : ('+', 0, 0);

    sprintf "%s, %d %s %d %02d:%02d:%02d %s%02d%02d",
            $day, $mday, $month, $year, $hour, $min, $sec, $direc, $tz_hr, $tz_mi;
  }
}

BEGIN {
  *email_date   = _format_date(1);
  *email_gmdate = _format_date(0);
};

1;
