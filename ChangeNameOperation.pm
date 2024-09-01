#!/usr/bin/env perl

=pod FILENAME

=encoding utf8

=head1 FILENAME

ChangeNameOperation.pm

=cut

=pod Synopsis, Description, Options

=head1 SYNOPSIS

    # Run file at the command line:
    perl -CAS ./ChangeNameOperation.pm

    # Run at the command line with arguments and flags:
    perl -CAS ./ChangeNameOperation.pm MyArchive bob Bobbi given --exact --verbose --live

=head1 FILE DESCRIPTION

A file containing multiple Perl packages,
that each help in an operation,
for changing the names associated with
an EPrint, within an EPrints repository.

The main body of the file itself,
sets global Perl settings,
such as the Perl version feature bundle to use,
and UTF-8 encoding globals,
before any embedded packages begin.

A C<BEGIN> block intervenes in load order,
to ensure language classes are loaded
before any packages that use
them.

After such language class loading,
the next package executed is then the first in the file
- the L</ChangeNameOperation> package.

=head1 ARGUMENTS

Considers the first four arguments provided at the commandline to be...

=over

=item 1

...an EPrints archive ID (C<MyArchive> in the L<SYNOPSIS> example above),

=item 2

...then a case insensitive search term (C<bob> in the L<SYNOPSIS> example above),

=item 3

...then a case sensitive replacement (C<Bobbi> in the L<SYNOPSIS> example above),

=item 4

...and finally a name part
- either "C<given>" name
or "C<family>" name
(C<given> in the L<SYNOPSIS> example above).

=back 

Can also accept a number of flags (preceded by two dashes 
- such as the C<--exact> C<--verbose> and C<--live> examples shown above).
The flags and their usage are described under L</OPTIONS>.

=head1 OPTIONS

=over

=item B<--lang>, I<language tag> B<--language>=I<language tag>

Allows setting of language, by way of a language tag.
i.e. en-GB, or de-DE.

    --lang en-GB

See L</LANGUAGES> for list of current language packages.

=item B<--config> I</path/to/yaml_config.yml>

Allows setting the location of a YAML configuration file to use.
i.e. ... 

    --config /path/to/yaml_config.yml

=item B<--live>

Ensures changes take effect.

=item B<--nolive>

Ensures dry run mode - changes do not take effect.
The script already runs in dry run mode by default.

=item B<--exact>

Indicates the search term, if provided on the command line,
should be interpreted as a case insensitive find value too.
This means you will not be prompted for a find value,
for the find and replace operation on the search results.
Your search term is considered to be your find value too,
making this an exact search (albeit case insensitive).

=item B<--verbose>

Provides additional insightful output during the operation.
If repeated, shows dumper and trace output,
unless these are surpressed by --no_dumper or --no_trace flags.

=item B<--debug>

Shows debugging information during execution.
This includes Data::Dumper and EPrints->trace output.
Use --no_dumper and --no_trace flags to surpress this.

=item B<--trace>

Should two verbose flags, or at least one debug flag be set,
this trace flag will ensure an EPrints->trace stack trace
is displayed alongside every log message.

=item B<--notrace>, B<--no_trace>

Prevents the display of EPrints->trace stack traces
when the debug flag or two verbose flags are in effect.

=item B<--nodump>, B<--no_dump>, B<--nodumper>, B<--no_dumper>

Prevents the display of Data::Dumper output
when the debug flag or two verbose flags are in effect.

=back

=cut

# Used throughout:
use     strict;
use     warnings;
use     v5.16;
use     utf8;

# Global Encoding Settings:
my      $encoding_layer;

SET_ENCODING_LAYER_AT_COMPILE_TIME: BEGIN {
    my  $encoding_to_use                =   'UTF-8';
        
    $encoding_layer                     =   ":encoding($encoding_to_use)";
};

use     open ':std'                     ,   "$encoding_layer";  # :std affect is global.
binmode STDIN                           ,   $encoding_layer;
binmode STDOUT                          ,   $encoding_layer;
binmode STDERR                          ,   $encoding_layer;

$ENV{'PERL_UNICODE'}                    =   'AS';               # A = Expect @ARGV values to be UTF-8 strings.
                                                                # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.
                                                                # ENV settings are global for current thread and any forked processes.
                                                                 


=head1 PERL PACKAGES

=cut

=head2 ChangeNameOperation

Performs the change name operation.

=cut

package ChangeNameOperation::Config v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.
                                    
    # Specific:
    use     File::Basename;         # Will use this to get the directory name that this file is in,
                                    # when looking for yaml file.
    use     CPAN::Meta::YAML qw(
                LoadFile
                Load
            );                      # Standard module in Core Perl since Perl 5.14. 
                                    # Better to use YAML::Tiny for YAML, except that is not in core, and this is.
                                    
    sub new {
        my  $class      =   shift;
        my  $params     =   {@ARG};
    
        my  $self       =   {};
        bless $self, $class;
    
        $self->_set_attributes($params);
    
        return $self;
    }

    sub _set_attributes {

        # Initial Values:
        my  ($self)                 =   shift;
    
        %{
            $self
        }                           =   (
    
            # Existing values in $self:
            %{$self},

            # Defaults:
            default_yaml_filepath   =>  dirname(__FILE__).'/ChangeNameOperationConfig.yml',
            data                    =>  undef,
            
        );
        
        return $self;
            
    }

    sub get_default_yaml_filepath {
        return shift->{default_yaml_filepath};
    }

    
    sub load {

        # Initial Values:
        my  $self                   =   shift;
        my  $external_filepath      =   shift;
        my  $default_filepath       =   $self->get_default_yaml_filepath;

        # Definitions:    
        my  $external               =   defined $external_filepath
                                        && (
                                            $external_filepath eq '0'?  1:
                                            $external_filepath
                                        )
                                        && -e $external_filepath;

        my  $external_not_found     =   defined $external_filepath
                                        && (
                                            $external_filepath eq '0'?  1:
                                            $external_filepath
                                        )
                                        && !(-e $external_filepath);

        my  $default                =   defined $default_filepath
                                        && $default_filepath
                                        && -e $default_filepath;

        my  $fellback_to_default    =   $external?  undef:
                                        $default?   1:
                                        undef;

        my  $internal               =   $external?  undef:
                                        $default?   undef:
                                        1;

        # Processing:
        $self->{data}               =   # External YAML file:
                                        $external?  LoadFile($external_filepath):           # Will die on any load error.
                                        $default?   LoadFile($default_filepath):            # Will die on any load error.
                        
                                        # Internal YAML __DATA__:
                                        Load(                                               # Will die on any load error.
                                            do {                                            # 'do' returns last value of block.
                                                local $INPUT_RECORD_SEPARATOR = undef;      # Read until end of input.
                                                <ChangeNameOperation::Config::YAML::DATA>   # Input is __DATA__ at the bottom of this very file.
                                            }
                                        );

        # Messages:                                    
        push @{ $self->{messages}->{error} }    ,   ['config.load.error.custom_external_not_found', $external_filepath]
                                                    if $external_not_found;

        push @{ $self->{messages}->{debug} }    ,   ['config.load.debug.default_external_not_found', $default_filepath]
                                                    unless $default;

        push @{ $self->{messages}->{verbose} }  ,   $external?              ['config.load.verbose.loaded_file', $external_filepath]:
                                                    $fellback_to_default?   ['config.load.verbose.loaded_file', $default_filepath]:
                                                    $internal?              ['config.load.verbose.internal']:
                                                    ();

        # Output:             
        return $self;
        
    };
    
    sub get_data {
        return shift->{data};
    }
    
    sub get_data_and_messages {
        my  $self   =   shift;

        return  wantarray?   ($self->{data}, $self->{messages}):
                [$self->{data}, $self->{messages}];
    }
    
    sub get_messages {
        return shift->{messages};
    }
    

}; # ChangeNameOperation::Config Package.

package ChangeNameOperation::Modulino v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance issue if they are invoked,
                                    # on Perl v5.18 or lower.

    # Specific:
    use     Getopt::Long;

    # Modulino:
    ChangeNameOperation::Modulino->run(@ARGV) unless caller;

    sub run {
        shift->new->process_input(@ARG)->utf8_check->setup_config->setup_language->say_debug_messages->say_config_messages->start_operation;
    }
    
    sub new {
        my  $class      =   shift;
        my  $params     =   {@ARG};
    
        my  $self       =   {};
        bless $self, $class;
    
        $self->_set_attributes($params);
    
        return $self;    
    }
    
    sub _set_attributes {

        # Initial Values:
        my  ($self, $params)        =   @ARG;
    
        %{
            $self
        }                           =   (
            acceptable_utf8_options =>  (${^UNICODE} >= '39')
                                        &&
                                        (${^UNICODE} <= '63'),
            we_should_halt          =>  0,
        );
    
    }

    sub process_input {

        my  $self           =   shift;

        # Defaults:
        $self->{options}    =   {
            language        =>  undef,
            live            =>  0,
            verbose         =>  0,
            debug           =>  0,
            trace           =>  0,
            no_dumper       =>  0,
            no_trace        =>  0,
            config          =>  undef,
            exact           =>  0,
        };
    
        # Command Line Options:    
        Getopt::Long::Parser->new->getoptionsfromarray(
            \@ARG,                                              # Array to get options from.
            $options,                                           # Hash to store options to.
    
            # Actual options:
            $self->multilingual_options('language',     ':s'),  # Optional string.
                                                                # Use 'language' for the hash ref key, 
                                                                # accept '--language' or '--lang' from the commandline.
                                                                # Syntax can be --lang=en-GB or --lang en-GB
    
            $self->multilingual_options('config',       ':s'),  # Optional string.
                                                                # Use 'config' for the hash ref key, 
                                                                # accept '--config' from the commandline.
                                                                # Syntax can be --config=path/to/yaml_config.yml or --config path/to/yaml_config.yml
     
            $self->multilingual_options('live',         '!'),   # if --live present,    set $live to 1,
                                                                # if --nolive present,  set $live to 0.
    
            $self->multilingual_options('verbose',      '+'),   # if --verbose present,    set $verbose
                                                                # to the number of times it is present.
                                                                # i.e. --verbose --verbose would set $verbose to 2.
    
            $self->multilingual_options('debug',        '!'),   # if --debug present,    set $debug to 1,
                                                                # if --nodebug present,  set $debug to 0.
    
            $self->multilingual_options('trace',        '!'),   # if --trace present,    set $trace to 1,
                                                                # if --notrace present,  set $trace to 0.
                                
            $self->multilingual_options('no_dumper',    '+'),   # if --no_dumper present set $no_dumper to 1.
    
            $self->multilingual_options('no_trace',     '+'),   # if --no_trace present  set $no_trace  to 1.
            
            $self->multilingual_options('exact',        '!'),   # if --exact present,   set $exact to 1,
                                                                # if --noexact present, set $exact to 0.
        );

        $self->{arguments}  =   {
            archive_id      =>  shift,
            search          =>  shift,
            replace         =>  shift,
            part            =>  shift,
        };

        return $self;

    }

    sub multilingual_options {
        # Initial Values:
        my ($self, $option, $option_suffix) =   @ARG;
        my  %multilingual_options_hash      =   ChangeNameOperation::Languages->maketext_in_all_languages($option);
        
        # Premature exits:
        return () unless ($option || ($option eq '0'));
        return () unless %multilingual_options_hash;
        
        # Further Initial Values:
        $option_suffix                      //= q{};
        my  @skip                           =   ();
        my  $option_separator               =   '|';

        # Regular Expressions:
        my  $contiguous_white_space         =   qr/
                                                    [\p{White_Space}\p{Pattern_White_Space}]    # Set of Properties that count as white space.
                                                    +                                           # Anything in the set one or more times.
                                                /x;                                             # x - to allow whitespace and comments in regex.
                                                                                                # Note x does not allow whitespace within the angled brackets,
                                                                                                # and xx would allow it in Perl 5.26 or higher.

        my  $matches_leading_whitespace     =   qr/
                                                    ^                                           # Start of string.
                                                    $contiguous_white_space                     # White Space however previously defined.
                                                    (?<data>                                    # Begin Capturing Group.
                                                        .*                                      # Zero or more of anything.
                                                    )                                           # End capturing group.
                                                    $                                           # End of string.
                                                /xs;                                            # x - to allow whitespace and comments in regex.
                                                                                                # s - to include newlines in 'anything'.

        # Processing:
        
        # Build our option:
        my  $our_option_string              =   $option;
        my  $used_already = {
            "$option"                       =>  1
        };

        # Add translations to option:        
        foreach my $translation (values %multilingual_options_hash }) {
                
            $translation                =   $translation =~ $matches_leading_whitespace?   $+{data}:
                                            $translation;

            my  @values                 =   map {
                                                my  $value              =   $ARG;
                                                
                                                return                      @skip
                                                                            if $used_already{$value};

                                                $used_already{$value}   =   1;

                                                return                      $value;
                                            }
                                            split $contiguous_white_space, $translation;

            $our_option_string          .=  @values? $option_separator.join($option_separator, @values):
                                            $our_option_string;
        };
        
        $our_option_string              .=  $option_suffix;
        return  $our_option_string;
    }

    sub utf8_check {
        my  $self                               =   shift;
        my  @nothing                            =   ();        
        $self->{input_that_requires_utf8}       =   scalar (
                                                        map {
                                                            defined $ARG && $ARG?   $ARG:
                                                            @nothing
                                                        }
            
                                                        (
            
                                                            # Arguments to be UTF-8:
                                                            $self->{arguments}->{archive_id},
                                                            $self->{arguments}->{search},
                                                            $self->{arguments}->{replace},
                                                            $self->{arguments}->{part},
                                                            
                                                            # Options where UTF-8 is important:
                                                            $self->{options}->{language},
                                                            $self->{options}->{config},    
            
                                                        )
                                                    );

        if ($self->{input_that_requires_utf8}) {

            unless ($self->{acceptable_utf8_options}) {

                $self->{we_should_halt} =   1;

            };

        };
        
        return $self;

    }
    
    sub setup_config {

        # Initial Values:
        my  $self                       =   shift;
        my  @nothing                    =   ();        
        
        # Definitions:
        my  @config_filepath_or_nothing =   exists  $self->{options}->{config}
                                            &&      $self->{options}->{config}? ($self->{options}->{config}):
                                            @nothing;

        # Processing:
        (
            $self->{config},
            $self->{config_messages}
        )                               =   ChangeNameOperation::Config->new->load(@config_filepath_or_nothing)->get_data_and_messages; # If nothing, will load default from YAML at bottom of this file.

        # Output:        
        return $self;

    }

    sub setup_language {

        my  $self           =   shift;
        
        $self->{language}   =   ChangeNameOperation::Languages->try_or_die(
                                    $self->{options}->{language}
                                    // $self->{config}->{'Language Tag'}
                                    # No further fall back, as the config should be enough 
                                    # because the default YAML config is at the bottom of this file,
                                    # and if an external YAML config is missing the setting, the try_or_die will handle it,
                                    # with its own fallback, if necessary.
                                );
        return  $self;

    }
 
    sub say_debug_messages {
    
        my  $self   =   shift;
        
        # Premature Exit:
        return $self unless $self->{options}->{debug};
        
        # Processing:
        say $self->localise->('Commandline Options are...');
        say Dumper($self->{options});
        say $self->localise->('Commandline Arguments are...');
        say Dumper($self->{arguments});
        
        # Output:
        return $self;
    
    }
    
    sub say_config_messages {

        # Initial Values:
        my  $self           =   shift;
        
        # Premature exit:
        return $self            unless $self->{config_messages}
                                && (
                                    $self->{config_messages}->{verbose} 
                                    || $self->{config_messages}->{debug}
                                    || $self->{config_messages}->{error}
                                );
        # Values:
        my  $prefix         =   shift // '[ChangeNameOperation::Modulino::say_config_messages] - ';
        my  $no_prefix      =   q{};
                            
        # Definitions:
        my  $verbose_mode   =   $self->{options}->{verbose}
                                || $self->{options}->{debug};

        my  $debug_mode     =   $self->{options}->{debug}
                                || (
                                    $self->{options}->{verbose} > 1
                                );
        
        # Definition Dependent Values:
        my  $prefix_or_not  =   $debug_mode? $prefix:
                                $no_prefix;

        # Processing:

        # Display order is Error, Debug, Verbose, by design. 
        # See ChangeNameOperation::Config::load for context.

        say STDERR $prefix_or_not.$self->localise(@{$ARG})     for @{$self->{config_messages}->{error}}; # Always show an error.

        if ($debug_mode) {    
            say STDOUT $prefix_or_not.$self->localise(@{$ARG}) for @{$self->{config_messages}->{debug}};
        };

        if ($verbose_mode) {
            say STDOUT $prefix_or_not.$self->localise(@{$ARG}) for @{$self->{config_messages}->{verbose}};
        };

        # Output:     
        return $self;
        
    }

    sub start_operation {

        # Initial Values:
        my  $self           =   shift;

        # Processing:    
        say (scalar $self->{arguments})?    $self->{input_that_requires_utf8}?  $self->{acceptable_utf8_options}?   $self->localise->('commandline.utf8_enabled'):
                                                                                $self->localise->('commandline.utf8_not_enabled'):
                                            $self->localise->('commandline.utf8_not_needed'):
        $self->localise->('commandline.no_arguments');


        
        die $self->localise->('commandline.end_program') if $self->{we_should_halt};

        my  @object_params  =   (

            # Flatten to one list - arguments overwrite options:

            @{
                $self->{options}
            },

            @{
                $self->{arguments}
            },

            config  =>  $self->{config};

        );
    
        ChangeNameOperation->start(@object_params);

        # Output:        
        return $self;

    }
 
    sub localise {
            return shift->{language}->maketext(@ARG);
    }
    
    sub get_config {
        return shift->{config};
    }

} # ChangeNameOperation::Modulino Package.

