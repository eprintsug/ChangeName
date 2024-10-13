#!/usr/bin/env perl

=pod LANGUAGES - List of Links to POD Languages

=encoding utf8

=head1 🌐 Language Links:

=over

=item * L<"🇬🇧 English (United Kingdom)"|/English (United Kingdom)>

=item * L<"🇩🇪 Deutsch (Deutschland)"|/Deutsch (Deutschland)>

=back

=cut

=pod English (United Kingdom) - English language will be mixed with code. Other languages will be in Language classes.

=head1 English (United Kingdom)

=cut

=pod FILENAME

=head2 FILENAME

ChangeName.pm

=cut

=pod Synopsis, Description, Options

=head2 SYNOPSIS

    # Run file at the command line:
    perl -CAS ./ChangeName.pm

    # Run at the command line with arguments and flags:
    perl -CAS ./ChangeName.pm MyArchive bob Bobbi given --exact --verbose --live

=head2 FILE DESCRIPTION

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
- the L</ChangeName> package.

=head2 ARGUMENTS

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

=head2 OPTIONS

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

=head2 PERL PACKAGES

=cut

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
    use Getopt::Long;

    ENSURE_EXPORTED_METHODS_AVAILABLE_FROM_START: BEGIN {
        our @EXPORT_OK =   qw(
            validate_class
            valid_object
            process_commandline_arguments
            get_options
            list_to_regex_logical_or_grouping
            is_populated_array_ref
            is_populated_hash_ref
            is_populated_scalar_ref
            is_true_or_zero
            chunkify
            stringify_array_ref            
        );
    }

    sub validate_class {
        my  ($self, $value, $acceptable_class)  =   @ARG;

        # OBJECT Validation:
        my  $valid_object                       =   _valid_object($self, $value);
        return                                      undef
                                                    unless $valid_object;

        # CLASS Validation:
        my  $valid_object_of_acceptable_class   =   $valid_object && $valid_object->isa($acceptable_class)? $valid_object:
                                                    undef;

        $self->logger                               ->set_caller_depth(4)
                                                    ->debug(
                                                        $valid_object_of_acceptable_class?  'utilities.validate_class.valid_class':
                                                        'utilities.validate_class.invalid_class',
                                                        blessed($valid_object),
                                                        $acceptable_class
                                                    )
                                                    ->set_caller_depth(3)
                                                    if _can_log($self);

        return                                      $valid_object_of_acceptable_class;
    }

    sub _valid_object {

        my  ($self, $value) =   @ARG;

        my  $valid_object   =   (defined $value) && blessed($value)?    $value:
                                undef;

        $self->logger           ->set_caller_depth(5)
                                ->debug(
                                    $valid_object?  'utilities.valid_object.valid_object':
                                    'utilities.valid_object.invalid_object'
                                )
                                ->set_caller_depth(4) 
                                if _can_log($self);

        return                  $valid_object;

    }

    sub valid_object {
        _valid_object(@ARG);
    }

    sub _can_log {
        my  $object =   shift;

        return
                defined $object
                && blessed($object)
                
                && $object->can('logger')
                && defined $object->logger
                && blessed($object->logger)
                
                && $object->logger->can('language')
                && defined $object->logger->language
                && blessed($object->logger->language);
    }

    sub get_options {
        return [process_commandline_arguments(@ARG)]->[0];
    }

    sub process_commandline_arguments {

        # Intial Values:
        my  $self                                   =   shift;
        my  $commandline_arguments                  =   shift;
        my  $expectations                           =   shift;
        my  $at_least_some_expectations             =   reftype($expectations) && (reftype ($expectations) eq 'HASH') && scalar keys %{$expectations};
        my  $option_types                           =   $at_least_some_expectations
                                                        && $expectations->{expected_options}
                                                        && reftype($expectations->{expected_options})
                                                        && (reftype($expectations->{expected_options}) eq 'HASH')
                                                        && scalar %{$expectations->{expected_options}}?     $expectations->{expected_options}:
                                                        _get_default_options($self);
        my  $expected_arguments                     =   $at_least_some_expectations
                                                        && $expectations->{expected_arguments}
                                                        && reftype($expectations->{expected_arguments})
                                                        && (reftype($expectations->{expected_arguments}) eq 'ARRAY')
                                                        && scalar @{$expectations->{expected_arguments}}?   $expectations->{expected_arguments}:
                                                        _get_default_expected_arguments($self);
        my  $arguments                              =   {};
        my  @options_specifications                 =   ();
        my  $suffix_for                             =   {
            simple_options                          =>  q{},
            optional_strings                        =>  ':s',
            negatable_options                       =>  '!',
            incremental_options                     =>  '+',
        };


        $self                                           ->logger
                                                        ->debug('Passed in commandline arguments from which to derive both options and arguments from are as follows...')
                                                        ->dumper($commandline_arguments)
                                                        if _can_log($self);

        # Definition:
        my  $valid_destructable_copy_of_arguments   =   $commandline_arguments && reftype($commandline_arguments) && (reftype($commandline_arguments) eq 'ARRAY')?  [(@{ $commandline_arguments })]:
                                                        undef;

        $self                                           ->logger
                                                        ->debug('Validated copy of arguments is as follows...')
                                                        ->dumper($valid_destructable_copy_of_arguments)
                                                        if _can_log($self);

        # Processing:
        my  $default_options                        =   {map {%{ $option_types->{$ARG} }} keys %{$option_types}};

        $self                                           ->logger
                                                        ->debug('Flattened list of default options are as follows...')
                                                        ->dumper($default_options)
                                                        if _can_log($self);

        for my $option_type (keys %{ $option_types }) {
            push @options_specifications            ,   (
                                                            map {
                                                                _multilingual_option_specification(
                                                                    $self, $ARG, $suffix_for->{$option_type}
                                                                )
                                                            }
                                                            keys %{
                                                                $option_types->{$option_type}
                                                            }
                                                        );
        };

        $self                                           ->logger
                                                        ->debug('Option Specifications have been determined as being as follows...')
                                                        ->dumper(@options_specifications)
                                                        if _can_log($self);

        Getopt::Long::Parser->new->getoptionsfromarray($valid_destructable_copy_of_arguments, $default_options, @options_specifications);

        my  @list_of_arguments                      =   @{ $valid_destructable_copy_of_arguments };
        my  $no_input                               =   !(scalar @list_of_arguments);
        for (@{ $expected_arguments }) {
            $arguments->{$ARG}                      =   shift @list_of_arguments;
        };

        # Output:

        $self                                           ->logger
                                                        ->debug('Options after processing the commandline arguments are now as follows...')
                                                        ->dumper($default_options)
                                                        ->debug('Arguments after processing the commandline arguments are as follows...')
                                                        ->dumper($arguments)
                                                        ->debug('The no_input flag will be returned with the value: "[_1]".', $no_input)
                                                        if _can_log($self);

        return ($default_options, $arguments, $no_input);

    }

    sub _get_default_options {

        my  $self                       =   shift;

        my  $default_options            =   {
            simple_options              =>  {
                trace                   =>  0,
                no_trace                =>  0,
                live                    =>  0,
                debug                   =>  0,
                exact                   =>  0,
                no_dumper               =>  0,
            },
            optional_strings            =>  {
                language                =>  undef,
                config                  =>  undef,
            },
            negatable_options           =>  {
                # Negatable options do not allow
                # for the negating "no" prefix to be localised.
                # To have full control over the localisation
                # consider using dedicated simple options
                # for both the option and the negated option,
                # and then process them in your business logic.
            },
            incremental_options         =>  {
                verbose                 =>  0,
            },
        };

        $self->logger->debug('Default options set as follows...')->dumper($default_options) if _can_log($self);

        return $default_options;

    }

    sub _get_default_expected_arguments {

        my  $self                       =   shift;

        my  $default_expected_arguments =   [
                                                # Enter List of expected arguments, if any.
                                            ];

        $self->logger->debug('Default expected arguments were requested and are being returned as follows...')->dumper($default_expected_arguments) if _can_log($self);

        return $default_expected_arguments;

    }

    sub _multilingual_option_specification {

        # Initial Values:
        my ($self, $option, $option_suffix) =   @ARG;
        my  @skip                           =   ();

        $self->logger->debug('Starting subroutine.')
        if _can_log($self);

        my  %multilingual_options_hash      =   ChangeName::Languages->maketext_in_all_languages('options.'.$option);

        # Premature exits:
        return @skip unless ($option || ($option eq '0'));
        return @skip unless %multilingual_options_hash;

        $self->logger->debug('Multilingual variations of [_1] are as dumped below...', $option)->dumper({%multilingual_options_hash})
        if _can_log($self);

        # Further Initial Values:
        my  $blank                          =   q{};
        $option_suffix                      //= $blank;
        my  $option_separator               =   '|';

        # Regular Expressions:
        my  $contiguous_white_space         =   qr/
                                                    [\p{White_Space}\p{Pattern_White_Space}]    # Set of Properties that count as white space.
                                                    +                                           # Anything in the set one or more times.
                                                /x;                                             # x - to allow whitespace and comments in regex.
                                                                                                # Note x does not allow whitespace within the angled brackets
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
        foreach my $translation (values %multilingual_options_hash) {

            $translation                    =   $translation =~ $matches_leading_whitespace?   $+{data}:
                                                $translation;

            $self->logger->debug('Initial option translation...')->dumper($translation)
            if _can_log($self);

            my  @values                     =   map {
                                                    my  $value              =   $ARG;
                                                    my  @value_to_use       =   $used_already->{$value}?    @skip:
                                                                                ($value);
                                                    $used_already->{$value} =   1;
                                                    @value_to_use;
                                                }
                                                split $contiguous_white_space, $translation;
            if ( _can_log($self) ) {
                $self                           ->logger
                                                ->debug('Option translation as a list with codebase\'s existing option key "[_1]" omitted...', $option)
                                                ->dumper(@values)
                                                if @values;

                $self                           ->logger
                                                ->debug('No list of translation values to add alongside codebase\'s existing option key "[_1]" for language [language_name].', $translation)
                                                unless @values;
            };

            $our_option_string              .=  @values? $option_separator.join($option_separator, @values):
                                                $blank;

        };

        $our_option_string                  .=  $option_suffix;

        # Output:

        $self->logger->debug('Option string is: [_1]', $our_option_string)->debug('Leaving subroutine.')
        if _can_log($self);

        return $our_option_string;

    }

    sub list_to_regex_logical_or_grouping {

        my  $self   =   shift;

        return  join(

            # Join by regex OR...
            '|',

            # Regex safe:
            map {quotemeta($ARG)}

            # List:
            (@ARG)

        );

    }

    sub _is_populated_ref {
        my  $self       =   shift;
        my  $value      =   shift;
        my  $type       =   shift;
        return              $value
                            && reftype($value)
                            && (
                                reftype($value) eq $type
                            )
                            && (
                                $type eq 'ARRAY'?   scalar @{$value}:
                                $type eq 'HASH'?    scalar %{$value}:
                                $type eq 'SCALAR'?  is_true_or_zero($self, ${$value}):
                                undef
                            )? $value:
                            undef;
    }

    sub is_populated_array_ref {
        _is_populated_ref(shift, shift, 'ARRAY');
    }

    sub is_populated_hash_ref {
        _is_populated_ref(shift, shift, 'HASH');
    }

    sub is_populated_scalar_ref {
        _is_populated_ref(shift, shift, 'SCALAR');
    }

    sub is_true_or_zero {
        my  $self   =   shift;
        my  $value  =   shift;
        return          defined $value
                        && (
                            $value || $value eq '0'
                        );
    }

    sub chunkify {

        # Initial Values:
        my  ($self, $list, $chunk_size) =   @ARG;
        $chunk_size                     //= 100;
        my  $valid_list                 =   $self->validate_class(
                                                ($list // $self->get_list_of_results) => 'EPrints::List',
                                            );
        my  @list_of_arrayrefs          =   ();

        # Processing:
        if ($valid_list) {
            $self->logger->debug('Valid list object. Proceeding to chunkify using chunk size [_1]...', $chunk_size) if _can_log($self);

            for (my $offset = 0; $offset < $valid_list->count; $offset += $chunk_size) {

                $self->logger->debug('Adding a chunk, from a list offset of [_1].', $offset) if _can_log($self);

                push @list_of_arrayrefs     ,   [$valid_list->slice($offset, $chunk_size)];

            };
        }
        else {
            $self->logger->debug('Invalid list object. Returning the default result - an empty list that will return false in scalar context.') if _can_log($self);
        };  

        # Output:    
        return @list_of_arrayrefs;

    }

    sub stringify_array_ref {
        return join shift->language->localise('separator.stringify_array_ref'), @{ (shift) };
    }

    1;

} # ChangeName::Utilities Package.


