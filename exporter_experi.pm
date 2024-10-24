#!/usr/bin/env perl



# Used throughout:
use     strict;
use     warnings;
use     v5.16;
use     utf8;

# Global Encoding Settings:
my      $encoding_layer;

SET_ENCODING_LAYER_AT_COMPILE_TIME: BEGIN {
    my  $encoding_to_use                =   'UTF-8'; # Change this to desired encoding value.
        
    $encoding_layer                     =   ":encoding($encoding_to_use)";  # This is what actually gets used for the layer.
};

use     open ':std'                     ,   "$encoding_layer";  # :std affect is global.
binmode STDIN                           ,   $encoding_layer;
binmode STDOUT                          ,   $encoding_layer;
binmode STDERR                          ,   $encoding_layer;

$ENV{'PERL_UNICODE'}                    =   'AS';               # A = Expect @ARGV values to be UTF-8 strings.
                                                                # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.
                                                                # ENV settings are global for current thread and any forked processes.
                                                                 



package ChangeName::Utilities v1.0.0 {

    # Standard:
    use English qw(
            -no_match_vars
        );                      # Use full english names for special perl variables,
                                # except the regex match variables
                                # due to a performance if they are invoked,
                                # on Perl v5.18 or lower.

    # Specific:
    use Scalar::Util qw(
            blessed
            reftype
        );
    use Exporter qw(import);
    use Data::Dumper;

    our @EXPORT =   qw(
        validate_class
        valid_object
    );

    sub validate_class {
        my  ($self, $value, $acceptable_class)  =   @ARG;

        # OBJECT Validation:
        my  $valid_object                       =   _valid_object($self, $value);
        return                                      undef
                                                    unless $valid_object;

        # CLASS Validation:
        my  $valid_object_of_acceptable_class   =   $valid_object && $valid_object->isa($acceptable_class)? $valid_object:
                                                    undef;

        warn 'Not class' unless $valid_object_of_acceptable_class;

        return                                      $valid_object_of_acceptable_class;
    }
    
    sub _valid_object {

        my  ($self, $value) =   @ARG;

        my  $valid_object   =   (defined $value) && blessed($value)?    $value:
                                undef;
#warn 'self logger is...'.Dumper($self->logger);
        warn "Not valid" unless $valid_object;
#(die "enough".Dumper(caller(2))) unless $valid_object;
        return                  $valid_object;

    }
    
    sub valid_object {
        _valid_object(@ARG);
    }

}

package ChangeName::Log v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.

    # Specific:
    ChangeName::Utilities->import;
    use     Scalar::Util qw(
                blessed
                reftype
            );
    use     Data::Dumper;

    # Data Dumper Settings:
    $Data::Dumper::Maxdepth     =   4;  # So when we dump we don't get too much stuff.
    $Data::Dumper::Sortkeys     =   1;  # Hashes in same order each time - for easier dumper comparisons.
    $Data::Dumper::Useperl      =   1;  # Perl implementation will see Data Dumper adhere to our binmode settings.
    no warnings 'redefine';
    local *Data::Dumper::qquote =   sub { qq["${\(shift)}"] };  # For UTF-8 friendly dumping - see: https://stackoverflow.com/questions/50489062/
    use warnings 'redefine';
 
    sub log_hello {
                say "Hello world log!";
        shift->validate_class(undef => 'log Something');
    }
}; # ChangeName::Log Package.


package ChangeName::Operation v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance issue if they are invoked,
                                    # on Perl v5.18 or lower.

    # Specific:
    use     File::Basename; # Will use this to get the directory name that this file is in, when looking for yaml file.
    use     Getopt::Long;

    use     Scalar::Util qw(
                blessed
                reftype
            );
    ChangeName::Utilities->import;
    
    sub hello {
        say "Hello world!";
        shift->validate_class(undef => 'Something');
    }
    
    1;

}; # ChangeName::Operation Package.

ChangeName::Log->log_hello();
ChangeName::Operation->hello();