package ChangeNameOperation::CompileTimeConfigValues {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance issue if they are invoked,
                                    # on Perl v5.18 or lower.

    sub new {
        # Initial Values:
        my  $class  =   shift;
        my  $prefix =   '[ChangeNameOperation::CompileTimeConfigValues::new] - ';

        # Set Attributes:
        my  $self   =   {
            config  =>  ChangeNameOperation::Modulino->new->process_input(@ARG)->setup_config->setup_localiser->say_config_messages($prefix)->get_config,
        };

        # Make Object:
        bless $self ,   $class;

        # Output:
        return $self;
    }

    sub get_path_to_eprints_perl_library {
        return shift->config->{'EPrints Perl Library Path'};
    }

} # ChangeNameOperation::CompileTimeValues Package.

package ChangeNameOperation v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance issue if they are invoked,
                                    # on Perl v5.18 or lower.

    # Specific:
    use     lib ChangeNameOperation::CompileTimeConfigValues->new(@ARGV)->get_path_to_eprints_perl_library;
    use     EPrints;
    use     EPrints::Repository;
    use     EPrints::Search;
    use     File::Basename; # Will use this to get the directory name that this file is in, when looking for yaml file.
    use     Getopt::Long;

    use     Scalar::Util qw(
                blessed
                reftype
            );
    use     CPAN::Meta::YAML qw(
                LoadFile
                Load
            ); # Standard module in Core Perl since Perl 5.14.

    use     Data::Dumper;               # Used by logging related subroutines and _check_commandline_input sub.

    # Data Dumper Settings:
    $Data::Dumper::Maxdepth     =   4;  # So when we dump we don't get too much stuff.
    $Data::Dumper::Sortkeys     =   1;  # Hashes in same order each time - for easier dumper comparisons.
    $Data::Dumper::Useperl      =   1;  # Perl implementation will see Data Dumper adhere to our binmode settings.
    no warnings 'redefine';
    local *Data::Dumper::qquote =   sub { qq["${\(shift)}"] };  # For UTF-8 friendly dumping - see: https://stackoverflow.com/questions/50489062/
    use warnings 'redefine';

    
=pod Name, Version

=encoding utf8


=head3 MODULE NAME

ChangeNameOperation

=head3 VERSION

v1.0.0

=cut

=pod Synopsis, Description

=head3 SYNOPSIS

    # Run at the command line:
    perl -CAS ./ChangeNameOperation.pm
    
    # Use in a unit test or other Perl Script:
    use ChangeNameOperation;
    
    my $object = ChangeNameOperation->new(@object_params);


=head3 DESCRIPTION

Calls a subroutine when ran from the commandline.
Currently set to call L</start_from_commandline>.

    # Run from the command line:
    perl -CAS ./ChangeNameOperation.pm MyArchive bob Bobbi given --exact --verbose --live

Considers the first four arguments provided at the commandline to be 
an EPrints archive ID (C<MyArchive> in the example above),
then a case insensitive search term (C<bob> in the example above),
then a case sensitive replacement (C<Bobbi> in the example above),
and finally a name part - either C<given> or C<family> (C<given> in the example above).

Can accept a number of flags (preceded by two dashes 
- such as the C<--exact> C<--verbose> and C<--live> examples shown above).
The flags and their usage are described under L</OPTIONS>.

Loads the class when used in another script.

    # Use in a unit test or other Perl Script:
    use ChangeNameOperation;
    
    my $object = ChangeNameOperation->new(@object_params);

See L</new> method for info on acceptable object parameters.

=cut

   
=head3 CLASS METHODS

=head4 $class->start_from_commandline(@ARGV);

    # Run at the command line:
    perl -CAS ./ChangeNameOperation.pm

Class method auto-ran when
L<ChangeNameOperation.pm> is ran from the commandline.

Considers arguments passed in to have come from the commandline,
processes them to obtain object construction parameters,
checks those parameters,
then uses them to construct a new ChangeNameOperation object,
upon which the program flow is called...

    # Construct new object, and begin program flow...
    ChangeNameOperation->new(@object_params)->search->part_specific->display->confirm->change->finish;

=over

=item *

Beginning with a search (L</search>),

=item *

then refining down to a specific part of a name (L</part_specific>),

=item *

then displaying the findings to the user (L</display>),

=item *

confirming any changes (L</confirm>),

=item *

making changes (L</change>),

=item *

and proceding to finish (L</finish>).

=back

=cut

    # Start Method:
    
    sub start {
        my  $class          =   shift;
        my  @object_params  =   @ARG;
    
        $class->new(@object_params)->search->part_specific->display->confirm->change->finish;
    }
    
    # Program Flow Methods:


=head3 CONSTRUCTORS

=cut

=head4 ChangeNameOperation->new(@object_params);

    # Construct new object, and begin program flow...
    my  $object =   ChangeNameOperation->new(@object_params);

Accepts parameters required for a new ChangeNameOperation,
and returns a new ChangeNameOperation object,
upon which program flow methods
or setters and getters,
can be called.

=cut

    sub new {
        my  $class      =   shift;
        my  $params     =   {@ARG};
    
        my  $self       =   {};
        bless $self, $class;
    
        $self->_set_attributes($params)->log_debug('Constructed New Object Instance.')->dumper;
    
        return $self;
    }

=head3 INSTANCE METHODS

=head4 $self->search;

    # Construct an object, and populate its 
    my  $object  =   ChangeNameOperation->new(@object_params)->search;

Performs an EPrints search,
according to values set during ChangeNameOperation object construction.

Returns the initial ChangeNameOperation object, now with list_of_results and records_found object attributes set.

=cut
    
    sub search {
        my  $self                   =   shift;
        
        $self->log_debug('Entered method.')->dumper
        ->log_debug('Using search settings...')->dumper($self->{search_settings})
        ->log_verbose(
            'Searching fields [_1] ...',
            join(
                $self->localise('separator.search_fields'),
                @{$self->{fields_to_search}},
            )
        );
        
        # Search:
        $self->{list_of_results}    =   $self->{repository}
                                        ->dataset($self->{dataset_to_use})
                                        ->prepare_search(%{$self->{search_settings}})
                                        ->perform_search;
                                        # Search interprets 'ó' as matching 'O.' (yes - even with the dot) and 'à' as matching 'A'
                                        # This is an EPrints API behaviour.
                                        # These are not direct matches, and so could be filtered out by us.
                                        # At the same time, it also works in reverse. Lopez-Aviles can match López-Avilés 
                                        # - which is beneficial if someone doesn't have the correct keyboard.
                                        # So let's leave this in.
    
        $self->{records_found}      =   scalar @{$self->{list_of_results}->{ids}};
    
        say $self->localise('No Results Found.') unless $self->{records_found};
        $self->log_verbose('Found Results.') if $self->{records_found};
    
        return $self->log_debug('Leaving method.')->dumper;
    
    }

=head4 $self->part_specific;

    # Narrow search down to specific part... 
    my  $object  =   ChangeNameOperation->new(@object_params)->search->part_specific;

Should search results have been retrieved (will return prematurely if not),
it will process the search results in order to generate useful lists,
and then attempt to refine the search down by setting or prompting for a specific name part.

If find and replace values have not already been set,
it will prompt the user for them too.

=cut
    
    sub part_specific {
    
        my  $self   =   shift;
    
        return $self->log_debug('Premature exit - No search results to narrow down.') unless $self->{records_found};
    
        $self->log_debug('Entering method.')->dumper->log_verbose('Narrowing search to a specific part...');
        
        return $self->log_debug('Premature Exit - our operation is already specific to a name part.') if $self->{part_specified};
            
        $self->log_debug('Generating lists, and setting values.')->_tally_frequencies->_generate_name_lists->_set_part->_set_find->_set_replace;
    
        # Determine what was set...
        $self->{unique_names_set}   =   $self->{'unique_names'}
                                        && (reftype($self->{'unique_names'}) eq 'ARRAY');
            
        $self->{part_specified}     =   $self->{part} && $self->{find} && defined($self->{replace})? 1: 
                                        undef;
                                        # Replace can be a blank string - hence defined test instead of true test.
    
        $self->log_debug('Leaving part_specific method.')->dumper;
    
        return $self;
    
    }

=head4 $self->part_specific;

    # Narrow search down to specific part... 
    my  $object  =   ChangeNameOperation->new(@object_params)->search->part_specific;

Should search results have been retrieved (will return prematurely if not),
it will process the search results in order to generate useful lists,
and then attempt to refine the search down by setting or prompting for a specific name part.

If find and replace values have not already been set,
it will prompt the user for them too.

=cut
    
    sub display {
    
        my  $self               =   shift;
        
        $self->log_debug('Called display method.')->dumper;
    
        my  $prerequisites      =   $self->{records_found}
                                    && $self->{part_specified}
                                    && $self->{unique_names_set};
    
        return $self->log_debug('Premature exit - Prerequisites not met.') unless $prerequisites;
        
        # Initial values:
        $self->{'matches_find'} =   qr/^\Q$self->{find}\E$/i;   # case insensitive.    
    
        # Processing:
        say $self->localise('Thank you for your patience. Your request is being processed...');
        for my $unique_name (@{$self->{'unique_names'}}) {
    
            $self->log_debug('Processing Unique name: [_1]', $unique_name);
    
            # Initial Values:
            $self->{'matches_unique_name'}              =   qr/^\Q$unique_name\E$/;
            $self->{'unique_name'}                      =   $unique_name;
            $self->{'display_lines'}->{"$unique_name"}  =   [];
            $self->{'display'}->{"$unique_name"}        =   undef;
    
            # Processing;
            foreach my $chunk_of_results ($self->chunkify) {
                $self->_add_relevant_display_lines($ARG) for @{$chunk_of_results};
            };
            
        };
    
        say $self->localise('Nothing was found to match.') unless $self->{display_set};
    
        # Output:
        return $self->log_debug('Leaving display method.')->dumper;
    
    }