=head2 ChangeName::Config::YAML

Package storing YAML formatted default configuration settings.
Used if no external .yml file is provided.

=cut
package ChangeName::Config::YAML v1.0.0 {

sub data {

return
'
# This is a YAML Configuration File:
%YAML 1.2
# Three dashes to start new YAML document.
---

EPrints Perl Library Path: /opt/eprints3/perl_lib/

'. #Language Tag: en-GB
'
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
'
};

1;

} # ChangeName::Config::YAML Package.


=head3 ChangeName::Config

Package that loads configuration.

=cut
package ChangeName::Config v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.

    # Specific:
    LOAD_UTILITIES_FIRST: BEGIN {

        ChangeName::Utilities->import(qw(
            get_options
        ));

    }
    use     File::Basename;         # Will use this to get the directory name that this file is in,
                                    # when looking for yaml file.
    use     CPAN::Meta::YAML qw(
                LoadFile
                Load
            );                      # Standard module in Core Perl since Perl 5.14. 
                                    # Better to use YAML::Tiny for YAML, except that is not in core, and this is.
    use     Scalar::Util qw(
                reftype
            );

    sub new {
        my  $class                              =   shift;
        my  $params                             =   {@ARG};
        my  $self                               =   {};
        bless $self                             ,   $class;

        my  $valid_options_param                =   exists $params->{options} && reftype($params->{options}) && (reftype($params->{options}) eq 'HASH') && scalar keys %{ $params->{options} }?    $params->{options}:
                                                    undef;

        $self->{options}                        =   $valid_options_param?   $valid_options_param:
                                                    $self->get_options($params->{commandline_arguments}); # No validation that get_options returns okay.

        my  $valid_external_filepath_string     =   exists $self->{options}->{config} && $self->{options}->{config}?                $self->{options}->{config}:
                                                    exists $params->{external_yaml_filepath} && $params->{external_yaml_filepath}?  $params->{external_yaml_filepath}:
                                                    undef;

        %{
            $self
        }                                       =   (

            # Existing values in $self:
            %{$self},

            # Defaults:
            default_yaml_filepath               =>  dirname(__FILE__).'/ChangeNameConfig.yml',
            data                                =>  undef,
            messages                            =>  {
                                                        error   =>  [],
                                                        debug   =>  [],
                                                        verbose =>   [],
                                                    },
            external_yaml_filepath              =>  $valid_external_filepath_string,
        );

        return $self;

    }

    sub load {

        # Initial Values:
        my  $self                               =   shift;
        my  $external_filepath                  =   shift // $self->get_external_yaml_filepath;
        my  $default_filepath                   =   $self->get_default_yaml_filepath;

        # Definitions:    
        my  $external                           =   defined $external_filepath
                                                    && (
                                                        $external_filepath eq '0'?  1:
                                                        $external_filepath
                                                    )
                                                    && -e $external_filepath;

        my  $external_not_found                 =   defined $external_filepath
                                                    && (
                                                        $external_filepath eq '0'?  1:
                                                        $external_filepath
                                                    )
                                                    && !(-e $external_filepath);

        my  $default                            =   defined $default_filepath
                                                    && $default_filepath
                                                    && -e $default_filepath;

        my  $fellback_to_default                =   $external?  undef:
                                                    $default?   1:
                                                    undef;

        my  $internal                           =   $external?  undef:
                                                    $default?   undef:
                                                    1;

        # Processing:
        $self->{data}                           =   # External YAML file:
                                                    $external?  LoadFile($external_filepath):           # Will die on any load error.
                                                    $default?   LoadFile($default_filepath):            # Will die on any load error.
                                    
                                                    # Internal YAML __DATA__:
                                                    Load(ChangeName::Config::YAML::data);      # Will die on any load error.
                
            
                                                        #do {                                            # 'do' returns last value of block.
                                                        #    local $INPUT_RECORD_SEPARATOR = undef;      # Read until end of input.
                                                        #    <ChangeName::Config::YAML::DATA>   # Input is __DATA__ at the bottom of this very file.
                                                        #}
                                                    #);

        # Messages:                                    
        push @{ $self->{messages}->{error} }    ,   ['config.load.error.custom_external_not_found', $external_filepath]
                                                    if $external_not_found;

        push @{ $self->{messages}->{debug} }    ,   ['config.load.debug.default_external_not_found', $default_filepath]
                                                    unless $default;

        push @{ $self->{messages}->{verbose} }  ,   (
                                                        $external?              ['config.load.verbose.loaded_file', $external_filepath]:
                                                        $fellback_to_default?   ['config.load.verbose.loaded_file', $default_filepath]:
                                                        $internal?              ['config.load.verbose.internal']:
                                                        ()
                                                    );

        # Output:             
        return $self;
        
    };
    
    sub get_data {
        return shift->{data};
    }

    sub get_messages {
        return shift->{messages};
    }

    sub get_data_and_messages {

        my  $self   =   shift;

        return  ($self->{data}, $self->{messages});

    }

    sub get_default_yaml_filepath {
        return shift->{default_yaml_filepath};
    }

    sub get_external_yaml_filepath {
        return shift->{external_yaml_filepath};
    }

    1;

}; # ChangeName::Config Package.


=head3 ChangeName::Languages

MakeText project class for loading language classes.

=cut
package ChangeName::Languages v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                  # Use full english names for special perl variables,
                                # except the regex match variables
                                # due to a performance if they are invoked,
                                # on Perl v5.18 or lower.

    # Specific:
    use     parent qw(Locale::Maketext);
    use     mro;
    use     Scalar::Util qw(
                reftype
                blessed
            );

    my  @tokens = (
        'separator.name_parts'              =>  ' ',            # space
        'separator.name_values'             =>  ', ',           # comma, space
        'separator.new_line'                =>  "\n",           # new line
        'separator.search_fields'           =>  ', ',           # comma, space
        'separator.stringify_array_ref'     =>  ', ',           # comma, space
        'horizontal.rule'                   =>  "\n-------\n",  # new line, horizontal line made of dashes, new line.
    );

    my  @configurations = (
        # Ignores formatting and case
        # and focuses on desired order.
        # Ignores characters or words 
        # that are not an EPrints::MetaField::Name name part.
        # This is a default version of name_parts.display_order for when no language has been set.
        'name_parts.default_display_order'  =>  'honourific, given, family, lineage',

    );

    my  @phrases = (
    );

    our %Lexicon = (
        #'_AUTO' => 1, # Commented out the auto for now.
        @configurations,
        @tokens,
        @phrases,
    );

    sub priority_language_class {
        return 'en_gb'; # Will be prioritised in ordered_language_handles method and thus also prioritised in any multi-language translations.
    }

    sub fallback_language_classes {
        my  $self   =   shift;
        # I believe these are to be given as relative to ChangeName::Languages
        # rather than a full qualified class name like ChangeName::Languages::en_gb
        my  @list_of_classes    =   (
            $self->ordered_language_handles,
        );
        return @list_of_classes;
    }
    
    sub ordered_language_handles {

        # Initial Values:
        my  $self                                   =   shift;

        my  $language_base_class                    =   __PACKAGE__;
        my  $priority_handle                        =   $self->priority_language_class;
        my  @full_class_names                       =   @{ mro::get_isarev($language_base_class) };

        my  @ordered_language_handles               =   ();

        # Regex:
        my  $matches_and_captures_language_handle   =   qr/
                                                            (?<captured_language_handle>    # Start named capture group.
                                                                [^:]+                       # One or more of anything except a colon.
                                                            )                               # End named capture group.
                                                            $                               # End of string.
                                                        /x;                                 # x flag - Ignore white space and allow comments.

        # Filters:
        my  $language_handle_only_filter            =   sub {
                                                            map {
                                                                $ARG
                                                                && ($ARG =~ $matches_and_captures_language_handle)?  $+{captured_language_handle}:
                                                                ()
                                                            } @ARG;
                                                        };

        my  $priority_only_filter                   =   sub {
                                                            map {
                                                                $ARG
                                                                && $ARG eq $priority_handle?   $ARG:
                                                                ()
                                                            } @ARG;
                                                        };

        my  $non_priority_filter                    =   sub {
                                                            map {
                                                                $ARG 
                                                                && $ARG ne $priority_handle?   $ARG:
                                                                ()
                                                            } @ARG;
                                                        };
                                                        
        my  $sort_alphabetically                    =   sub {
                                                            sort { $a cmp $b } @ARG
                                                        };
        
        my  $reverse_order_of_final_result          =   1; # Boolean

        # Processing:
        my  @language_handles                       =   $language_handle_only_filter->(@full_class_names);

        # Premature exit:
        return () unless @language_handles;

        # Further Processing:
        my  @found_priority_handle                  =   $priority_only_filter->(@language_handles);
        my  @non_priority_handles                   =   $non_priority_filter->(@language_handles);

        # Lead with priority...
        push @ordered_language_handles              ,   @found_priority_handle
                                                        if @found_priority_handle;

        # ...followed by others...                      ...sorted:
        push @ordered_language_handles              ,   $sort_alphabetically->(@non_priority_handles);

        # Output:
        return  $reverse_order_of_final_result? reverse @ordered_language_handles:
                @ordered_language_handles;

    } # technically, these are ordered classes rather than language handle objects.

    sub ordered_language_names {

        # Initial Values:
        my  $self                                   =   shift;
        my  @output_strings                         =   ();

        for my $language_handle ($self->ordered_language_handles) {

            my  $language_instance                  =   (__PACKAGE__.'::'.$language_handle)->new;

            next unless $language_instance;

            push @output_strings                    ,   $language_instance->language_name;

        };

        my  $output_strings                         =   join $Lexicon{'separator.name_values'}, @output_strings;

        return  wantarray?  @output_strings:
                $output_strings;
    }

    sub maketext_in_all_languages {

        # Initial Values:
        my  $self                                   =   shift;
        my  $phrase_key                             =   $ARG[0];
        my  $phrase_considered_universal            =   scalar (grep {$phrase_key && $phrase_key eq $ARG} keys %Lexicon);  # Inspired by David (and the "any" documentation).
        my  @in_all_languages                       =   ();
        my  $in_all_languages_string                =   q{};
        my  $language_base_class                    =   __PACKAGE__;
        my  $format                                 =   "%s: %s\n"; # String, colon, space, string, newline (useful as line seperator).
        my  $remove_trailing_new_line               =   qr/\n$/;    # Remove any trailing newline possibly left by the above format.

        # Processing:
        for my $language_handle ($self->ordered_language_handles) {
                                                        
            if ($language_handle) {

                my  $language_instance              =   ($language_base_class.'::'.$language_handle)->new;

                next unless $language_instance;

                my  $language_tag                   =   $language_instance->language_tag # Typically lower-case.
                                                        || undef; # Or undefined.

                next unless $language_tag;

                my  $phrase                         =   $language_instance->maketext(@ARG);
                my  $phrase_is_valid                =   $phrase || $phrase eq '0';
                

                # HASH context:
                push @in_all_languages, (
                    "$language_tag"                 =>  $phrase_is_valid?   $phrase:
                                                        undef,
                );

                # SCALAR context...

                $in_all_languages_string            .=  (
                                                            $phrase_considered_universal?   $phrase:
                                                            sprintf($format, uc($language_tag), $phrase)
                                                        )
                                                        if $phrase_is_valid; #...if valid phrase.
                                                        
                last if $phrase_considered_universal;

            };

        };
        $in_all_languages_string                    =~  s/$remove_trailing_new_line//;

        #Output:
        return  wantarray?  @in_all_languages:  # key value pairs in a list
                $in_all_languages_string;       # Multi-line string
    }

    sub nest {
        my  $self   =   shift;
        die             ChangeName::Languages::maketext_in_all_languages('nest.error.language') unless _can_maketext($self);
        my  $key    =   shift;
        my  $result =   $self->maketext($key)
                        // $self->maketext('nest.error.key'); # This error will never get used, as a failed maketext will die unless you have a custom failure method denoted via fail_with method.
        my  $string =   reftype($result) && (reftype($result) eq 'SCALAR')? ${  $result }:
                        $result;
        return $string;
    }

    sub _can_maketext {
        my  $self   =   shift;
        return          defined($self)
                        && blessed($self)
                        && $self->isa('ChangeName::Languages')
                        && $self->can('maketext');
    }

    1;

}; # ChangeName::Languages Package.

