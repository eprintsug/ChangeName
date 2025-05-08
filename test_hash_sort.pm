#!/usr/bin/env perl

# Used throughout:
use     strict;
use     warnings;
use     v5.16;
use     utf8;

# Global Encoding Settings:
my      $encoding_layer;

SET_ENCODING_LAYER_AT_COMPILE_TIME: BEGIN {
    my  $encoding_to_use                =   'UTF-8'; # Change this to desired encoding value.

    $encoding_layer                     =   ":encoding($encoding_to_use)";  # This is what actually gets used for the layer.
};

use     open ':std'                     ,   "$encoding_layer";  # :std affect is global.
binmode STDIN                           ,   $encoding_layer;
binmode STDOUT                          ,   $encoding_layer;
binmode STDERR                          ,   $encoding_layer;

$ENV{'PERL_UNICODE'}                    =   'AS';               # A = Expect @ARGV values to be UTF-8 strings.
                                                                # S = Shortcut for I+O+E - Standard input, output and error, will be UTF-8.
                                                                # ENV settings are global for current thread and any forked processes.

our $VERSION                            =   'v2.0.6';

use English;

my %hash                                =   (
    # ChangeName::Utilities::process_commandline_arguments
    'Validated copy of arguments is as follows...'                              =>  'Eine validierte Kopie der Argumente lautet wie folgt...',
    'Flattened list of default options are as follows...'                       =>  'Die abgeflachte Liste der Standardoptionen lautet wie folgt...',
    'Option Specifications have been determined as being as follows...'         =>  'Die Optionsspezifikationen wurden wie folgt festgelegt...',
    'Options after processing the commandline arguments are now as follows...'  =>  'Die Optionen nach der Verarbeitung der Befehlszeilenargumente sind jetzt wie folgt...',
    'Arguments after processing the commandline arguments are as follows...'    =>  'Die Argumente nach der Verarbeitung der Befehlszeilenargumente lauten wie folgt...',
    'The no_input flag will be returned with the value: "[_1]".'                =>  'Das Flag no_input wird mit dem Wert „[_1]“ zurückgegeben.',



                                            );

