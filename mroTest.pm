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

use Data::Dumper;

package MyBaseClass {

    sub my_base_class_method_one {
    }

}

package MyBaseClass::ChildClassOne {
MyBaseClass->import;
    sub child_class_one_method_one {
    }

    sub child_class_one_method_two {
    }

}

package MyBaseClass::ChildClassTwo {
MyBaseClass->import;
    sub child_class_two_method_one {
    }

    sub child_class_two_method_two {
    }

}

package MyBaseClass::UglyDuckling {
MyBaseClass->import;
    sub ugly_duckling_method_one {
    }

    sub ugly_duckling_method_two {
    }

}

package MyDiffBaseClass::ChildClassOne {

    sub diff_child_class_one_method_one {
    }

    sub diff_child_class_one_method_two {
    }

}

package UnrelatedClass {

    sub unrelated_class_method_one {
    }

    sub unrelated_class_method_two {
    }

}

say 'List of child classes:';
say $ARG for @{ mro::get_linear_isa('MyBaseClass') };

1;