package ChangeName::Language v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.
                                    
    ChangeName::Languages->import;
    use     Scalar::Util qw(
                reftype
            );
    #use Data::Dumper;
    #use lib '/opt/eprints3/perl_lib/';
    #use EPrints;

    # Construct Object:
    sub new {
        # Initial Values;
        my  $class              =   shift;
        my  @language_tags      =   @ARG;
        my  @default_attributes = (
            language_handle     =>  undef,
        );
        my  $self               =   {@default_attributes};
#warn 'lang new caller'."\n".Dumper(caller);
        # Object Creation:
        bless $self             ,   $class;
        
        # Set Attributes:
        $self->set_language_handle(@language_tags) if @language_tags;
                            
        # Output:
        return $self;
    }

    # Instance Methods:
    sub localise {
            my  $self   =   shift;
            #say 'Dumping localise caller...'."\n".Dumper (caller);
#        EPrints->trace;
 #       say Dumper(@ARG? @ARG: 'No args');
            return          $self->{language_handle}?   $self->{language_handle}->maketext(@ARG):
                            scalar ChangeName::Languages->maketext_in_all_languages(@ARG);
    }

    sub localise_no_formatting {
            my  $self   =   shift;
            #say 'Dumping localise caller...'."\n".Dumper (caller);
            return          $self->{language_handle}?   $self->{language_handle}->maketext(@ARG):
                            (values %{{(ChangeName::Languages->maketext_in_all_languages(@ARG))}}); # Attempting list context.
    }

    sub get_first_localisation_for {
        #EPrints->trace;
        #say Dumper(@ARG);
        [(shift->localise_no_formatting(@ARG))]->[0];   # Uses localise to obtain
                                                        # the current language translation,
                                                        # or all language translations,
                                                        # and takes the first result of either situation, delivering only one string back.

    }

    sub localise_regex_or {
            my  $self   =   shift;
            #say 'Dumping localise caller...'."\n".Dumper (caller);
            return          $self->{language_handle}?   quotemeta($self->{language_handle}->maketext(@ARG)):
                            join '|', map {quotemeta($ARG)} values %{{(ChangeName::Languages->maketext_in_all_languages(@ARG))}};
    }

    sub matches_case_sensitively {
        shift->_get_match(0,@ARG);
    }

    sub matches_case_insensitively {
        shift->_get_match(1,@ARG);
    }

    sub _get_match {
        #warn 'Eprint trace for _get_match...';
        #EPrints->trace;
        # Initial Values:
        my  $self                   =   shift;
        my  $case_insensitive       =   shift; # expects true or false value - i.e 1 or 0.
        my  $value                  =   shift;

        # Premature Exit:
        return                          undef
                                        unless $value;

        # More Initial Values:
        my  $many                   =   reftype($ARG[0]) && (reftype($ARG[0]) eq 'ARRAY');
        my  $regex_string           =   q{};


        # Processing Regex String - many or single:

        if ($many) {

            # Initial Values:
            my  @array_refs_only    =   grep {reftype($ARG) && (reftype($ARG) eq 'ARRAY')} @ARG;
            my  @regex_strings      =   ();

            # Processing:
            foreach my $current_phrase_and_arguments (@array_refs_only) {
                my  @arguments      =   @{ $current_phrase_and_arguments };
                push @regex_strings ,   $self->{language_handle}?   quotemeta($self->{language_handle}->maketext(@arguments)):
                                        join '|', map {quotemeta($ARG)} values %{{(ChangeName::Languages->maketext_in_all_languages(@arguments))}};

            }

            # Output:
            $regex_string           =   join '|', @regex_strings;

        }
        else {
            # Output:
            $regex_string           =   $self->{language_handle}?   quotemeta($self->{language_handle}->maketext(@ARG)):
                                        join '|', map {quotemeta($ARG)} values %{{(ChangeName::Languages->maketext_in_all_languages(@ARG))}};
        }
        #warn '_get_match regex string:'.Dumper($regex_string);
        #EPrints->trace;
        # Processing Match:
        my  $matches                =   $case_insensitive?  qr/^($regex_string)$/i:
                                        qr/^($regex_string)$/;

        my  $match                  =   $value && ($value =~ $matches);

        # Output:
        return $match;

    }


    sub set_language_handle {
        my  $self                       =   shift;

  #      warn 'set_language_handle caller'."\n".Dumper(caller);

        return                              $self
                                            unless @ARG;

        my  @nothing                    =   ();

        my  @defined_values             =   (
                                                map {
                                                    (defined $ARG)?   $ARG:
                                                    @nothing
                                                }
                                                @ARG
                                            );

   #     warn "Def values:\n".Dumper(@defined_values);

        if (@defined_values) {
            $self->{language_handle}    =   ChangeName::Languages->get_handle(@defined_values) 
                                            || die scalar ChangeName::Languages->maketext_in_all_languages('language.error.set_language_handle');
        };

        return $self;
    }

    sub unset_language_handle {
        my  $self   =   shift;
        $self->{language_handle}   =   undef;
        return $self;
    }
    
    sub get_language_handle {
        shift->{language_handle};
    }

    1;

} # ChangeName::Language Package.



=head3 ChangeName::Log

Allows for creating a logger object
that has methods related to logging
verbose, debug, trace, and data dumper output
to the EPrints log.

=cut
package ChangeName::Log v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance if they are invoked,
                                    # on Perl v5.18 or lower.

    # Specific:
    LOAD_UTILITIES_FIRST: BEGIN {

        ChangeName::Utilities->import(qw(
            validate_class
            list_to_regex_logical_or_grouping
            is_populated_array_ref
        ));

    }
    use     lib ChangeName::Config->new(commandline_arguments => \@ARGV)->load->get_data->{'EPrints Perl Library Path'};
    use     EPrints;
    use     EPrints::Repository;
    use     Scalar::Util qw(
                blessed
                reftype
            );
    use     Data::Dumper;

=pod Name, Version

=encoding utf8

=over

=over

=item MODULE NAME

ChangeName

=item VERSION

v1.0.0

=cut

=pod Synopsis, Description

=item SYNOPSIS

    # Run at the command line:
    perl -CAS ./ChangeName.pm
    
    # Use in a unit test or other Perl Script:
    use ChangeName;
    
    my $object = ChangeName::Operation->new(@object_params);


=item DESCRIPTION

Calls a subroutine when ran from the commandline.
Currently set to call L</start_from_commandline>.

    # Run from the command line:
    perl -CAS ./ChangeName.pm

