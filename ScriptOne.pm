#!/usr/bin/perl -I /opt/eprints3/perl_lib

package ScriptOne;

use     strict;
use     warnings;

use     File::Basename;
use     lib dirname(__FILE__).'/../../perl_lib';
use     Data::Dumper;
use     EPrints;
use     EPrints::Repository;
use     EPrints::Search;

use     v5.32;
use     feature 'signatures'; # Not activated by default until the 5.36 bundle.
use     utf8;
use     English;

=pod Name, Version

=encoding utf8

=head1 NAME

Script One.

=head1 VERSION

v1.0.0

=cut

our $VERSION    =   'v1.0.0';

=pod Synopsis, Description

=head1 SYNOPSIS

    # Run at the command line:
    perl ./ScriptOne.pm

=head1 DESCRIPTION

Put description here.

    # Run from the command line:
    perl ./ScriptOne.pm

=cut

say ScriptOne->my_example();

=head1 METHODS

=over

=item hello();

    use ScriptOne qw(hello);
    my  $greeting = hello();
    
    # Alternatively:
    use ScriptOne;
    my  $greeting = ScriptOne->hello();

Returns a string containing a greeting.

=back

=cut

sub hello {
    my  $message = "Hello World";
    return $message;
}

=over

=item using_objects_and_methods();

Getting familiar with the objects and methods from Ed and Justin's examples.

=back

=cut

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

sub my_example {

    # Initial Values:
    my  $repository_id          =   'initial_archive'; # can later be input
    my  $dataset_to_use         =   'eprint';
    my  $meta_field             =   'userid.username';
    my  $search_term            =   'admin';
    my  $text = {
        data_count              =>  'Number of dataset records found: ',
        search_count            =>  'Number of search results found: ',
    };
    my  $search_fields          =   [
                                        {
                                            meta_fields     =>  [
                                                                    $meta_field,
                                                                ],
                                            value           =>  $search_term,
                                        },
                                    ];
    my  $output = {
                        lines  =>  [],
    };
    
    # Processing:

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

    my  $result_processing      =   \&result_processing;

    $list_of_results->map($result_processing,$output); 

    my  $counts = {
        data                    =>  $list_of_results->get_dataset
                                    ->count($list_of_results->get_dataset->repository),
        search                  =>  $list_of_results->count,
    };

    $list_of_results->get_dataset->repository->terminate();


    # Output:
    say $ARG for $output->{'lines'}->@*;
    say $text->{'data_count'}.      $counts->{'data'};
    say $text->{'search_count'}.    $counts->{'search'};

    return "End.";
}

sub result_processing ($session, $dataset, $result, $output) {

    my  $seperator = {
        creators                =>  ', ',   # comma, space
        name_parts              =>  ' ',    # space
    };
    my  $id_suffix              =   ': ';

    push $output->{'lines'}->@*,
        $result->id.$id_suffix.
        join($seperator->{'creators'},
            map {
                join $seperator->{'name_parts'}, (
                    $ARG->{'honourific'}?   $ARG->{'honourific'}:
                    (),
                    $ARG->{'given'}?        $ARG->{'given'}:
                    (),
                    $ARG->{'family'}?       $ARG->{'family'}:
                    (),
                );
            }
            $result->get_value('creators_name')->@*
        );
}


1;

=head1 AUTHOR

Andrew Mehta

=cut


__END__
