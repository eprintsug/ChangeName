#!/usr/bin/env perl

package ChangeNameOperation v1.0.0;

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
use     List::Util  qw(
            mesh
        );
use     Getopt::Long;

use     open ':std',   ':encoding(UTF-8)';
use     Scalar::Util qw(
            blessed
            reftype
        );
use     CPAN::Meta::YAML qw(
            LoadFile
            Load
        ); # Standard module in Core Perl since Perl 5.14.
use     File::Basename;


=pod Name, Version

=encoding utf8

=head1 NAME

ChangeNameOperation

=head1 VERSION

v1.0.0

=cut

=pod Synopsis, Description

=head1 SYNOPSIS

    # Run at the command line:
    perl -CAS ./ChangeNameOperation.pm

=head1 DESCRIPTION

Calls a subroutine.
Currently set to call L</start;>.

    # Run from the command line:
    perl -CAS ./ChangeNameOperation.pm

=cut

#UTF-8 the default on standard input and output:
binmode STDIN           ,   ChangeNameOperation->get_encoding;  # Using a sub/method avoids needing to wrap this package in a block
                                                                # to prevent a my variable maintaining scope for whole file.
binmode STDOUT          ,   ChangeNameOperation->get_encoding;
binmode STDERR          ,   ChangeNameOperation->get_encoding;
$ENV{'PERL_UNICODE'}    =   'AS';   # A = Expect @ARGV values to be UTF-8 strings.
                                    # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.

# Data Dumper Settings:
$Data::Dumper::Useperl  =   1;  # Perl implementation will see Data Dumper adhere to our binmode settings.
$Data::Dumper::Maxdepth =   4;  # So when we dump a repository object we don't get too much stuff.
$Data::Dumper::Sortkeys =   1;  # Hashes in same order each time - for easier dumper comparisons.

# Command Line Auto-run:
ChangeNameOperation->start_from_commandline(@ARGV) unless caller;

=head1 METHODS

=over

=item hello();

    use ChangeName qw(hello);
    my  $greeting = hello();
    
    # Alternatively:
    use ChangeName;
    my  $greeting = ChangeName->hello();

Returns a string containing a greeting.

=back

=cut

# Start:

sub start_from_commandline {
    my  $class          =   shift;
    my  @object_params  =   $class->_get_commandline_arguments(@ARG);

    $class->_check_commandline_input(@object_params)->new(@object_params)->search->part_specific->display->confirm->change->finish;

}

# Program Flow:

sub new {
    my  $class      =   shift;
    my  $params     =   {@ARG};

    my  $self       =   {};
    bless $self, $class;

    $self->_set_attributes($params)->log_debug('Constructed New Object Instance.')->dumper;

    return $self;
}

sub search {
    my  $self                   =   shift;
    
    $self->log_debug('Entered method.')->dumper->log_verbose('Searching...');
    
    # Search:
    $self->{list_of_results}    =   $self->{repository}
                                    ->dataset($self->{dataset_to_use})
                                    ->prepare_search($self->{search_settings})
                                    ->perform_search;
                                    # Search interprets 'ó' as matching 'O.' (yes - even with the dot) and 'à' as matching 'A'
                                    # This is an EPrints API behaviour.
                                    # These are not direct matches, and so could be filtered out by us.
                                    # At the same time, it also works in reverse. Lopez-Aviles can match López-Avilés 
                                    # - which is beneficial if someone doesn't have the correct keyboard.
                                    # So let's leave this in.

    $self->{records_found}      =   scalar $self->{list_of_results}->{ids}->@*;

    $self->log_verbose(
        $self->{records_found}? 'Found Results.':
        'No Results Found.'
    );

    return $self->log_debug('Leaving method.')->dumper;

}

