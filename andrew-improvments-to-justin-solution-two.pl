use strict;
use warnings;
use lib '/opt/eprints3/perl_lib/';
use EPrints;
use English;

# Usage:
# $ ./andrew-improvments-to-justin-solution-two.pl MyArchive Surname
# Unicode stuff like ☃☃☃☃☃☃☃☃☃☃☃ not appearing to work.

my  ($repo_id, $term)   =   @ARGV;

my  $repository         =   EPrints::Repository->new($repo_id);

unless (defined $repository) {
        print STDERR "Failed to load repository: $repo_id\n";
        exit 1;
}


my  $dataset            =   $repository->dataset('eprint');


my  $search_expression  =   EPrints::Search
                            ->new(
                                repository          =>  $repository,
                                session             =>  $repository,
                                dataset             =>  $dataset,
                            );

    $search_expression      ->add_field(
                                $dataset->get_field( 'creators_name' ),
                                $term,
                            ); # No method chaining - this returns the field.
                            
$search_expression->perform_search->map(

    # Display Search Results that match the search term in the family name part:
    sub {
        my  ($repository, $dataset, $eprint)    =   @ARG;
        
        my  @creators_names                     =   @{
                                                        $eprint->get_value('creators_name')
                                                    };

        foreach my $creators_name ( @creators_names ) {

            if ($creators_name->{'family'} eq $term) {
                say sprintf("[%s]\t %s %s", $eprint->get_id(), $creators_name->{'given'}, $creators_name->{'family'});
            };

        }

    }

);

$repository->terminate();