=head4 $self->confirm;

    # Narrow search down to specific part... 
    my  $object  =   ChangeNameOperation->new(@object_params)->search->part_specific->confirm;

To do.

=cut
  
    sub confirm {
    
        my  $self           =   shift;
    
        $self->log_debug('Called confirm method.')->dumper;
    
        my  $prerequisites  =   $self->{records_found}
                                && $self->{part_specified}
                                && $self->{unique_names_set}
                                && $self->{display_set};
    
        return $self->log_debug('Premature exit - Prerequisites not met.') unless $prerequisites;
    
        # Initial values:
        $self->{what_to_change}             =   [];
    
        # Processing:
        for my $unique_name (@{$self->{'unique_names'}}) {
        
            $self->log_debug('Processing Unique name: [_1]', $unique_name);
    
            # Initial Values:
            $self->{display_lines_shown}    =   undef;
            $self->{matches_unique_name}    =   qr/^\Q$unique_name\E$/;
            $self->{unique_name}            =   $unique_name;
            $self->{auto_yes}               =   undef;
            $self->{auto_no}                =   undef;
    
            # Processing:        
            foreach my $chunk_of_results ($self->chunkify) {
                $self->_seeking_confirmation($ARG) for @{$chunk_of_results};
            };
    
        };
    
        # Output:
        return $self->log_debug('Leaving confirm method.')->dumper;
    
    }

=head4 $self->change;

    # Narrow search down to specific part... 
    my  $object  =   ChangeNameOperation->new(@object_params)->search->part_specific->confirm->change;

To do.

=cut

    sub change {
    
        my  $self   =   shift;
        
        $self->log_debug('Called change method.')->dumper;
    
        my  $prerequisites              =   $self->{what_to_change}
                                            && reftype($self->{what_to_change}) eq 'ARRAY'
                                            && @{$self->{what_to_change}};
        
        return                              $self->log_debug('Premature exit - Nothing to change.')
                                            unless $prerequisites;
    
        $self->{changes_made}           =   0;
    
        for my $details (@{$self->{what_to_change}}) {
    
            my  (
                    $result,
                    $search_field,
                    $names,
                    $name,
                    $current,
                )                       =   @{$details};
    
            my  $fresh_result           =   $self->{repository}->dataset($self->{dataset_to_use})->dataobj($result->id);
            my  $fresh_names            =   $fresh_result->get_value($search_field);
            my  $fresh_name             =   $fresh_names->[$current];
            my  $can_or_cannot          =   $fresh_result->is_locked?   'cannot':
                                            'can';
    
            say $self->localise('horizontal.rule');
            
            say $self->localise('change.from.'.$can_or_cannot, $self->format_single_line_for_display($fresh_result, $search_field));
    
            $name->{"$self->{'part'}"}          =   $self->{'replace'};
            $result->set_value($search_field, $names);
            $self->log_debug('Changed our working result - this will not be committed.')->dumper($result->get_value($search_field));
    
            $fresh_name->{"$self->{'part'}"}    =   $self->{'replace'};
            $fresh_result->set_value($search_field, $fresh_names);
            $self->log_debug('Changed our fresh result - this will be committed.')->dumper($fresh_result->get_value($search_field));
    
            # Is it ever possible, our working result, originally confirmed, could differ from our fresh result?
            # Should there be a comparison and warning at some point?
            # If not, then there's really no reason to be using the original working result we confirmed on
            # - we only need the id to get our fresh result.
    
            say $self->localise('change.to.'.$can_or_cannot, $self->format_single_line_for_display($fresh_result, $search_field), $fresh_result->id);
        
            if ($self->{live}) {
                unless ($fresh_result->is_locked) {
                    $fresh_result->commit(@{$self->{force_or_not}});
                    say $self->localise('change.done');
                    $self->{changes_made}++;
                }
                else {
                    say $self->localise('Due to the edit lock presently on Record [_1], changes to Record [_1] were not saved.', $fresh_result->id);
                };
            }
            else {
                say $self->localise('change.dry_run');
            };
    
        };
        
        return $self;
    
    }

=head4 $self->finish;

    # Narrow search down to specific part... 
    my  $object  =   ChangeNameOperation->new(@object_params)->search->part_specific->confirm->change->finish;

To do.

