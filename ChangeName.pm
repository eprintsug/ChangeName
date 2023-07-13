#!/usr/bin/perl -I /opt/eprints3/perl_lib

package ChangeName;

use     strict;
use     warnings;

#use     v5.32;
use     v5.16;
#use     feature 'signatures'; # Not activated by default until the 5.36 bundle.
use     utf8;
use		warnings (
			'FATAL',	#makes anything in this list fatal
			'utf8',		#utf8 is a warnings category. There is no FATAL UTF-8
		); 
use     English;

use     Data::Dumper;
use     List::Util  qw(
            pairmap
            mesh
        );
use     EPrints;
use     EPrints::Repository;
use     EPrints::Search;
use     Getopt::Long;


=pod Name, Version

=encoding utf8

=head1 NAME

Change Name.

=head1 VERSION

v2.0.0

=cut

our $VERSION    =   'v2.0.0';

=pod Synopsis, Description

=head1 SYNOPSIS

    # Run at the command line:
    perl ./ChangeName.pm

=head1 DESCRIPTION

Calls a subroutine.
Currently set to call L</my_example();>.

    # Run from the command line:
    perl ./ChangeName.pm

=cut

#UTF-8 the default on standard input and output:
my  $our_encoding   =   ":encoding(UTF-8)";
binmode STDIN, $our_encoding;
binmode STDOUT, $our_encoding;

say ChangeName->version_from_pdl(@ARGV);

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

sub hello {
    my  $message = "Hello World";
    return $message;
}

sub presentable_compound_name {
    my  $self           =   shift;
    my  $compound_name  =   shift;
    my  @name_parts     =   @_;
    warn 'Name_parts: '.Dumper(@name_parts);
    my  $true_arguments =   $self && $compound_name && (scalar @_);
    die                     "Insufficient or false arguments for presentable_compound_name subroutine, "
                            unless $true_arguments;
    my  $regex_friendly =   join(
                                "|",                # Or
                                map {
                                    quotemeta($ARG) # Safe
                                }
                                @name_parts
                            );
    my  $keys           =   \@name_parts;
    my  $values         =   [split /$regex_friendly/, $compound_name];
    my  $hash           =   {mesh $keys, $values};
    my  $presentable_compound_name  =   "Honorary: $hash->{'honourary'}\n".
                                        "Given:    $hash->{'given'}\n".
                                        "Family:   $hash->{'family'}\n".
                                        "Lineage:  $hash->{'lineage'}";
    return $presentable_compound_name;
}