Loads the class when used in another script.

    # Use in a unit test or other Perl Script:
    use ChangeName;
    
    my $object = ChangeName::Operation->new(@object_params);

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

        # Initial Values:
        my  ($self, $params)            =   @ARG;
        my  @nothing                    =   ();

        # Some Validation:
        my  $acceptable_language_class  =   'ChangeName::Language';
        my  $valid_language_object      =   $self->validate_class($params->{language} => $acceptable_language_class);

        # Object Attributes:
        %{
            $self
        }                               =   (

            # Existing values in $self:
            %{$self},

            # From params:
            debug                       =>  $params->{debug} // 0,
            verbose                     =>  $params->{verbose} // 0,
            trace                       =>  (
                                                $params->{no_trace} < 1
                                                &&
                                                (
                                                    ($params->{verbose} > 2)
                                                    || ($params->{debug} && $params->{verbose})
                                                    || ($params->{debug} && $params->{trace})
                                                )
                                            ),
            no_dumper                   =>  $params->{no_dumper} // 0,
            no_trace                    =>  $params->{no_trace} // 0,

            caller_depth                =>  3,  # Three for logging this class, then after construction,
                                                # the new method sets it to four for logging external calls.

            dumper_class_name_only      =>  $params->{dumper_class_name_only} // [],

            dumper_exclude              =>  $params->{dumper_exclude} // [],

            # Internationalisation:
            acceptable_language_class   =>  $acceptable_language_class,

            language                    =>  $valid_language_object? $valid_language_object:
                                            $acceptable_language_class->new(
                                                (
                                                    (
                                                        exists $params->{language} 
                                                        && defined $params->{language} 
                                                        && $params->{language}
                                                    )
                                                    || @nothing
                                                )
                                            ),
            # EPrints specific:
            acceptable_repository_class =>  'EPrints::Repository',
        );

        $self->{repository}             =  $self->validate_class($params->{repository} => $self->get_acceptable_repository_class); # Requires language to be set first.
        $self->{dumper_default}         =  $self; # Isn't this frozen in time?

        return  $self;
    }

    sub get_acceptable_repository_class {
        return shift->{acceptable_repository_class};
    }

    sub language_is_set {
        my  $self   =   shift;
        return $self->language && $self->language->get_language_handle;
    }

    sub set_dumper_class_name_only {
        my  $self                       =   shift;
        my  $value                      =   shift;
        my  $valid_value                =   $self->is_populated_array_ref($value);

        $self->{dumper_class_name_only} =   $valid_value?   $valid_value:
                                            $self->{dumper_class_name_only};

        return $self;
    }

    sub get_dumper_class_name_only {
        shift->{dumper_class_name_only};
    }

    sub add_dumper_class_name_only {

        my  $self   =   shift;

        $self->set_dumper_class_name_only(
            [
                (
                    $self->is_populated_array_ref($self->get_dumper_class_name_only)?   @{ $self->get_dumper_class_name_only }:
                    ()
                ),

                @ARG,

            ]
        ); 

        return $self;
    }

    sub set_dumper_exclude {
        my  $self                       =   shift;
        my  $value                      =   shift;
        my  $valid_value                =   $value
                                            && reftype($value)
                                            && (reftype($value) eq 'ARRAY')?  $value:
                                            undef;

        $self->{dumper_exclude}         =   $valid_value?   $valid_value:
                                            $self->{dumper_exclude};

        return $self;
    }

    sub replace_language_object {
        my  $self                   =   shift;

        $self->debug('Entering method.')->debug('Current language object is as follows...')->add_dumper_class_name_only('language_handle')->dumper($self->{language});

         # Initial values:
        my  $new_language_object    =   shift;

        # Premature exit:
        return                          $self->debug('Leaving method prematurely due to no replacement provided.')
                                        unless $new_language_object;

        $self->debug('Proposed replacement language object is as follows...')->add_dumper_class_name_only('language_handle')->dumper($new_language_object);

        # Initial values:
        my  $valid_language_object  =   $self->validate_class($new_language_object => $self->{acceptable_language_class});

        # Processing:
        if ($valid_language_object) {
            $self->debug('Proposed replacement was found to be a valid language object.');
            $self->{language}       =   $valid_language_object;
            $self->debug('Replacement operation performed.');
        }

        # Output:
        return $self->debug('Leaving method.');
    }

    sub language {
        shift->{language};
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
        my  $self                           =   shift;
        my  $replacement_repository         =   shift;

        $self->{repository}                 =   $self->validate_class($replacement_repository => $self->get_acceptable_repository_class)
                                                // $self->debug('log.set_repository.error.bad_value')->{repository};

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

        return          $self->debug('Data dump prevented by no_dumper option.')
                        if $self->{no_dumper};

        return          $self->debug('Premature exit - Prerequisites not met.')
                        unless ($self->{debug} || $self->{verbose} > 1);

        # Default Params if no arguments passed in...
        my  $exclude    =   $self->list_to_regex_logical_or_grouping(
                                # List of attributes to exclude from dump...
                                (
                                    #    'repository',
                                    @{ $self->{dumper_exclude} },
                                )
                            );

        #warn 'dumper_class_name_only currently set as follows
        #
        #'.Dumper($self->get_dumper_class_name_only);

        my  $class_only =   $self->list_to_regex_logical_or_grouping(
                                # List of attributes
                                # that are objects
                                # we wish to dump only
                                # the class names of:
                                (
                                    @{ $self->get_dumper_class_name_only },
                                )
                            );

        my  %default    =   map
                            {
                                $ARG =~ m/^($class_only)$/
                                && blessed($self->{dumper_default}->{$ARG})?  ($ARG => blessed($self->{dumper_default}->{$ARG})):
                                ($ARG => $self->{dumper_default}->{$ARG})
                            }
                            map {$ARG =~ m/^($exclude)$/? ():($ARG)}
                            keys %{$self->{dumper_default}};
        #warn 'Dumper Default Self'.Dumper($self->{dumper_default});
        # Set params:
        my  @params     =   @ARG?   @ARG:
                            (\%default);
        #warn 'Dumper Default Processed Default Hash'.Dumper(%default);
        return $self->_log('dumper',@params);
    }

    sub _log {

        # Initial Values:
        my  $self                   =   shift;
        my  $type                   =   shift;
        my  $use_prefix             =   $self->{verbose} > 1 || $self->{debug};

        my  $valid_repository       =   $self->validate_class($self->{repository} => $self->get_acceptable_repository_class);

        my  $language_handle        =   $self->language->get_language_handle;
        my  $blank                  =   q{};
        my  $messages               =   $blank;
        my  $trace_prefixes         =   $blank;
        my  $loop_count             =   0;
        my  $format                 =   '%s: '; # String, colon, space. Used for language prefix (lang_prefix).
        
        # Data Dumper Settings:
        $Data::Dumper::Maxdepth     =   4;  # So when we dump we don't get too much stuff.
        $Data::Dumper::Sortkeys     =   1;  # Hashes in same order each time - for easier dumper comparisons.
        $Data::Dumper::Useperl      =   1;  # Perl implementation will see Data Dumper adhere to our binmode settings.
        no warnings 'redefine';
        local *Data::Dumper::qquote =   sub { qq["${\(shift)}"] };  # For UTF-8 friendly dumping - see: https://stackoverflow.com/questions/50489062/
        use warnings 'redefine';

        # Content:

        my  @languages              =   $language_handle?  ($language_handle->language_tag):
                                        ChangeName::Languages->ordered_language_handles;

        my  $number_of_languages    =   scalar @languages;

        foreach my $current_language (@languages) {

            $self->language->set_language_handle($current_language);

            my  $last_loop          =   ++$loop_count eq $number_of_languages;

            my  $suffix             =   $last_loop? $blank:
                                        $self->language->localise('separator.new_line');

            my  $prefix             =   $use_prefix?    $self->_generate_log_prefix(uc($type)):
                                        $blank;

            my  $lang_prefix        =   $number_of_languages == 1?  $blank:
                                        sprintf($format, uc $current_language); # Shouldn't the lang prefix be part of generate_log_prefix?

            my  $message            =   $type eq 'dumper'?  $blank:
                                        $self->language->localise(@ARG);

            $messages               .=  $lang_prefix.
                                        $prefix.
                                        $message.
                                        $suffix;

        }

        if (@languages && ($type eq 'dumper')) {
            $messages               .=  $self->language->localise('separator.new_line').
                                        Dumper(@ARG);
            chomp($messages);
        };
        $self->language->unset_language_handle unless $language_handle;

        # Log:
        $self->{repository}->log($messages)  if      $valid_repository;
        say STDERR $messages                 unless  $valid_repository;

        # Premature log-only exit:
        return $self unless $self->{trace};

        # Stack trace:
        $loop_count                 =   0;
        foreach my $current_language (@languages) {

            $self->language->set_language_handle($current_language);

            my  $last_loop          =   ++$loop_count eq $number_of_languages;

            my  $suffix             =   $last_loop? $blank:
                                        $self->language->localise('separator.new_line');

            my  $trace_prefix       =   $self->_generate_log_prefix('trace');

            my  $lang_prefix        =   sprintf($format, uc $current_language);

            $trace_prefixes         .=  $lang_prefix.
                                        $trace_prefix.
                                        $suffix;

        }

        $self->language->unset_language_handle unless $language_handle;

        $self->{repository}->log($trace_prefixes)   if      $valid_repository;
        say STDERR $trace_prefixes                  unless  $valid_repository;

        EPrints->trace;

        # Final log-and-trace exit:
        return $self;

    }

    sub _generate_log_prefix {

        my  $self           =   shift;
        my  $type           =   shift;
        my  $localised_type =   $type?  $self->language->localise('log.type.' . lc $type):
                                q{};

        return sprintf(
             '[%s] [%s, %d] [%s] - ',                   # Three strings in square brackets, derived from the below...

             scalar localtime,                          # Human readable system time and date - linux's ctime(3).

             ((caller $self->{caller_depth})    [3]),   # Back by caller depth, to what called dumper / log_debug / log_verbose,
                                                        # and get the 3rd array index value
                                                        # - the perl module and subroutine name.

             ((caller $self->{caller_depth} - 1)[2]),   # Back by caller depth minus one, to within what called dumper / log_debug / log_verbose,
                                                        # and get the 2nd array index value
                                                        # - the line number.

             uc($localised_type),                       # Log type - LOG / DEBUG / DUMPER / TRACE, etc...
         );

    }

    1;

}; # ChangeName::Log Package.



package ChangeName::Modulino v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance issue if they are invoked,
                                    # on Perl v5.18 or lower.

    # Specific:
    LOAD_UTILITIES_FIRST: BEGIN {

        ChangeName::Utilities->import(qw(
            process_commandline_arguments
        ));

    }

    # Modulino:

    ChangeName::Modulino->run(@ARGV) unless caller;

    # Class Methods:

    sub run {
        my  $class  =   shift;
        $class->new(commandline_arguments => \@ARG)->start_change_name_operation;
    }

    # Constructor:

    sub new {

        # Initial Values:
        my  $class                      =   shift;
        my  $self                       =   {};
        my  $params                     =   {@ARG};

        # Object construction - blessed hash approach:
        bless $self, $class;

        # Object Attributes:
        $self->{language}               =   ChangeName::Language->new;

        # Logger options hardcoded here before commandline options processed:
        $self->{logger}                 =   ChangeName::Log->new(
                                                debug       =>  0,
                                                verbose     =>  0,
                                                no_trace    =>  0,
                                                no_dumper   =>  0,
                                                language    =>  $self->language,
                                            )->set_caller_depth(3);

        my  $expecting                  =   {
            expected_arguments          =>  [qw(
                                                archive_id
                                                search
                                                replace
                                                part
                                            )],
        };

        (
            $self->{options},
            $self->{arguments},
            $self->{no_input},
        )                               =   $self->process_commandline_arguments($params->{commandline_arguments},$expecting);

        # Update language with options processed:
        $self->language->set_language_handle($self->{options}->{language}); # set_language_handle contains validation of language option.

        # Update logger with options processed:
        my  %logger_params              =   (
                                                # Existing options
                                                %{ $self->{options} },

                                                # Our overriding options:
                                                language    =>  $self->language,
                                            );
        $self->logger->debug('Params to be used for a new logger are as follows...')->dumper(%logger_params);
        $self->{logger}                 =   ChangeName::Log->new(%logger_params)->set_caller_depth(3);

        # Set later via setup method, called in last line of this new method:
        $self->{config}                 =   undef;
        $self->{config_messages}        =   undef;

        return $self->utf8_check->setup;    # Setup method will attempt to define config and config_messages attributes.

    }

    sub logger {
        shift->{logger};
    }

    sub language {
        shift->{language};
    }

    sub utf8_check {
        my  $self                           =   shift;
        my  $continue                       =   1;
        my  @nothing                        =   ();     
        my  $input_that_requires_utf8       =   scalar (
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
                                                        
                                                        # Options where UTF-8 is possibly/arguably important:
                                                        $self->{options}->{language},
                                                        $self->{options}->{config},    
                                                
                                                    )
                                                );
        my  $no_input_that_requires_utf8    =  !$input_that_requires_utf8; 

        my  $acceptable_utf8_options        =   (${^UNICODE} >= '39')
                                                &&
                                                (${^UNICODE} <= '63');

        if ($input_that_requires_utf8) {
            $continue                       =   $acceptable_utf8_options?   1:
                                                0;
        };

        say $self->language->localise(
            $self->{no_input}?                  'commandline.no_arguments':
            $no_input_that_requires_utf8?       'commandline.utf8_not_needed':
            $acceptable_utf8_options?           'commandline.utf8_enabled':
            'commandline.utf8_not_enabled'
        );

        die                                     $self->language->localise('commandline.end_program')
                                                unless $continue;

        return $self;
    }

    sub setup {

        # Initial Values:
        my  $self                       =   shift;
        my  @nothing                    =   ();

        # Processing:
        (
            $self->{config},
            $self->{config_messages}
        )                               =   (ChangeName::Config->new(options => $self->{options})->load->get_data_and_messages);

        if ($self->{config_messages}) {

            # Display order is Error, Debug, Verbose, by design. 
            # See ChangeName::Config::load for context.

            say $self->language->localise(@{$ARG})  for @{$self->{config_messages}->{error}};

            $self->logger->debug(@{$ARG})           for @{$self->{config_messages}->{debug}};

            $self->logger->verbose(@{$ARG})         for @{$self->{config_messages}->{verbose}};

        }

        # Update language, considering config values:
        my  @language_tag_or_nothing    =   ($self->{options}->{language} // $self->{config}->{'Language Tag'} // @nothing);
        $self->language->set_language_handle(@language_tag_or_nothing);
        $self->logger->replace_language_object($self->language);

        # Output:

        if ($self->logger->language_is_set) {

            $self->logger->verbose('Language set to [language_name].');

        }
        else {

            $self->logger->verbose(
                'No specific language set. Using all supported languages: [_1].',
                scalar ChangeName::Languages->ordered_language_names
            );

        };

        $self->logger
        ->debug('Commandline Options are...'    )->dumper(%{$self->{options}})
        ->debug('Commandline Arguments are...'  )->dumper(%{$self->{arguments}})
        ->debug('Configuration Values are...'   )->dumper(%{$self->{config}})
        ->debug('Leaving method.');

        return $self;

    }

    sub start_change_name_operation {

        # Initial Values:
        my  $self               =   shift;

        my  $custom_attributes  =   {
            # (As constructed in new method,
            # and setup in setup method):
            config              =>  $self->config,
            language            =>  $self->language,
            logger              =>  $self->logger,
        };

        $self->logger
        ->debug('In subroutine.')
        ->debug('Creating object params for ChangeName::Operation')
        ->debug('Options we will use are as follows...')
        ->dumper($self->{options})
        ->debug('Arguments we will use are as follows...')
        ->dumper($self->{arguments});

        my  @object_params      =   (

            # Flatten to one list
            # (arguments overwrite options):

            %{
                $self->{options}
            },

            %{
                $self->{arguments}
            },

            # Overwrite above with our attributes
            %{
                $custom_attributes
            },

        );

        $self->logger
        ->debug('Object params as follows...')
        ->dumper(@object_params)
        ->debug('About to call start method on ChangeName::Operation class');

        ChangeName::Operation->start(@object_params);

        # Output:        
        return $self->logger->debug('Leaving method.');

    }

    sub config {
        my  $self   =   shift;

        die             $self->localise->('commandline.config_undefined')
                        unless $self->{config};

        return $self->{config};
    }

    1;

} # ChangeName::Modulino Package.