=cut

    sub finish {
        my  $self   =   shift;
        say $self->localise('horizontal.rule');
        say $self->localise('finish.change',$self->{changes_made}, scalar @{$self->{what_to_change}});
        say $self->localise('finish.no_change') unless $self->{changes_made};
        say $self->localise('finish.thank_you');
        return $self;
    }
    
    # Setters and Getters:

    sub get_default_yaml_filepath {
        return shift->{default_yaml_filepath};
    }
    
    sub get_default_language {
        return 'en-GB'
    }
    
    sub _set_archive {
        return shift->_set_or_prompt_for('archive' => shift, @ARG);
    }
    
    sub _set_part {
        return shift->_set_or_prompt_for('part' => shift, @ARG);
    }
    
    sub _set_find {
        return shift->_set_or_prompt_for('find' => shift, @ARG);
    }
    
    sub _set_search_normal {
        return shift->_set_or_prompt_for('search' => shift, @ARG);
    
    }
    
    sub _set_search_exact {
        my  $self   =   shift;
        my  $value  =   shift;
        return          $self
                        ->_set_find             ($value, @ARG)
                        ->_set_search_normal    ($value, @ARG)
                        ->log_debug             ('Find attribute set to ([_1]).', $self->{find})
                        ->log_debug             ('Search attribute set to ([_1]).', $self->{search})
                        ;
    }
    
    sub _set_search {
        my  $self   =   shift;
        my  $value  =   shift;
        return          $value && $self->{exact}?   $self->log_verbose('Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.', $value)->_set_search_exact($value, @ARG):
                        $self->log_debug('Set search normally, as no --exact flag provided.')->_set_search_normal($value, @ARG);
    }
    
    sub _set_replace {
        return shift->_set_or_prompt_for('replace' => shift, @ARG);
    }
    
    sub set_name_parts {
    
        my  $self               =   shift;
        
        $self->log_debug('Entering method.')->log_debug('Name parts before we begin:')->dumper($self->{name_parts});
        
        my  $already_set        =   $self->{name_parts}
                                    && ref($self->{name_parts}) eq 'ARRAY'
                                    && @{$self->{name_parts}};
    
        return                      $self->log_debug('Premature exit - name parts already populated.')
                                    if $already_set;
    
        my  $valid_name_parts   =   join(
    
                                        # Join by regex OR character:
                                        '|',                    
    
                                        # Make name parts regex safe:
                                        map {quotemeta $ARG}    
    
                                        # Name Parts for Each Field:
                                        map {
                                            keys %{
                                                $self->{repository}->dataset($self->{dataset_to_use})->field($ARG)->property('input_name_cols')
                                            }
                                        }
    
                                        # Fields:
                                        @{$self->{fields_to_search}}
    
                                    );
    
        my  $not_a_name_part    =   qr/[^($valid_name_parts)]/i;
     
        $self->{name_parts}     =   [   map
                                        {
                                                $ARG || $ARG eq '0'? ($ARG):    # True or zero - use.
                                                ();                             # Else filter out.
                                        } 
                                        split $not_a_name_part, $self->localise('name_parts.display_order')
                                    ]; # Array ref, so order preserved.
    
        $self->log_debug('Set name parts according to language localisation as follows...')->dumper($self->{name_parts});
    
        return $self->log_debug('Leaving method.');
    
    }
    
    # Private Setters:
    
    sub _set_yaml {
        my  $self           =   shift;
        my  $filepath       =   shift // $self->get_default_yaml_filepath;
    
        $self->{yaml}       =   # External YAML file:
                                (defined $filepath && -e $filepath)?    LoadFile($filepath):             # Will die on any load error.
                        
                                # Internal YAML __DATA__:
                                Load(                                           # Will die on any load error.
                                    do                                          # 'do' returns last value of block.
                                    {
                                        local $INPUT_RECORD_SEPARATOR = undef;  # Read until end of input.
                                        <ChangeNameOperation::Config::YAML::DATA> # Input is __DATA__ at the bottom of this very file.
                                    }
                                );
                                
        return $self;
    
    }
    
    sub _set_repository {
        my  $self           =   shift;
        my  $archive_id     =   shift;
        $self->{repository} =   EPrints::Repository->new(
                                    $self->_set_archive($archive_id)->{archive}
                                );
        return $self;
    }
    
    # Function-esque subroutines:
    
    sub format_single_line_for_display {
    
        # Initial Values:
        my  ($self, $result, $field)    =   @ARG;
    
        $self->log_debug('Entered method.');
    
        die                                 $self->localise('format_single_line_for_display.error.no_params')
                                            unless ($result && $field);
    
        $self->log_debug('Found params, and about to process them...');
    
        my  $names                      =   join(
                                                $self->localise('separator.name_values'),
                                                map {$self->_stringify_name($ARG) // ()}
                                                @{$result->get_value("$field")}
                                            );
    
        $self->log_debug('Stringified names for use in a localised display line.');
    
    
        return                              $self->log_debug('Returning localised display line as we leave the method.')
                                            ->localise('display_line', $result->id, $names);
    
    }
    
    sub chunkify {
    
        # Initial Values:
        my  ($self, $list, $chunk_size) =   @ARG;
        $chunk_size                     //= 100;
        $list                           //= $self->{list_of_results}; # validate it is a list object?
        my  @list_of_arrayrefs          =   ();
    
        # Processing:
        for (my $offset = 0; $offset < $list->count; $offset += $chunk_size) {
            push @list_of_arrayrefs     ,   [$list->slice($offset, $chunk_size)];
        };
    
        # Output:    
        return @list_of_arrayrefs; # Could improve with a wantarray check.
    
    }
    
    sub stringify_arrayref {
        my $self    =   shift;
        return join ', ', @{ (shift) };
    }
    
    sub prompt_for {
    
        my  $self                   =   shift;
        my  $prompt_type            =   shift;
        die                             $self->localise('prompt_for.error.no_prompt_type')
                                        unless $prompt_type;
                                
        my  $prompt                 =   'prompt_for.'.$prompt_type;
        my  @prompt_arguments       =   ();
    
        my  $input                  =   undef;
    
        # Definitions:
        my  $part_prompt            =   ($prompt_type eq 'part');
        my  $replace_prompt         =   ($prompt_type eq 'replace');
        my  $confirm_prompt         =   ($prompt_type eq 'confirm');
        my  $find_prompt            =   ($prompt_type eq 'find');
        my  $continue_prompt        =   ($prompt_type eq 'continue');
        my  @prompt_on_blank_for    =   qw(
                                            replace
                                        );
        my  $prompt_on_blank_for    =   join '|',
                                        map {quotemeta($ARG)}
                                        @prompt_on_blank_for;
        my  $matches_prompt_on_blank=   qr/^($prompt_on_blank_for)$/;   # This list to join to regex is done so often, it should be a subroutine or method.
    
        if  ($find_prompt) {
            die                         $self->localise('prompt_for.find.error.no_part')
                                        unless $self->{part};
            @prompt_arguments       =   (
                                            $self->localise('name.'.$self->{part}),
                                        );
        };
    
        if ($part_prompt) {
        
            my  $number;
            @prompt_arguments               =   (
                                                    $self->stringify_arrayref($self->{'given_names'}),
                                                    $self->stringify_arrayref($self->{'family_names'}),
                                                );
            my  $acceptable_input           =   join '|',
                                                (
                                                    'given',
                                                    'family',
                                                );
            my  $matches_acceptable_input   =   qr/^($acceptable_input)$/;
    
            say $self->localise($prompt, @prompt_arguments);
    
            until ( $input && ($input =~ $matches_acceptable_input) ) {
    
                say $self->localise('prompt_for.1or2');
                chomp($number   =   <STDIN>);
    
                $input          =   $number?    $number eq $self->localise('input.1')?  'given':    # should mapping occur to variables set centrally?
                                                $number eq $self->localise('input.2')?  'family':   # should mapping occur to variables set centrally?
                                                undef:
                                    undef;
    
            };
        
        }    
    
        elsif  ($confirm_prompt) {
        
            my  $confirmation;
            @prompt_arguments               =   @{$self->{confirm_prompt_arguments}}; # A hack. Maybe refactor to be passed in.
            my  $acceptable_input           =   join '|',
                                                map {quotemeta $self->localise($ARG)}
                                                (
                                                    'input.yes_letter',
                                                    'input.no_letter',
                                                    'input.all',
                                                    'input.none',
                                                );
            my  $matches_acceptable_input   =   qr/^($acceptable_input)$/i;
    
            say $self->localise($prompt, @prompt_arguments);
            say $self->localise('horizontal.rule');
    
            until ( $confirmation && ($confirmation =~ $matches_acceptable_input) ) {
                say $self->localise('prompt_for.confirm.acceptable_input');
                chomp($confirmation   =   <STDIN>)
            };
    
            $input = $confirmation;
        }
    
        elsif ($continue_prompt) {
    
            say $self->localise($prompt);
            say $self->localise('horizontal.rule');
            chomp($input   =   <STDIN>);
    
        }
    
        else {
        
            until ($input) {
        
                say $self->localise($prompt, @prompt_arguments);
                chomp(my $typed_input           =   <STDIN>);
                ($input)                        =   $self->_validate( ($typed_input) );
                
                last if $input;
                if ($prompt_type =~ $matches_prompt_on_blank) {
        
                    say $self->localise($prompt.'.prompt_on_blank');
                    chomp(my $typed_input2      =  <STDIN>); # Not validated and should be okay as we only ever use it in an equality test in the line below...
                    
                    # Definition:
                    my  $blank_input_desired    =   ( fc $typed_input2 eq fc $self->localise('input.yes_letter') ); # fc supported in Perl 5.16 onwards.
    
                    if ($blank_input_desired) {
                        $input = q{};
                        last;
                    };
                    
                };
    
            };
            
        };
        
        return $input;
    
    }
    
    sub localise {
            return shift->{language}->maketext(@ARG);
    }
    
    # Private subs:
    
    sub _get_commandline_arguments {
    
        my  $self       =   shift;
        
        # Defaults:
    
        # Params:
        my  $params     =   {
            language    =>  undef,
            live        =>  0,
            verbose     =>  0,
            debug       =>  0,
            trace       =>  0,
            no_dumper   =>  0,
            no_trace    =>  0,
            config      =>  undef,
            exact       =>  0,
        };
    
        # Command Line Options:    
        Getopt::Long::Parser->new->getoptionsfromarray(
            \@ARG,                  # Array to get options from.
            $params,                # Hash to store options to.
    
            # Actual options:
            'language|lang:s',      # Optional string.
                                    # Use 'language' for the hash ref key, 
                                    # accept '--language' or '--lang' from the commandline.
                                    # Syntax can be --lang=en-GB or --lang en-GB
    
            'config:s',             # Optional string.
                                    # Use 'config' for the hash ref key, 
                                    # accept '--config' from the commandline.
                                    # Syntax can be --config=path/to/yaml_config.yml or --config path/to/yaml_config.yml
     
            'live!',                # if --live present,    set $live to 1,
                                    # if --nolive present,  set $live to 0.
    
            'verbose+',             # if --verbose present,    set $verbose
                                    # to the number of times it is present.
                                    # i.e. --verbose --verbose would set $verbose to 2.
    
            'debug!',               # if --debug present,    set $debug to 1,
                                    # if --nodebug present,  set $debug to 0.
    
            'trace!',               # if --trace present,    set $trace to 1,
                                    # if --notrace present,  set $trace to 0.
                                
            'no_dumper'.
            '|no_dump'.
            '|nodumper'.
            '|nodump+',             # if --no_dumper present set $no_dumper to 1.
    
            'no_trace|notrace+',    # if --no_trace present  set $no_trace  to 1.
            
            'exact!',               # if --exact present,   set $exact to 1,
                                    # if --noexact present, set $exact to 0.
    
        );
    
        $params={
            %{$params},
            archive_id  =>  shift,
            search      =>  shift,
            replace     =>  shift,
            part        =>  shift,
        };
    
        return              wantarray?  %{$params}: # List context
                            $params;                # Scalar or void contexts.
    
    }
    
    sub _check_commandline_input {
    
        my  $class              =   shift;
        my  $params             =   {@ARG};
        my  @commandline_input  =   map { defined $ARG && $ARG? $ARG:() } (
                                        $params->{archive_id},
                                        $params->{search},
                                        $params->{replace},
                                        $params->{part},
                                    );
    
        my  $language_to_use    =   $params->{'language'}
                                //  $class->get_default_language;
    
        my  $language           =   ChangeNameOperation::Languages->try_or_die($language_to_use);
    
        my  $localise           =   sub { $language->maketext(@ARG) };
    
        if ($params->{live}) {
            say $localise->('LIVE mode - changes will be made at the end after confirmation.');
        }
        else {
            say $localise->('DRY RUN mode - no changes will be made.');
            say $localise->('Run again with the --live flag when ready to implement your changes.');
        };
    

    
        if (@commandline_input) {
    
            # Definition:
            my  $acceptable_utf8_options    =   (${^UNICODE} >= '39')
                                                &&
                                                (${^UNICODE} <= '63');
    
    
            if ($acceptable_utf8_options) {
                say $localise->('commandline.utf8_enabled');
            }
            else {
                say $localise->('commandline.utf8_not_enabled');
                die $localise->('commandline.end_program');
            };
    
        }
        else {
            say $localise->('commandline.no_arguments');
        };
        
        return $class;
    
    }
    
    sub _set_attributes {
    
        # Initial Values:
        my  ($self, $params)        =   @ARG;
    
        my  $matches_yes            =   qr/^(y|yes)$/i; # Used with YAML. Case insensitive y or yes and an exact match - no partial matches like yesterday.
        my  $matches_match_types    =   qr/^(IN|EQ|EX|SET|NO)$/;
        my  $matches_merge_types    =   qr/^(ANY|ALL)$/;

        $self->_set_repository          ($params->{archive_id});
    
        %{
            $self
        }                           =   (
    
            # Existing values in $self:
            %{$self},
    
            # From params:
            live                    =>  $params->{live} // 0,
            exact                   =>  $params->{exact} // 0,
            logger                  =>  ChangeNameOperation::Log->new(
                                            debug                   =>  $params->{debug},
                                            verbose                 =>  $params->{verbose},
                                            trace                   =>  $params->{trace},
                                            no_dumper               =>  $params->{no_dumper},
                                            no_trace                =>  $params->{no_trace},
                                            language                =>  $params->{language},
                                            repository              =>  $self->{repository},
                                            dumper_class_name_only  =>  [
                                                                            'repository',
                                                                            'list_of_results',
                                                                            'dumper_default', # typically $self - except the Log self unless set_dumper_default submits another self. Probably ought to change that.
                                                                        ],
                                            dumper_exclude          =>  [
                                                                            #'repository',
                                                                        ],
                                        ),
    
            # Internationalisation:
            language                =>  ChangeNameOperation::Languages->try_or_die($params->{language}//$self->get_default_language),
    
            # Defaults:
            default_yaml_filepath   =>  dirname(__FILE__).'/ChangeNameOperationConfig.yml',
    
        );

        $self
        ->log_verbose                   ('Language set to [_1].', $self->{language}->language_tag)
        ->log_debug                     ('Set initial instance attributes using params or defaults.')
        ->log_debug                     ('Archive, repository, and log related params were all required for log methods.')
        ->log_debug                     ('Now setting additional instance attributes from params...')
        ->_set_search                   ($params->{search})
        ->_set_replace                  ($params->{replace},'no_prompt') # Optional on object instantiation, so no prompt for value needed if not set.
        ->_set_part                     ($params->{part},'no_prompt') # Also optional on initialisation.
        ->_set_yaml                     ($params->{config})
        ->dumper;
    
        %{
            $self->log_debug('Setting self-referential instance attributes...')
        }                       =   (
    
            # Existing values in $self:
            %{$self},
    
            # From YAML Configuration:
            force_or_not        =>  [
                                        ($self->{yaml}->{'Force commit changes to database'} =~ $matches_yes)?  [1]:
                                        ()
                                    ],
            dataset_to_use      =>  $self->_validate($self->{yaml}->{'Dataset to use'}),
            fields_to_search    =>  [
                                        $self->_validate(
                                            @{
                                                $self->{yaml}->{'Fields to search'}
                                            }
                                        )
                                    ],
            search_match_type   =>  $self->{yaml}->{'Search Field Match Type'}
                                    &&
                                    (uc($self->{yaml}->{'Search Field Match Type'}) =~ $matches_match_types)?     uc $self->{yaml}->{'Search Field Match Type'}:
                                    'IN',
            search_merge_type   =>  $self->{yaml}->{'Search Field Merge Type'}
                                    &&
                                    (uc($self->{yaml}->{'Search Field Merge Type'}) =~ $matches_merge_types)?     uc $self->{yaml}->{'Search Field Merge Type'}:
                                    'ANY',
    
        );
    
        %{
            $self->log_verbose('Set YAML configurations.')->dumper
        }                       =   (
        
            # Existing values in $self:
            %{$self},
    
            # Search:
            search_fields       =>  [{
                                        meta_fields     =>  $self->{fields_to_search},
                                        value           =>  $self->{search},
                                        match           =>  $self->{search_match_type},
                                        merge           =>  $self->{search_merge_type},
                                    }],
            
        );
    
        %{
            $self->log_debug('Set search-fields.')->dumper
            ->log_debug('Setting further self-referential attributes...')
        }                       =   (
    
            # Existing values in $self:
            %{$self},
    
            # Search Settings:
            search_settings     =>  {
    
                                        #limit               =>  30,    # Limit the number of matching records.
    
                                        satisfy_all         =>  0,      # If this is true than all search-fields must be satisfied,
                                                                        # if false then results matching any search-field will be returned.
    
                                        staff               =>  1,      # If true then this is a "staff" search,
                                                                        # which prevents searching unless the user is staff,
                                                                        # and the results link to the staff URL of an item
                                                                        # rather than the public URL.
    
                                        show_zero_results   =>  1,      # Should the search go to the results page
                                                                        # if there are no results of stay on the search form page
                                                                        # with a warning about no results.
    
                                        allow_blank         =>  0,      # Unless this is set, a search with no conditions
                                                                        # will return zero records rather than all records.
                                                                        # So presumably when a search has no conditions...
                                                                        # - if this is set, you get all records,
                                                                        # - if this is not set, you get zero records
    
                                        search_fields       =>  $self->{search_fields},
                                    },
        );
    
        $self->dumper
        ->set_name_parts
        ->dumper;
    
        return $self;
    
    }
    
    sub _tally_frequencies {
    
        my  ($self)  =   @ARG;
    
        # Processing:
        foreach my $results_chunk ($self->chunkify) {
            foreach my $result (@{$results_chunk}) {
                foreach my $search_field (@{$self->{'fields_to_search'}}) {
    
                    my  $names          =   $result->get_value($search_field);
                    my  @range_of_names =   (0..$#{$names});
    
                    for my $current (@range_of_names) {
    
                        my  $name           =   $names->[$current];
                        my  $unique_name    =   q{};
    
                        for my $name_part (@{$self->{'name_parts'}}) { # Array, so in specific order that's the same each time.
    
                            $unique_name    .=  $name_part.
                                                ($name->{"$name_part"} // q{});
    
                        }
    
                        $self->{frequencies}->{'unique_names'   }->{"$unique_name"      }++;
                        $self->{frequencies}->{'given_names'    }->{"$name->{'given'}"  }++;
                        $self->{frequencies}->{'family_names'   }->{"$name->{'family'}" }++;
                    }
                }
    
            }
            
        };
    
        # Output:    
        return $self;
    }
    
    sub _generate_name_lists {
    
        my  $self                       =   shift;
    
        for my $name_of_list (keys %{$self->{frequencies}}) {
    
            $self->{"$name_of_list"}    =   [
                                                sort {$a cmp $b} 
                                                keys %{$self->{frequencies}->{"$name_of_list"}}    # Defined in _tally_frequencies method.
                                            ];
        };
        
        return $self;
    }
    
    sub _add_relevant_display_lines {
    
        my  $self                       =   shift;
    
        $self->log_debug('Entered method. Attribute display_lines is...')->dumper($self->{display_lines});
    
        my  $result                     =   shift;
    
        return                              $self->log_debug('Premature exit - no result passed in.') # should this be a die?
                                            unless $result;
    
        foreach my $search_field (@{$self->{'fields_to_search'}}) {
    
            $self->log_debug('Processing search field: [_1]', $search_field);
    
            for my $name (@{$result->get_value($search_field)}) {
    
                if ( $self->_match($name)->{matches} ) {
                    
                    my  $line                                                   =   $self->format_single_line_for_display($result, $search_field);
    
                    push @{$self->{'display_lines'}->{"$self->{unique_name}"}}  ,   $line;
    
                    $self->{'display'}->{"$self->{unique_name}"}                =   'Yes';
    
                    $self->{'display_set'}                                      =   'Yes';
                    
                    $self->log_debug('Set display flags and added display line:')->dumper($line);
    
                }
    
            };
    
        };
        
        return $self->log_debug('Leaving method. Attribute display_lines is...')->dumper($self->{display_lines});
    
    }
    
    sub _seeking_confirmation {
    
        my  $self                       =   shift;
    
        $self->log_debug('Entered method.')->dumper;
    
        my  $result                     =   shift;
    
        return                              $self->log_debug('Premature exit - no result passed in.') # should this be a die?
                                            unless $result;
    
        my  ($yes,$all,$no,$none)       =   (
                                                $self->localise('input.yes_letter'),
                                                $self->localise('input.all'),
                                                $self->localise('input.no_letter'),
                                                $self->localise('input.none'),
                                            );
    
        foreach my $search_field (@{$self->{'fields_to_search'}}) {
    
            $self->log_debug('Processing search field: [_1]', $search_field);
    
            my  $names                  =   $result->get_value($search_field);
            my  @range_of_names         =   (0..$#{$names});
    
            for my $current (@range_of_names) {
    
                my  $name   =  $names->[$current];
    
                next unless $self->_match($name)->{matches};
    
                $self->log_debug('Checking if display lines have been shown.')->dumper($self->{display_lines_shown});
                           
                unless ($self->{display_lines_shown}) {
    
                    say $self->localise('horizontal.rule');
                    say $self->localise(
                            'seeking_confirmation.display_lines',
                            $self->_stringify_name($name),
                            join(
                                $self->localise('separator.new_line'),
                                @{$self->{display_lines}->{"$self->{unique_name}"}},
                            ),
                        );
                    say $self->localise('horizontal.rule');
    
                    $self->{display_lines_shown}    =   'Yes';
    
                };
    
                # Set or get confirmation:
                $self->log_debug('Setting confirmation');
                
                $self->{confirm_prompt_arguments}   =   [
                                                            $self->{'part'},
                                                            $name->{"$self->{'part'}"},
                                                            $self->{'replace'},
                                                            ($current+1),
                                                            $search_field,
                                                            $self->format_single_line_for_display($result, $search_field),
                                                        ];
                
                $self->log_debug('Will check matches auto no result ([_1]) and matches auto yes result ([_2])...', $self->{matches_auto_no}, $self->{matches_auto_yes} );
                
                my  $confirmation       =   $self->{matches_auto_no}?   $no:    # Match determined in _match method and could be refactored out.
                                            $self->{matches_auto_yes}?  $yes:   # Match determined in _match method and could be refactored out.
                                            $self->prompt_for('confirm');
    
                # Process confirmation:
                $self->log_debug('Processing confirmation ([_1])', $confirmation);
    
                if (fc $confirmation eq fc $none) {
                    $self->{auto_no}    =   $self->{unique_name};
                    $confirmation       =   $no;
                };
    
                if (fc $confirmation eq fc $all) {
                    $self->{auto_yes}   =   $self->{unique_name};
                    $confirmation       =   $yes;
                };
    
                if (fc $confirmation eq fc $yes) {
    
                    my  $feedback       =   [
                                                $self->{matches_unique_name},
                                                $self->_stringify_name($name),
                                                uc($confirmation),
                                                $self->format_single_line_for_display($result, $search_field),
                                            ];
                
                    my  $details        =   [
                                                $result,
                                                $search_field,
                                                $names,
                                                $name,
                                                $current,
                                                $feedback,
                                            ];
    
                    push @{$self->{what_to_change}}, $details;
    
                    $self->log_debug('Added details to what_to_change')->dumper($details);
                    
                };
    
                say $self->_generate_confirmation_feedback->log_debug('Displaying generated confirmation feedback.')->{confirmation_feedback} // q{};
                $self->prompt_for('continue') if $self->{confirmation_feedback};
    
            };
    
        };
        
        return $self->log_debug('Leaving method.')->dumper;
    
    }
    
    sub _generate_confirmation_feedback {
    
        my  $self                                               =   shift;
    
        $self->log_debug('Entered method.')->dumper;
    
        my  $prerequisites                                      =   @{$self->{what_to_change}}
                                                                    && @{$self->{unique_names}};
    
        return $self->log_debug('Premature exit - Prerequisites not met.') unless $prerequisites;
    
        my  $output                                             =   $self->localise('horizontal.rule').
                                                                    $self->localise('_confirmation_feedback.heading.confirmed_so_far');
        my  $at_least_one_confirmation                          =   undef;
        my  $heading_shown_for                                  =   {};
    
        foreach my $details (@{$self->{what_to_change}}) {
            for my $current_unique_name (@{$self->{unique_names}}) {
    
                my  (
                        $matches_unique_name,
                        $stringified_name,
                        $confirmation,
                        $display_line
                    )                                           =   @{ $details->[5] };
    
                if ($current_unique_name                        =~  $matches_unique_name) {
    
                    $self->log_debug('Matched unique name.');
    
                    $at_least_one_confirmation                  =   'Yes';
    
                    $output                                     .=  $self->localise('_confirmation_feedback.heading.unique_name', $stringified_name)
                                                                    unless $heading_shown_for->{$current_unique_name};
    
                    $output                                     .=  $self->localise('_confirmation_feedback.record.confirmed_for_changing', $confirmation, $display_line);
            
                    $heading_shown_for->{"$current_unique_name"}=   'Yes';
    
                    $self->log_debug('Added record to confirmation feedback.');
                    
                    $self->log_debug('Since unique names are unique, we can leave unique name loop now we have processed a match.');
                    last;
    
                };
        
            };
            $self->log_debug('Exited unique name loop.');
        };
        
        #$output                                                 .=  $self->localise('horizontal.rule');    # Not needed if continue prompt will follow.
        
        $self->{confirmation_feedback}                          =   $at_least_one_confirmation? $output:
                                                                    undef;
        
        $self->log_debug(
            $self->{confirmation_feedback}? 'Generated confirmation feedback.':
            'No confirmation feedback generated.',
        );
        
        return $self->log_debug('Leaving method.')->dumper;
    
    }
    
    sub _match {
    
        my  $self       =   shift->log_debug('Entering method.');
        my  $name       =   shift;
    
        my  $uniqueness =   q{};
    
        for my $name_part (@{$self->{'name_parts'}}) { # Array, so in specific order that's the same each time.
    
            $uniqueness .=  $name_part.($name->{"$name_part"}//q{});
    
        };
    
        $self->{matches}            =   $uniqueness
                                        && ($uniqueness =~ $self->{'matches_unique_name'})                      # This name is the current unique name,
                                        && ($name->{"$self->{'part'}"} || $name->{"$self->{'part'}"} eq '0')    # ...and we have a name part value to match against,
                                        && ($name->{"$self->{'part'}"} =~ $self->{'matches_find'});             # ...and we have found a match with that value.
                            
    
        $self->{matches_auto_no}    =   $self->{auto_no}
                                        && $self->{auto_no} =~ $uniqueness;
    
        $self->{matches_auto_yes}   =   $self->{auto_yes}
                                        && $self->{auto_yes} =~ $uniqueness;
    
    
        if ($self->{matches}) {
            $self->log_debug('Match found for: [_1]', $self->_stringify_name($name))
            ->log_debug('Matched "[_1]" in "[_2]" part of the following unique name...', $self->{'find'}, $self->{'part'})
            ->dumper($uniqueness);
        }
        else {
            $self->log_debug('No match found.');
        };
    
        return  $self;
    }
    
    sub _set_or_prompt_for {
        my  ($self, $attribute, $value, $prompt_type)   =   @ARG;
        #say 'in set and prompt_for';
        $self->{"$attribute"}   =   defined $value?                                 $self->_validate($value):
                                    defined $self->{"$attribute"}?                  $self->{"$attribute"}:
                                    $prompt_type && ($prompt_type eq 'no_prompt')?  undef:
                                    $prompt_type?                                   $self->prompt_for($prompt_type):
                                    $self->prompt_for($attribute);
    
        return $self;
    }
    
    # Private Function-esque subs:
    
    sub _stringify_name {
        my  $self           =   shift;
        my  $name           =   shift;
        
        # Premature Exit:
        die                     $self->localise('_stringify_name.error.no_params')
                                unless $name; # hash ref check?
        
        my  @order_or_omit  =   ();
    
        for my $current_part (@{$self->{name_parts}}) {
            push @order_or_omit,
            $name->{"$current_part"} && $name->{"$current_part"} eq '0'?    "0 but true": # 0 is potentially a valid one character name - haha.
            $name->{"$current_part"}?                                       $name->{"$current_part"}:
            ();
        };
    
        return                  @order_or_omit? join $self->localise('separator.name_parts'), @order_or_omit:
                                undef;
    }
    
    sub _validate {
    
        # Initial Values:
        my  $self                           =   shift;
        my  @input                          =   @ARG;
        
        # Definitions:
        my  $number_of_input_arguments      =   scalar @input;
        my  $matches_four_byte_character    =   qr/[\N{U+10000}-\N{U+7FFFFFFF}]/;    
    
        # Premature death:
        die                                     $self->localise('_validate.error.no_arguments')
                                                unless $number_of_input_arguments; # Blank string or a zero are both valid values.
    
        # Processing:
        for my $current_index (0..$#input) {
    
            # Consider a sole zero as a true input value:
            $input[$current_index]          =   $input[$current_index] eq '0'? "0 but true":
                                                $input[$current_index];
    
            # Stop out of range input:
            die                                 $self->localise('_validate.error.four_byte_character')
                                                if (
                                                    $input[$current_index]
                                                    && ($input[$current_index] =~ $matches_four_byte_character)
                                                );
    
        };
    
        # Output:
        return  # In list context:
                wantarray?                          @input:
                # In Scalar and void contexts..
                $number_of_input_arguments == 1?    $input[0]:  # if only one value, return sole value...
                \@input;                                        # ...otherwise return an array ref.
    }
    
    # Log Stuff:
    
    sub log_verbose {
        return shift->{logger}->set_caller_depth(4)->verbose(@ARG);
    }
    
    sub log_debug {
        return shift->{logger}->set_caller_depth(4)->debug(@ARG);
    }
    
    sub dumper {
        my  $self   =   shift;
    
        $self->{logger}->set_caller_depth(4)->set_dumper_default($self)->dumper(@ARG);

        return $self;
    }
    
    1;
    
=pod End of methods.

=back

=cut


=item AUTHOR

Andrew Mehta

=back

=back

=cut

}; # ChangeNameOperation Package.

=head2 ChangeNameOperation::Log

Allows for creating a logger object
that has methods related to logging
verbose, debug, trace, and data dumper output
to the EPrints log.

=cut

package ChangeNameOperation::Log v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.

    # Specific:
    use     lib ChangeNameOperation::CompileTimeConfigValues->new(@ARGV)->get_path_to_eprints_perl_library;
    use     EPrints;
    use     EPrints::Repository;
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
 
=pod Name, Version

=encoding utf8

=over

=over

=item MODULE NAME

ChangeNameOperation

=item VERSION

v1.0.0

=cut

=pod Synopsis, Description

=item SYNOPSIS

    # Run at the command line:
    perl -CAS ./ChangeNameOperation.pm
    
    # Use in a unit test or other Perl Script:
    use ChangeNameOperation;
    
    my $object = ChangeNameOperation->new(@object_params);


=item DESCRIPTION

Calls a subroutine when ran from the commandline.
Currently set to call L</start_from_commandline>.

    # Run from the command line:
    perl -CAS ./ChangeNameOperation.pm

Loads the class when used in another script.

    # Use in a unit test or other Perl Script:
    use ChangeNameOperation;
    
    my $object = ChangeNameOperation->new(@object_params);

See L</new> method for info on acceptable object parameters.

=back

=back

=cut
 
    
    sub new {
        my  $class      =   shift;
        my  $params     =   {@ARG};
    
        my  $self       =   {};
        bless $self, $class;
    
        $self->_set_attributes($params)->debug('Constructed New Logger Object Instance.')->dumper($self)->set_caller_depth(4);
    
        return $self;
    }

    sub _set_attributes {
        my  ($self, $params)        =   @ARG;

        %{
            $self
        }                           =   (
    
            # Existing values in $self:
            %{$self},
    
            # From params:
            debug                   =>  $params->{debug} // 0,
            verbose                 =>  $params->{verbose} // 0,
            trace                   =>  (
                                            $params->{no_trace} < 1
                                            &&
                                            (
                                                $params->{verbose} > 2
                                                || ($params->{debug} && $params->{verbose})
                                                || ($params->{debug} && $params->{trace})
                                            )
                                        ),
            no_dumper               =>  $params->{no_dumper} // 0,
            no_trace                =>  $params->{no_trace} // 0,

            repository              =>  $self->valid_repository($params->{repository}),
            caller_depth            =>  3,
            
            dumper_class_name_only  =>  $params->{dumper_class_name_only} // [],

            dumper_exclude          =>  $params->{dumper_exclude} // [],
    
            # Internationalisation:
            language                =>  $params->{language}?    ChangeNameOperation::Languages->try_or_die($params->{language}):
                                        undef;
    
        );

        $self->{dumper_default}     =  $self;
        
        return  $self;
    }

    sub valid_repository {
        my  $self               =   shift;
        my  $value              =   shift // $self->{respository};
        my  $value_is_valid     =   defined $value
                                    && blessed($value)
                                    && $value->isa('EPrints::Repository');
        warn                        $self->localise('log.valid_repository.error.invalid')
                                    unless $repository; # Should this use _log instead of warn?

        return  $value_is_valid?    $value:
                undef;
    }
    
    sub localise {
            my  $self   =   shift;
            
            return $self->{language}?   $self->{language}->maketext(@ARG):
            ChangeNameOperation::Languages->maketext_in_all_languages(@ARG);
    }
    
    
    
    sub set_dumper_default {
        my  $self   =   shift;

        $self->{dumper_default} = shift // $self->{dumper_default};

        return $self;
    }

    sub set_caller_depth {
        my  $self   =   shift;

        $self->{caller_depth} = shift // $self->{caller_depth};

        return $self;
    }

    sub set_repository {
        my  $self       =   shift;
        my  $repository =   $self->valid_repository(shift); # Valid or undef.
        
        warn                        $self->localise('log.set_repository.error.bad_value')
                                    unless $repository; # Should this use _log instead of warn?

        $self->{repository}     =   $repository;

        return $self;
    }

    sub set_language {
        my  $self           =   shift;
        
        $self->{language}   =   @ARG?   ChangeNameOperation::Languages->try_or_die(@ARG):
                                $self->{language};

        return $self;
    }

    sub verbose {
        my  $self   =   shift;
    
        # Premature Exit:
        return $self unless ($self->{verbose} || $self->{debug});
    
        return $self->_log('verbose',@ARG);
    }
    
    sub debug {
        my  $self   =   shift;
    
        # Premature Exit:
        return $self unless $self->{debug};
    
        return $self->_log('debug',@ARG);
    }
    
    sub dumper {
        my  $self   =   shift;
    
        return $self if $self->{no_dumper};
        return $self unless ($self->{debug} || $self->{verbose} > 1);
    
        # Default Params if no arguments passed in...
        my  $exclude    =   join(
    
                                # Join by regex OR...
                                '|',
    
                                # Regex safe:
                                map {quotemeta($ARG)}
    
                                # List of attributes to exclude from dump...
                                (
                                #    'repository',
                                    @{ $self->{dumper_exclude} },
                                )
                            );
    
        my  $class_only =   join(
    
                                # Join by regex OR...
                                '|',
    
                                # Regex safe:
                                map {quotemeta($ARG)}
    
                                # List of attributes
                                # that are objects
                                # we wish to dump only
                                # the class names of:
                                (
                                    @{ $self->{dumper_class_name_only} },
                                )
                            );
    
        my  %default    =   map
                            {
                                $ARG =~ m/^($class_only)$/
                                && blessed($self->{$ARG})? ($ARG => blessed($self->{$ARG})):
                                ($ARG => $self->{$ARG})
                            }
                            map {$ARG =~ m/^($exclude)$/? ():($ARG)}
                            keys %{$self->{dumper_default}};
    
        # Set params:
        my  @params     =   @ARG?   @ARG:
                            (\%default);
    
        return $self->_log('dumper',@params);
    }
    
    sub _log {
    
        my  $self       =   shift;
    
        # Initial Values:
        my  $type               =   shift;
        my  $use_prefix         =   $self->{verbose} > 1 || $self->{debug};

        my  $valid_repository   =   $self->valid_repository($self->{repository});

        # Content:
        my  $prefix             =   $use_prefix?    $self->_get_log_prefix(uc($type)):
                                    q{};
    
        my  $message            =   $prefix.(
                                        $type eq 'dumper'?  $self->localise('separator.new_line').Dumper(@ARG):
                                        $self->localise(@ARG)
                                    );

        # Log:
        $self->{repository}->log($message)  if      $valid_repository;
        say STDERR $message                 unless  $valid_repository;

        # Premature log-only exit:
        return $self unless $self->{trace};

        # Stack trace:
        my  $trace_prefix   =   $self->_get_log_prefix('TRACE');

        $self->{repository}->log($trace_prefix) if      $valid_repository;
        say STDERR $trace_prefix                unless  $valid_repository;

        EPrints->trace;
        
        # Final log-and-trace exit:
        return $self;
    }

    sub ensure_single_line {

        # Passed in arguments:
        my  $self       =   shift;
        my  $string     =   shift;
        
        # Premature death:
        die unless $string;

        # Initial Values:
        my  $replace_with_divider   =   quotemeta(' / ');
        my  $find_newline           =   qr/\n/;
        
        # Processing:
        $string                     =~  s/$find_newline/$replace_with_divider/g;    # g - find and replace globally.
        
        # Output:
        return $string;
        
    }
    
    sub _get_log_prefix {
        my  $self   =   shift;
        my  $type   =   shift;
        my  $localised_type =   $type?  $self->ensure_single_line(
                                            $self->localise(
                                                'log.type.'.lc($type)
                                            )
                                        ):
                                q{};
        return sprintf(
             '[%s] [%s] [%s] - ',                   # Three strings in square brackets, derived from the below...
    
             scalar localtime,                      # Human readable system time and date - linux's ctime(3).
    
             ((caller $self->{caller_depth})[3]),   # Back by caller depth, to what called dumper / log_debug / log_verbose,
                                                    # and get the 3rd array index value
                                                    # - the perl module and subroutine name.
    
             uc($localised_type),                   # Log type - LOG / DEBUG / DUMPER / TRACE, etc...
         );
    }

}; # ChangeNameOperation::Log Package.

=head2 ChangeNameOperation::Languages

MakeText project class for loading language classes.

=cut

package ChangeNameOperation::Languages v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.
    
    # Specific:
    use     parent qw(Locale::Maketext);
    
    sub try_or_die {
    
        my  ($self, $language)  =   @ARG;
    
        $language               //= 'en-GB';
    
        my  $error={
            language            =>  'Trouble finding a language to use.',
        };
    
        return  $self->get_handle($language)
                || die  $error->{'language'};
    }
    
    sub fallback_language_classes {
        # I believe these are to be given as relative to ChangeNameOperation::Languages
        # rather than a full qualified class name like ChangeNameOperation::Languages::en_gb
        my  @list_of_classes    =   (
            'en_gb',
        );
        return @list_of_classes;
    }

    sub maketext_in_all_languages {
        # Initial Values:
        my  $self                                   =   shift;
        my  @in_all_languages                       =   ();
        my  $in_all_languages_string                =   q{};
        my  $language_base_class                    =   __PACKAGE__;
        my  $format                                 =   "%s: %s\n"; # String, colon, space, string, newline.

        # Regex:
        my  $matches_and_captures_language_handle   =   qr/
                                                            (                               # Start capture group.
                                                                ?<captured_language_handle> # Name the capture group.
                                                                [^:]+                       # One or more of anything except a colon.
                                                            )                               # End capture group.
                                                            $                               # End of string.
                                                        /x;                                 # x flag - Ignore white space and allow comments.

        # Processing:
        for my $language_class (@{ mro::get_isarev($language_base_class) }) {

            my  $language_handle                    =   $language_class
                                                        && ($language_class =~ $matches_and_captures_language_handle)?  $+{captured_language_handle}:
                                                        undef;

            my  $language_tag                       =   $language_base_class->$language_handle->language_tag # Typically lower-case.
                                                        || undef; # Or undefined.

            if ($language_handle && $language_tag) {

                my  $phrase                         =   $language_base_class->$language_handle->maketext(@ARG);
                my  $phrase_is_valid                =   $phrase || $phrase eq '0';

                # Build hash-compatible list
                push @in_all_languages, (
                    "$language_tag"             =>  $phrase_is_valid?   $phrase:
                                                    undef,
                );

                # Build string - or skip if no valid phrase:
                if ($phrase_is_valid) {
                    $in_all_languages_string   .=  sprintf($format, uc($language_tag), $phrase);
                };

            };

        };

        #Output:
        return  wantarray?  @in_all_languages:
                $in_all_languages_string;
    }


    1;
}; # ChangeNameOperation::Languages Package.

=head2 Language Packages:

These lexicons contain language specific configurations, tokens, and phrases.

=over

=cut

LOAD_LANGUAGE_CLASSES_FIRST: BEGIN {

=item ChangeNameOperation::Languages::en_gb

British English.

=cut

package ChangeNameOperation::Languages::en_gb { 

# Use --lang=en-GB at the commandline to use it.

ChangeNameOperation::Languages->import;
our @ISA                        =   ('ChangeNameOperation::Languages');

# ----------------------------------

my  $new_line                   =   "\n";

my  @configurations = (

# Ignores formatting and case
# and focuses on desired order.
# Ignores characters or words 
# that are not an EPrints::MetaField::Name name part.
'name_parts.display_order'      =>  'honourific, given, family, lineage',

);

my  @tokens = (

'options.language'              =>  'language lang',
'options.config'                =>  'config configuration',
'options.live'                  =>  'live',
'options.verbose'               =>  'verbose',
'options.debug'                 =>  'debug',
'options.trace'                 =>  'trace stacktrace',
'options.no_dumper'             =>  'no_dumper no_dump nodumper nodump',
'options.no_trace'              =>  'no_trace notrace no_stacktrace nostacktrace',
'options.exact'                 =>  'exact',

'input.yes_letter'              =>  'Y',
'input.no_letter'               =>  'N',
'input.all'                     =>  'ALL',
'input.none'                    =>  'NONE',
'input.1'                       =>  '1',
'input.2'                       =>  '2',
'separator.name_parts'          =>  ' ', #space
'separator.name_values'         =>  ', ', #comma space
'separator.new_line'            =>  $new_line,
'separator.search_fields'       =>  ', ', #comma space
'name.given'                    =>  'Given Name',
'name.family'                   =>  'Family Name',
'name.honourific'               =>  'Honourific Name',
'name.lineage'                  =>  'Lineage Name',
'display_line'                  =>  'Record [_1]: [_2].',

'log.type.verbose'              =>  'verbose',
'log.type.log'                  =>  'log',
'log.type.debug'                =>  'debug',
'log.type.dumper'               =>  'dumper',
'log.type.trace'                =>  'trace',

'config.load.error.custom_external_not_found'=>
'Config file [_1] not found.',

'config.load.debug.default_external_not_found'=>
'Default external config file [_1] not found.',

'config.load.verbose.loaded_file'=>
'Loaded Config from [_1]',

'config.load.verbose.internal'=>
'Loading internal configuration.',

'log.valid_repository.error.invalid'    =>
'Value passed to valid_repository method not a valid repository.',

'log.set_repository.error.bad_value'    =>
'Value passed to set_repository method not a repository. Value left unchanged.',

'modulino.error.perl_lib'       =>
'EPrints Perl Library Path either not defined in YAML config,
or is a path to a directory that does not appear to exist.',

'modulino.perl_lib_path' =>
'The EPrints Perl Library Path value was:
[_1]',

'horizontal.rule'               =>  
'
-------
',

'format_single_line_for_display.error.no_params' =>
'Method format_single_line_for_display requires
a DataObj object (i.e. a search result or eprint) 
and a string of a field name (i.e. a search field like creators_name),
to be passed to it as params,
and no params were passed in.',

'_stringify_name.error.no_params' =>
'Method requires a name hash reference of name parts,
to be passed in as an argument,
and no such params were provided.',

'commandline.end_program'       =>  'This program will now end...'.$new_line,
'validation.errors.invalid'     =>  'Invalid [_1] field in [_2] form.'.$new_line,

'commandline.utf8_not_needed'   =>  'No UTF-8 critical commandline options or arguments given.',
'commandline.no_arguments'      =>  'No commandline arguments given.',
'commandline.utf8_enabled'      =>  'UTF-8 commandline arguments enabled.',

'commandline.utf8_not_enabled'  =>

'UTF-8 commandline arguments do not appear to be enabled.

To enable UTF-8 arguments,
please run the script again with, for example, -CAS after perl as such...

    perl -CAS ChangeNameOperation.pm
    
To learn more,
you can view https://perldoc.perl.org/perlrun#-C-%5Bnumber/list%5D
or run...

    perldoc perlrun
    
...and scroll to the Command Switches section,
and read the -C switch section within that.

Alternatively,
if you cannot enable UTF-8 commandline arguments in this way,
consider running the script without arguments,
and you will be prompted for input instead.
',

'prompt_for.1or2'               =>  'Please enter 1 or 2.',
'prompt_for.part'               =>
    
'
From your search we found matching records with the following given names associated...

Given Names: 
[_1]

...and the following family names associated...

Family Names: 
[_2]

Which do you wish to perform your change on first?
    1) Given Name
    2) Family Name
',

'prompt_for.confirm' =>

'Confirm to change [_1] name from...

"[_2]"

...to...

"[_3]"

...for name [_4] in field [_5] in the following record...

[_6]

...?',

'change.from.can'  =>

'Changing...

[_1]
',

'change.from.cannot'  =>

'Unable to change...

[_1]
',

'change.to.can' =>

'...to...

[_1]',

'change.to.cannot' =>

'...to...

[_1]

...due to an edit lock on this record (record [_2]).',

'change.dry_run'    =>  'Not done, because this is a dry run. For changes to count, run the script again with the --live flag added.',

'change.done'       =>  'Done - the change has been made for you.',

'seeking_confirmation.display_lines' =>

'For the unique name combination...

[_1]

...the following matching records were found:

[_2]',

'prompt_for.confirm.acceptable_input'  =>

'Enter "Y" for Yes,
Enter "N" for No,
Enter "ALL" for Yes to All Remaining for this unique name combination.
Enter "NONE" for No to All Remaining for this unique name combination.
',

'prompt_for.continue'                       =>  'Press the ENTER or RETURN key to continue...',
'prompt_for.archive'                        =>  'Please specify an Archive ID: ',
'prompt_for.search'                         =>  'Please specify a Search Term: ',
'prompt_for.replace'                        =>  'Please specify a Replace Term: ',

'prompt_for.find'                           =>  

'Your change will be performed using find and replace,
(looking to find full and not partial matches, and with case insensitivity).

What is your find value when matching within [_1]?
',

'prompt_for.find.error.no_part'             =>  

'A part attribute must be set
when prompting to find a value
in a particular name part, ',

'prompt_for.replace.prompt_on_blank'        =>  

'Did you mean for the replace value to be a blank/null value,
that if later confirmed would effectively be clearing the field?
Enter Y or y for Yes, or anything else for No: ',

'prompt_for.error.no_prompt_type'           =>  

'No prompt type argument supplied to prompt_for method, ',


'_validate.error.four_byte_character'       =>

'This script does not support
four byte characters in input.',

'_validate.error.no_arguments'              =>

'Private _validate method was called with no arguments, 
and thus had no input to validate.
The method requires at least one thing to validate, ',

'_log.error.no_repository'                  =>  'Private _log method requires a valid EPrints::Repository object set as an attribute of $self.',

'_confirmation_feedback.heading.confirmed_so_far'       =>  

'
Records you have confirmed for changing so far...

',

'_confirmation_feedback.heading.unique_name'            =>

'
For the unique name [_1] ...

Confirmation | Record To Change...
',

'_confirmation_feedback.record.confirmed_for_changing'  =>  

'[_1] | [_2]
',


'finish.change'     =>  '[quant,_1,change] out of [quant,_2,change] completed.',

'finish.no_change'  => 'No changes made.', 

'finish.thank_you'  => 'Thank you for using this script.',

);

my  @phrases = (
    'Constructed New Object Instance.'  =>  'Constructed New Object Instance.',
    'Commandline Options are...'        =>  'Commandline Options are...',
    'Commandline Arguments are...'      =>  'Commandline Arguments are...',
    'Language set to [_1].'             =>  'Language set to [_1].',
    'Set initial instance attributes using params or defaults.' =>  'Set initial instance attributes using params or defaults.',
    'Archive, repository, and log related params were all required for log methods.' =>  'Archive, repository, and log related params were all required for log methods.',
    'Now setting additional instance attributes from params...' => 'Now setting additional instance attributes from params...',
    'Setting self-referential instance attributes...' => 'Setting self-referential instance attributes...',
    'Set YAML configurations.' => 'Set YAML configurations.',
    'Set search-fields.' => 'Set search-fields.',
    'Setting further self-referential attributes...' => 'Setting further self-referential attributes...',
    'Entering method.' => 'Entering method.',
    'Name parts before we begin:' => 'Name parts before we begin:',
    'Set name parts according to language localisation as follows...' => 'Set name parts according to language localisation as follows...',
    'Leaving method.' => 'Leaving method.',
    'Entered method.' => 'Entered method.',
    'Searching...' => 'Searching...',
    'Found Results.' => 'Found Results.',
    'No Results Found.'=>'No Results Found.',
    'Narrowing search to a specific part...' => 'Narrowing search to a specific part...',
    'Generating lists, and setting values.' => 'Generating lists, and setting values.',
    'DRY RUN mode - no changes will be made.'=>'DRY RUN mode - no changes will be made.',
    'LIVE mode - changes will be made at the end after confirmation.'=>'LIVE mode - changes will be made at the end after confirmation.',
    'Run again with the --live flag when ready to implement your changes.' => 'Run again with the --live flag when ready to implement your changes.',
    'Processing search field: [_1]'=>'Processing search field: [_1]',
    'Leaving part_specific method.'=>'Leaving part_specific method.',
    'Called display method.' => 'Called display method.',
    'Processing Unique name: [_1]'=>'Processing Unique name: [_1]',
    'Entered method. Attribute display_lines is...'=>'Entered method. Attribute display_lines is...',
    'Leaving method. Attribute display_lines is...'=>'Leaving method. Attribute display_lines is...',
    'Match found for: [_1]'=>'Match found for: [_1]',
    'No match found.'=>'No match found.',
    'Matched "[_1]" in "[_2]" part of the following unique name...'=>'Matched "[_1]" in "[_2]" part of the following unique name...',
    'Found params, and about to process them...'=>'Found params, and about to process them...',
    'Stringified names for use in a localised display line.'=>'Stringified names for use in a localised display line.',
    'Returning localised display line as we leave the method.'=>'Returning localised display line as we leave the method.',
    'Set display flags and added display line:'=>'Set display flags and added display line:',
    'Leaving display method.'=>'Leaving display method.',
    'Called confirm method.'=>'Called confirm method.',
    'Checking if display lines have been shown.'=>'Checking if display lines have been shown.',
    'Setting confirmation'=>'Setting confirmation',
    'Processing confirmation...'=>'Processing confirmation...',
    'Will check matches auto no result ([_1]) and matches auto yes result ([_2])...'=>'Will check matches auto no result ([_1]) and matches auto yes result ([_2])...',
    'Added details to what_to_change'=>'Added details to what_to_change',
    'Leaving confirm method.'=>'Leaving confirm method.',
    'Called change method.'=>'Called change method.',
    'Processing confirmation ([_1])' => 'Processing confirmation ([_1])',
    'Premature exit - Prerequisites not met.'=>'Premature exit - Prerequisites not met.',
    'Premature exit - Nothing to change.'=>'Premature exit - Nothing to change.',
    'Searching fields [_1] ...'=>'Searching fields [_1] ...',
    'Using search settings...'=>'Using search settings...',
    'Generated confirmation feedback.'=>'Generated confirmation feedback.',
    'No confirmation feedback generated.'=>'No confirmation feedback generated.',
    'Displaying generated confirmation feedback.'=>'Displaying generated confirmation feedback.',
    'Thank you for your patience. Your request is being processed...'=>'Thank you for your patience. Your request is being processed...',
    'Matched unique name.'=>'Matched unique name.',
    'Added record to confirmation feedback.'=>'Added record to confirmation feedback.',
    'Since unique names are unique, we can leave unique name loop now we have processed a match.'=>'Since unique names are unique, we can leave unique name loop now we have processed a match.',
    'Exited unique name loop.'=>'Exited unique name loop.',
    'This item (Record [_1]) is under an edit lock.'=>'This item (Record [_1]) is under an edit lock.',
    'Due to the edit lock presently on Record [_1], changes to Record [_1] were not saved.'=>'Due to the edit lock presently on Record [_1], changes to Record [_1] were not saved.',
    'Nothing was found to match.'=>'Nothing was found to match.',
    'Premature exit - No search results to narrow down.'=>'Premature exit - No search results to narrow down.',
    'Premature Exit - our operation is already specific to a name part.'=>'Premature Exit - our operation is already specific to a name part.',
    'Premature exit - name parts already populated.'=>'Premature exit - name parts already populated.',
    'Premature exit - no result passed in.'=>'Premature exit - no result passed in.',
    'Changed our working result - this will not be committed.'=>'Changed our working result - this will not be committed.',
    'Changed our fresh result - this will be committed.'=>'Changed our fresh result - this will be committed.',
    'Set search normally, as no --exact flag provided.'=>'Set search normally, as no --exact flag provided.',
    'Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.'=>'Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.',
    'Find attribute set to ([_1]).'=>'Find attribute set to ([_1]).',
    'Search attribute set to ([_1]).'=>'Search attribute set to ([_1]).',
    'Constructed New Logger Object Instance.'=>'Constructed New Logger Object Instance.',
);

our %Lexicon = (
    #'_AUTO' => 1, # Commented out the auto for now.
    @configurations,
    @tokens,
    @phrases,
);

# ----------------------------------

1;

}

=item ChangeNameOperation::Languages::de_de

German.

=cut

package ChangeNameOperation::Languages::de_de {

# Use --lang=de-DE at the commandline to use it.

# Specific:
ChangeNameOperation::Languages->import;
our @ISA                        =   ('ChangeNameOperation::Languages');

# ----------------------------------

my  $new_line                   =   "\n";

my  @configurations = (

# Ignores formatting and case
# and focuses on desired order.
# Ignores characters or words 
# that are not an EPrints::MetaField::Name name part.
'name_parts.display_order'      =>  'honourific, given, family, lineage',

);

my  @tokens = (

'options.language'              =>  'sprache spr',
'options.config'                =>  'konfig konfiguration',
'options.live'                  =>  'live',
'options.verbose'               =>  'ausführlich ausführl',
'options.debug'                 =>  'debug',
'options.trace'                 =>  'stacktrace trace',
'options.no_dumper'             =>  'kein_dumper kein_dump keindumper keindump',
'options.no_trace'              =>  'kein_trace keintrace kein_stacktrace kein_stacktrace',
'options.exact'                 =>  'exakt genau genaue',

'input.yes_letter'              =>  'J',
'input.no_letter'               =>  'N',
'input.all'                     =>  'ALLE',
'input.none'                    =>  'KEINER',
'input.1'                       =>  '1',
'input.2'                       =>  '2',
'separator.name_parts'          =>  ' ', #space
'separator.name_values'         =>  ', ', #comma space
'separator.new_line'            =>  $new_line,
'separator.search_fields'       =>  ', ', #comma space
'name.given'                    =>  'Vorname',
'name.family'                   =>  'Familienname',
'name.honourific'               =>  'Ehrenname',
'name.lineage'                  =>  'Abstammungsname', # Unsure about this one - it's literally Ancestral Name
'display_line'                  =>  'Datensatz [_1]: [_2].',

'horizontal.rule'               =>  
'
-------
',

'log.type.verbose'              =>  'ausführlich',
'log.type.log'                  =>  'protokoll',
'log.type.debug'                =>  'debug',
'log.type.dumper'               =>  'dumper',
'log.type.trace'                =>  'stacktrace',

'config.load.error.custom_external_not_found'=>
'Konfigurationsdatei [_1] nicht gefunden.',

'config.load.debug.default_external_not_found'=>
'Standard-externe Konfigurationsdatei [_1] nicht gefunden.',

'config.load.verbose.loaded_file'=>
'Konfiguration von [_1] geladen',

'config.load.verbose.internal'=>
'Interne Konfiguration wird geladen.',

'log.valid_repository.error.invalid'    =>
'An die Methode valid_repository übergebener Wert ist kein gültiges Repository.',

'log.set_repository.error.bad_value'    =>
'Der an die Methode „set_repository“ übergebene Wert ist kein Repository. Der Wert bleibt unverändert.',

'modulino.error.perl_lib'       =>
'Der Pfad zur EPrints Perl-Bibliothek ist entweder nicht in der YAML-Konfiguration definiert
oder ist ein Pfad zu einem Verzeichnis, das scheinbar nicht existiert.',

'modulino.perl_lib_path' =>
'Der Wert des EPrints Perl-Bibliothekspfads war:
[_1]',

'format_single_line_for_display.error.no_params' =>
'Die Methode format_single_line_for_display erfordert,
dass ein DataObj-Objekt (d. h. ein Suchergebnis oder ein E-Print)
und eine Zeichenfolge eines Feldnamens (d. h. ein Suchfeld wie Erstellername)
als Parameter übergeben werden,
und es wurden keine Parameter übergeben.',

'_stringify_name.error.no_params' =>
'Die Methode erfordert die Übergabe
einer Namens-Hash-Referenz von Namensteilen als Argument,
und es wurden keine derartigen Parameter bereitgestellt.',

'commandline.end_program'       =>  'Dieses Programm wird nun beendet...'.$new_line,
'validation.errors.invalid'     =>  'Invalid [_1] field in [_2] form.'.$new_line,

'commandline.utf8_not_needed'   =>  'Keine UTF-8-kritischen Befehlszeilenoptionen oder Argumente als Eingabe angegeben.',

'commandline.no_arguments'      =>  'Es wurden keine Befehlszeilenargumente bereitgestellt.',
'commandline.utf8_enabled'      =>  'UTF-8-Befehlszeilenargumente aktiviert.',

'commandline.utf8_not_enabled'  =>

'UTF-8-Befehlszeilenargumente scheinen nicht aktiviert zu sein.

Um UTF-8-Argumente zu aktivieren,
führen Sie das Skript bitte erneut aus,
beispielsweise mit -CAS nach Perl als solchem ...

     perl -CAS ChangeNameOperation.pm
    
Um mehr zu erfahren, 
können Sie 
https://perldoc.perl.org/perlrun#-C-%5Bnumber/list%5D
anzeigen oder ausführen...

     perldoc perlrun
    
...und scrollen Sie zum Abschnitt „Befehlsschalter“
und lesen Sie den Abschnitt zum Schalter „-C“ darin.

Wenn Sie alternativ
UTF-8-Befehlszeilenargumente auf diese Weise nicht aktivieren können,
erwägen Sie, das Skript ohne Argumente auszuführen.
Stattdessen werden Sie zur Eingabe aufgefordert.',

'prompt_for.1or2'               =>  'Bitte geben Sie 1 oder 2 ein.',
'prompt_for.part'               =>
    
'
Bei Ihrer Suche haben wir übereinstimmende Datensätze gefunden,
die den folgenden Vornamen zugeordnet sind ...

Vornamen:
[_1]

...und die folgenden damit verbundenen Familiennamen...

Familiennamen:
[_2]

Wo möchten Sie Ihre Änderung zuerst durchführen?
     1) Vorname
     2) Familienname
',

'prompt_for.confirm' =>

'Bestätigen Sie, um den Namen von [_1] zu ändern von...

„[_2]“

...Zu...

"[_3]"

...für den Namen [_4] im Feld [_5] im folgenden Datensatz...

[_6]

...?',

'change.from.can'  =>

'Ändern...

[_1]
',

'change.from.cannot'  =>

'Änderung nicht möglich... 

[_1]
',

'change.to.can' =>

'...zu...

[_1]',

'change.to.cannot' =>

'...zu...

[_1]

..aufgrund einer Bearbeitungssperre für diesen Datensatz (Datensatz [_2]).',

'change.dry_run'    =>  'Nicht erledigt, da dies ein Probelauf ist. Damit die Änderungen übernommen werden, führen Sie das Skript erneut mit hinzugefügtem Flag --live aus.',

'change.done'       =>  'Fertig – die Änderung wurde für Sie vorgenommen.',

'seeking_confirmation.display_lines' =>

'
Für die eindeutige Namenskombination...

[_1]

... wurden die folgenden übereinstimmenden Datensätze gefunden:

[_2]',

'prompt_for.confirm.acceptable_input'  =>

'Geben Sie „J“ für „Ja“ ein.
Geben Sie „N“ für „Nein“ ein.
Geben Sie „ALLE“ für „Ja für alle verbleibenden“ für diese eindeutige Namenskombination ein.
Geben Sie „KEINER“ für „Nein zu allen verbleibenden“ für diese eindeutige Namenskombination ein.
',

'prompt_for.continue'                       =>  'Drücken Sie die ENTER- oder RETURN-Taste, um fortzufahren...',
'prompt_for.archive'                        =>  'Bitte geben Sie eine Archiv-ID an: ',
'prompt_for.search'                         =>  'Bitte geben Sie einen Suchbegriff ein:  ',
'prompt_for.replace'                        =>  'Bitte geben Sie einen Ersetzungsbegriff an: ',

'prompt_for.find'                           =>  

'Ihre Änderung wird mithilfe von „Suchen und Ersetzen“ durchgeführt
(wobei nach vollständigen und nicht nach teilweisen Übereinstimmungen gesucht wird
und die Groß-/Kleinschreibung nicht beachtet wird).

Was ist Ihr Suchwert beim Abgleich innerhalb von [_1]?
',

'prompt_for.find.error.no_part'             =>  

'Bei der Aufforderung,
einen Wert in einem bestimmten namensteil zu finden,
muss ein teil-Attribut festgelegt werden.',

'prompt_for.replace.prompt_on_blank'        =>  

'Wollten Sie absichtlich, dass der „Ersetzen“-Wert ein Leer-/Nullwert ist,
der, wenn er später während des Bestätigungsprozesses als Änderung bestätigt wird,
das Feld effektiv löscht?
Geben Sie J oder j für Ja oder etwas anderes für Nein ein: ',

'prompt_for.error.no_prompt_type'           =>  

'Kein Eingabeaufforderungstypargument für die Methode prompt_for bereitgestellt.',


'_validate.error.four_byte_character'       =>

'Dieses Skript unterstützt keine 
4-Byte-Zeichen in der Eingabe.',

'_validate.error.no_arguments'              =>

'Die private _validate-Methode wurde ohne Argumente aufgerufen.
und hatte daher keine Eingaben zur Validierung.
Die Methode erfordert mindestens eine Sache zur Validierung, ',

'_log.error.no_repository'                  =>  'Für die private _log-Methode ist ein gültiges EPrints::Repository-Objekt erforderlich, das als Attribut von $self festgelegt ist.',

'_confirmation_feedback.heading.confirmed_so_far'       =>  

'
Die von Ihnen bestätigten Datensätze sollen bisher geändert werden...

',

'_confirmation_feedback.heading.unique_name'            =>

'
Für den einzigartigen Namen [_1]...

Bestätigung | Zum Ändern aufzeichnen...
',

'_confirmation_feedback.record.confirmed_for_changing'  =>  

'[_1] | [_2]
',


'finish.change'     =>  '[quant,_1,Änderung] von [quant,_2,Änderungen] abgeschlossen.',

'finish.no_change'  => 'Keine Änderungen vorgenommen.', 

'finish.thank_you'  => 'Vielen Dank, dass Sie dieses Skript verwenden.',

);

my  @phrases = (
    'Constructed New Object Instance.'  =>  'Neue Objektinstanz erstellt.',
    'Commandline Options are...'        =>  'Befehlszeilenoptionen sind...',
    'Commandline Arguments are...'      =>  'Befehlszeilenargumente sind...',
    'Language set to [_1].'             =>  'Sprache auf [_1] eingestellt.',
    'Set initial instance attributes using params or defaults.' =>  'Legen Sie anfängliche Instanzattribute mithilfe von Parametern oder Standardwerten fest.',
    'Archive, repository, and log related params were all required for log methods.' =>  'Für die Protokollierung Methoden waren Archiv- und Repository-Attribute sowie mit der Protokollierung verbundene Parameter erforderlich.',
    'Now setting additional instance attributes from params...' => 'Jetzt werden zusätzliche Instanzattribute aus Parametern festgelegt ...',
    'Setting self-referential instance attributes...' => 'Selbstreferenzielle Instanzattribute festlegen...',
    'Set YAML configurations.' => 'Legen Sie YAML-Konfigurationen fest.',
    'Set search-fields.' => 'Legen Suchfelder.',
    'Setting further self-referential attributes...' => 'Derzeit werden weitere selbstreferenzielle Attribute gesetzt...',
    'Entering method.' => 'Jetzt innerhalb der Objektmethode.',
    'Name parts before we begin:' => 'Benennen Sie Teile, bevor wir beginnen:',
    'Set name parts according to language localisation as follows...' => 'Legen Sie Namensteile entsprechend der Sprachlokalisierung wie folgt fest ...',
    'Leaving method.' => 'Jetzt verlassen wir die Objektmethode.',
    'Entered method.' => 'Innerhalb der Methode.',
    'Searching...' => 'Jetzt auf der Suche...',
    'Found Results.' => 'Gefundene Ergebnisse.',
    'No Results Found.'=>'Keine Ergebnisse gefunden.',
    'Narrowing search to a specific part...' => 'Die Suche auf ein bestimmtes Teil eingrenzen...',
    'Generating lists, and setting values.' => 'Derzeit werden Listen erstellt und Werte festgelegt.',
    'DRY RUN mode - no changes will be made.'=>'DRY RUN-Modus – in diesem Modus werden tatsächlich keine Änderungen vorgenommen.',
    'LIVE mode - changes will be made at the end after confirmation.'=>'LIVE-Modus – Änderungen werden am Ende nach Bestätigung vorgenommen.',
    'Run again with the --live flag when ready to implement your changes.' => 'Führen Sie den Vorgang erneut mit dem Flag --live aus, wenn Sie bereit sind, Ihre Änderungen umzusetzen.',
    'Processing search field: [_1]'=>'Suchfeld wird verarbeitet: [_1]',
    'Leaving part_specific method.'=>'Verlassen der „part_specific“-Methode.',
    'Called display method.' => 'Wird als Anzeige Objektmethode bezeichnet.',
    'Processing Unique name: [_1]'=>'Eindeutiger Name für die Verarbeitung: [_1]',
    'Entered method. Attribute display_lines is...'=>'Eingegebene Methode. Das Attribut display_lines ist...',
    'Leaving method. Attribute display_lines is...'=>'Methode verlassen. Das display_lines-Attribut ist...',
    'Match found for: [_1]'=>'Übereinstimmung gefunden für: [_1]',
    'No match found.'=>'Keine Übereinstimmung gefunden.',
    'Matched "[_1]" in "[_2]" part of the following unique name...'=>'Entspricht „[_1]“ im „[_2]“-Teil des folgenden eindeutigen Namens...',
    'Found params, and about to process them...'=>'Parameter gefunden und bin bereit, sie zu verarbeiten...',
    'Stringified names for use in a localised display line.'=>'Stringifizierte Namen zur Verwendung in einer lokalisierten „display_line“(Anzeigezeile).',
    'Returning localised display line as we leave the method.'=>'Wir geben die lokalisierte Anzeigezeile zurück, da wir nun die Methode verlassen.',
    'Set display flags and added display line:'=>'Setzen Sie das Anzeigeflag und die hinzugefügten Anzeigezeilen:',
    'Leaving display method.'=>'Verlassen der „display“-Methode.',
    'Called confirm method.'=>'Wird als „confirm“-Objektmethode bezeichnet.',
    'Checking if display lines have been shown.'=>'Prüfe gerade, ob Anzeigezeilen angezeigt wurden.',
    'Setting confirmation'=>'Bestätigungswert festlegen.',
    'Processing confirmation...'=>'Bestätigungswert wird jetzt verarbeitet...',
    'Will check matches auto no result ([_1]) and matches auto yes result ([_2])...'=>'Überprüfe nun die Ergebnisse von „matches_auto_no“ ([_1]) und „matches_auto_yes“ ([_2]) ...',
    'Added details to what_to_change'=>'Details zu what_to_change hinzugefügt',
    'Leaving confirm method.'=>'Verlassen der „confirm“-Methode.',
    'Called change method.'=>'Wird als „change“-Objektmethode bezeichnet.',
    'Processing confirmation ([_1])' => 'Bestätigungswert wird jetzt verarbeitet ([_1])',
    'Premature exit - Prerequisites not met.'=>'Vorzeitiger Ausstieg – Voraussetzungen nicht erfüllt.',
    'Premature exit - Nothing to change.'=>'Vorzeitiger Ausstieg – Es gibt nichts zu ändern.',
    'Searching fields [_1] ...'=>'Derzeit verwenden wir die folgenden Suchfelder, um unsere Suche durchzuführen [_1] ...',
    'Using search settings...'=>'Die folgenden Sucheinstellungen zu verwenden....', # Google translate only gives German for use rather than using!?
    'Generated confirmation feedback.'=>'Generiertes Bestätigungs-Feedback.',
    'No confirmation feedback generated.'=>'Es wurde kein Bestätigungsfeedback generiert.',
    'Displaying generated confirmation feedback.'=>'Zeigt nun das generierte Bestätigungsfeedback an.',
    'Thank you for your patience. Your request is being processed...'=>'Vielen Dank für Ihre Geduld. Ihre Anfrage wird bearbeitet...',
    'Matched unique name.'=>'Der aktuelle Name stimmte mit dem eindeutigen Namen überein.',
    'Added record to confirmation feedback.'=>'Der Datensatz wurde unserer Bestätigungs-Feedback hinzugefügt.',
    'Since unique names are unique, we can leave unique name loop now we have processed a match.'=>'Da eindeutige Namen eindeutig sind, können wir die Schleife für eindeutige Namen verlassen, nachdem wir eine Übereinstimmung verarbeitet haben.',
    'Exited unique name loop.'=>'Aus der Schleife für eindeutige Namen ausgebrochen.',
    'This item (Record [_1]) is under an edit lock.'=>'Für dieses Element (Datensatz [_1]) besteht eine Bearbeitungssperre.',
    'Due to the edit lock presently on Record [_1], changes to Record [_1] were not saved.'=>'Aufgrund der aktuellen Bearbeitungssperre für Datensatz [_1] wurden Änderungen an Datensatz [_1] nicht gespeichert.',
    'Nothing was found to match.'=>'Es wurde keine Übereinstimmung festgestellt.',
    'Premature exit - No search results to narrow down.'=>'Vorzeitiger Ausstieg – Keine Suchergebnisse zum Eingrenzen.',
    'Premature Exit - our operation is already specific to a name part.'=>'Vorzeitiger Ausstieg – unser Vorgang ist bereits spezifisch für einen Namensteil.',
    'Premature exit - name parts already populated.'=>'Vorzeitiges Beenden – Listenvariable name_parts bereits gefüllt.',
    'Premature exit - no result passed in.'=>'Vorzeitiges Beenden – kein Ergebnis wird an die Unterroutine übergeben.',
    'Changed our working result - this will not be committed.'=>'Unsere Arbeitskopie des Ergebnisobjekts wurde geändert. Diese Änderungen werden nicht in der Datenbank „festgeschrieben“ (nicht gespeichert).',
    'Changed our fresh result - this will be committed.'=>'Unsere neue Kopie des Ergebnisdatensatzes wurde geändert. Diese Änderungen werden in Kürze in die Datenbank „übertragen“ (in Kürze gespeichert).',
    'Constructed New Logger Object Instance.'=>'Neue Logger-Objektinstanz erstellt.',
);

our %Lexicon = (
    #'_AUTO' => 1, # Commented out the auto for now.
    @configurations,
    @tokens,
    @phrases,
);

# ----------------------------------

1;

}

};

