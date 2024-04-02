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
$Data::Dumper::Useperl = 1;
use     List::Util  qw(
            pairmap
            mesh
        );
use     Getopt::Long;

use     open ':std',   ':encoding(UTF-8)';

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
my  $our_encoding                       =   ':encoding(UTF-8)';
binmode STDIN                           ,   $our_encoding;
binmode STDOUT                          ,   $our_encoding;
binmode STDERR                          ,   $our_encoding;
$ENV{'PERL_UNICODE'}                    =   'AS';   # A = Expect @ARGV values to be UTF-8 strings.
                                                    # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.

ChangeNameOperation->start(@ARGV) unless caller;

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
            say '    perl -CAS ChangeName.pm';
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

sub presentable_compound_name {
    my  $self           =   shift;
    my  $compound_name  =   shift;
    my  @name_parts     =   @_;

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
    my  $presentable_compound_name  =   "Honorary: ".($hash->{'honourary'}? $hash->{'honourary'}: '')."\n".
                                        "Given:    ".($hash->{'given'}? $hash->{'given'}: '')."\n".
                                        "Family:   ".($hash->{'family'}? $hash->{'family'}: '')."\n".
                                        "Lineage:  ".($hash->{'lineage'}? $hash->{'lineage'}: '');###
    return $presentable_compound_name;
}

sub start {

    my  $class      =   shift;

    $class->utf8_input_check(@ARG);

    my  @params     =   (
        archive_id  =>  $self->validate(shift),
        find        =>  $self->validate(shift),
        replace     =>  $self->validate(shift),
        part        =>  $self->validate(shift),
    );
                    
    ChangeNameOperation->new(@params)->search->display->confirm->change->finish;

}

sub new {
    my  $class      =   shift;
    my  $params     =   {@ARG};
    my  $self       =   {};
    
    bless $self, $class;
    $self->_set_attributes($params);
    
    return $self;
}

sub 