=head3 ChangeName::Operation

Performs the change name operation.

=cut
package ChangeName::Operation v1.0.0 {

    # Standard:
    use     English qw(
                -no_match_vars
            );                      # Use full english names for special perl variables,
                                    # except the regex match variables
                                    # due to a performance issue if they are invoked,
                                    # on Perl v5.18 or lower.

    # Specific:
    LOAD_UTILITIES_FIRST: BEGIN {

            ChangeName::Utilities->import(qw(
                validate_class
                list_to_regex_logical_or_grouping
                is_populated_array_ref
                is_true_or_zero
                chunkify
                stringify_array_ref
            ));

    }
    use     lib ChangeName::Config->new(commandline_arguments => \@ARGV)->load->get_data->{'EPrints Perl Library Path'};
    use     EPrints;
    use     EPrints::Repository;
    use     EPrints::Search;
    use     Scalar::Util qw(
                blessed
                reftype
            );
    #use     Data::Dumper;

=pod Name, Version

=encoding utf8


=head3 MODULE NAME

ChangeName::Operation

=head3 VERSION

v1.0.0

=cut

=pod Synopsis, Description

=head3 SYNOPSIS

    # Run at the command line:
    perl -CAS ./ChangeName.pm
    
    # Use in a unit test or other Perl Script:
    use ChangeName;
    
    my $object = ChangeName::Operation->new(@object_params);


=head3 DESCRIPTION

Calls a subroutine when ran from the commandline.
Currently set to call L</start_from_commandline>.

    # Run from the command line:
    perl -CAS ./ChangeName.pm MyArchive bob Bobbi given --exact --verbose --live

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
    use ChangeName;
    
    my $object = ChangeName::Operation->new(@object_params);

See L</new> method for info on acceptable object parameters.

=cut

   
=head3 CLASS METHODS

=head4 $class->start_from_commandline(@ARGV);

    # Run at the command line:
    perl -CAS ./ChangeName.pm

Class method auto-ran when
L<ChangeName.pm> is ran from the commandline.

Considers arguments passed in to have come from the commandline,
processes them to obtain object construction parameters,
checks those parameters,
then uses them to construct a new ChangeName::Operation object,
upon which the program flow is called...

    # Construct new object, and begin program flow...
    ChangeName::Operation->new(@object_params)->search->part_specific->display->confirm->change->finish;

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

        $class->new(@object_params)->search->prepare->display->confirm->change->finish;
    }

    # Program Flow Methods:


=head3 CONSTRUCTORS

=cut

=head4 ChangeName::Operation->new(@object_params);

    # Construct new object, and begin program flow...
    my  $object =   ChangeName::Operation->new(@object_params);

Accepts parameters required for a new ChangeName::Operation,
and returns a new ChangeName::Operation object,
upon which program flow methods
or setters and getters,
can be called.

=cut

    sub new {

        my  $class      =   shift;
        my  $params     =   {@ARG};

        my  $self       =   {};
        bless $self     ,   $class;

        $self->_set_attributes($params)->log_debug('Constructed New Object Instance.')->dumper;

        return $self;
    }

=head3 INSTANCE METHODS

=head4 $self->search;

    # Construct an object, and populate its 
    my  $object  =   ChangeName::Operation->new(@object_params)->search;

Performs an EPrints search,
according to values set during ChangeName::Operation object construction.

Returns the initial ChangeName::Operation object, now with list_of_results and records_found object attributes set.

=cut

    sub search {
        my  $self                   =   shift;

        $self
        ->log_debug('Entered method.')->dumper
        ->log_debug('Using search settings...')->dumper($self->get_search_settings)
        ->log_verbose(
            'Searching fields [_1] ...',
            $self->stringify_array_ref($self->get_fields_to_search),
        );

        # Search:
        $self->{list_of_results}    =   $self->get_repository
                                        ->dataset($self->get_dataset_to_use)
                                        ->prepare_search(%{$self->get_search_settings})
                                        ->perform_search;
                                        # Search interprets 'ó' as matching 'O.' (yes - even with the dot) and 'à' as matching 'A'
                                        # This is an EPrints API behaviour.
                                        # These are not direct matches, and so could be filtered out by us.
                                        # At the same time, it also works in reverse. Lopez-Aviles can match López-Avilés 
                                        # - which is beneficial if someone doesn't have the correct keyboard.
                                        # So let's leave this in.

        $self->{records_found}      =   scalar @{$self->{list_of_results}->{ids}};

        say $self->language->localise('No Results Found.') unless $self->records_found;
        $self->log_verbose('Found Results.') if $self->records_found;

        return $self->log_debug('Leaving method.')->dumper;

    }

=head4 $self->part_specific;

    # Narrow search down to specific part... 
    my  $object  =   ChangeName::Operation->new(@object_params)->search->part_specific;

Should search results have been retrieved (will return prematurely if not),
it will process the search results in order to generate useful lists,
and then attempt to refine the search down by setting or prompting for a specific name part.

If find and replace values have not already been set,
it will prompt the user for them too.

=cut

    sub prepare {

        # Initial Values:
        my  $self           =   shift->log_debug('Entering method.')->dumper;

        # Premature Exits:
        return                  $self->log_debug('Premature exit - No search results to narrow down.')
                                unless $self->records_found;

        return                  $self->log_debug('Premature Exit - our operation is already specific to a name part.')
                                if $self->prepared;

        # Processing:
        $self                   ->log_verbose('Narrowing search to a specific part...')
                                ->log_debug('Generating lists, and setting values.')
                                ->_tally_frequencies->_generate_name_lists
                                ->_set_part->_set_find->_set_replace;

        $self->{prepared}   =   $self->records_found
                                && $self->is_populated_array_ref($self->{'unique_names'})
                                && $self->get_part
                                && $self->get_find
                                && defined($self->get_replace);
                                # Replace can be a blank string - hence defined test instead of true test.

        return $self->log_debug('Leaving prepare method.')->dumper;

    }

=head4 $self->part_specific;

    # Narrow search down to specific part... 
    my  $object  =   ChangeName::Operation->new(@object_params)->search->part_specific;

Should search results have been retrieved (will return prematurely if not),
it will process the search results in order to generate useful lists,
and then attempt to refine the search down by setting or prompting for a specific name part.

If find and replace values have not already been set,
it will prompt the user for them too.