sub part_specific {

    my  $self   =   shift;

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
    for my $unique_name ($self->{'unique_names'}->@*) {

        $self->log_debug('Processing Unique name: [_1]', $unique_name);

        # Initial Values:
        $self->{'matches_unique_name'}              =   qr/^\Q$unique_name\E$/;
        $self->{'unique_name'}                      =   $unique_name;
        $self->{'display_lines'}->{"$unique_name"}  =   [];
        $self->{'display'}->{"$unique_name"}        =   undef;

        # Processing;
        foreach my $chunk_of_results ($self->chunkify) {
            $self->_add_relevant_display_lines($ARG) for $chunk_of_results->@*;
        };
        
    };

    # Output:
    return $self->log_debug('Leaving display method.')->dumper;

}

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
    for my $unique_name ($self->{'unique_names'}->@*) {
    
        $self->log_debug('Processing Unique name: [_1]', $unique_name);

        # Initial Values:
        $self->{display_lines_shown}    =   undef;
        $self->{matches_unique_name}    =   qr/^\Q$unique_name\E$/;
        $self->{unique_name}            =   $unique_name;
        $self->{auto_yes}               =   undef;
        $self->{auto_no}                =   undef;

        # Processing:        
        foreach my $chunk_of_results ($self->chunkify) {
            $self->_seeking_confirmation($ARG) for $chunk_of_results->@*;
        };

    };

    # Output:
    return $self->log_debug('Leaving confirm method.')->dumper;

}

sub change {
    my  $self   =   shift;
    $self->log_debug('Called change method.')->dumper;

    my  $prerequisites  =   $self->{what_to_change}
                            && reftype($self->{what_to_change}) eq 'ARRAY'
                            && $self->{what_to_change}->@*;
    
    return $self->log_debug('Premature exit - Nothing to change.') unless $prerequisites;

    for my $details ($self->{what_to_change}->@*) {

        my  ($result, $search_field, $names, $name) =   $details->@*;
        
        say $self->localise('change.from', format_single_line_for_display($result, $search_field));

        $name->{"$self->{'part'}"}  =   $self->{'replace'};
        $result->set_value($search_field, $names);

        say $self->localise('change.to', format_single_line_for_display($result, $search_field));
    
        if ($self->{live}) {
            $result->commit($self->{force_or_not}->@*);
            say $self->localise('change.done');
            $self->{changes_made} = 'Yes';
        }
        else {
            say $self->localise('change.dry_run')
        };

    };
    
    return $self;
}

sub finish {
    my  $self   =   shift;
    say $self->localise('finish.change') if $self->{changes_made};
    say $self->localise('finish.no_change') unless $self->{changes_made};
    say $self->localise('finish.thank_you');
    return $self;
}

# Setters and Getters:

sub get_encoding {
    return ':encoding(UTF-8)';  # Encoding is also set for the open command
                                # at the top of this package:
                                # use     open ':std',   ':encoding(UTF-8)';
                                # So if ever changing encoding, change that line too.
}

