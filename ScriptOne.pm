#!/usr/bin/perl -I /opt/eprints3/perl_lib

package ScriptOne;

use     strict;
use     warnings;

use     File::Basename;
use     lib dirname(__FILE__).'/../../perl_lib';
use     Data::Dumper;
use     EPrints::Repository;
use     EPrints::Search;

use     v5.32;
use     feature 'signatures'; # Not activated by default until the 5.36 bundle.

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

say ScriptOne->using_objects_and_methods();

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
    my  $repository_id  =   'initial_archive'; # can later be input
    my  $dataset_to_use =   'eprint';

    #my  @search_values =(
    #    session =>  $session,
    #    dataset =>  
    #);

    my  $session        =   EPrints::Repository->new($repository_id);
    my  $dataset        =   $session->dataset($dataset_to_use);

    my  @search_values =(
        session =>  $session,
        dataset =>  $dataset,
    );

    #my  $search         =   EPrints::Search
    #                        ->new($search_values)
    #                        ->add_field(;

    # Let's dump our dataset to understand its data structure.
    
    return "Dataset follows:\n".
            Dumper($dataset).
            "\nDataset ends.";
           #'Dataset with-held while debugging signatures.';

}



1;

=head1 AUTHOR

Andrew Mehta

=cut


__END__