my  $col                                =   81;
my  $col_calculation                    =   $col - 5;
my @array                               =   sort {fc $a cmp fc $b} keys %hash;
my  $single_quote                       =   q{'};
my  $new_line                           =   "\n";
#say $ARG for @array;

# Phrases Formatting:
my  $output                             =   $new_line;
    ($output                            .=  '    '. # four spaces
                                            sprintf(
                                                '%-'.$col_calculation.'s',
                                                $single_quote.$ARG.$single_quote
                                            ).
                                            '=>  '.
                                            $single_quote.
                                            $hash{$ARG}.
                                            $single_quote.
                                            ','.
                                            $new_line
    )                                       for @array;

say $output;

__END__


my  $output                             =   $new_line;
Token Short formatting:

    ($output                            .=  sprintf(
                                                "%-40s",
                                                $single_quote.$ARG.$single_quote
                                            ).
                                            '=>  '.
                                            $single_quote.
                                            %hash{$ARG}.
                                            $single_quote.
                                            ','.
                                            $new_line
    )                                       for @array;


Output edited:

===============

Token Short

German:

'display_line'                          =>  'Datensatz [_1]: [_2].',

'finish.change'                         =>  '[quant,_1,Änderung] von [quant,_2,Änderungen] abgeschlossen.',
'finish.no_change'                      =>  'Keine Änderungen vorgenommen.',
'finish.thank_you'                      =>  'Vielen Dank, dass Sie dieses Skript verwenden.',

'input.1'                               =>  '1',
'input.2'                               =>  '2',
'input.all'                             =>  'ALLE',
'input.family'                          =>  'familienname',
'input.given'                           =>  'vorname',
'input.no_letter'                       =>  'N',
'input.none'                            =>  'KEINER',
'input.yes_letter'                      =>  'J',

'language.error.set_language_handle'    =>  'Probleme beim Finden einer zu verwendenden Sprache.',
'language.name'                         =>  'Deutsch (Deutschland)',

'log.type.debug'                        =>  'debug',
'log.type.dumper'                       =>  'dumper',
'log.type.log'                          =>  'protokoll',
'log.type.trace'                        =>  'stacktrace',
'log.type.verbose'                      =>  'ausführlich',

'name.family'                           =>  'Familienname',
'name.given'                            =>  'Vorname',
'name.honourific'                       =>  'Ehrenname',
'name.lineage'                          =>  'Abstammungsname',  # Unsure about this one - it's literally Ancestral Name

'nest.error.key'                        =>  'Fehler beim Verschachteln eines Lexikonwerts.',
'nest.error.language'                   =>  'Ungültiger Sprach-Handle zum Aufrufen der Methode „maketext“.',

'options.config'                        =>  'konfig konfiguration',
'options.debug'                         =>  'debug',
'options.exact'                         =>  'exakt genau genaue',
'options.help'                          =>  'hilfe',
'options.language'                      =>  'sprache spr',
'options.live'                          =>  'live',
'options.no_dumper'                     =>  'kein_dumper kein_dump keindumper keindump',
'options.no_trace'                      =>  'kein_stacktrace keinstacktrace kein_trace keintrace',
'options.trace'                         =>  'stacktrace trace',
'options.verbose'                       =>  'ausführlich ausführl',

======

Token Short

English:

'display_line'                          =>  'Record [_1]: [_2].',

'finish.change'                         =>  '[quant,_1,change] out of [quant,_2,change] completed.',
'finish.no_change'                      =>  'No changes made.',
'finish.thank_you'                      =>  'Thank you for using this script.',

'input.1'                               =>  '1',
'input.2'                               =>  '2',
'input.all'                             =>  'ALL',
'input.family'                          =>  'family',
'input.given'                           =>  'given',
'input.no_letter'                       =>  'N',
'input.none'                            =>  'NONE',
'input.yes_letter'                      =>  'Y',

'language.error.set_language_handle'    =>  'Trouble finding a language to use.',
'language.name'                         =>  'English (United Kingdom)',

'log.type.debug'                        =>  'debug',
'log.type.dumper'                       =>  'dumper',
'log.type.log'                          =>  'log',
'log.type.trace'                        =>  'trace',
'log.type.verbose'                      =>  'verbose',

'name.family'                           =>  'Family Name',
'name.given'                            =>  'Given Name',
'name.honourific'                       =>  'Honorific Name',
'name.lineage'                          =>  'Lineage Name',

'nest.error.key'                        =>  'Error nesting a Lexicon value.',
'nest.error.language'                   =>  'Not a valid language handle from which to call the maketext method.',

'options.config'                        =>  'config configuration',
'options.debug'                         =>  'debug',
'options.exact'                         =>  'exact',
'options.help'                          =>  'help',
'options.language'                      =>  'language lang',
'options.live'                          =>  'live',
'options.no_dumper'                     =>  'no_dumper no_dump nodumper nodump',
'options.no_trace'                      =>  'no_trace notrace no_stacktrace nostacktrace',
'options.trace'                         =>  'trace stacktrace',
'options.verbose'                       =>  'verbose',

=======

GERMAN:

@debug_phrases = (

    # Commonly used:
    
    Before:
    'Entering method.'                          =>  'Jetzt innerhalb der Objektmethode.',
    'Entered method.'                           =>  'Innerhalb der Methode.',
    'Leaving method.'                           =>  'Jetzt verlassen wir die Objektmethode.',
    'Processing search field: [_1]'             =>  'Suchfeld wird verarbeitet: [_1]',
    'Processing Unique name: [_1]'              =>  'Eindeutiger Name für die Verarbeitung: [_1]',
    'Premature exit - Prerequisites not met.'   =>  'Vorzeitiger Ausstieg – Voraussetzungen nicht erfüllt.',
    'Premature exit - no result passed in.'     =>  'Vorzeitiges Beenden – kein Ergebnis wird an die Unterroutine übergeben.',

    After:
    'Entered method.'                           =>  'Innerhalb der Methode.',
    'Entering method.'                          =>  'Jetzt innerhalb der Objektmethode.',
    'Leaving method.'                           =>  'Jetzt verlassen wir die Objektmethode.',
    'Premature exit - no result passed in.'     =>  'Vorzeitiges Beenden – kein Ergebnis wird an die Unterroutine übergeben.',
    'Premature exit - Prerequisites not met.'   =>  'Vorzeitiger Ausstieg – Voraussetzungen nicht erfüllt.',
    'Processing search field: [_1]'             =>  'Suchfeld wird verarbeitet: [_1]',
    'Processing Unique name: [_1]'              =>  'Eindeutiger Name für die Verarbeitung: [_1]',
    
    # ChangeName::Modulino::setup
    Before:
    'Commandline Options are...'        =>  'Befehlszeilenoptionen sind...',
    'Commandline Arguments are...'      =>  'Befehlszeilenargumente sind...',
    'Configuration Values are...'       =>  'Konfigurationswerte sind...',
    After:
    'Commandline Arguments are...'      =>  'Befehlszeilenargumente sind...',
    'Commandline Options are...'        =>  'Befehlszeilenoptionen sind...',
    'Configuration Values are...'       =>  'Konfigurationswerte sind...',
    
    Before:
    
    # ChangeName::Modulino::start_change_name_operation
    'In subroutine.'                                            =>  'Im Unterprogramm.',
    'Creating object params for ChangeName::Operation'          =>  'Erstellen von Objektparametern für ChangeName::Operation',
    'Object params as follows...'                               =>  'Objektparameter wie folgt...',
    'About to call start method on ChangeName::Operation class' =>  'Im Begriff, die Methode „start“ der Klasse „ChangeName::Operation“ aufzurufen',
    'Options we will use are as follows...'                     =>  'Die von uns verwendeten Optionen sind die folgenden...',
    'Arguments we will use are as follows...'                   =>  'Wir werden die folgenden Argumente verwenden...',

    After:
    
    'About to call start method on ChangeName::Operation class' =>  'Im Begriff, die Methode „start“ der Klasse „ChangeName::Operation“ aufzurufen',
    'Arguments we will use are as follows...'                   =>  'Wir werden die folgenden Argumente verwenden...',
    'Creating object params for ChangeName::Operation'          =>  'Erstellen von Objektparametern für ChangeName::Operation',
    'In subroutine.'                                            =>  'Im Unterprogramm.',
    'Object params as follows...'                               =>  'Objektparameter wie folgt...',
    'Options we will use are as follows...'                     =>  'Die von uns verwendeten Optionen sind die folgenden...',
    
b:

    # ChangeName::Operation::_set_attributes
    'Set initial instance attributes using params or defaults.' =>  'Legen Sie anfängliche Instanzattribute mithilfe von Parametern oder Standardwerten fest.',
    'Now setting additional instance attributes from params...' =>  'Jetzt werden zusätzliche Instanzattribute aus Parametern festgelegt...',
    'Setting self-referential instance attributes...'           =>  'Selbstreferenzielle Instanzattribute festlegen...',
    'Set YAML configurations.'                                  =>  'Legen Sie YAML-Konfigurationen fest.',
    'Set search-fields.'                                        =>  'Legen Suchfelder.',
    'Setting further self-referential attributes...'            =>  'Derzeit werden weitere selbstreferenzielle Attribute gesetzt...',
    'In method.'                                                =>  'In der Methode.',
    'Language and Logger attributes set.'                       =>  'Sprach- und Logger-Attribute festgelegt.',
    'About to set Repository.'                                  =>  'Der nächste Schritt besteht darin, das Repository einzurichten.',
    'Set Repository.'                                           =>  'Legen Sie das zu verwendende Repository fest.',
    'About to add attributes from params...'                    =>  'Der nächste Schritt besteht darin, Attribute aus Parametern hinzuzufügen...',
    'Params have been as follows...'                            =>  'Die Parameter, mit denen wir gearbeitet haben und weiterhin arbeiten werden, sind die folgenden...',
    'Premature exit - Unable to set valid Repository.'          =>  'Vorzeitiges Beenden – Gültiges Repository konnte nicht festgelegt werden.',

a:

    'About to add attributes from params...'                    =>  'Der nächste Schritt besteht darin, Attribute aus Parametern hinzuzufügen...',
    'About to set Repository.'                                  =>  'Der nächste Schritt besteht darin, das Repository einzurichten.',
    'In method.'                                                =>  'In der Methode.',
    'Language and Logger attributes set.'                       =>  'Sprach- und Logger-Attribute festgelegt.',
    'Now setting additional instance attributes from params...' =>  'Jetzt werden zusätzliche Instanzattribute aus Parametern festgelegt...',
    'Params have been as follows...'                            =>  'Die Parameter, mit denen wir gearbeitet haben und weiterhin arbeiten werden, sind die folgenden...',
    'Premature exit - Unable to set valid Repository.'          =>  'Vorzeitiges Beenden – Gültiges Repository konnte nicht festgelegt werden.',
    'Set initial instance attributes using params or defaults.' =>  'Legen Sie anfängliche Instanzattribute mithilfe von Parametern oder Standardwerten fest.',
    'Set Repository.'                                           =>  'Legen Sie das zu verwendende Repository fest.',
    'Set search-fields.'                                        =>  'Legen Suchfelder.',
    'Set YAML configurations.'                                  =>  'Legen Sie YAML-Konfigurationen fest.',
    'Setting further self-referential attributes...'            =>  'Derzeit werden weitere selbstreferenzielle Attribute gesetzt...',
    'Setting self-referential instance attributes...'           =>  'Selbstreferenzielle Instanzattribute festlegen...',
    
b:

    'Name parts before we begin:'                                       =>  'Benennen Sie Teile, bevor wir beginnen:',
    'Set name parts according to language localisation as follows...'   =>  'Legen Sie Namensteile entsprechend der Sprachlokalisierung wie folgt fest...',
    'Premature exit - name parts already populated.'                    =>  'Vorzeitiges Beenden – Listenvariable name_parts bereits gefüllt.',
    'Invalid name parts filter regex as follows...'                     =>  'Ungültige Namensteile filtern reguläre Ausdrücke wie folgt...',
    
a:

    'Invalid name parts filter regex as follows...'                     =>  'Ungültige Namensteile filtern reguläre Ausdrücke wie folgt...',
    'Name parts before we begin:'                                       =>  'Benennen Sie Teile, bevor wir beginnen:',
    'Premature exit - name parts already populated.'                    =>  'Vorzeitiges Beenden – Listenvariable name_parts bereits gefüllt.',
    'Set name parts according to language localisation as follows...'   =>  'Legen Sie Namensteile entsprechend der Sprachlokalisierung wie folgt fest...',
    
b:

    'Generating lists, and setting values.'                                 =>  'Derzeit werden Listen erstellt und Werte festgelegt.',
    'Leaving prepare method.'                                               =>  'Verlassen der „prepare“-Methode.',
    'Premature exit - No search results to narrow down.'                    =>  'Vorzeitiger Ausstieg – Keine Suchergebnisse zum Eingrenzen.',
    'Premature Exit - our operation is already specific to a name part.'    =>  'Vorzeitiger Ausstieg – unser Vorgang ist bereits spezifisch für einen Namensteil.',
    
a:
    'Generating lists, and setting values.'                                 =>  'Derzeit werden Listen erstellt und Werte festgelegt.',
    'Leaving prepare method.'                                               =>  'Verlassen der „prepare“-Methode.',
    'Premature exit - No search results to narrow down.'                    =>  'Vorzeitiger Ausstieg – Keine Suchergebnisse zum Eingrenzen.',
    'Premature Exit - our operation is already specific to a name part.'    =>  'Vorzeitiger Ausstieg – unser Vorgang ist bereits spezifisch für einen Namensteil.',
    
b:

    # ChangeName::Operation::_seeking_confirmation
    'Checking if display lines have been shown.'    =>  'Prüfe gerade, ob Anzeigezeilen angezeigt wurden.',
    'Setting confirmation'                          =>  'Bestätigungswert festlegen.',
    'Added details to what_to_change'               =>  'Details zu what_to_change hinzugefügt',
    'Processing confirmation ([_1])'                =>  'Bestätigungswert wird jetzt verarbeitet ([_1])',
    'Displaying generated confirmation feedback.'   =>  'Zeigt nun das generierte Bestätigungsfeedback an.',
    'Detected [nest,input.none].'                   =>  '„[nest,input.none]“ erkannt.', # [nest,input.none] is a function and parameter not to be translated.
    'Detected [nest,input.all].'                    =>  '„[nest,input.all]“ erkannt.', # [nest,input.all] is a function and parameter not to be translated.
    'Detected [nest,input.yes_letter].'             =>  'Erkannt „[nest,input.yes_letter]“.', # [nest,input.yes_letter] is a function and parameter not to be translated.

a:
    'Added details to what_to_change'               =>  'Details zu what_to_change hinzugefügt',
    'Checking if display lines have been shown.'    =>  'Prüfe gerade, ob Anzeigezeilen angezeigt wurden.',
    'Detected [nest,input.all].'                    =>  '„[nest,input.all]“ erkannt.',
    'Detected [nest,input.none].'                   =>  '„[nest,input.none]“ erkannt.',
    'Detected [nest,input.yes_letter].'             =>  'Erkannt „[nest,input.yes_letter]“.',
    'Displaying generated confirmation feedback.'   =>  'Zeigt nun das generierte Bestätigungsfeedback an.',
    'Processing confirmation ([_1])'                =>  'Bestätigungswert wird jetzt verarbeitet ([_1])',
    'Setting confirmation'                          =>  'Bestätigungswert festlegen.',
    
b:
    # ChangeName::Operation::_generate_confirmation_feedback
    'Generated confirmation feedback.'          =>  'Generiertes Bestätigungs-Feedback.',
    'No confirmation feedback generated.'       =>  'Es wurde kein Bestätigungsfeedback generiert.',
    'Matched unique name.'                      =>  'Der aktuelle Name stimmte mit dem eindeutigen Namen überein.',
    'Added record to confirmation feedback.'    =>  'Der Datensatz wurde unserer Bestätigungs-Feedback hinzugefügt.',
    'Exited unique name loop.'                  =>  'Aus der Schleife für eindeutige Namen ausgebrochen.',
    
b:
    'Match found for: [_1]'                                         =>  'Übereinstimmung gefunden für: [_1]',
    'No match found.'                                               =>  'Keine Übereinstimmung gefunden.',
    'Matched "[_1]" in "[_2]" part of the following unique name...' =>  'Entspricht „[_1]“ im „[_2]“-Teil des folgenden eindeutigen Namens...',
a:
    'Match found for: [_1]'                                         =>  'Übereinstimmung gefunden für: [_1]',
    'Matched "[_1]" in "[_2]" part of the following unique name...' =>  'Entspricht „[_1]“ im „[_2]“-Teil des folgenden eindeutigen Namens...',
    'No match found.'                                               =>  'Keine Übereinstimmung gefunden.',
    
b:
    # ChangeName::Log::replace_language_object
    'Current language object is as follows...'                      =>  'Das aktuelle Sprachobjekt ist wie folgt...',
    'Leaving method prematurely due to no replacement provided.'    =>  'Methode vorzeitig verlassen, da kein Ersatz bereitgestellt wurde.',
    'Proposed replacement language object is as follows...'         =>  'Das vorgeschlagene Ersatzsprachobjekt ist wie folgt...',
    'Proposed replacement was found to be a valid language object.' =>  'Der vorgeschlagene Ersatz wurde erfolgreich als gültiges Sprachobjekt validiert.',
    'Replacement operation performed.'                              =>  'Der Ersetzungsvorgang wurde erfolgreich abgeschlossen.',
    
a:
    'Current language object is as follows...'                      =>  'Das aktuelle Sprachobjekt ist wie folgt...',
    'Leaving method prematurely due to no replacement provided.'    =>  'Methode vorzeitig verlassen, da kein Ersatz bereitgestellt wurde.',
    'Proposed replacement language object is as follows...'         =>  'Das vorgeschlagene Ersatzsprachobjekt ist wie folgt...',
    'Proposed replacement was found to be a valid language object.' =>  'Der vorgeschlagene Ersatz wurde erfolgreich als gültiges Sprachobjekt validiert.',
    'Replacement operation performed.'                              =>  'Der Ersetzungsvorgang wurde erfolgreich abgeschlossen.',
    
    SAME!!!
    
b:

    # ChangeName::Utilities::_multilingual_option_specification
    'Starting subroutine.'                                      =>  'Unterprogramm wird gestartet.',
    'Multilingual variations of [_1] are as dumped below...'    =>  'Mehrsprachige Varianten von [_1] finden Sie weiter unten, solange die Datendumps auf die Anzeige eingestellt sind...',
    'Initial option translation...'                             =>  'Anfängliche Optionsübersetzung...',
    'Option string is: [_1]'                                    =>  'Optionszeichenfolge ist: [_1]',
    'Leaving subroutine.'                                       =>  'Im Begriff, das Unterprogramm zu verlassen.',
    
a:
    'Initial option translation...'                             =>  'Anfängliche Optionsübersetzung...',
    'Leaving subroutine.'                                       =>  'Im Begriff, das Unterprogramm zu verlassen.',
    'Multilingual variations of [_1] are as dumped below...'    =>  'Mehrsprachige Varianten von [_1] finden Sie weiter unten, solange die Datendumps auf die Anzeige eingestellt sind...',
    'Option string is: [_1]'                                    =>  'Optionszeichenfolge ist: [_1]',
    'Starting subroutine.'                                      =>  'Unterprogramm wird gestartet.',
    
b:
    # ChangeName::Utilities::process_commandline_arguments
    'Validated copy of arguments is as follows...'                              =>  'Eine validierte Kopie der Argumente lautet wie folgt...',
    'Flattened list of default options are as follows...'                       =>  'Die abgeflachte Liste der Standardoptionen lautet wie folgt...',
    'Option Specifications have been determined as being as follows...'         =>  'Die Optionsspezifikationen wurden wie folgt festgelegt...',
    'Options after processing the commandline arguments are now as follows...'  =>  'Die Optionen nach der Verarbeitung der Befehlszeilenargumente sind jetzt wie folgt...',
    'Arguments after processing the commandline arguments are as follows...'    =>  'Die Argumente nach der Verarbeitung der Befehlszeilenargumente lauten wie folgt...',
    'The no_input flag will be returned with the value: "[_1]".'                =>  'Das Flag no_input wird mit dem Wert „[_1]“ zurückgegeben.',

a:

    'Arguments after processing the commandline arguments are as follows...'    =>  'Die Argumente nach der Verarbeitung der Befehlszeilenargumente lauten wie folgt...',
    'Flattened list of default options are as follows...'                       =>  'Die abgeflachte Liste der Standardoptionen lautet wie folgt...',
    'Option Specifications have been determined as being as follows...'         =>  'Die Optionsspezifikationen wurden wie folgt festgelegt...',
    'Options after processing the commandline arguments are now as follows...'  =>  'Die Optionen nach der Verarbeitung der Befehlszeilenargumente sind jetzt wie folgt...',
    'The no_input flag will be returned with the value: "[_1]".'                =>  'Das Flag no_input wird mit dem Wert „[_1]“ zurückgegeben.',
    'Validated copy of arguments is as follows...'                              =>  'Eine validierte Kopie der Argumente lautet wie folgt...',