=cut

    sub display {

        # Initial values:
        my  $self                                       =   shift->log_debug('Called display method.')->dumper;

        # Premature Exit:
        return                                              $self->log_debug('Premature exit - Prerequisites not met.')
                                                            unless $self->prepared;

        # Further Initial Values:
        $self->{'matches_find'}                         =   qr/^\Q$self->{find}\E$/i;   # case insensitive.

        # Processing:
        say                                                 $self->language->localise('Thank you for your patience. Your request is being processed...');

        for my $unique_name (@{$self->get_unique_names}) {

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

        say $self->language->localise('Nothing was found to match.') unless $self->display_is_set;

        # Output:
        return $self->log_debug('Leaving display method.')->dumper;

    }

=head4 $self->confirm;

    # Narrow search down to specific part... 
    my  $object  =   ChangeName::Operation->new(@object_params)->search->part_specific->confirm;

To do.

=cut

    sub confirm {

        my  $self                           =   shift;

        $self->log_debug('Called confirm method.')->dumper;

        return $self->log_debug('Premature exit - Prerequisites not met.') unless $self->prepared && $self->display_is_set;

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
    my  $object  =   ChangeName::Operation->new(@object_params)->search->part_specific->confirm->change;

To do.

=cut

    sub change {

        my  $self                               =   shift;

        $self->log_debug('Called change method.')->dumper;

        return                                      $self->log_debug('Premature exit - Nothing to change.')
                                                    unless $self->is_populated_array_ref($self->get_what_to_change);

        $self->{changes_made}                   =   0;

        for my $details (@{$self->{what_to_change}}) {

            my  (
                    $result,
                    $search_field,
                    $names,
                    $name,
                    $current,
                )                               =   @{$details};

            my  $fresh_result                   =   $self->get_repository->dataset($self->get_dataset_to_use)->dataobj($result->id);
            my  $fresh_names                    =   $fresh_result->get_value($search_field);
            my  $fresh_name                     =   $fresh_names->[$current];
            my  $can_or_cannot                  =   $fresh_result->is_locked?   'cannot':
                                                    'can';

            say $self->language->localise('horizontal.rule');
            say $self->language->localise('change.from.'.$can_or_cannot, $self->format_single_line_for_display($fresh_result, $search_field));

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

            say $self->language->localise('change.to.'.$can_or_cannot, $self->format_single_line_for_display($fresh_result, $search_field), $fresh_result->id);

            if ($self->{live}) {
                unless ($fresh_result->is_locked) {
                    $fresh_result->commit(@{$self->{force_or_not}});
                    say $self->language->localise('change.done');
                    $self->{changes_made}++;
                }
                else {
                    say $self->language->localise('change.locked', $fresh_result->id);
                };
            }
            else {
                say $self->language->localise('change.dry_run');
            };

        };

        return $self;

    }

=head4 $self->finish;

    # Narrow search down to specific part... 
    my  $object  =   ChangeName::Operation->new(@object_params)->search->part_specific->confirm->change->finish;

To do.

=cut

    sub finish {
        my  $self   =   shift;
        say $self->language->localise('horizontal.rule');
        say $self->language->localise('finish.change', $self->{changes_made}, scalar @{$self->{what_to_change}});
        say $self->language->localise('finish.no_change') unless $self->{changes_made};
        say $self->language->localise('finish.thank_you');
        return $self;
    }

    # Setters and Getters:

    sub _set_archive {
        return shift->_set_or_prompt_for('archive' => shift, @ARG);
    }

    sub _set_part {
        return shift->_set_or_prompt_for('part' => shift, @ARG);
    }

    sub get_part {
        return shift->{part};
    }

    sub get_find {
        return shift->{find};
    }

    sub get_replace {
        return shift->{replace};
    }

    sub _set_find {
        return shift->_set_or_prompt_for('find' => shift, @ARG);
    }

    sub _set_search_normal {
        return shift->_set_or_prompt_for('search' => shift, @ARG);
    }

    sub get_archive {
        return shift->{archive};
    }

    sub get_repository {
        return shift->{repository};
    }

    sub get_search_settings {
        return shift->{search_settings};
    }

    sub get_dataset_to_use {
        return shift->{dataset_to_use};
    }

    sub get_fields_to_search {
        return shift->{fields_to_search};
    }

    sub get_list_of_results {
        shift->{list_of_results};
    }

    sub records_found {
        return shift->{records_found};
    }

    sub prepared {
        return shift->{prepared}; # Boolean flag, and not a name part value.
    }

    sub get_unique_names {
        return shift->{unique_names};
    }

    sub display_is_set {
        return shift->{display_is_set};
    }

    sub get_what_to_change {
        return shift->{what_to_change};
    }

    sub _set_search_exact {
        my  $self   =   shift;
        my  $value  =   shift;
        return          $self
                        ->_set_find             ($value, @ARG)
                        ->_set_search_normal    ($value, @ARG)
                        ->log_debug             ('Find attribute set to ([_1]).',   $self->{find}   )
                        ->log_debug             ('Search attribute set to ([_1]).', $self->{search} )
                        ;
    }

    sub _set_search {
        my  $self   =   shift;
        my  $value  =   shift;
        return          $self->is_true_or_zero($value) && $self->{exact}?   $self
                                                                            ->log_verbose('Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.', $value)
                                                                            ->_set_search_exact($value, @ARG):
                        $self
                        ->log_debug('Set search normally, as no --exact flag provided.')
                        ->_set_search_normal($value, @ARG);
    }

    sub _set_replace {
        return shift->_set_or_prompt_for('replace' => shift, @ARG);
    }

    sub set_name_parts {

        my  $self               =   shift;
        my  @skip               =   ();

        $self->log_debug('Entering method.')->log_debug('Name parts before we begin:')->dumper($self->{name_parts});

        my  $already_set        =   $self->is_populated_array_ref($self->{name_parts});

        return                      $self->log_debug('Premature exit - name parts already populated.')
                                    if $already_set;

        my  $valid_name_parts   =   $self->list_to_regex_logical_or_grouping(

                                        # Name Parts for Each Field:
                                        map {
                                            keys %{
                                                $self->get_repository->dataset($self->get_dataset_to_use)->field($ARG)->property('input_name_cols')
                                            }
                                        }

                                        # Fields:
                                        @{$self->get_fields_to_search}

                                    );

        my  $not_a_name_part    =   qr/[^($valid_name_parts)]/i;

        $self->log_debug('Invalid name parts filter regex as follows...')->dumper($not_a_name_part);

        $self->{name_parts}     =   [
                                        map
                                        {
                                                $self->is_true_or_zero($ARG)? ($ARG):
                                                @skip;
                                        } 
                                        split $not_a_name_part,
                                        $self->language->get_language_handle?   $self->language->localise('name_parts.display_order'):
                                        $self->language->get_first_localisation_for('name_parts.default_display_order') # Avoids duplicate and lang-tag prefixed response if multiple languages.
                                    ]; # Array ref, so order preserved.

        $self->log_debug('Set name parts according to language localisation as follows...')->dumper($self->{name_parts});

        return $self->log_debug('Leaving method.');

    }

    # Private Setters:

    sub _set_repository {
        # Initial Values:
        my  $self           =   shift;
        my  $archive_id     =   shift;
        
        # Processing:
        $self->{repository} =   EPrints::Repository->new(
                                    $self->_set_archive($archive_id)->get_archive
                                );

        # Debugging:
        $self->log_debug('Archive attribute of [_1] instance is now "[_2]".', scalar __PACKAGE__, $self->get_archive);

        if (blessed($self->get_repository)) {
            $self->log_debug('Repository attribute of [_1] instance is now of class "[_2]".', scalar __PACKAGE__, blessed($self->get_repository));
        }
        else {
            $self->log_debug('Repository attribute of [_1] instance is not a blessed object. Dumped contents are as follows...', scalar __PACKAGE__)->dumper($self->get_repository);
        };
        
        # Output:
        return $self;
    }

    # Function-esque subroutines:

    sub format_single_line_for_display {

        # Initial Values:
        my  ($self, $result, $field)    =   @ARG;

        $self->log_debug('Entered method.');

        # Premature death:
        die                                 $self->language->localise('format_single_line_for_display.error.no_params')
                                            unless ($result && $field); # Should we check they're the relevant classes too?

        # Processing:
        $self->log_debug('Found params, and about to process them...');

        my  $names                      =   join(
                                                $self->language->localise('separator.name_values'),
                                                map {$self->_stringify_name($ARG) // ()}
                                                @{$result->get_value("$field")}
                                            );

        $self->log_debug('Stringified names for use in a localised display line.');

        # Output:
        return                              $self->log_debug('Returning localised display line as we leave the method.')
                                            ->language->localise('display_line', $result->id, $names);

    }

    sub prompt_for {

        # Initial Values:
        my  $self                   =   shift;
        my  $prompt_type            =   shift;

        die                             $self->language->localise('prompt_for.error.no_prompt_type')
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
        my  $prompt_on_blank_for    =   $self->list_to_regex_logical_or_grouping(@prompt_on_blank_for);
        my  $matches_prompt_on_blank=   qr/^($prompt_on_blank_for)$/;

        if  ($find_prompt) {

            die                         $self->language->localise('prompt_for.find.error.no_part')
                                        unless $self->get_part;

            @prompt_arguments       =   (
                                            'name.'.$self->get_part,
                                        );

        };

        if ($part_prompt) {

            my  $number;
            @prompt_arguments               =   (
                                                    $self->stringify_array_ref($self->{'given_names'}),
                                                    $self->stringify_array_ref($self->{'family_names'}),
                                                );
            my  $acceptable_input           =   $self->list_to_regex_logical_or_grouping(
                                                    'given',
                                                    'family',
                                                );
            my  $matches_acceptable_input   =   qr/^($acceptable_input)$/;

            say $self->language->localise($prompt, @prompt_arguments);

            until ( $input && ($input =~ $matches_acceptable_input) ) {

                say $self->language->localise('prompt_for.1or2');
                chomp($number   =   <STDIN>);

                $input          =   $number?    $self->language->matches_case_sensitively($number, 'input.1')?  'given':
                                                $self->language->matches_case_sensitively($number, 'input.2')?  'family':
                                                undef:
                                    undef;

            };

        }

        elsif  ($confirm_prompt) {

            my  $confirmation;
            @prompt_arguments                   =   @{$self->{confirm_prompt_arguments}}; # A hack. Maybe refactor to be passed in.
            my  @acceptable_input               =   (
                                                        ['input.yes_letter'],
                                                        ['input.no_letter'],
                                                        ['input.all'],
                                                        ['input.none'],
                                                    );

            say $self->language->localise($prompt, @prompt_arguments);
            say $self->language->localise('horizontal.rule');

            until ( $confirmation && $self->language->matches_case_insensitively($confirmation, @acceptable_input) ) {
                say $self->language->localise('prompt_for.confirm.acceptable_input');
                chomp($confirmation   =   <STDIN>)
            };

            $input = $confirmation;
        }

        elsif ($continue_prompt) {

            say $self->language->localise($prompt);
            say $self->language->localise('horizontal.rule');
            chomp($input   =   <STDIN>);

        }

        else {

            until ($input) {

                say $self->language->localise($prompt, @prompt_arguments);
                chomp(my $typed_input           =   <STDIN>);
                ($input)                        =   $self->_validate( ($typed_input) );

                last if $input;
                if ($prompt_type =~ $matches_prompt_on_blank) {

                    say $self->language->localise($prompt.'.prompt_on_blank');
                    chomp(my $typed_input2      =  <STDIN>); # Not validated and should be okay as we only ever use in a match in the line below...

                    # Definition:
                    my  $blank_input_desired    =   $self->language->matches_case_insensitively($typed_input2, 'input.yes_letter');

                    if ($blank_input_desired) {
                        $input = q{};
                        last;
                    };

                };

            };

        };

        return $input;

    }


    # Private subs:

    sub _set_attributes {

        # Initial Values:
        my  ($self, $params)        =   @ARG;

        my  $matches_yes            =   qr/^(y|yes)$/i; # Used with YAML. Case insensitive y or yes and an exact match - no partial matches like yesterday.
        my  $matches_match_types    =   qr/^(IN|EQ|EX|SET|NO)$/;
        my  $matches_merge_types    =   qr/^(ANY|ALL)$/;
        my  $config_param_is_a_hash =   exists $params->{config}
                                        && (
                                            reftype($params->{config})
                                            && (reftype($params->{config}) eq 'HASH')
                                        );

        my  $dumper_class_name_only =   [
                                            'Repository',
                                            'repository',
                                            'list_of_results',
                                            'dumper_default', # The Log's $self instance unless set_dumper_default submits another $self object instance.
                                            'logger',
                                            'language',
                                        ];
        my  $dumper_exclude         =   [
                                            #'repository',
                                        ];

        my  $valid_language_object  =   $self->validate_class(
                                            $params->{language}     =>  'ChangeName::Language',
                                        );

        my  $valid_logger_object    =   $self->validate_class(
                                            $params->{logger}       =>  'ChangeName::Log',
                                        );

        $self->{language}           =   $valid_language_object? $valid_language_object:
                                        # If not, assume a language tag string from which we can create an object...
                                        ChangeName::Language->new($params->{language});

        $self->{logger}             =   $valid_logger_object?   $valid_logger_object
                                                                ->set_dumper_class_name_only    ($dumper_class_name_only    )
                                                                ->set_dumper_exclude            ($dumper_exclude            )
                                                                ->replace_language_object       ($self->language            ):
                                        ChangeName::Log->new(
                                            debug                   =>  $params->{debug},
                                            verbose                 =>  $params->{verbose},
                                            trace                   =>  $params->{trace},
                                            no_dumper               =>  $params->{no_dumper},
                                            no_trace                =>  $params->{no_trace},

                                            language                =>  $self->language,
                                            dumper_class_name_only  =>  $dumper_class_name_only,
                                            dumper_exclude          =>  $dumper_exclude,
                                        );

        $self->log_debug    ('In method.'                         )
        ->log_debug         ('Language and Logger attributes set.')
        ->log_debug         ('Params have been as follows...')
        ->dumper            ($params)
        ->log_debug         ('About to set Repository.'           )
        ->_set_repository   ($params->{archive_id}                );

        $self->logger->set_repository(
            $self->get_repository
        );

        $self->log_debug    ('Set Repository. About to add attributes from params...'             );

        %{
            $self
        }                           =   (

            # Existing values in $self:
            %{$self},

            # From params:
            live                    =>  $params->{live} // 0,
            exact                   =>  $params->{exact} // 0,
            yaml                    =>  $config_param_is_a_hash? $params->{config}:
                                        (ChangeName::Config->new(commandline_arguments => \@ARGV)->load->get_data),

        );
#warn 'Self dump2...'.Dumper($self); #die 'enough2';
        #warn 'About to use the logger...';

        $self
        ->log_debug                     ('Set initial instance attributes using params or defaults.')
        ->log_debug                     ('Now setting additional instance attributes from params...')
        ->_set_search                   ($params->{search})
#warn 'Self dump...'.Dumper($self); die 'enough3';        
        ->_set_replace                  ($params->{replace}, 'no_prompt')
#        warn 'Self dump...'.Dumper($self); die 'enough4';           # Optional on object instantiation, so no prompt for value needed if not set.
        ->_set_part                     ($params->{part},    'no_prompt')   # Also optional on initialisation.
        ->dumper;
#warn 'Self dump5...'.Dumper($self); $self->dumper; $self->dumper($self); die 'enough5';        
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
#warn 'Self dump...'.Dumper($self); die 'enough6';        
        %{
            $self->log_debug('Set YAML configurations.')->dumper
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
    
    sub language {
        shift->{language};
    }
    
    sub logger {
        shift->{logger};
    };

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
    
                    $self->{'display_is_set'}                                   =   'Yes';
                    
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
    
        my  ($yes, $no)                 =   (
                                                $self->language->get_first_localisation_for('input.yes_letter'),
                                                $self->language->get_first_localisation_for('input.no_letter'),
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
    
                    say $self->language->localise('horizontal.rule');
                    say $self->language->localise(
                            'seeking_confirmation.display_lines',
                            $self->_stringify_name($name),
                            join(
                                $self->language->localise('separator.new_line'),
                                @{$self->{display_lines}->{"$self->{unique_name}"}},
                            ),
                        );
                    say $self->language->localise('horizontal.rule');
    
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
                                            $self->log_debug('Have determined that confirmation is not to be set automatically to yes or no. Instead we\'ll now prompt the user for a confirmation value.')
                                            ->prompt_for('confirm');
    
                # Process confirmation:
                $self->log_debug('Processing confirmation ([_1])', $confirmation);
    
                if ( $self->language->matches_case_insensitively($confirmation, 'input.none') ) {
                    $self->log_debug('Detected [nest,input.none].');
                    $self->{auto_no}    =   $self->{unique_name};
                    $confirmation       =   $no;
                };
    
                if ($self->language->matches_case_insensitively($confirmation, 'input.all')) {
                    $self->log_debug('Detected [nest,input.all].');
                    $self->{auto_yes}   =   $self->{unique_name};
                    $confirmation       =   $yes;
                };
    
                if ($self->language->matches_case_insensitively($confirmation, 'input.yes_letter')) {
                    $self->log_debug('Detected [nest,input.yes_letter].');
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
        #warn 'check what up';
        #EPrints->trace;
        return $self->log_debug('Premature exit - Prerequisites not met.') unless $prerequisites;
    
        my  $output                                             =   $self->language->localise('horizontal.rule')."\n".
                                                                    $self->language->localise('_confirmation_feedback.heading.confirmed_so_far');
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
    
                    $output                                     .=  $self->language->localise('_confirmation_feedback.heading.unique_name', $stringified_name)
                                                                    unless $heading_shown_for->{$current_unique_name};
    
                    $output                                     .=  $self->language->localise('_confirmation_feedback.record.confirmed_for_changing', $confirmation, $display_line);
            
                    $heading_shown_for->{"$current_unique_name"}=   'Yes';
    
                    $self->log_debug('Added record to confirmation feedback.');
                    
                    $self->log_debug('Since unique names are unique, we can leave unique name loop now we have processed a match.');
                    last;
    
                };
        
            };
            $self->log_debug('Exited unique name loop.');
        };
        
        #$output                                                 .=  $self->language->localise('horizontal.rule');    # Not needed if continue prompt will follow.
        
        $self->{confirmation_feedback}                          =   $at_least_one_confirmation? $output:
                                                                    undef;
        
        $self->log_debug(
            $self->{confirmation_feedback}? 'Generated confirmation feedback.':
            'No confirmation feedback generated.',
        );
        
        return $self->log_debug('Leaving method.')->dumper;
    
    }

    sub _match {
    
        my  $self                   =   shift->log_debug('Entering method.');
        my  $name                   =   shift;
        my  $name_part_value        =   $name->{"$self->{'part'}"};
        my  $valid_name_part_value  =   $name_part_value || $name_part_value eq '0'?    $name_part_value:
                                        undef;
        my  $uniqueness             =   q{};

        for my $name_part (@{$self->{'name_parts'}}) { # Array, so in specific order that's the same each time.

            $uniqueness             .=  $name_part.($name->{"$name_part"}//q{});

        };

        my  $matched_unique_name    =   $uniqueness
                                        && ($uniqueness =~ $self->{'matches_unique_name'});

        $self->{matches}            =   $matched_unique_name
                                        && ($valid_name_part_value)
                                        && ($valid_name_part_value =~ $self->{'matches_find'});

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
        #warn 'in set and prompt_for';
        #warn 'Args are...'.Dumper(@ARG);
        #die 'enough';
        $self->{"$attribute"}                           =   defined $value?                                 $self->_validate($value):
                                                            defined $self->{"$attribute"}?                  $self->{"$attribute"}:
                                                            $prompt_type && ($prompt_type eq 'no_prompt')?  undef:
                                                            $prompt_type?                                   $self->prompt_for($prompt_type):
                                                            $self->prompt_for($attribute);
        #warn 'Self is...'.Dumper($self);
        #die 'enough';
        return $self;
    }

    # Private Function-esque subs:

    sub _stringify_name {
        my  $self           =   shift;
        my  $name           =   shift;
        
        # Premature Exit:
        die                     $self->language->localise('_stringify_name.error.no_params')
                                unless $name; # hash ref check?

        my  @order_or_omit  =   ();

        for my $current_part (@{$self->{name_parts}}) {
            push @order_or_omit,
            $name->{"$current_part"} && $name->{"$current_part"} eq '0'?    "0 but true": # 0 is potentially a valid one character name - haha.
            $name->{"$current_part"}?                                       $name->{"$current_part"}:
            ();
        };

        return                  @order_or_omit? join $self->language->localise('separator.name_parts'), @order_or_omit:
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
        die                                     $self->language->localise('_validate.error.no_arguments')
                                                unless $number_of_input_arguments; # Blank string or a zero are both valid values.
    
        # Processing:
        for my $current_index (0..$#input) {
    
            # Consider a sole zero as a true input value:
            $input[$current_index]          =   $input[$current_index] eq '0'? "0 but true":
                                                $input[$current_index];
    
            # Stop out of range input:
            die                                 $self->language->localise('_validate.error.four_byte_character')
                                                if (
                                                    $input[$current_index]
                                                    && ($input[$current_index] =~ $matches_four_byte_character)
                                                );
    
        };
        #warn 'validate Input 0 is: '.$input[0];
        #warn 'validate Input array is: '.Dumper(@input);
        #die 'enough';
        # Output:
        return  # In list context:
                wantarray?                          @input:
                # In Scalar and void contexts..
                $number_of_input_arguments == 1?    $input[0]:  # if only one value, return sole value...
                \@input;                                        # ...otherwise return an array ref.
    }

    # Log Stuff:

    sub log_verbose {
        my  $self   =   shift;

        $self->{logger}->set_caller_depth(4)->verbose(@ARG);

        return $self;
    }

    sub log_debug {
        my  $self   =   shift;
        
        $self->{logger}->set_caller_depth(4)->debug(@ARG);

        return $self;
    }

    sub dumper {
        my  $self   =   shift;
    
        $self->{logger}->set_caller_depth(4)->set_dumper_default($self)->dumper(@ARG);

        return $self;
    }

    1;

=pod End of methods.

=cut



}; # ChangeName::Operation Package.

=head2 Language Packages:

These classes contain a language specific lexicon, containing localised configurations, tokens, and phrases.
Additionally POD translations may also be included in these classes.

=over

=item ChangeName::Languages::en_gb

English (United Kingdom).

=item ChangeName::Languages::de_de

German (Germany).

=back

=cut

=head2 AUTHOR

Andrew Mehta

=cut
LOAD_LANGUAGE_CLASSES_FIRST: BEGIN {


package ChangeName::Languages::en_gb { 

# Use --lang=en-GB at the commandline to use it.

ChangeName::Languages->import;
our @ISA                        =   ('ChangeName::Languages');

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

'language.name'                 =>  'English (United Kingdom)',
'language.error.set_language_handle'   =>  'Trouble finding a language to use.',

'nest.error.language'           =>  'Not a valid language handle from which to call the maketext method.',
'nest.error.key'                =>  'Error nesting a Lexicon value.',

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

'utilities.valid_object.invalid_object' =>
'Error - Not a valid object.',

'utilities.valid_object.valid_object' =>
'Valid object.',

'utilities.validate_class.invalid_class' =>
'Error - Your [_1] object is considered an invalid object
for this purpose, due to its class.
The only acceptable object class for this purpose is [_2]
- so please use an object of this class instead.',

'utilities.validate_class.valid_class' =>
'[_1] object is a valid class of object for this purpose.',

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

# Using q{} instead of single or double quotes in line below, so single and double quote characters are free to use within the string:
'commandline.config_undefined'  =>  q{Attempted to retrieve a modulino instance's "config" attribute, only to find it had not been defined yet.},

'commandline.end_program'       =>  'This program will now end...'.$new_line,
'validation.errors.invalid'     =>  'Invalid [_1] field in [_2] form.'.$new_line,

'commandline.utf8_not_needed'   =>  'No UTF-8 critical commandline options or arguments given.',
'commandline.no_arguments'      =>  'No commandline arguments given.',
'commandline.utf8_enabled'      =>  'UTF-8 commandline arguments enabled.',

'commandline.utf8_not_enabled'  =>

'UTF-8 commandline arguments do not appear to be enabled.

To enable UTF-8 arguments,
please run the script again with, for example, -CAS after perl as such...

    perl -CAS ChangeName.pm
    
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

'change.locked'     =>  'Due to the edit lock presently on Record [_1], changes to Record [_1] were not saved.',

'change.from.can'   =>

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

What is your find value when matching within [nest,_1]?
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
    'Language set to [language_name].'  =>  'Language set to [language_name].',
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
    'Leaving prepare method.'=>'Leaving prepare method.',
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
    'Starting subroutine.'=>'Starting subroutine.',
    'Multilingual variations of [_1] are as dumped below...'=>'Multilingual variations of [_1] are as dumped below...',
    'Initial option translation...'=>'Initial option translation...',
    'Option translation as a list with codebase\'s existing option key "[_1]" omitted...'=>'Option translation as a list with codebase\'s existing option key "[_1]" omitted...',
    'Option string is: [_1]'=>'Option string is: [_1]',
    'No list of translation values to add alongside codebase\'s existing option key "[_1]" for language [language_name].' # [language_name] is a function not to be translated.
    =>'No list of translation values to add alongside codebase\'s existing option key "[_1]" for language [language_name].', # [language_name] is a function not to be translated.
    'Leaving subroutine.'=>'Leaving subroutine.',
    'Configuration Values are...'=>'Configuration Values are...',
    'In subroutine.'=>'In subroutine.',
    'Creating object params for ChangeName::Operation'=>'Creating object params for ChangeName::Operation',
    'Object params as follows...'=>'Object params as follows...',
    'About to call start method on ChangeName::Operation class'=>'About to call start method on ChangeName::Operation class',
    'Current language object is as follows...'=>'Current language object is as follows...',
    'Leaving method prematurely due to no replacement provided.'=>'Leaving method prematurely due to no replacement provided.',
    'Proposed replacement language object is as follows...'=>'Proposed replacement language object is as follows...',
    'Proposed replacement was found to be a valid language object.'=>'Proposed replacement was found to be a valid language object.',
    'Replacement operation performed.'=>'Replacement operation performed.',
    'In method.'=>'In method.',
    'Language and Logger attributes set.'=>'Language and Logger attributes set.',
    'About to set Repository.'=>'About to set Repository.',
    'Set Repository. About to add attributes from params...'=>'Set Repository. About to add attributes from params...',
    'Data dump prevented by no_dumper option.'=>'Data dump prevented by no_dumper option.',
    'No specific language set. Using all supported languages: [_1].'=>'No specific language set. Using all supported languages: [_1].',
    'Default options set as follows...'=>'Default options set as follows...',
    'Passed in commandline arguments from which to derive both options and arguments from are as follows...'=>'Passed in commandline arguments from which to derive both options and arguments from are as follows...',
    'Validated copy of arguments is as follows...'=>'Validated copy of arguments is as follows...',
    'Flattened list of default options are as follows...'=>'Flattened list of default options are as follows...',
    'Option Specifications have been determined as being as follows...'=>'Option Specifications have been determined as being as follows...',
    'Options after processing the commandline arguments are now as follows...'=>'Options after processing the commandline arguments are now as follows...',
    'Arguments after processing the commandline arguments are as follows...'=>'Arguments after processing the commandline arguments are as follows...',
    'The no_input flag will be returned with the value: "[_1]".'=>'The no_input flag will be returned with the value: "[_1]".',
    'Params to be used for a new logger are as follows...'=>'Params to be used for a new logger are as follows...',
    'Detected [nest,input.none].'=>'Detected [nest,input.none].',
    'Detected [nest,input.all].'=>'Detected [nest,input.all].',
    'Detected [nest,input.yes_letter].'=>'Detected [nest,input.yes_letter].',
    'Params have been as follows...'=>'Params have been as follows...',
    'Options we will use are as follows...'=>'Options we will use are as follows...',
    'Arguments we will use are as follows...'=>'Arguments we will use are as follows...',
    'Archive attribute of [_1] instance is now "[_2]".'=>'Archive attribute of [_1] instance is now "[_2]".',
    'Repository attribute of [_1] instance is now of class "[_2]".'=>'Repository attribute of [_1] instance is now of class "[_2]".',
    'Repository attribute of [_1] instance is not a blessed object. Dumped contents are as follows...'=>'Repository attribute of [_1] instance is not a blessed object. Dumped contents are as follows...',
    'Valid list object. Proceeding to chunkify using chunk size [_1]...'=>'Valid list object. Proceeding to chunkify using chunk size [_1]...',
    'Adding a chunk, from a list offset of [_1].'=>'Adding a chunk, from a list offset of [_1].',
    'Invalid list object. Returning the default result - an empty list that will return false in scalar context.'=>'Invalid list object. Returning the default result - an empty list that will return false in scalar context.',
    'Have determined that confirmation is not to be set automatically to yes or no. Instead we\'ll now prompt the user for a confirmation value.'=>'Have determined that confirmation is not to be set automatically to yes or no. Instead we\'ll now prompt the user for a confirmation value.',
    'Invalid name parts filter regex as follows...'=>'Invalid name parts filter regex as follows...',
);

our %Lexicon = (
    #'_AUTO' => 1, # Commented out the auto for now.
    @configurations,
    @tokens,
    @phrases,
);

sub language_name {
    return $Lexicon{'language.name'};
}

# ----------------------------------

1;

}

package ChangeName::Languages::de_de {

=pod Deutsch

=head1 Deutsch (Deutschland)

=cut

# Use --lang=de-DE at the commandline to use it.

# Specific:
ChangeName::Languages->import;
our @ISA                        =   ('ChangeName::Languages');

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

'language.name'                 =>  'Deutsch (Deutschland)',
'language.error.set_language_handle'   =>  'Probleme beim Finden einer zu verwendenden Sprache.',

'nest.error.language'           =>  'Ungültiger Sprach-Handle zum Aufrufen der Methode „maketext“.',
'nest.error.key'                =>  'Fehler beim Verschachteln eines Lexikonwerts.',

'options.language'              =>  'sprache spr',
'options.config'                =>  'konfig konfiguration',
'options.live'                  =>  'live',
'options.verbose'               =>  'ausführlich ausführl',
'options.debug'                 =>  'debug',
'options.trace'                 =>  'stacktrace trace',
'options.no_dumper'             =>  'kein_dumper kein_dump keindumper keindump',
'options.no_trace'              =>  'kein_stacktrace keinstacktrace kein_trace keintrace',
'options.exact'                 =>  'exakt genau genaue',

'input.yes_letter'              =>  'J',
'input.no_letter'               =>  'N',
'input.all'                     =>  'ALLE',
'input.none'                    =>  'KEINER',
'input.1'                       =>  '1',
'input.2'                       =>  '2',


'name.given'                    =>  'Vorname',
'name.family'                   =>  'Familienname',
'name.honourific'               =>  'Ehrenname',
'name.lineage'                  =>  'Abstammungsname', # Unsure about this one - it's literally Ancestral Name
'display_line'                  =>  'Datensatz [_1]: [_2].',

'log.type.verbose'              =>  'ausführlich',
'log.type.log'                  =>  'protokoll',
'log.type.debug'                =>  'debug',
'log.type.dumper'               =>  'dumper',
'log.type.trace'                =>  'stacktrace',

'utilities.valid_object.invalid_object' =>
'Fehler – Kein gültiges Objekt.',

'utilities.valid_object.valid_object' =>
'Gültiges Objekt.',

'utilities.validate_class.invalid_class' =>
'Fehler - Ihr [_1] Objekt wird aufgrund seiner Klasse
für diesen Zweck als ungültiges Objekt betrachtet.
Die einzige zulässige Objektklasse für diesen Zweck ist [_2]
- verwenden Sie stattdessen ein Objekt dieser Klasse.',

'utilities.validate_class.valid_class' =>
'[_1] Objekt ist eine gültige Objektklasse für diesen Zweck.',

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

'commandline.config_undefined'  =>  'Beim Versuch, das „Config“-Attribut einer Modulino-Instanz abzurufen, wurde festgestellt, dass es noch nicht definiert war.',

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

     perl -CAS ChangeName.pm
    
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

'change.locked'     =>  'Aufgrund der aktuellen Bearbeitungssperre für Datensatz [_1] wurden Änderungen an Datensatz [_1] nicht gespeichert.',

'change.from.can'   =>

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

Was ist Ihr Suchwert beim Abgleich innerhalb von [nest,_1]?
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
    'Language set to [language_name].'             =>  'Sprache auf [language_name] eingestellt.',
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
    'Leaving prepare method.'=>'Verlassen der „prepare“-Methode.',
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
    'Nothing was found to match.'=>'Es wurde keine Übereinstimmung festgestellt.',
    'Premature exit - No search results to narrow down.'=>'Vorzeitiger Ausstieg – Keine Suchergebnisse zum Eingrenzen.',
    'Premature Exit - our operation is already specific to a name part.'=>'Vorzeitiger Ausstieg – unser Vorgang ist bereits spezifisch für einen Namensteil.',
    'Premature exit - name parts already populated.'=>'Vorzeitiges Beenden – Listenvariable name_parts bereits gefüllt.',
    'Premature exit - no result passed in.'=>'Vorzeitiges Beenden – kein Ergebnis wird an die Unterroutine übergeben.',
    'Changed our working result - this will not be committed.'=>'Unsere Arbeitskopie des Ergebnisobjekts wurde geändert. Diese Änderungen werden nicht in der Datenbank „festgeschrieben“ (nicht gespeichert).',
    'Changed our fresh result - this will be committed.'=>'Unsere neue Kopie des Ergebnisdatensatzes wurde geändert. Diese Änderungen werden in Kürze in die Datenbank „übertragen“ (in Kürze gespeichert).',
    'Set search normally, as no --exact flag provided.'=>'Suche normal einstellen, da kein --exact-Flag bereitgestellt wird.',
    'Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.'=>'Der Suchbegriff „[_1]“ wird als exakte (wenn auch nicht zwischen Groß- und Kleinschreibung unterscheidende) Zeichenfolge interpretiert, die gesucht werden soll.',
    'Find attribute set to ([_1]).'=>'Das Attribut „find“ wurde auf ([_1]) gesetzt.',
    'Search attribute set to ([_1]).'=>'Das Attribut „search“ wurde ([_1]) gesetzt.',
    'Constructed New Logger Object Instance.'=>'Neue Logger-Objektinstanz erstellt.',
    'Starting subroutine.'=>'Unterprogramm wird gestartet.',
    'Multilingual variations of [_1] are as dumped below...'=>'Mehrsprachige Varianten von [_1] finden Sie weiter unten, solange die Datendumps auf die Anzeige eingestellt sind ...',
    'Initial option translation...'=>'Anfängliche Optionsübersetzung...',
    'Option translation as a list with codebase\'s existing option key "[_1]" omitted...'=>'Optionenübersetzung als Liste, wobei der vorhandene Optionsschlüssel "[_1]" der Codebasis weggelassen wird...',
    'Option string is: [_1]'=>'Optionszeichenfolge ist: [_1]',
    'No list of translation values to add alongside codebase\'s existing option key "[_1]" for language [language_name].' # [language_name] is a function not to be translated.
    =>'Keine Liste mit Übersetzungswerten zum Hinzufügen neben dem vorhandenen Optionsschlüssel „[_1]“ der Codebasis für die Sprache [language_name].',
    'Leaving subroutine.'=>'Im Begriff, das Unterprogramm zu verlassen.',
    'Configuration Values are...'=>'Konfigurationswerte sind ...',
    'In subroutine.'=>'Im Unterprogramm.',
    'Creating object params for ChangeName::Operation'=>'Erstellen von Objektparametern für ChangeName::Operation',
    'Object params as follows...'=>'Objektparameter wie folgt...',
    'About to call start method on ChangeName::Operation class'=>'Im Begriff, die Methode „start“ der Klasse „ChangeName::Operation“ aufzurufen',
    'Current language object is as follows...'=>'Das aktuelle Sprachobjekt ist wie folgt...',
    'Leaving method prematurely due to no replacement provided.'=>'Methode vorzeitig verlassen, da kein Ersatz bereitgestellt wurde.',
    'Proposed replacement language object is as follows...'=>'Das vorgeschlagene Ersatzsprachobjekt ist wie folgt...',
    'Proposed replacement was found to be a valid language object.'=>'Der vorgeschlagene Ersatz wurde erfolgreich als gültiges Sprachobjekt validiert.',
    'Replacement operation performed.'=>'Der Ersetzungsvorgang wurde erfolgreich abgeschlossen.',
    'In method.'=>'In der Methode.',
    'About to set Repository.'=>'Der nächste Schritt besteht darin, das Repository einzurichten.',
    'Set Repository. About to add attributes from params...'=>'Legen Sie das zu verwendende Repository fest. Der nächste Schritt besteht darin, Attribute aus Parametern hinzuzufügen...',
    'Language and Logger attributes set.'=>'Sprach- und Logger-Attribute festgelegt.',
    'Data dump prevented by no_dumper option.'=>'Datendump durch Option kein_dumper verhindert.',
    'No specific language set. Using all supported languages: [_1].'=>'Kein bestimmter Sprachsatz. Es werden alle unterstützten Sprachen verwendet: [_1]',
    'Default options set as follows...'=>'Die Standardoptionen sind wie folgt eingestellt ...',
    'Passed in commandline arguments from which to derive both options and arguments from are as follows...'=>'Die bereitgestellten Befehlszeilenargumente, aus denen sowohl Optionen als auch Argumente abgeleitet werden müssen, sind wie folgt...',
    'Validated copy of arguments is as follows...'=>'Eine validierte Kopie der Argumente lautet wie folgt...',
    'Flattened list of default options are as follows...'=>'Die abgeflachte Liste der Standardoptionen lautet wie folgt...',
    'Option Specifications have been determined as being as follows...'=>'Die Optionsspezifikationen wurden wie folgt festgelegt...',
    'Options after processing the commandline arguments are now as follows...'=>'Die Optionen nach der Verarbeitung der Befehlszeilenargumente sind jetzt wie folgt...',
    'Arguments after processing the commandline arguments are as follows...'=>'Die Argumente nach der Verarbeitung der Befehlszeilenargumente lauten wie folgt...',
    'The no_input flag will be returned with the value: "[_1]".'=>'Das Flag no_input wird mit dem Wert „[_1]“ zurückgegeben.',
    'Params to be used for a new logger are as follows...'=>'Die für einen neuen Logger in Kürze zu verwendenden Parameter sind wie folgt...',
    'Detected [nest,input.none].'=>'„[nest,input.none]“ erkannt.',
    'Detected [nest,input.all].'=>'„[nest,input.all]“ erkannt.',
    'Detected [nest,input.yes_letter].'=>'Erkannt „[nest,input.yes_letter]“.',
    'Params have been as follows...'=>'Die Parameter, mit denen wir gearbeitet haben und weiterhin arbeiten werden, sind die folgenden...',
    'Options we will use are as follows...'=>'Die von uns verwendeten Optionen sind die folgenden...',
    'Arguments we will use are as follows...'=>'Wir werden die folgenden Argumente verwenden...',
    'Archive attribute of [_1] instance is now "[_2]".'=>'Das Archivattribut der [_1] Instanz ist jetzt "[_2]".',
    'Repository attribute of [_1] instance is now of class "[_2]".'=>'Das Repository-Attribut der [_1] Instanz ist jetzt von der Klasse "[_2]".',
    'Repository attribute of [_1] instance is not a blessed object. Dumped contents are as follows...'=>'Das Repository-Attribut der [_1]-Instanz ist kein gesegnetes Objekt. Der DataDump des Inhalts ist wie folgt...',
    'Valid list object. Proceeding to chunkify using chunk size [_1]...'=>'Gültiges Listenobjekt. Mit der Chunkifizierung wird mit der Chunkgröße [_1] fortgefahren...',
    'Adding a chunk, from a list offset of [_1].'=>'Jetzt wird ein „Chunk“ aus einem Listenoffset von [_1] hinzugefügt.',
    'Invalid list object. Returning the default result - an empty list that will return false in scalar context.'=>'Ungültiges Listenobjekt. Das Standardergebnis wird zurückgegeben – eine leere Liste, die im Skalarkontext „False“ zurückgibt.',
    'Have determined that confirmation is not to be set automatically to yes or no. Instead we\'ll now prompt the user for a confirmation value.'=>'Habe festgelegt, dass die Bestätigung nicht automatisch auf ja oder nein gesetzt werden soll. Stattdessen fordern wir den Benutzer nun zur Eingabe eines Bestätigungswertes auf.',
    'Invalid name parts filter regex as follows...'=>'Ungültige Namensteile filtern reguläre Ausdrücke wie folgt...',
);

our %Lexicon = (
    #'_AUTO' => 1, # Commented out the auto for now.
    @configurations,
    @tokens,
    @phrases,
);

sub language_name {
    return $Lexicon{'language.name'};
}

# ----------------------------------

1;

}

}; # LOAD_LANGUAGE_CLASSES_FIRST BEGIN Block.


1;

__END__

