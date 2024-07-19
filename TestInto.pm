#!/usr/bin/env perl

use     warnings;
use     v5.16; # 

package BoilerPlate::PragmasAndEncoding v1.0.0 {
    use     strict;
    use     warnings;
    use     utf8;                                       # This file in utf8.

    my      $encoding_layer;
    BEGIN {
        my  $encoding_to_use    =   'UTF-8';
            
        $encoding_layer         =   ":encoding($encoding_to_use)";
    };

    # Global (so not in the import subroutine):
    use     open ':std'         ,   "$encoding_layer";  # :std affect is global.
    $ENV{'PERL_UNICODE'}        =   'AS';               # A = Expect @ARGV values to be UTF-8 strings.
                                                        # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.
                                                        # ENV settings are global for current thread and any forked processes.

    sub import {

        # Processing / Declaring what Pragmas to import:
        $_->import for qw(
            strict
            warnings
            utf8
        );

        #Set default on standard input, output, and error:
        binmode STDIN,  $encoding_layer;
        binmode STDOUT, $encoding_layer;
        binmode STDERR, $encoding_layer;
    
    }
    
    # Protect subclasses using AUTOLOAD
    sub DESTROY { }
    
    1;

} # ChangeNameOperation::BoilerPlate::PragmaAndEncoding Package.

package ChangeNameOperation v1.0.0 {

    BoilerPlate::PragmasAndEncoding->import;
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.
                                    
    use Data::Dumper;
    
    print Dumper('what');
    #local $baz = 9;	# Strict works!
#    use warnings;
    my $x = "2:" + 3;
    say "Hello!".$PERL_VERSION;
    
    1;

}; # ChangeNameOperation Package.


