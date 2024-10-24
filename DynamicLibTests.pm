#!/usr/bin/env perl

# Used throughout:
use     strict;
use     warnings;
use     v5.16;
use     utf8;

# Global Encoding Settings:
my      $encoding_layer;
my      $eprints_perl_lib_path;
my      $global_path_to_eprints_perl_library; # Populated later 

BEGIN {
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

BEGIN {
package DoesIt v1.0.0 {

    DoesIt->run() unless caller;

    sub run {
            #$eprints_perl_lib_path  =   '/opt/eprints3/perl_lib';
    }

}
}


package FilePath {

    sub filepath {
        return '/opt/eprints3/perl_lib';
    }

}

package Config {
        use Getopt::Long;
    sub filepath {
        my  $class  =   shift;

        my $provided_filepath  =   undef;

        Getopt::Long::Parser->new->getoptionsfromarray(
            \@_,
            "config:s"      =>  \$provided_filepath
        );
        my $filepath           =   FilePath->filepath();
        
        return $provided_filepath?  $provided_filepath:
        $filepath;
    }
}

package DynamicLibTests v1.0.0 {

    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.
    my  $provided_filepath;
    my  $filepath;


    say $encoding_layer;
    use lib Config->filepath(@ARGV);
    use EPrints;
    say join "\n", @INC;
    say join "\n", @ARGV;
                                    
};

