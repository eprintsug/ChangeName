#!/usr/bin/perl -I /opt/eprints3/perl_lib

package ScriptOne;

use     strict;
use     warnings;

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

v2.0.0

=cut

our $VERSION    =   'v2.0.0';

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

=item my_example();

    # Run from command line:
    perl ./ScriptOne.pl

Add description here.

=back

=cut

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
    my  $line_delimiter         =   "\n";
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
