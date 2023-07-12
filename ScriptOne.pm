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
use		warnings (
			'FATAL',	#makes anything in this list fatal
			'utf8',		#utf8 is a warnings category. There is no FATAL UTF-8
		); 
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

Calls a subroutine.
Currently set to call L</my_example();>.

    # Run from the command line:
    perl ./ScriptOne.pm

=cut

#UTF-8 the default on standard input and output:
my  $our_encoding   =   ":encoding(UTF-8)";
binmode STDIN,  $our_encoding;
binmode STDOUT, $our_encoding;

say ScriptOne->test_commandline_arguments(@ARGV);

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
    my  $repository_id          =   $ARGV[0]; # can later be input
    my  $dataset_to_use         =   'eprint';
    my  @fields_to_search       =   qw(
                                        creators_name
                                        contributors_name
                                    );
    my  @name_parts             =   (
                                        'given',
                                        'family',
                                        # 'honourific',
                                        # 'lineage',
                                    );
    my  $search_term            =   'Wilco';
    my  $text = {
        data_count              =>  'Number of dataset records found: ',
        search_count            =>  'Number of search results found: ',
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
    my  $matches_search_term    =   qr/
                                        \Q$search_term\E    # Quotemeta'd String for safety - note it will will match anything if empty. 
                                    /ix;
    my  $output = {
        lines                   =>  [],
        matches_search_term     =>  $matches_search_term,
        search_fields           =>  \@fields_to_search,
        name_parts              =>  \@name_parts,
        said_already            =>  0,
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

    warn "Type of First Result is: ".ref($list_of_results->item(0));

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

sub result_processing ($session, $dataset, $result, $output) {

    # Initial Values:
    my  $format_output_line = \&format_outputline;

    #unless ($output->{'said_already'}) { # redundant - it already only does this once, as we're outside of the foreach loops below.#####
    warn 'Here is some useful info once:'.
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
    #}


    foreach my $search_field ($output->{'search_fields'}->@*) {
        warn "In search fields.\n";

        for my $i (0..$#{$result->get_value($search_field)}) {
            warn "In value.\n";        
            for my $name_part ($output->{'name_parts'}->@*) {
                warn "In name part with name part $name_part being ".$result->get_value($search_field)->[$i]->{"$name_part"}."\n";
                # Definition:
                my  $matched  =  ($result->get_value($search_field)->[$i]->{"$name_part"} =~ $output->{'matches_search_term'});
                #warn "Search is ".Dumper($output->{'matches_search_term'});

                if ($matched) {
                    warn "In match.\n";
                    push $output->{'lines'}->@*, 'Record ID: '.$result->id."'s search field $search_field with name part $name_part matched.";
                    #my $whole_thing = $value;
                    #my $part_to_change = $value->{"$name_part"}
                    #$value->{"$name_part"} = "Browne";
                    $result->get_value($search_field)->[$i]->{"$name_part"} = "Browne"; 
                    warn "Woooooooo!";
                    push $output->{'lines'}->@*, 'Changing Wilco match to Browne';
                    
                    push $output->{'lines'}->@*, 'This is what we\'re about to set:'."\n".Dumper ($result->get_value($search_field));
                    $result->set_value($search_field, $result->get_value($search_field));
                    $result->commit([1]);
                    #$result->set_value($search_field, $result->get_value($search_field)->[$i]);
                    
                };
                
            }

        }
        push $output->{'lines'}->@*, "Result $search_field value this time is an array as follows... ". Dumper($result->get_value($search_field));
    }
    

    
    
    # Add to Display Output:
    push $output->{'lines'}->@*, $format_output_line->($result);
#   push $output->{'lines'}->@*, "Before: ".$format_output_line->($result);
#   push $output->{'lines'}->@*, "After: ".$format_output_line->($result);
}

sub format_outputline ($result) {

    # Initial Values:
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