sub version_from_pdl {

    # Input:
    my  $our_encoding   =   ":encoding(UTF-8)";
    binmode STDIN, $our_encoding;
    binmode STDOUT, $our_encoding;
    warn Dumper(@_);
    my  $self                               =   shift;
	my  $live                               =   q{};
    Getopt::Long::Parser->new->getoptionsfromarray(
        \@_,
        'live!'                             =>  \$live
                                                # if --live present, 	set live to 1,
						                        # if --nolive present, 	set live to 0.
    );

    my ($archive, $find, $replace, $part)   =   $self->validate(@_);
        $archive                            //= $self->prompt_for('archive');
    my  $repository                         =   EPrints::Repository->new($archive);
        $find                               //= $self->prompt_for('search');
    my  $part_search                        =   $part? 1:
                                                0;
    my  $dataset_to_use                     =   'eprint';
    my  @fields_to_search                   =   (
                                                    'creators_name',
                                                    'contributors_name',
                                                );
    my  @name_parts                         =   (
                                                    'honourific',
                                                    'given',
                                                    'family',
                                                    'lineage',
                                                );
    my  $text = {
        data_count                          =>  'Number of dataset records found: ',
        search_count                        =>  'Number of search results found: ',
        part_suffix                         =>  ' Name',
    };
    my  $line_delimiter                     =   "\n";
    my  $search_fields                      =   [
                                                  {
                                                        meta_fields     =>  [
                                                                                @fields_to_search,
                                                                            ],
                                                        value           =>  $find,
                                                    },
                                                ];
    my  $get_useful_frequency_counts        =   \&get_useful_frequency_counts;
    my  $display_records                    =   \&display_records;
    my  $part_match                         =   \&part_match;
    my  @common_info = (
        search_fields                       =>  \@fields_to_search,
        name_parts                          =>  \@name_parts,
    );
    my  $useful_info = {
        @common_info,
        compound_names                      =>  {},
        given_names                         =>  {},
        family_names                        =>  {},
    };

    my  $part_match_info = {
        @common_info,
        live                                =>  $live,
    };


    # Processing:
    
    # Search:

    my  $list_of_results                    =   $repository
                                                ->dataset($dataset_to_use)
                                                ->prepare_search(
                                                    satisfy_all         =>  1,
                                                    staff               =>  1,
                                                    limit               =>  30,
                                                    show_zero_results   =>  0,
                                                    allow_blank         =>  1,
                                                    search_fields       =>  $search_fields,
                                                )
                                                ->perform_search;

    # Process Search Results:
    $list_of_results->map($get_useful_frequency_counts,$useful_info);
    
    unless ($part_search) {
        $part                       =   $self->prompt_for('part', $useful_info);
        # shouldn't we validate part is one of the accepted @name_parts?
        my  @presentable_part_name  =   $part?  (ucfirst($part).$text->{'part_suffix'}):
                                        ();
        $find                       =   $self->prompt_for('find', @presentable_part_name);
        $replace                    //= $self->prompt_for('replace');
        $part_search                =   $part && $find && defined($replace)? 1:
                                        undef;
    };
 
    if ($part_search) {

        for my $compound_name (keys $useful_info->{'compound_names'}->%*) {

            # Initial Values:
            $part_match_info->{'matches_compound_name'} =   qr/^\Q$compound_name\E$/;
            $part_match_info->{'matches_find'}          =   qr/^\Q$find\E$/i; # case insensitive.
            $part_match_info->{'part'}                  =   $part;
            $part_match_info->{'display_lines'}         =   [];

            # Processing:
            $list_of_results->map($display_records,$part_match_info);
            
            # Output:
            say "For the unique name combination...\n";
            say q{}; # Does it deliver a line return?
            say $self->presentable_compound_name($compound_name,@name_parts);
            say "...the following matching records were found:\n";
            say join $line_delimiter, $part_match_info->{'display_lines'}->@*;
            say q{};
            say '------';
            say q{};
                        
            # Do you need output from a single loop? If so you'll need to reset and export the part match info each iteration.

            # compound_names include non-part-matching names irrelevant to our search - so ... we need to filter those out / skip them.
        }
    };
 

    
    # Output:
    
    return Dumper([
        repo_is         =>  $archive,
        find_is         =>  $find,
        replace_is      =>  $replace,
        part_is         =>  $part,
        part_search_is  =>  $part_search,
        dataset_is      =>  $dataset_to_use,
        live_is         =>  $live,
        given_list_is   =>  join(', ',keys $useful_info->{'given_names'}->%*),
        family_list_is  =>  join(', ',keys $useful_info->{'family_names'}->%*),
        compound_list_is=>  join(', ',keys $useful_info->{'compound_names'}->%*),
    ]);
    
}

#sub get_useful_info {
#    my  ($session, $dataset, $result, $useful_info)  =   @_;
#
#    my  $given_names
#        foreach my $search_field ($output->{'search_fields'}->@*) {
#        warn "In search fields.\n" if $debugging;
#        my  $entries        =   $result->get_value($search_field);
#        my  @entry_range    =   (0..$entries->$#*);
#
#        for my $i (@entry_range) {
#    
#}