sub start_old {

    # Input:
    my  $self                               =   shift;
    $self->utf8_input_check(@ARG); # This will do for now.
	my  $live                               =   q{};
	my  @force_or_not                       =   (
	                                                [1] # Comment out line to disable force commits.
	                                            );
    Getopt::Long::Parser->new
    ->getoptionsfromarray(
        \@_,
        'live!'                             =>  \$live
                                                # if --live present,    set $live to 1,
                                                # if --nolive present,  set $live to 0.
    );

    my  ($archive_id,$find,$replace,$part)  =   $self->validate(@_);
        $archive_id                         //= $self->prompt_for('archive');
    my  $repository                         =   EPrints::Repository->new($archive_id);
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
                                                ); # Is this the correct order?
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
    my  $change_records                     =   \&change_records;
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
                                                # Search interprets 'ó' as matching 'O.' (yes - even with the dot) and 'à' as matching 'A'
                                                # This is an EPrints API behaviour.
                                                # These are not direct matches, and so could be filtered out by us.
                                                # At the same time, it also works in reverse. Lopez-Aviles can match López-Avilés 
                                                # - which is beneficial if someone doesn't have the correct keyboard.
                                                # So let's leave this in.
                                                
    my  @record_ids_to_search              =   $list_of_results->{ids}->@*;

    say 'Find             '.Dumper ($find);
    say 'Find             '.$find;
    say 'Search fields:   '.Dumper ($search_fields);
    say 'List of Results: '.Dumper (keys $list_of_results->%*);
    say 'IDs              '.Dumper ($list_of_results->{ids});

    # Process Search Results:
    $list_of_results->map($get_useful_frequency_counts,$useful_info);


    say 'Find             '.Dumper ($find);
    say 'Find             '.$find;
    say 'Search fields:   '.Dumper ($search_fields);
    say 'List of Results: '.Dumper (keys $list_of_results->%*);
    say 'IDs              '.Dumper ($list_of_results->{ids});
    say 'Useful info      '.Dumper ($useful_info);

    if (@record_ids_to_search) {
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
    #    warn "Part is earlier: $part";
        if ($part_search) {

            for my $compound_name (keys $useful_info->{'compound_names'}->%*) {

                # Initial Values:
                $part_match_info->{'matches_compound_name'} =   qr/^\Q$compound_name\E$/;
                $part_match_info->{'matches_find'}          =   qr/^\Q$find\E$/i; # case insensitive.
                $part_match_info->{'part'}                  =   $part;
    #            warn "Part is: $part and stored part is $part_match_info->{'part'}";
                $part_match_info->{'display_lines'}         =   [];
                $part_match_info->{'display'}               =   undef;

                # Processing:
                $list_of_results->map($display_records,$part_match_info);

                # Output:
                if ($part_match_info->{'display'}) {
                    say "For the unique name combination...";
                    say q{}; # Does it deliver a line return? Yes it does
                    say $self->presentable_compound_name($compound_name,@name_parts);
                    say q{}; # Does it deliver a line return? Yes it does
                    say "...the following matching records were found:";
                    say q{}; # Does it deliver a line return? Yes it does
                    say join $line_delimiter, $part_match_info->{'display_lines'}->@*;
                    say q{};
                    say '------';
                    say q{};
                };

                # Reset Values:
                $part_match_info->{'display_lines'}         =   [];
                $part_match_info->{'display'}               =   undef;

                # Initial values for implementing a change:
                $part_match_info->{'replace'}               =   $replace;
                $part_match_info->{'force_or_not'}          =   \@force_or_not;
                $part_match_info->{'dry_run'}               =   $live? 0:
                                                                1;

                #Processing:
                $list_of_results->map($change_records,$part_match_info);

                # Do you need output from a single loop? If so you'll need to reset and export the part match info each iteration.

                # compound_names include non-part-matching names irrelevant to our search - so ... we need to filter those out / skip them.
            }
        };

    }
    else {
        say "No search results.";
    };

    # Output:

    return Dumper([
        repo_is         =>  $archive_id,
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

sub display_records {

    my  ($session, $dataset, $result, $part_match_info)  =   @_;

    foreach my $search_field ($part_match_info->{'search_fields'}->@*) {

        my  $names                      =   $result->get_value($search_field);
        my  @range_of_names             =   (0..$names->$#*);

        for my $current (@range_of_names) {

            my  $name                   =   $names->[$current];        
            my  $compound_name          =   q{};

            my  $find_matched           =   $name->{"$part_match_info->{'part'}"} && ($name->{"$part_match_info->{'part'}"}   =~  $part_match_info->{'matches_find'});

            if ($find_matched) {

                for my $name_part ($part_match_info->{'name_parts'}->@*) { # Array, so in specific order that's the same each time.

                    $compound_name      .=  $name_part.$name->{"$name_part"};

                };
                
                my  $compound_matched   =  $compound_name && ($compound_name =~ $part_match_info->{'matches_compound_name'});
                
                if ($compound_matched) {
                    
                    push $part_match_info->{'display_lines'}->@*, format_single_line_for_display($result, $search_field);
                    $part_match_info->{'display'} = 'Yes';

                }
                
            };
            
        }
    }
    
}

sub change_records {

    my  ($session, $dataset, $result, $part_match_info)  =   @_;

    foreach my $search_field ($part_match_info->{'search_fields'}->@*) {

        my  $names                      =   $result->get_value($search_field);
        my  @range_of_names             =   (0..$names->$#*);

        for my $current (@range_of_names) {

            my  $name                   =   $names->[$current];        
            my  $compound_name          =   q{};

            my  $find_matched           =   $name->{"$part_match_info->{'part'}"} && ($name->{"$part_match_info->{'part'}"}   =~  $part_match_info->{'matches_find'});

            if ($find_matched) {

                for my $name_part ($part_match_info->{'name_parts'}->@*) { # Array, so in specific order that's the same each time.

                    $compound_name      .=  $name_part.$name->{"$name_part"};

                };
                
                my  $compound_matched   =   $compound_name && ($compound_name =~ $part_match_info->{'matches_compound_name'});
                
                if ($compound_matched) {
                    say                     "Confirm to change ".$part_match_info->{'part'}.
                                            " name from...";
                    say                     q{};
                    say                     "'".$name->{"$part_match_info->{'part'}"}."'";
                    say                     q{};
                    say                     "...to...";
                    say                     q{};
                    say                     "'".$part_match_info->{'replace'}."'";
                    say                     q{};
                    say                     "...for name ".($current+1).
                                            ' in field '.$search_field.
                                            ' in the following record... ';
                    say                     q{};
                    say                     format_single_line_for_display($result, $search_field);
                    say                     q{};
                    say                     '...?';
                    my  $confirmation   =   ChangeName->prompt_for('change');
                    say                     q{};

                    say                     'Changing...';
                    say                     q{};
                    say                     format_single_line_for_display($result, $search_field);
                    say                     q{};
                    say                     '...to...';

                    # Change:                                  
                    $name->{"$part_match_info->{'part'}"}      =   $part_match_info->{'replace'};
                    $result->set_value($search_field, $names);

                    say                     q{};
                    say                     format_single_line_for_display($result, $search_field);
                    say                     q{};

                    if ($part_match_info->{'dry_run'}) {
                        say "Not done, because this is a dry run. For changes to count, run the script again with the --live flag added.";
                        say q{};
                    }
                    else {
                        $result->commit($part_match_info->{'force_or_not'}->@*);
                        say "Done.";
                        say q{};
                    }

                    
                    #$result->commit([1]);
                    
                    #commit($part_match_info->{'force_or_not'}->@*)
                    #push $part_match_info->{'display_lines'}->@*, format_single_line_for_display($result, $search_field);
                    #$part_match_info->{'display'} = 'Yes';

                }
                
            };
            
        }
    }
    
}

####
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

sub prompt_for {

    my  $self           =   shift;
    my  $prompt_type    =   shift;
    my  ($useful_info)  =   @_;

    my  $input          =   undef;

    # Definitions:
    my  $part_prompt    =   ($prompt_type eq 'part' && $useful_info);
    my  $replace_prompt =   ($prompt_type eq 'replace');
    my  $change_prompt  =   ($prompt_type eq 'change');
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

    if  ($change_prompt) {
    
            my  $confirmation;
    
            until ( $confirmation && ($confirmation =~ m/^Y|ALL|N|NONE$/i) ) {
                say "Enter 'Y' for Yes,";
                say "Enter 'N' for No,";
                say "Enter 'ALL' for Yes to All for this unique name combination.";
                say "Enter 'NONE' for No to All for this unique name combination.";
                chomp($confirmation   =   <STDIN>)
            };
            
            $input = $confirmation;
    }
    
    if ($prompt->{"$prompt_type"}) {
    
        until ($input) {
    
            say $prompt->{"$prompt_type"};
            chomp(my $typed_input           =   <STDIN>);
            ($input)                        =   $self->validate( ($typed_input) );
            
            last if $input;
            if ($prompt->{"$prompt_type\_blank"}) {
    
                say $prompt->{"$prompt_type\_blank"};
                chomp(my $typed_input2      =  <STDIN>);
                
                # Definition:
                my  $blank_input_desired    =   (fc $typed_input2 eq fc 'y'); # fc supported in Perl 5.16 onwards.

                if ($blank_input_desired) {
                    $input = q{};
                    last;
                };
                
            };

        };
        
    };
    
    return $input;

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


__END__