=pod End Language Packages

=back

=cut


=head2 ChangeNameOperation::Config

Package that loads configuration.

=cut


=head2 ChangeNameOperation::Config::YAML

Package storing YAML formatted default configuration settings.
Used if no external .yml file is provided.

=cut

# Load Configuration - positioned last and without a package block, so __DATA__ can be used:
package ChangeNameOperation::Config::YAML v1.0.0;

1;

=pod End of Packages.

=cut

=head1 AUTHOR

Andrew Mehta

=cut

__DATA__
# This is a YAML Configuration File:
%YAML 1.2
# Three dashes to start new YAML document.
---

EPrints Perl Library Path: /opt/eprints3/perl_lib/

Language Tag: en-GB

Fields to search:
    -   creators_name
    -   contributors_name
    -   editors_name

Dataset to use: eprint

Force commit changes to database: yes

# For the above, provide a yes or y (case insensitive) to force commit,
# or anything else (such as no) to not force commit.

Search Field Match Type: IN

Search Field Merge Type: ANY

# The "Search Field Match Type" parameter which can be one of:

# IN
# (short for index)
# Treat the value as a list of whitespace-seperated words. Search for each one in the full-text index.
# In the case of subjects, match these subject ids or the those of any of their decendants in the subject tree.

# EQ
# (short for equal)
# Treat the value as a single string. Match only fields which have this value.