sub display_records {

    my  ($session, $dataset, $result, $part_match_info)  =   @_;



    foreach my $search_field ($part_match_info->{'search_fields'}->@*) {

        my  $names                      =   $result->get_value($search_field);
        my  @range_of_names             =   (0..$names->$#*);

        for my $current (@range_of_names) {

            my  $name                   =   $names->[$current];        
            my  $compound_name          =   "";
            my  $find_matched           =   $name->{"$part_match_info->{'part'}"}   =~  $part_match_info->{'matches_find'};

            if ($find_matched) {

                for my $name_part ($part_match_info->{'name_parts'}->@*) { # Array, so in specific order that's the same each time.

                    $compound_name      .=  $name_part.$name->{"$name_part"};

                };
                
                my  $compound_matched   =  $compound_name   =~  $part_match_info->{'matches_compound_name'};
                
                if ($compound_matched) {

                    push $part_match_info->{'display_lines'}->@*, format_single_line_for_display($result, $search_field);

                }
                
            };
            
        }
    }
    
}


sub format_single_line_for_display {

    # Initial Values:
    my  ($result, $field)       =   @_;
    my  $seperator = {
        fields                  =>  ', ',   # comma, space
        name_parts              =>  ' ',    # space
    };
    my  $id_suffix              =   ': ';

    my  @order_and_omit_blanks  =   map {
                                        join $seperator->{'name_parts'}, (
                                            $ARG->{'honourific'}?   $ARG->{'honourific'}:
                                            (),
                                            $ARG->{'given'}?        $ARG->{'given'}:
                                            (),
                                            $ARG->{'family'}?       $ARG->{'family'}:
                                            (),
                                            $ARG->{'lineage'}?       $ARG->{'lineage'}:
                                            (),
                                        )
                                    }
                                    $result->get_value("$field")->@*;

    return                          $result->id.$id_suffix.
                                    join($seperator->{'fields'}, @order_and_omit_blanks);
}



sub part_match {
    my  ($session, $dataset, $result, $part_match_info)  =   @_;
    
    foreach my $search_field ($part_match_info->{'search_fields'}->@*) {

        my  $names          =   $result->get_value($search_field);
        my  @range_of_names =   (0..$names->$#*);

        for my $current (@range_of_names) {

            my  $name           =   $names->[$current];        
            my  $compound_name  =   "";
            my  $matched        =   $name->{"$part_match_info->{'part'}"}   =~  $part_match_info->{'matches_find'};
            
            
            
            for my $name_part ($part_match_info->{'name_parts'}->@*) { # Array, so in specific order that's the same each time.

                $compound_name  .=  $name_part.$name->{"$name_part"};

            }

        }
    }

    
}

sub get_useful_frequency_counts {
    my  ($session, $dataset, $result, $useful_info)  =   @_;

    foreach my $search_field ($useful_info->{'search_fields'}->@*) {

        my  $names          =   $result->get_value($search_field);
        my  @range_of_names =   (0..$names->$#*);

        for my $current (@range_of_names) {

            my  $name           =   $names->[$current];
            my  $compound_name  =   "";

            for my $name_part ($useful_info->{'name_parts'}->@*) { # Array, so in specific order that's the same each time.

                $compound_name  .=  $name_part.$name->{"$name_part"};

            }

            $useful_info->{'compound_names'} ->{"$compound_name"    }++;
            $useful_info->{'given_names'}    ->{"$name->{'given'}"  }++;
            $useful_info->{'family_names'}   ->{"$name->{'family'}" }++;
        }
    }
}


sub validate {
    my  $our_encoding   =   ":encoding(UTF-8)";
    binmode STDIN, $our_encoding;
    binmode STDOUT, $our_encoding;
    my  $self                           =   shift;
    my  @input                          =   @_;
    warn "Validate input: ".Dumper($input[2]);
    my  $matches_four_byte_character    =   qr/[^\N{U+10000}-\N{U+7FFFFFFF}]/;
    
    for my $input (@input) {
        die                                 "This script does not support ".
                                            "four byte characters in input."
                                            if ($input =~ $matches_four_byte_character);
    };
    
    return @input;
}

sub prompt_for {
    my  $our_encoding   =   ":encoding(UTF-8)";
    binmode STDIN, $our_encoding;
    binmode STDOUT, $our_encoding;
    my  $self           =   shift;
    my  $prompt_type    =   shift;
    my  ($useful_info)  =   @_;

    my  $input          =   undef;

    # Definitions:
    my  $part_prompt    =   ($prompt_type eq 'part' && $useful_info);
    my  $replace_prompt =   ($prompt_type eq 'replace');
    my $prompt = {
        archive         =>  'Please specify an Archive ID: ',
        search          =>  'Please specify a Search Term: ',
        replace         =>  'Please specify a Replace Term: ',
        find            =>  "Your change will be performed using find and replace,\n".
                            "(looking to find full and not partial matches, and with case insensitivity).\n".
                            'What is your find value'.
                            ($useful_info?  " when matching within $useful_info":
                                            '').    
                            '? ',
        replace_blank   =>  'Did you mean for the replace value to be a blank/null value, '.
                            'that if later confirmed would effectively be clearing the field? '.
                            'Enter Y for Yes, or anything else for No: ',
    };

    if ($part_prompt) {
    
        my  $number;
    
        say "\nFrom your search we found matching records with the following given names associated...\n";
        say 'Given Names: ';
        say join(', ',keys $useful_info->{'given_names'}->%*)."\n";
        say "...and the following family names associated...\n";
        say 'Family Names: ';
        say join(', ',keys $useful_info->{'family_names'}->%*)."\n";
        say "Which do you wish to perform your change on first?";
        say "\t1) Given Name";
        say "\t2) Family Name";
    
        until ($number && ($number eq "1" || $number eq "2")) {

            say "Please enter 1 or 2.";
            chomp($number   =   <STDIN>)

        };
    
        $input  =   $number?    ($number eq "1")?   'given':
                                ($number eq "2")?   'family':
                                undef:
                    undef;
    }    
    
    if ($prompt->{"$prompt_type"}) {
    
        until ($input) {
    
            say $prompt->{"$prompt_type"};
            chomp(my $typed_input           =   <STDIN>);
            ($input)                        =   $self->validate( ($typed_input) );
    
            if ($prompt->{"$prompt_type\_blank"}) {
    
                say $prompt->{"$prompt_type\_blank"};
                chomp(my $typed_input2      =  <STDIN>);
                
                # Definition:
                my  $blank_input_desired    =   (fc $typed_input2 eq fc 'y');

                if ($blank_input_desired) {
                    $input = q{};
                    last;
                };
                
            };

        };
        
    };
    
    return $input;

}

sub test_increment {
    my %hash = ();
    $hash{keyname}++; # 1
    $hash{keyname}++; # 2
    return "Keyname is [".$hash{keyname}."]";
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

sub simple_version {

    # Initial Values:
    my  ($self, $repository_id) =   @_;
    my  $dataset_to_use         =   'eprint';
    my  @fields_to_search       =   (
                                        'creators_name',
                                        'contributors_name',
                                    );
    my  @name_parts             =   (
                                        'given',
                                        'family',
                                        # 'honourific',
                                        # 'lineage',
                                    );
    my  @search_terms           =   (
                                        'given' =>  'Behzadian Moghadam',
                                        family  =>  'Kourosh',
                                    );
    my  @replacement_terms      =   (
                                        'given' =>  'Behzadian',
                                        #family  =>  'Kourosh',
                                    );
    my  $match_terms            =   {
                                        pairmap {
                                            ($a  =>  qr/^\Q$b\E$/)
                                        }
                                        @search_terms
                                    };
    die                             "Match terms:".Dumper($match_terms);
    my  $search_term_seperator  =   ' ';
    my  $search_term            =   join $search_term_seperator, @search_terms;
    my  $text = {
        data_count              =>  'Number of dataset records found: ',
        search_count            =>  'Number of search results found: ',
        archive_id              =>  'Please specify an Archive ID: ',
    };
    my  $line_delimiter         =   "\n";
    my  $search_fields          =   [
                                        {
                                            meta_fields     =>  [
                                                                    @fields_to_search,
                                                                ],
                                            value           =>  $search_term,
                                        },
                                    ];
    my  $result_processing      =   \&result_processing;
    my  $matches_search_term    =   qr/^$/i;
    my  $output = {
        lines                   =>  [],
        matches_search_term     =>  $matches_search_term,
        search_fields           =>  \@fields_to_search,
        name_parts              =>  \@name_parts,
        said_already            =>  0,
    };
    
    # Check repo_id provided:
    until ($repository_id) {
        say $text->{'archive_id'};
        chomp($repository_id  =   <STDIN>);
    };
    
    # Processing:

    # Search:
    my  $list_of_results        =   EPrints::Repository
                                    ->new($repository_id)
                                    ->dataset($dataset_to_use)
                                    ->prepare_search(
                                        satisfy_all         =>  1,
                                        staff               =>  1,
                                        limit               =>  30,
                                        show_zero_results   =>  0,
                                        allow_blank         =>  1,
                                        search_fields       =>  $search_fields,
                                    )
                                    ->perform_search;

    # Process Search Results:
    $list_of_results->map($result_processing,$output);
    




    # Get counts:
    my  $counts = {

        data                    =>  $list_of_results->get_dataset
                                    ->count($list_of_results->get_dataset->repository),

        search                  =>  $list_of_results->count,

    };

    # End Session:
    $list_of_results->get_dataset->repository->terminate();


    # Output:
    push $output->{'lines'}->@*, (
        $text->{'data_count'}.      $counts->{'data'},
        $text->{'search_count'}.    $counts->{'search'},
    );
    
    return join $line_delimiter, $output->{'lines'}->@*;

}

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

sub test_input {

    my $prompt = {
        1   =>  "Your name: ",
        2   =>  "Your age: ",
        3   =>  "Your choice of moped: ",
        4   =>  "Your preferred tumbleweed when in a desert: ",
        5   =>  "Your preferred custard when in a dessert: ",
    };
    
    say "Hello World";
    
    for my $i (1..5) {
        say $prompt->{"$i"};
        my $answer = <STDIN>;
        say 'Your Answer: '.$answer;
    };
            
    return "Goodbye World";
    
}

sub test_commandline_arguments {

    my  ($self, $input) = @_;
    
    until ($input) {
        say "Please specify an Archive ID: ";
        chomp($input  =   <STDIN>);
    };

    my  $output =   "You provided a command line input of: $input";

    return $output;
    
}

sub get_input {
    say "Please specify an Archive ID: ";
    my $input = <STDIN>;
    return $input;
}

sub get_unique_creator_hashes {
    my  ($session, $dataset, $result, $output)  =   @_;
    return "Nothing here yet";
}

sub result_processing {

    # Initial Values:
    my  ($session, $dataset, $result, $output)  =   @_;
    my  $format_output_line = \&format_outputline;
    my  $debugging          = 0;
    
    if ($debugging) {
        warn    'Here is some useful info:'.
                "\n".
                'Under Construction: '. (exists $result->{under_construction}?
                                            defined $result->{under_construction}?
                                                $result->{under_construction}?
                                                    $result->{under_construction}:
                                                'False.':
                                            'Undefined':
                                        'Doesn\'t exist.').
                "\n".
                'Change: '. (exists $result->{changed}?
                                defined $result->{changed}?
                                    $result->{changed}->%*?
                                        Dumper($result->{changed}->%*):
                                    'False, presumaby empty Hashref':
                                'Undefined':
                            'Doesn\'t exist.').
                "\n".
                'Non volatile Change: '. $result->{non_volatile_change}.
                "\n";
    }


    foreach my $search_field ($output->{'search_fields'}->@*) {
        warn "In search fields.\n" if $debugging;
        my  $entries        =   $result->get_value($search_field);
        my  @entry_range    =   (0..$entries->$#*);

        for my $i (@entry_range) {

            warn    "In entries.\n"
                    if $debugging;

            for my $name_part ($output->{'name_parts'}->@*) {

                my $value = $entries->[$i];
                
                warn    "In name part with name part $name_part being value ".$value->{"$name_part"}."\n"
                        if $debugging;

                # Definition:
                my  $matched  =  ($value->{"$name_part"} =~ $output->{'matches_search_term'});

                if ($matched) {
                    warn    "In match.\n"
                            if $debugging;

                    push $output->{'lines'}->@* ,   'Record ID: '.$result->id."'s search field $search_field with name part $name_part matched."
                                                    if $debugging;
                                                    
                    $value->{"$name_part"}      =   "Browne";

                    push $output->{'lines'}->@* ,    'Changing Wilco match to Browne'
                                                    if $debugging;
                    
                    push $output->{'lines'}->@* ,    'This is what we\'re about to set:'."\n".
                                                    Dumper($value)
                                                    if $debugging;

                    $result->set_value($search_field, $value);

                    # Commit commented in/out:
                    #$result->commit([1]);
                    
                };
                
            }

        }
        push $output->{'lines'}->@*             ,   "Result $search_field value this time is an array as follows... ".
                                                    Dumper($entries)
                                                    if $debugging;
    }
    
    # Add to Display Output:
    push $output->{'lines'}->@*, $format_output_line->($result);

}

sub format_outputline {

    # Initial Values:
    my  $result                 =   shift;
    my  $seperator = {
        creators                =>  ', ',   # comma, space
        name_parts              =>  ' ',    # space
    };
    my  $id_suffix              =   ': ';

    my  @order_and_omit_blanks  =   map {
                                        join $seperator->{'name_parts'}, (
                                            $ARG->{'honourific'}?   $ARG->{'honourific'}:
                                            (),
                                            $ARG->{'given'}?        $ARG->{'given'}:
                                            (),
                                            $ARG->{'family'}?       $ARG->{'family'}:
                                            (),
                                            $ARG->{'lineage'}?       $ARG->{'lineage'}:
                                            (),
                                        )
                                    }
                                    $result->get_value('creators_name')->@*;

    return                          $result->id.$id_suffix.
                                    join($seperator->{'creators'}, @order_and_omit_blanks);
}

1;

=head1 AUTHOR

Andrew Mehta

=cut


__END__

Old Code from commit 58fd07485770c913e12b5df9b4c02aeb27f526b7 is below to use as resource:


sub using_objects_and_methods ($self) {
    say "Do additional says work?";
    # Find and Change name
    
    my  @fields_name_is_found_in = qw(
        creators
        contributors
    );
    
    my  @sub_fields = (
        'family',     # may be part of a name field within creator or contributor
        'given',    # may be part of a name field within creator or contributor
        'id',         # id may be a creator or contributor id and not part of a name field
    );
    
    # Currently ignorant of data structure, so let's understand that first.

    # Initial Values:
    my  $repository_id          =   'initial_archive'; # can later be input
    my  $dataset_to_use         =   'eprint';
    my  $compound_name_field    =   'creators_name';
    my  $search_term            =   'Moghadam';
    my  $process_results        =   \&process_results;

    #my  @search_values =(
    #    session =>  $session,
    #    dataset =>  
    #);

    my  $session        =   EPrints::Repository->new($repository_id);
    my  $dataset        =   $session->dataset($dataset_to_use);

    #my  @search_values = (
    #    ,
    #);

    #my  %search_options = (
    #    fields  =>  $compound_name_field,
    #    value   =>  $search_term,
    #);

    my  $search         =   EPrints::Search->new(session =>  $session, dataset =>  $dataset);

    $search->add_field($dataset->get_field($compound_name_field), $search_term, 'EQ', 'ANY');

    my  $list_of_results=   $search->perform_search;
                            
 #   $list_of_results->map(sub {
 #       say "In anon subroutine.";
 #   },
 #   {search_term => $search_term});
    my  $number_of_search_results = $list_of_results->count;
    # Let's dump our dataset to understand its data structure.
    
#    return "Dataset follows:\n".
#            Dumper($dataset).
#            "\nDataset ends.";
           #'Dataset with-held while debugging signatures.';
#    return "Dataset fields follow:\n".
#            Dumper($dataset->fields).
#            "\nDataset fields end.";

    $session->terminate();

    return "Number of Results follow:\n".
            $number_of_search_results.
            "\nResults end.";
           #"\nEnd.";

}

sub process_results ($session, $dataset, $result, $useful_values) {
        my $text={
            output_line => "[%s] %s %s", 
        };

        say "In Process Results subroutine.";

        foreach my $creators_name ( $result->get_value("creators_name")->@* ) {

            #Definition:
            #my  $search_term_found = $creators_name->{'family'} eq $useful_values->{'search_term'};

            my  @values = (
                $result->get_id(),
                $creators_name->{'given'},
                $creators_name->{'family'},
            );
                
            #say         sprintf($text->{'output_line'}, @values)
            #            if $search_term_found;
            
            say "Result: ".Dumper(@values);
        }; 
        
};

sub justin_example {

    my  ($term, $repoid) = ('Fam','initial_archive');
    my $session = EPrints::Session->new( 1 , $repoid , 0 );

    if( !defined $session )

    {
            say "Failed to load repository: $repoid\n";
            exit 1;
    }

    my $ds = $session->dataset( "eprint" );

    die "Non-defined dataset!" if (!defined $ds);

    my  @search_values = (
        session =>  $session,
        dataset =>  $ds,
        satisfy_all => 0,
    );

    my $searchexp = new EPrints::Search(@search_values);

    my  $field = $ds->get_field( "creators_name" );
    
    #say "Field Description: ".Dumper($field->render_description); #can't run method as MetaField::Name not Search::Field
    
    my $description = $searchexp->add_field( $field, $term )->render_description;

    my $list = $searchexp->perform_search;

    say "Field Description: ".Dumper($description); # Blessed coderef setting a number??

    say "Number of dataset records found: ".$ds->count($session);
    say "Number of search results found: ".$list->count;

#    $list->map( sub
#    {
#            my( $session, $dataset, $eprint ) = @_;
#            my @creators_name = @{ $eprint->get_value("creators_name") };
#            foreach my $cn ( @creators_name )
#            {
#                    print "[". $eprint->get_id() . "]\t" . $cn->{given} . " " . $cn->{family} . "\n" if $cn->{family} eq $term;
#            }
#    } );

    $session->terminate();
}

======

__END__

So multiple maps might be:

    $list_of_results->map($result_processing,$output);
    $list_of_results->map($result_processing,$output);
    
    =====
    
    
my  $search_fields          =   [
                                        {
                                            meta_fields     =>  [
                                                                    @fields_to_search,
                                                                ],
                                            value           =>  $search_term,
                                        },
                                    ];

    my  $matches_search_term    =   qr/^\Q$search_term\E$/i; # Exact match, case insensitive.