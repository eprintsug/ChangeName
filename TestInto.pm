#!/usr/bin/env perl

# Used throughout:
use     strict;
use     warnings;
use     v5.16;
use     utf8;

# Global Encoding Settings:
my      $encoding_layer;

BEGIN {
    my  $encoding_to_use    =   'UTF-8';
        
    $encoding_layer         =   ":encoding($encoding_to_use)";
};

use     open ':std'         ,   "$encoding_layer";  # :std affect is global.
$ENV{'PERL_UNICODE'}        =   'AS';               # A = Expect @ARGV values to be UTF-8 strings.
                                                    # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.
                                                    # ENV settings are global for current thread and any forked processes.
#Set default on standard input, output, and error:
binmode STDIN,  $encoding_layer;
binmode STDOUT, $encoding_layer;
binmode STDERR, $encoding_layer;

package ChangeNameOperation v1.0.0 {

    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.
#    use     utf8;
                                    
    use Data::Dumper;   # Dumper works when local.
    
    print Dumper('what');
    #local $baz = 9;	# Strict works!
    #my $x = "2:" + 3; # Warnings works!
    say "Hello!".$PERL_VERSION; # English works
    my $é = 'test'; # utf8 works.
    1;
    my  @input_layers =   PerlIO::get_layers(STDIN, details => 1);
    say 'Input: ';
    say join "\n", @input_layers;

    my  @output_layers =   PerlIO::get_layers(STDOUT, details => 1);
    say 'Output: ';
    say join "\n", @output_layers;

    my  @error_layers =   PerlIO::get_layers(STDERR, details => 1);
    say 'Error Layers: ';
    say join "\n", @error_layers;


}; # ChangeNameOperation Package.