# EX
# (short for exact)
# If the value is an empty string then search for fields which are empty, as oppose to skipping this search field.
# In the case of subjects, match the specified subjects, but not their decendants.

# SET
# If the value is non-empty.

# NO
# This is only really used internally, it means the search field will just fail to match anything without doing any actual searching.

# The "Search Field Merge Type" parameter can be one of:

# ANY
# Match an item if any of the space-separated words in the value match.

# ALL
# Match an item only if all of the space-separated words in the value match.

# "Search Field Merge Type" has no affect on EX matches, which always match the entire value.

...
# Three dots to end current YAML document.


__END__

Logger
	Construct from within operation.::DONE
	Have fall back ways to log if no valid repository submitted::DONE
	cluck does the same as the longmess trace, so we could use that instead::SKIP
		# cluck, longmess and shortmess not exported by default
		use Carp qw(cluck longmess shortmess);
		cluck "This is how we got here!"; # warn with stack backtrace
	Could add a set_repository method for setting the repository attribute after object construction.::DONE

Logging before logger:
	Use localise methods
Localiser
	language tag - use it::ALREADY-DONE
		if no -CAS then halt::DONE EARLIER VIA UTF-8 Check.
	no language tag - load from config::ALREADY-DONE
	fallback in effect via languages base class::ALREADY-DONE
	We could pass in $config->{messages} or similar, to store any logging we want.::NOT-APPLICABLE - localiser uses MakeText, and not our Log.
localise
	Check if you really want the say. You may want to have different methods for stdout and stderr::IMPROVED/DONE

Config
	As normal. If path faulty, it will fall back to internal config.::DONE
	Store messages instead of logging.::DONE
		Alternatively, we could pass in the modulino object, and store to the hash it has for deferred logs? Slightly pointless, it's only saving values to a hash.
	$config->{messages}->{verbose}
	$config->{messages}->{debug}
	$config->{messages}->{normal}
Halt
	To come after config and language.
	
Cleanup:
    You need to clean up the way localise and delayed localise is working within Modulino.
        You need to store messages,
        then later simply display them as appropriate.
        This needs some thought. Are we printing different types to different handles?
        Or all sequentially in order?
        The gist is to move the messages from start_operation to utf8_check, using the delayed feature,
        then print them all effectively in start_operation.
        My guess is all is much simpler than we think.
        Alternatively we could do an output_messages method before the start_operation.
        Give it some thought and do it tomorrow.

In summary....

What we appear to have is 

An approach to load config despite halt,
[if there are errors they will halt the program for us]
An approach to load a language despite a halt
[if there are errors, it will fall back to a known class]
...and the ability to log messages within the config, that can be displayed later.