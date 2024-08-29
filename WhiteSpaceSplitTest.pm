#!/usr/bin/env perl

# Used throughout:
use     strict;
use     warnings;
use     v5.16;
use     utf8;
use     mro;
use     English;

# Global Encoding Settings:
my      $encoding_layer;
my      $eprints_perl_lib_path;
my      $global_path_to_eprints_perl_library; # Populated later 

SET_ENCODING_LAYER: BEGIN {
    my  $encoding_to_use        =   'UTF-8';
        $encoding_layer         =   ":encoding($encoding_to_use)";
};

use     open ':std'             ,   "$encoding_layer";  # :std affect is global.
$ENV{'PERL_UNICODE'}            =   'AS';               # A = Expect @ARGV values to be UTF-8 strings.
                                                        # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.
                                                        # ENV settings are global for current thread and any forked processes.
#Set default on standard input, output, and error:
binmode STDIN                   ,   $encoding_layer;
binmode STDOUT                  ,   $encoding_layer;
binmode STDERR                  ,   $encoding_layer;

say 'Can you label a begin?'.$encoding_layer; # We'll soon find out!

use     Data::Dumper;





package WhiteSpaceSplitTest {

    my @values =    split /[\p{White_Space}\p{Pattern_White_Space}]+/,
    '    test
    
    
          whatup whatup2 whatup3    whatup4
     
     
    whatup5';
    
    say Data::Dumper::Dumper(@values);

}

1;

__END__

# Data Dumper Settings:
$Data::Dumper::Maxdepth     =   4;  # So when we dump we don't get too much stuff.
$Data::Dumper::Sortkeys     =   1;  # Hashes in same order each time - for easier dumper comparisons.
$Data::Dumper::Useperl      =   1;  # Perl implementation will see Data Dumper adhere to our binmode settings.
no warnings 'redefine';
local *Data::Dumper::qquote =   sub { qq["${\(shift)}"] };  # For UTF-8 friendly dumping - see: https://stackoverflow.com/questions/50489062/
use warnings 'redefine';