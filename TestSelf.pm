#!/usr/bin/env perl

package TestSelf v1.0.0;

use     strict;
use     warnings;

use     lib '/opt/eprints3/perl_lib';
use     EPrints;
use     EPrints::Repository;
use     EPrints::Search;

use     v5.16;
#use     feature 'signatures'; # Not activated by default until the "use v5.36" feature bundle. Only available from Perl 5.20 onwards.
use     utf8;
use     English;

use     Encode;
use     Data::Dumper;
$Data::Dumper::Useperl = 1;
use     List::Util  qw(
            pairmap
            mesh
        );
use     Getopt::Long;

use     open ':std',   ':encoding(UTF-8)';

#UTF-8 the default on standard input and output:
my  $our_encoding                       =   ':encoding(UTF-8)';
binmode STDIN                           ,   $our_encoding;
binmode STDOUT                          ,   $our_encoding;
binmode STDERR                          ,   $our_encoding;
$ENV{'PERL_UNICODE'}                    =   'AS';   # A = Expect @ARGV values to be UTF-8 strings.
                                                    # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.

TestSelf->start(@ARGV) unless caller;

sub utf8_input_check {

    # Imported from encoding_change and needs to be improved...
    my $self = shift;
    if (@ARG) {

        # Definition:
        my  $acceptable_utf8_options    =   (${^UNICODE} >= '39')
                                            &&
                                            (${^UNICODE} <= '63');


        if ($acceptable_utf8_options) {
            say 'UTF-8 commandline arguments enabled.';
        }
        else {
            say 'UTF-8 commandline arguments do not appear to be enabled.';
            say '';
            say 'To enable UTF-8 arguments,';
            say 'please run the script again with, for example, -CAS after perl as such...';
            say '';
            say '    perl -CAS TestSelf.pm';
            say '';
            say 'To learn more,';
            say 'you can view https://perldoc.perl.org/perlrun#-C-%5Bnumber/list%5D';
            say 'or run...';
            say '';
            say '    perldoc perlrun';
            say '';
            say '...and scroll to the Command Switches section,';
            say 'and read the -C switch section within that.';
        };

    }
    else {
        say 'No arguments.';
    }

};

sub start {

    my  $class      =   shift;

    $class->utf8_input_check(@ARG);

    my  @params     =   (
        archive_id  =>  shift,
        find        =>  shift,
        replace     =>  shift,
        part        =>  shift,
    );
                    
    TestSelf->new(@params)->search->display->confirm->change->finish;

}

sub new {
    my  $class      =   shift;
    my  $params     =   {@ARG};
    my  $self       =   {find => 'default',};
    
    bless $self, $class;

    say 'Called new method.';
    say Dumper($self);

    $self->_set_attributes($params);
    
    return $self;
}

sub _set_attributes {

    say 'Setting attributes.';

    # Set Initial Values:
    my  $self   =   shift;
    my  $params =   shift;
    my  @data   =   (

    );

    $self->%*   =   (
        $self->%*,
        $params->%*,
        new_key =>  'new value',
    );

#    $self->{data} = {
#        repository  =>  EPrints::Repository->new($archive_id),
#    }
    # Check Not

    return $self

}

sub _validate {
    my  $self                           =   shift;
    my  @input                          =   @_;
    
    # No longer seems to stop out of range input? Why?
    my  $matches_four_byte_character    =   qr/[\N{U+10000}-\N{U+7FFFFFFF}]/;
    
    for my $input (@input) {
        die                                 "This script does not support ".
                                            "four byte characters in input."
                                            if (
                                                $input
                                                && ($input =~ $matches_four_byte_character)
                                            );

    };
    
    return @input;
}

sub search {
    my  $self   =   shift;
    say "Called search method.";
    say Dumper($self);
    return $self;
}

sub display {
    my  $self   =   shift;
    say "Called display method.";
    return $self;
}

sub confirm {
    my  $self   =   shift;
    say "Called confirm method.";
    return $self;
}

sub change {
    my  $self   =   shift;
    say "Called change method.";
    return $self;
}

sub finish {
    my  $self   =   shift;
    say "At the finish. Thank you for using this test script.";
    return $self;
}

1;



__END__
