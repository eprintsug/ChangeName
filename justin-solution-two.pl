#!/usr/bin/perl -I /opt/eprints3/perl_lib

 

use EPrints;
use strict;
use Data::Dumper;

my $repoid = $ARGV[0];

my $term = $ARGV[1];

my $session = new EPrints::Session( 1 , $repoid , 0 );

if( !defined $session )

{
        print STDERR "Failed to load repository: $repoid\n";
        exit 1;
}

my $ds = $session->dataset( "eprint" );

my $searchexp = new EPrints::Search( session=>$session, dataset=>$ds );

$searchexp->add_field( $ds->get_field( "creators_name" ), $term );

my $list = $searchexp->perform_search;

$list->map( sub
{
        my( $session, $dataset, $eprint ) = @_;
        my @creators_name = @{ $eprint->get_value("creators_name") };
        foreach my $cn ( @creators_name )
        {
                print "[". $eprint->get_id() . "]\t" . $cn->{given} . " " . $cn->{family} . "\n" if $cn->{family} eq $term;
        }
} );

$session->terminate();

 

$ ./search_creator_family test34 Smith