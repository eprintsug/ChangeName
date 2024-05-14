#!/usr/bin/env perl

package TestLoop v1.0.0;

use     strict;
use     warnings;

use     v5.16;
#use     feature 'signatures'; # Not activated by default until the "use v5.36" feature bundle. Only available from Perl 5.20 onwards.
use     utf8;
use     English;

use     Data::Dumper;
$Data::Dumper::Useperl = 1;

use     open ':std',   ':encoding(UTF-8)';

#UTF-8 the default on standard input and output:
my  $our_encoding                       =   ':encoding(UTF-8)';
binmode STDIN                           ,   $our_encoding;
binmode STDOUT                          ,   $our_encoding;
binmode STDERR                          ,   $our_encoding;
$ENV{'PERL_UNICODE'}                    =   'AS';   # A = Expect @ARGV values to be UTF-8 strings.
                                                    # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.

TestLoop->start(@ARGV) unless caller;


sub start {

    my  $class      =   shift;
    my  $max        =   10;
    for my $number (0..100) {
        say $number;
#        for my $inner_number ($offset..$max) {
 #       }
        say $number += 2; # Will 0 jump by 2 digits, skipping 1?
    };

}

1;



__END__