sub default_yaml_filepath {
    return dirname(__FILE__).'/ChangeNameOperationConfig.yml';
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

sub _set_search {
    return shift->_set_or_prompt_for('find' => shift, 'search', @ARG); # Search prompt type.
}

sub _set_replace {
    return shift->_set_or_prompt_for('replace' => shift, @ARG);
}

sub set_name_parts {

    my  $self               =   shift;
    
    $self->log_debug('Entering method.')->log_debug('Name parts before we begin:')->dumper($self->{name_parts});
    
    my  $already_set        =   $self->{name_parts}
                                && ref($self->{name_parts}) eq 'ARRAY'
                                && $self->{name_parts}->@*;

    return                      $self->log_debug('Premature exit - name parts already populated.')
                                if $already_set;

    my  $valid_name_parts   =   join(

                                    # Join by regex OR character:
                                    '|',                    

                                    # Make name parts regex safe:
                                    map {quotemeta $ARG}    

                                    # Name Parts for Each Field:
                                    map {keys $self->{repository}->dataset($self->{dataset_to_use})->field($ARG)->property('input_name_cols')->%*}

                                    # Fields:
                                    $self->{fields_to_search}->@*

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
    my  $filepath       =   shift // $self->default_yaml_filepath;

    $self->{yaml}       =   # External YAML file:
                            #(defined $filepath && -e $filepath)?    LoadFile($filepath):             # Will die on any load error.
                    
                            # Internal YAML __DATA__:
                            Load(                                           # Will die on any load error.
                                do                                          # 'do' returns last value of block.
                                {
                                    local $INPUT_RECORD_SEPARATOR = undef;  # Read until end of input.
                                    <ChangeNameOperationYAMLConfig::DATA>   # Input is __DATA__ at the bottom of this very file.
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

    $self->log_debug('Entered module.');

    die                                 $self->localise('format_single_line_for_display.error.no_params')
                                        unless ($result && $field);

    $self->log_debug('Found params, and about to process them...');

    my  $names                      =   join(
                                            $self->localise('separator.name_values'),
                                            map {$self->_stringify_name($ARG) // ()}
                                            $result->get_value("$field")->@*
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
    return join ', ', shift->@*;
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
        @prompt_arguments               =   $self->{confirm_prompt_arguments}->@*; # A hack. Maybe refactor to be passed in.
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

        until ( $confirmation && ($confirmation =~ $matches_acceptable_input) ) {
            say $self->localise('prompt_for.confirm.acceptable_input');
            chomp($confirmation   =   <STDIN>)
        };

        $input = $confirmation;
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

sub log_verbose {
    my  $self   =   shift;
    #say 'in log verbose';
    # Premature Exit:
    return $self unless ($self->{verbose} || $self->{debug});
    #say 'still in log verbose';
    return $self->_log('verbose',@ARG);
}

sub log_debug {
    my  $self   =   shift;
    #say 'in log debug';
    # Premature Exit:
    return $self unless $self->{debug};
    #say 'still in log debug';
    return $self->_log('debug',@ARG);
}

sub dumper {
    my  $self   =   shift;
    
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
                            qw(
                                repository
                                list_of_results
                            )
                        );
                    
    my  %default    =   map
                        {
                            $ARG =~ m/^($class_only)$/
                            && blessed($self->{$ARG})? ($ARG => blessed($self->{$ARG})):
                            ($ARG => $self->{$ARG})
                        }
                        map {$ARG =~ m/^($exclude)$/? ():($ARG)}
                        keys $self->%*;

    # Set params:
    my  @params     =   @ARG?   @ARG:
                        (\%default);

    return $self->_log('dumper',@params); 
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
        config      =>  undef,
    };

    # Command Line Options:    
    Getopt::Long::Parser->new->getoptionsfromarray(
        \@ARG,              # Array to get options from.
        $params,            # Hash to store options to.

        # Actual options:
        'language|lang:s',  # Optional string.
                            # Use 'language' for the hash ref key, 
                            # accept '--language' or '--lang' from the commandline.
                            # Syntax can be --lang=en-GB or --lang en-GB

        'config:s',         # Optional string.
                            # Use 'config' for the hash ref key, 
                            # accept '--config' from the commandline.
                            # Syntax can be --config=path/to/yaml_config.yml or --config path/to/yaml_config.yml
 
        'live!',            # if --live present,    set $live to 1,
                            # if --nolive present,  set $live to 0.

        'verbose+',         # if --verbose present,    set $verbose
                            # to the number of times it is present.
                            # i.e. --verbose --verbose would set $verbose to 2.

        'debug!',           # if --debug present,    set $debug to 1,
                            # if --nodebug present,  set $debug to 0.

        'trace!',           # if --trace present,    set $trace to 1,
                            # if --notrace present,  set $trace to 0.

    );

    $params={
        $params->%*,
        archive_id  =>  shift,
        find        =>  shift,
        replace     =>  shift,
        part        =>  shift,
    };

    #say "Dump params:".Dumper($params->%*);

    return              wantarray?  $params->%*:    # List context
                        $params;                    # Scalar or void contexts.

}

sub _check_commandline_input {

    my  $class              =   shift;
    my  $params             =   {@ARG};
    my  @commandline_input  =   map { defined $ARG && $ARG? $ARG:() } (
                                    $params->{archive_id},
                                    $params->{find},
                                    $params->{replace},
                                    $params->{part},
                                );

    my  $language_to_use    =   'en-GB'; #$params->{'language'} //  
                            #//  $class->get_default_language;

    my  $language           =   ChangeNameOperation::Languages->try_or_die($language_to_use);

    my  $localise           =   sub { $language->maketext(@ARG) };

    if ($params->{live}) {
        say $localise->('LIVE mode - changes will be made at the end after confirmation.');
    }
    else {
        say $localise->('DRY RUN mode - no changes will be made.');
        say $localise->('Run again with the --live flag when ready to implement your changes.');
    };

    if ($params->{debug}) {
        say $localise->("Commandline Params are...");
        say Dumper($params);
        say $localise->("Commandline Input is...");
        say Dumper(@commandline_input);
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

};

sub _set_attributes {

    # Initial Values:
    my  ($self, $params)    =   @ARG;

    my  $matches_yes        =   qr/^(y|yes)$/i; # Used with YAML. Case insensitive y or yes and an exact match - no partial matches like yesterday.

    $self->%*               =   (

        # Existing values in $self:
        $self->%*,

        # From params:
        live                =>  $params->{live} // 0,
        debug               =>  $params->{debug} // 0,
        verbose             =>  $params->{verbose} // 0,
        trace               =>  (
                                    $params->{verbose} > 2
                                    || ($params->{debug} && $params->{verbose})
                                    || ($params->{debug} && $params->{trace})
                                ),
        # Internationalisation:
        language            =>  ChangeNameOperation::Languages->try_or_die($params->{language}//$self->get_default_language),

    );

    $self->_set_repository      ($params->{archive_id})
    ->log_verbose               ('Language set to [_1].', $self->{language}->language_tag)
    ->log_debug                 ('Set initial instance attributes using params or defaults.')
    ->log_debug                 ('Language, archive, repository, and debug/verbose/trace settings were all required for log methods.')
    ->log_debug                 ('Now setting additional instance attributes from params...')
    ->_set_search               ($params->{find})
    ->_set_replace              ($params->{replace},'no_prompt') # Optional on initialisation
    ->_set_part                 ($params->{part},'no_prompt') # Optional on initialisation
    ->_set_yaml                 ($params->{yaml})
    ->dumper;
    
    $self->log_debug('Setting self-referential instance attributes...')
    ->%*                    =   (

        # Existing values in $self:
        $self->%*,

        # From YAML Configuration:
        force_or_not        =>  [
                                    ($self->{yaml}->{'Force commit changes to database'} =~ $matches_yes)?    [1]:
                                    ()
                                ],
        dataset_to_use      =>  $self->{yaml}->{'Dataset to use'},
        fields_to_search    =>  $self->{yaml}->{'Fields to search'},
    );

    $self->log_verbose('Set YAML configurations.')->dumper
    ->%*                    =   (
    
        # Existing values in $self:
        $self->%*,
    
        # Search:
        search_fields       =>  [{
                                    meta_fields     =>  $self->{fields_to_search},
                                    value           =>  $self->{find},
                                }],
        
    );

    $self->log_debug('Set search-fields.')->dumper
    ->log_debug('Setting further self-referential attributes...')
    ->%*                    =   (

        # Existing values in $self:
        $self->%*,

        # Search Settings:
        search_settings =>  {
                                    satisfy_all         =>  1,
                                    staff               =>  1,
                                    limit               =>  30,
                                    show_zero_results   =>  0,
                                    allow_blank         =>  1,
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
        foreach my $result ($results_chunk->@*) {
            foreach my $search_field ($self->{'fields_to_search'}->@*) {

                my  $names          =   $result->get_value($search_field);
                my  @range_of_names =   (0..$names->$#*);

                for my $current (@range_of_names) {

                    my  $name           =   $names->[$current];
                    my  $unique_name    =   q{};

                    for my $name_part ($self->{'name_parts'}->@*) { # Array, so in specific order that's the same each time.

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

    for my $name_of_list (keys $self->{frequencies}->%*) {

        $self->{"$name_of_list"}    =   [
                                            sort {$a cmp $b} 
                                            keys $self->{frequencies}->{"$name_of_list"}->%*    # Defined in _tally_frequencies method.
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

    foreach my $search_field ($self->{'fields_to_search'}->@*) {

        $self->log_verbose('Processing search field: [_1]', $search_field);

        for my $name ($result->get_value($search_field)->@*) {

            if ( $self->_match($name)->{matches} ) {
                
                my  $line                                                   =   $self->format_single_line_for_display($result, $search_field);

                push $self->{'display_lines'}->{"$self->{unique_name}"}->@* ,   $line;

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

    foreach my $search_field ($self->{'fields_to_search'}->@*) {

        $self->log_verbose('Processing search field: [_1]', $search_field);

        my  $names                  =   $result->get_value($search_field);
        my  @range_of_names         =   (0..$names->$#*);             

        for my $current (@range_of_names) {

            my  $name   =  $names->[$current];

            next unless $self->_match($name)->{matches};

            $self->log_debug('Checking if display lines have been shown.')->dumper($self->{display_lines_shown});
                       
            unless ($self->{display_lines_shown}) {

                say $self->localise(
                        'seeking_confirmation.display_lines',
                        $self->_stringify_name($name),
                        join(
                            $self->localise('separator.new_line'),
                            $self->{display_lines}->{"$self->{unique_name}"}->@*,
                        ),
                    );

                $self->{display_lines_shown}    =   'Yes';

            };

            # Set or get confirmation:
            $self->log_debug('Setting confirmation');
            
            my  $self->{confirm_prompt_arguments}   =   [
                                                            $self->{'part'},
                                                            $name->{"$self->{'part'}"},
                                                            $self->{'replace'},
                                                            ($current+1),
                                                            $search_field,
                                                            format_single_line_for_display($result, $search_field),
                                                        ];

            my  $confirmation       =   $self->{matches_auto_no}?   $no:
                                        $self->{matches_auto_yes}?  $yes:
                                        $self->prompt_for('confirm');

            # Process confirmation:
            $self->log_debug('Processing confirmation...')->dumper($confirmation);

            if ($confirmation eq $none) {
                $self->{auto_no}    =   $self->{unique_name};
            };

            if ($confirmation eq $all) {
                $self->{auto_yes}   =   $self->{unique_name};
            };

            next if ($confirmation eq $no || $confirmation eq $none);

            if ( $confirmation eq $yes || $confirmation eq $all ) {
            
                my $details         =   [
                                            $result,
                                            $search_field,
                                            $names,
                                            $name,
                                        ];

                push $self->{what_to_change}->@*, $details;

                $self->log_debug('Added details to what_to_change')->dumper($details);

            };

        };

    };
    
    return $self->log_debug('Leaving method.')->dumper;

}

sub _match {

    my  $self       =   shift->log_debug('Entering method');
    my  $name       =   shift;

    my  $uniqueness =   q{};

    for my $name_part ($self->{'name_parts'}->@*) { # Array, so in specific order that's the same each time.

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
        $self->log_verbose('Match found for: [_1]', $self->_stringify_name($name))
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

    for my $current_part ($self->{name_parts}->@*) {
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
    
        # Stop out of range input:
        die                                 $self->localise('_validate.error.four_byte_character')
                                            if (
                                                $input[$current_index]
                                                && ($input[$current_index] =~ $matches_four_byte_character)
                                            );

        # Consider a sole zero as a true input value:
        $input[$current_index]          =   $input[$current_index] eq '0'? "0 but true":
                                            $input[$current_index];

    };

    # Output:
    return  # In list context:
            wantarray?                          @input:
            # In Scalar and void contexts..
            $number_of_input_arguments == 1?    $input[0]:  # if only one value, return sole value...
            \@input;                                        # ...otherwise return an array ref.
}

sub _log {
    #say 'In _log';
    my  $self       =   shift;

    # Premature exit:
    die                 $self->localise('_log.error.no_repository')
                        unless blessed($self->{repository}) && $self->{repository}->isa('EPrints::Repository');

    # Initial Values:
    my  $type       =   shift;
    my  $use_prefix =   $self->{verbose} > 1 || $self->{debug};
    #Dumper(((caller 2)[3]));
    #Dumper(scalar localtime);
    #Dumper(uc($type));
    my  $prefix     =   $use_prefix?    sprintf(
                                            '[%s] [%s] [%s] - ',

                                            scalar localtime,      # Human readable system time and date - linux's ctime(3).

                                            ((caller 2)[3]),  # Back 2, to what called dumper / log_debug / log_verbose, 
                                                            # and get the 3rd array index value 
                                                            # - the perl module and subroutine name.

                                            uc($type),      # Log type - LOG / DEBUG / DUMPER
                                        ):
                        q{};

    # Log:
    $self->{repository}->log(
        $prefix.(
            $type eq 'dumper'?  $self->localise('separator.new_line').Dumper(@ARG):
            $self->localise(@ARG)
        ),
    );
    
    # Stack trace:
    if ($self->{trace}) {
        $self->{repository}->log(
            sprintf(
                                                '[%s] [%s] [%s] - ',

                                                scalar localtime,      # Human readable system time and date - linux's ctime(3).

                                                ((caller 2)[3]),  # Back 2, to what called dumper / log_debug / log_verbose, 
                                                                # and get the 3rd array index value 
                                                                # - the perl module and subroutine name.

                                                'TRACE',      # Log type - LOG / DEBUG / DUMPER
                                            )
        );
        EPrints->trace;
    };
    
    return $self;
}



=over

=item my_example();

    # Run from command line:
    perl ./ChangeName.pl

Input set internally.
Searches EPrints according to internally set search criteria,
then calls L</result_processing( $session, $dataset, $result, $output);>
for processing of the search results for output purposes.
Returns a multi-line string that can be used with say or print,
to display the output returned from the result processing.

=back

=cut

=over

=item result_processing( $session, $dataset, $result, $output);

Expects an L<EPrints::Repository> object ($session),
L<EPrints::DataSet> object,
L<EPrints::List> object (as typically returned from a search),
and a hash reference of useful information (traditionally $info),
which in this case will be used 
to manipulate the value of a lines hash key,
that stores an array reference to an array of lines,
to be used for printing output to the terminal,
and so is described as $output.

Output is expected to be the manipulated $output hash reference,
so there is no explicit return statement.

Notes:
Used internally by my_example, 
so should possibly be made a private method
(as is possible with lexical methods 
in L<Object::Pad> or presumably Perl 5.38 too).
Might go back to making it 
an anonymous sub / coderef within my_example method.

=back

=cut



1;



=head1 AUTHOR

Andrew Mehta

=cut

package ChangeNameOperation::Languages;

# Always:
use     strict;
use     warnings;

# UTF-8:
use     utf8;
use     v5.16;

# Specific:
use     English;
use     parent qw(Locale::Maketext);

sub try_or_die {

    my  ($self, $language)  =   @ARG;
    #say 'LANG ='.(defined $language? $language:'Nothing');
    $language               //= 'en-GB';
    #say 'LANG ='.$language;
    my  $error={
        language            =>  'Trouble finding a language to use.',
    };

    return  $self->get_handle($language)
            || die  $error->{'language'};
}


1;


BEGIN { # Load prior to ChangeNameOperation::Languages and restrict scope of our variables to this block
package ChangeNameOperation::Languages::en_gb;

# Always:
use     strict;
use     warnings;

# UTF-8:
use     utf8;
use     v5.16;
use     warnings (
            'FATAL',    #makes anything in this list fatal
            'utf8',     #utf8 is a warnings category. There is no FATAL UTF-8
        ); 

# Specific:
use     parent -norequire, qw(
            ChangeNameOperation::Languages
        );


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

'input.yes_letter'              =>  'Y',
'input.no_letter'               =>  'N',
'input.all'                     =>  'ALL',
'input.none'                    =>  'NONE',
'input.1'                       =>  '1',
'input.2'                       =>  '2',
'separator.name_parts'          =>  ' ', #space
'separator.name_values'         =>  ',',
'separator.new_line'            =>  $new_line,
'name.given'                    =>  'Given Name',
'name.family'                   =>  'Family Name',
'display_line'                  =>  'Record [_1]: [_2].',

'_stringify_name.error.no_params' =>
'Method requires a name hash reference of name parts,
to be passed in as an argument,
and no such params were provided.',

'commandline.end_program'       =>  'This program will now end...'.$new_line,
'validation.errors.invalid'     =>  "Invalid [_1] field in [_2] form.\n",

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

'change.from'  =>

'
Changing...

[_1]

',

'change.to' =>

'...to...

[_2]

',

'change.dry_run'    =>  'Not done, because this is a dry run. For changes to count, run the script again with the --live flag added.',

'change.done'       =>  'Done.',

'seeking_confirmation.display_lines' =>

'For the unique name combination...

[_1]

...the following matching records were found:

[_2]

------
',

'prompt_for.confirm.acceptable_input'  =>

'Enter "Y" for Yes,
Enter "N" for No,
Enter "ALL" for Yes to All for this unique name combination.
Enter "NONE" for No to All for this unique name combination.',


'prompt_for.archive'                        =>  'Please specify an Archive ID: ',
'prompt_for.search'                         =>  'Please specify a Search Term: ',
'prompt_for.replace'                        =>  'Please specify a Replace Term: ',

'prompt_for.find'                           =>  

'Your change will be performed using find and replace,
(looking to find full and not partial matches, and with case insensitivity).
What is your find value when matching within [_1]?',

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

'finish.change'     =>  '[quant,_1,Change] successfully completed.',

'finish.no_change'  => 'No changes made.', 

'finish.thank_you'  => 'Thank you for using this script.',

);

my  @phrases = (
    'Constructed New Object Instance'   =>  'Constructed New Object Instance',
    'Commandline Params are...'         =>  'Commandline Params are...',
    'Commandline Input is...'           =>  'Commandline Input is...',
    'Language set to [_1].'             =>  'Language set to [_1].',
    'Set initial instance attributes using params or defaults.' =>  'Set initial instance attributes using params or defaults.',
    'Language, archive, repository, and debug/verbose/trace settings were all required for log methods.' =>  'Language, archive, repository, and debug/verbose/trace settings were all required for log methods.',
    'Now setting additional instance attributes from params...' => 'Now setting additional instance attributes from params...',
    'Setting self-referential instance attributes...' => 'Setting self-referential instance attributes...',
    'Set YAML configurations.' => 'Set YAML configurations.',
    'Set search-fields.' => 'Set search-fields.',
    'Setting further self-referential attributes...' => 'Setting further self-referential attributes...',
    'Entering method.' => 'Entering method.',
    'Name parts before we begin:' => 'Name parts before we begin:',
    'Set name parts according to language localisation as follows...' => 'Set name parts according to language localisation as follows...',
    'Leaving method.' => 'Leaving method.',
    'Constructed New Object Instance.' => 'Constructed New Object Instance.',
    'Entered method.' => 'Entered method.',
    'Searching...' => 'Searching...',
    'Found Results.' => 'Found Results.',
    'Narrowing search to a specific part...' => 'Narrowing search to a specific part...',
    'Generating lists, and setting values.' => 'Generating lists, and setting values.',
    'DRY RUN mode - no changes will be made.'=>'DRY RUN mode - no changes will be made.',
    'Run again with the --live flag when ready to implement your changes.' => 'Run again with the --live flag when ready to implement your changes.',
    'Processing search field: [_1]'=>'Processing search field: [_1]',
    'Leaving part_specific method.'=>'Leaving part_specific method.',
    'Called display method.' => 'Called display method.',
    'Processing Unique name: [_1]'=>'Processing Unique name: [_1]',
    'Entered method. Attribute display_lines is...'=>'Entered method. Attribute display_lines is...',
    'Entering method'=>'Entering method',
    'Leaving method. Attribute display_lines is...'=>'Leaving method. Attribute display_lines is...',
    'Match found for: [_1]'=>'Match found for: [_1]',
    'No match found.'=>'No match found.',
    'Matched "[_1]" in "[_2]" part of the following unique name...'=>'Matched "[_1]" in "[_2]" part of the following unique name...',
    'Entered module.'=>'Entered module.',
    'Found params, and about to process them...'=>'Found params, and about to process them...',
    'Stringified names for use in a localised display line.'=>'Stringified names for use in a localised display line.',
    'Returning localised display line as we leave the method.'=>'Returning localised display line as we leave the method.',
    'Set display flags and added display line:'=>'Set display flags and added display line:',
    'Leaving display method.'=>'Leaving display method.',
    'Called confirm method.'=>'Called confirm method.',
    'Checking if display lines have been shown.'=>'Checking if display lines have been shown.',
    'Setting confirmation'=>'Setting confirmation',

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

package ChangeNameOperationYAMLConfig;

1;

__DATA__
# This is a YAML Configuration File:
%YAML 1.2
# Three dashes to start new YAML document.
---

Fields to search:
    -   creators_name
    -   contributors_name

Dataset to use: eprint

Force commit changes to database: yes

# For the above, provide a yes or y (case insensitive) to force commit,
# or anything else (such as no) to not force commit.

...
# Three dots to end current YAML document.


