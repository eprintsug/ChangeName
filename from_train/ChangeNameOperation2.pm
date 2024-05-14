package something;

use     strict;
use     warnings;

print ChangeNameOperation::Languages->try_or_die('en-GB')->maketext('input.yes_letter');

1;

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
    $language               //= 'en-GB';
    my  $error={
        language            =>  'Trouble finding a language to use.',
    };

    return  $self->get_handle($language)
            #ChangeNameOperation::Languages::en_gb->new()
            || die  $error->{'language'};
}

#sub get_handle {
#    say "Test handle";
#}

1;




BEGIN { # Package placed within block to define scope of my and our variables 
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
#use     base ChangeNameOperation::Languages->import;



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

