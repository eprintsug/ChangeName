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

my %hash_to_sort                        =   (
    # ChangeName::Utilities::process_commandline_arguments
    'Validated copy of arguments is as follows...'                              =>  'Eine validierte Kopie der Argumente lautet wie folgt...',
    'Flattened list of default options are as follows...'                       =>  'Die abgeflachte Liste der Standardoptionen lautet wie folgt...',
    'Option Specifications have been determined as being as follows...'         =>  'Die Optionsspezifikationen wurden wie folgt festgelegt...',
    'Options after processing the commandline arguments are now as follows...'  =>  'Die Optionen nach der Verarbeitung der Befehlszeilenargumente sind jetzt wie folgt...',
    'Arguments after processing the commandline arguments are as follows...'    =>  'Die Argumente nach der Verarbeitung der Befehlszeilenargumente lauten wie folgt...',
    'The no_input flag will be returned with the value: "[_1]".'                =>  'Das Flag no_input wird mit dem Wert „[_1]“ zurückgegeben.',



                                            );
                                            
my  @key_order_for_english              =   (

         # Commonly used:
    'Entered method.'                           =>  'Innerhalb der Methode.',
    'Entering method.'                          =>  'Jetzt innerhalb der Objektmethode.',
    'Leaving method.'                           =>  'Jetzt verlassen wir die Objektmethode.',
    'Premature exit - no result passed in.'     =>  'Vorzeitiges Beenden – kein Ergebnis wird an die Unterroutine übergeben.',
    'Premature exit - Prerequisites not met.'   =>  'Vorzeitiger Ausstieg – Voraussetzungen nicht erfüllt.',
    'Processing search field: [_1]'             =>  'Suchfeld wird verarbeitet: [_1]',
    'Processing Unique name: [_1]'              =>  'Eindeutiger Name für die Verarbeitung: [_1]',


    # ChangeName::Modulino::new
    'Params to be used for a new logger are as follows...'  =>  'Die für einen neuen Logger in Kürze zu verwendenden Parameter sind wie folgt...',


    # ChangeName::Modulino::setup
    'Commandline Arguments are...'      =>  'Befehlszeilenargumente sind...',
    'Commandline Options are...'        =>  'Befehlszeilenoptionen sind...',
    'Configuration Values are...'       =>  'Konfigurationswerte sind...',


    # ChangeName::Modulino::start_change_name_operation
    'About to call start method on ChangeName::Operation class' =>  'Im Begriff, die Methode „start“ der Klasse „ChangeName::Operation“ aufzurufen',
    'Arguments we will use are as follows...'                   =>  'Wir werden die folgenden Argumente verwenden...',
    'Creating object params for ChangeName::Operation'          =>  'Erstellen von Objektparametern für ChangeName::Operation',
    'In subroutine.'                                            =>  'Im Unterprogramm.',
    'Object params as follows...'                               =>  'Objektparameter wie folgt...',
    'Options we will use are as follows...'                     =>  'Die von uns verwendeten Optionen sind die folgenden...',


    # ChangeName::Operation::new
    'Constructed New Object Instance.'  =>  'Neue Objektinstanz erstellt.',


    # ChangeName::Operation::_set_attributes
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


    # ChangeName::Operation::_set_search
    'Set search normally, as no --exact flag provided.' =>  'Suche normal einstellen, da kein --exact-Flag bereitgestellt wird.',


    # ChangeName::Operation::_set_search_exact
    'Find attribute set to ([_1]).'     =>  'Das Attribut „find“ wurde auf ([_1]) gesetzt.',
    'Search attribute set to ([_1]).'   =>  'Das Attribut „search“ wurde ([_1]) gesetzt.',


    # ChangeName::Operation::set_name_parts
    'Invalid name parts filter regex as follows...'                     =>  'Ungültige Namensteile filtern reguläre Ausdrücke wie folgt...',
    'Name parts before we begin:'                                       =>  'Benennen Sie Teile, bevor wir beginnen:',
    'Premature exit - name parts already populated.'                    =>  'Vorzeitiges Beenden – Listenvariable name_parts bereits gefüllt.',
    'Set name parts according to language localisation as follows...'   =>  'Legen Sie Namensteile entsprechend der Sprachlokalisierung wie folgt fest...',


    # ChangeName::Operation::_set_repository
    'Archive attribute of [_1] instance is now "[_2]".'             =>  'Das Archivattribut der [_1] Instanz ist jetzt "[_2]".',
    'Repository attribute of [_1] instance is now of class "[_2]".' =>  'Das Repository-Attribut der [_1] Instanz ist jetzt von der Klasse "[_2]".',

    'Repository attribute of [_1] instance is not a blessed object. Dumped contents are as follows...'
    =>  'Das Repository-Attribut der [_1]-Instanz ist kein gesegnetes Objekt. Der DataDump des Inhalts ist wie folgt...',


    # ChangeName::Operation::search
    'Using search settings...'  =>  'Die folgenden Sucheinstellungen zu verwenden....', # Google translate only gives German for use rather than using!?


    # ChangeName::Operation::prepare
    'Generating lists, and setting values.'                                 =>  'Derzeit werden Listen erstellt und Werte festgelegt.',
    'Leaving prepare method.'                                               =>  'Verlassen der „prepare“-Methode.',
    'Premature exit - No search results to narrow down.'                    =>  'Vorzeitiger Ausstieg – Keine Suchergebnisse zum Eingrenzen.',
    'Premature Exit - our operation is already specific to a name part.'    =>  'Vorzeitiger Ausstieg – unser Vorgang ist bereits spezifisch für einen Namensteil.',


    # ChangeName::Operation::display
    'Called display method.'    =>  'Wird als Anzeige Objektmethode bezeichnet.',
    'Leaving display method.'   =>  'Verlassen der „display“-Methode.',


    # ChangeName::Operation::confirm
    'Called confirm method.'    =>  'Wird als „confirm“-Objektmethode bezeichnet.',
    'Leaving confirm method.'   =>  'Verlassen der „confirm“-Methode.',


    # ChangeName::Operation::change
    'Called change method.'                 =>  'Wird als „change“-Objektmethode bezeichnet.',
    'Premature exit - Nothing to change.'   =>  'Vorzeitiger Ausstieg – Es gibt nichts zu ändern.',

    'Changed our fresh result - this will be committed.'
    =>  'Unsere neue Kopie des Ergebnisdatensatzes wurde geändert. Diese Änderungen werden in Kürze in die Datenbank „übertragen“ (in Kürze gespeichert).',

    'Changed our working result - this will not be committed.'
    =>  'Unsere Arbeitskopie des Ergebnisobjekts wurde geändert. Diese Änderungen werden nicht in der Datenbank „festgeschrieben“ (nicht gespeichert).',


    # ChangeName::Operation::_seeking_confirmation
    'Added details to what_to_change'               =>  'Details zu what_to_change hinzugefügt',
    'Checking if display lines have been shown.'    =>  'Prüfe gerade, ob Anzeigezeilen angezeigt wurden.',
    'Detected [nest,input.all].'                    =>  '„[nest,input.all]“ erkannt.',          # [nest,input.all] is a function and parameter not to be translated.
    'Detected [nest,input.none].'                   =>  '„[nest,input.none]“ erkannt.',         # [nest,input.none] is a function and parameter not to be translated.
    'Detected [nest,input.yes_letter].'             =>  'Erkannt „[nest,input.yes_letter]“.',   # [nest,input.yes_letter] is a function and parameter not to be translated.
    'Displaying generated confirmation feedback.'   =>  'Zeigt nun das generierte Bestätigungsfeedback an.',
    'Processing confirmation ([_1])'                =>  'Bestätigungswert wird jetzt verarbeitet ([_1])',
    'Setting confirmation'                          =>  'Bestätigungswert festlegen.',

    'Have determined that confirmation is not to be set automatically to yes or no. Instead we\'ll now prompt the user for a confirmation value.'
    =>  'Habe festgelegt, dass die Bestätigung nicht automatisch auf ja oder nein gesetzt werden soll. Stattdessen fordern wir den Benutzer nun zur Eingabe eines Bestätigungswertes auf.',

    'Will check matches auto no result ([_1]) and matches auto yes result ([_2])...'
    =>  'Überprüfe nun die Ergebnisse von „matches_auto_no“ ([_1]) und „matches_auto_yes“ ([_2])...',


    # ChangeName::Operation::_generate_confirmation_feedback
    'Added record to confirmation feedback.'    =>  'Der Datensatz wurde unserer Bestätigungs-Feedback hinzugefügt.',
    'Exited unique name loop.'                  =>  'Aus der Schleife für eindeutige Namen ausgebrochen.',
    'Generated confirmation feedback.'          =>  'Generiertes Bestätigungs-Feedback.',
    'Matched unique name.'                      =>  'Der aktuelle Name stimmte mit dem eindeutigen Namen überein.',
    'No confirmation feedback generated.'       =>  'Es wurde kein Bestätigungsfeedback generiert.',

    'Since unique names are unique, we can leave unique name loop now we have processed a match.'
    =>  'Da eindeutige Namen eindeutig sind, können wir die Schleife für eindeutige Namen verlassen, nachdem wir eine Übereinstimmung verarbeitet haben.',


    # ChangeName::Operation::_add_relevant_display_lines
    'Entered method. Attribute display_lines is...' =>  'Eingegebene Methode. Das Attribut display_lines ist...',
    'Leaving method. Attribute display_lines is...' =>  'Methode verlassen. Das display_lines-Attribut ist...',
    'Set display flags and added display line:'     =>  'Setzen Sie das Anzeigeflag und die hinzugefügten Anzeigezeilen:',


    # ChangeName::Operation::_match
    'Match found for: [_1]'                                         =>  'Übereinstimmung gefunden für: [_1]',
    'Matched "[_1]" in "[_2]" part of the following unique name...' =>  'Entspricht „[_1]“ im „[_2]“-Teil des folgenden eindeutigen Namens...',
    'No match found.'                                               =>  'Keine Übereinstimmung gefunden.',


    # ChangeName::Operation::format_single_line_for_display
    'Found params, and about to process them...'                =>  'Parameter gefunden und bin bereit, sie zu verarbeiten...',
    'Returning localised display line as we leave the method.'  =>  'Wir geben die lokalisierte Anzeigezeile zurück, da wir nun die Methode verlassen.',
    'Stringified names for use in a localised display line.'    =>  'Stringifizierte Namen zur Verwendung in einer lokalisierten „display_line“(Anzeigezeile).',


    # ChangeName::Log::New
    'Constructed New Logger Object Instance.'   =>  'Neue Logger-Objektinstanz erstellt.',


    # ChangeName::Log::replace_language_object
    'Current language object is as follows...'                      =>  'Das aktuelle Sprachobjekt ist wie folgt...',
    'Leaving method prematurely due to no replacement provided.'    =>  'Methode vorzeitig verlassen, da kein Ersatz bereitgestellt wurde.',
    'Proposed replacement language object is as follows...'         =>  'Das vorgeschlagene Ersatzsprachobjekt ist wie folgt...',
    'Proposed replacement was found to be a valid language object.' =>  'Der vorgeschlagene Ersatz wurde erfolgreich als gültiges Sprachobjekt validiert.',
    'Replacement operation performed.'                              =>  'Der Ersetzungsvorgang wurde erfolgreich abgeschlossen.',


    # ChangeName::Log::dumper
    'Data dump prevented by no_dumper option.'  =>  'Datendump durch Option kein_dumper verhindert.',


    # ChangeName::Utilities::_multilingual_option_specification
    'Initial option translation...'                             =>  'Anfängliche Optionsübersetzung...',
    'Leaving subroutine.'                                       =>  'Im Begriff, das Unterprogramm zu verlassen.',
    'Multilingual variations of [_1] are as dumped below...'    =>  'Mehrsprachige Varianten von [_1] finden Sie weiter unten, solange die Datendumps auf die Anzeige eingestellt sind...',
    'Option string is: [_1]'                                    =>  'Optionszeichenfolge ist: [_1]',
    'Starting subroutine.'                                      =>  'Unterprogramm wird gestartet.',

    'No list of translation values to add alongside codebase\'s existing option key "[_1]" for language [nest,language.name].' # [nest,language.name] is a function and parameter not to be translated.
    =>  'Keine Liste mit Übersetzungswerten zum Hinzufügen neben dem vorhandenen Optionsschlüssel „[_1]“ der Codebasis für die Sprache [nest,language.name].',

    'Option translation as a list with codebase\'s existing option key "[_1]" omitted...'
    =>  'Optionenübersetzung als Liste, wobei der vorhandene Optionsschlüssel "[_1]" der Codebasis weggelassen wird...',


    # ChangeName::Utilities::_get_default_options
    'Default options set as follows...' =>  'Die Standardoptionen sind wie folgt eingestellt...',


    # ChangeName::Utilities::process_commandline_arguments
    'Arguments after processing the commandline arguments are as follows...'    =>  'Die Argumente nach der Verarbeitung der Befehlszeilenargumente lauten wie folgt...',
    'Flattened list of default options are as follows...'                       =>  'Die abgeflachte Liste der Standardoptionen lautet wie folgt...',
    'Option Specifications have been determined as being as follows...'         =>  'Die Optionsspezifikationen wurden wie folgt festgelegt...',
    'Options after processing the commandline arguments are now as follows...'  =>  'Die Optionen nach der Verarbeitung der Befehlszeilenargumente sind jetzt wie folgt...',
    'The no_input flag will be returned with the value: "[_1]".'                =>  'Das Flag no_input wird mit dem Wert „[_1]“ zurückgegeben.',
    'Validated copy of arguments is as follows...'                              =>  'Eine validierte Kopie der Argumente lautet wie folgt...',

    'Passed in commandline arguments from which to derive both options and arguments from are as follows...'
    =>  'Die bereitgestellten Befehlszeilenargumente, aus denen sowohl Optionen als auch Argumente abgeleitet werden müssen, sind wie folgt...',


    # ChangeName::Utilities::chunkify
    'Adding a chunk, from a list offset of [_1].'                           =>  'Jetzt wird ein „Chunk“ aus einem Listenoffset von [_1] hinzugefügt.',
    'Valid list object. Proceeding to chunkify using chunk size [_1]...'    =>  'Gültiges Listenobjekt. Mit der Chunkifizierung wird mit der Chunkgröße [_1] fortgefahren...',

    'Invalid list object. Returning the default result - an empty list that will return false in scalar context.'
    =>  'Ungültiges Listenobjekt. Das Standardergebnis wird zurückgegeben – eine leere Liste, die im Skalarkontext „False“ zurückgibt.',


    # ChangeName::Modulino::setup
    'Language set to [nest,language.name].'                             =>  'Sprache auf [nest,language.name] eingestellt.',
    'No specific language set. Using all supported languages: [_1].'    =>  'Kein bestimmter Sprachsatz. Es werden alle unterstützten Sprachen verwendet: [_1].',

    # ChangeName::Operation::_set_search
    'Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.'
    =>  'Der Suchbegriff „[_1]“ wird als exakte (wenn auch nicht zwischen Groß- und Kleinschreibung unterscheidende) Zeichenfolge interpretiert, die gesucht werden soll.',

    # ChangeName::Operation::search
    'Found Results.'    =>  'Gefundene Ergebnisse.',

    # ChangeName::Operation::prepare
    'Narrowing search to a specific part...'    =>  'Die Suche auf ein bestimmtes Teil eingrenzen...',



     # ChangeName::Operation::search
    'No Results Found.'         =>  'Keine Ergebnisse gefunden.',
    'Searching fields [_1] ...' =>  'Derzeit verwenden wir die folgenden Suchfelder, um unsere Suche durchzuführen [_1] ...',

    # ChangeName::Operation::_set_attributes
    'DRY RUN mode - no changes will be made.'                           =>  'DRY RUN-Modus – in diesem Modus werden tatsächlich keine Änderungen vorgenommen.',
    'LIVE mode - changes will be made at the end after confirmation.'   =>  'LIVE-Modus – Änderungen werden am Ende nach Bestätigung vorgenommen.',

    # ChangeName::Operation::display
    'Nothing was found to match.'                                       =>  'Es wurde keine Übereinstimmung festgestellt.',
    'Thank you for your patience. Your request is being processed...'   =>  'Vielen Dank für Ihre Geduld. Ihre Anfrage wird bearbeitet...',
                                            );
                                            
my  %english_value_look_up              =   (
    # Commonly used:
    'Entering method.'                          =>  'Entering method.',
    'Entered method.'                           =>  'Entered method.',
    'Leaving method.'                           =>  'Leaving method.',
    'Processing search field: [_1]'             =>  'Processing search field: [_1]',
    'Processing Unique name: [_1]'              =>  'Processing Unique name: [_1]',
    'Premature exit - Prerequisites not met.'   =>  'Premature exit - Prerequisites not met.',
    'Premature exit - no result passed in.'     =>  'Premature exit - no result passed in.',

    # ChangeName::Modulino::new
    'Params to be used for a new logger are as follows...'=>'Params to be used for a new logger are as follows...',

    # ChangeName::Modulino::setup
    'Commandline Options are...'        =>  'Commandline Options are...',
    'Commandline Arguments are...'      =>  'Commandline Arguments are...',
    'Configuration Values are...'       =>  'Configuration Values are...',

    # ChangeName::Modulino::start_change_name_operation
    'In subroutine.' => 'In subroutine.',
    'Creating object params for ChangeName::Operation' => 'Creating object params for ChangeName::Operation',
    'Object params as follows...' => 'Object params as follows...',
    'About to call start method on ChangeName::Operation class' => 'About to call start method on ChangeName::Operation class',
    'Options we will use are as follows...' => 'Options we will use are as follows...',
    'Arguments we will use are as follows...' => 'Arguments we will use are as follows...',

    # ChangeName::Operation::new
    'Constructed New Object Instance.' => 'Constructed New Object Instance.',

    # ChangeName::Operation::_set_attributes
    'Set initial instance attributes using params or defaults.' => 'Set initial instance attributes using params or defaults.',
    'Now setting additional instance attributes from params...' => 'Now setting additional instance attributes from params...',
    'Setting self-referential instance attributes...' => 'Setting self-referential instance attributes...',
    'Set YAML configurations.' => 'Set YAML configurations.',
    'Set search-fields.' => 'Set search-fields.',
    'Setting further self-referential attributes...' => 'Setting further self-referential attributes...',
    'In method.' => 'In method.',
    'Language and Logger attributes set.' => 'Language and Logger attributes set.',
    'About to set Repository.' => 'About to set Repository.',
    'Set Repository.' => 'Set Repository.',
    'About to add attributes from params...' => 'About to add attributes from params...',
    'Params have been as follows...' => 'Params have been as follows...',
    'Premature exit - Unable to set valid Repository.' => 'Premature exit - Unable to set valid Repository.',

    # ChangeName::Operation::_set_search
    'Set search normally, as no --exact flag provided.' => 'Set search normally, as no --exact flag provided.',

    # ChangeName::Operation::_set_search_exact
    'Find attribute set to ([_1]).' => 'Find attribute set to ([_1]).',
    'Search attribute set to ([_1]).' => 'Search attribute set to ([_1]).',

    # ChangeName::Operation::set_name_parts
    'Name parts before we begin:' => 'Name parts before we begin:',
    'Set name parts according to language localisation as follows...' => 'Set name parts according to language localisation as follows...',
    'Premature exit - name parts already populated.' => 'Premature exit - name parts already populated.',
    'Invalid name parts filter regex as follows...' => 'Invalid name parts filter regex as follows...',

    # ChangeName::Operation::_set_repository
    'Archive attribute of [_1] instance is now "[_2]".' => 'Archive attribute of [_1] instance is now "[_2]".',
    'Repository attribute of [_1] instance is now of class "[_2]".' => 'Repository attribute of [_1] instance is now of class "[_2]".',
    'Repository attribute of [_1] instance is not a blessed object. Dumped contents are as follows...' => 'Repository attribute of [_1] instance is not a blessed object. Dumped contents are as follows...',

    # ChangeName::Operation::search
    'Using search settings...' => 'Using search settings...',

    # ChangeName::Operation::prepare
    'Generating lists, and setting values.' => 'Generating lists, and setting values.',
    'Leaving prepare method.' => 'Leaving prepare method.',
    'Premature exit - No search results to narrow down.' => 'Premature exit - No search results to narrow down.',
    'Premature Exit - our operation is already specific to a name part.' => 'Premature Exit - our operation is already specific to a name part.',

    # ChangeName::Operation::display
    'Called display method.'    =>  'Called display method.',
    'Leaving display method.'   =>  'Leaving display method.',

    # ChangeName::Operation::confirm
    'Called confirm method.'    =>  'Called confirm method.',
    'Leaving confirm method.'   =>  'Leaving confirm method.',

    # ChangeName::Operation::change
    'Called change method.'                                     =>  'Called change method.',
    'Premature exit - Nothing to change.'                       =>  'Premature exit - Nothing to change.',
    'Changed our working result - this will not be committed.'  =>  'Changed our working result - this will not be committed.',
    'Changed our fresh result - this will be committed.'        =>  'Changed our fresh result - this will be committed.',

    # ChangeName::Operation::_seeking_confirmation
    'Checking if display lines have been shown.'    =>  'Checking if display lines have been shown.',
    'Setting confirmation'                          =>  'Setting confirmation',
    'Added details to what_to_change'               =>  'Added details to what_to_change',
    'Processing confirmation ([_1])'                =>  'Processing confirmation ([_1])',
    'Displaying generated confirmation feedback.'   =>  'Displaying generated confirmation feedback.',
    'Detected [nest,input.none].'                   =>  'Detected [nest,input.none].', # [nest,input.none] is a function and parameter not to be translated.
    'Detected [nest,input.all].'                    =>  'Detected [nest,input.all].', # [nest,input.all] is a function and parameter not to be translated.
    'Detected [nest,input.yes_letter].'             =>  'Detected [nest,input.yes_letter].', # [nest,input.yes_letter] is a function and parameter not to be translated.

    'Will check matches auto no result ([_1]) and matches auto yes result ([_2])...'
    =>  'Will check matches auto no result ([_1]) and matches auto yes result ([_2])...',

    'Have determined that confirmation is not to be set automatically to yes or no. Instead we\'ll now prompt the user for a confirmation value.'
    =>  'Have determined that confirmation is not to be set automatically to yes or no. Instead we\'ll now prompt the user for a confirmation value.',

    # ChangeName::Operation::_generate_confirmation_feedback
    'Generated confirmation feedback.'          =>  'Generated confirmation feedback.',
    'No confirmation feedback generated.'       =>  'No confirmation feedback generated.',
    'Matched unique name.'                      =>  'Matched unique name.',
    'Added record to confirmation feedback.'    =>  'Added record to confirmation feedback.',
    'Exited unique name loop.'                  =>  'Exited unique name loop.',

    'Since unique names are unique, we can leave unique name loop now we have processed a match.'
    =>  'Since unique names are unique, we can leave unique name loop now we have processed a match.',

    # ChangeName::Operation::_add_relevant_display_lines
    'Entered method. Attribute display_lines is...' =>  'Entered method. Attribute display_lines is...',
    'Leaving method. Attribute display_lines is...' =>  'Leaving method. Attribute display_lines is...',
    'Set display flags and added display line:'     =>  'Set display flags and added display line:',

    # ChangeName::Operation::_match
    'Match found for: [_1]'                                         =>  'Match found for: [_1]',
    'No match found.'                                               =>  'No match found.',
    'Matched "[_1]" in "[_2]" part of the following unique name...' =>  'Matched "[_1]" in "[_2]" part of the following unique name...',

    # ChangeName::Operation::format_single_line_for_display
    'Found params, and about to process them...'                =>  'Found params, and about to process them...',
    'Stringified names for use in a localised display line.'    =>  'Stringified names for use in a localised display line.',
    'Returning localised display line as we leave the method.'  =>  'Returning localised display line as we leave the method.',

    # ChangeName::Log::New
    'Constructed New Logger Object Instance.'   =>  'Constructed New Logger Object Instance.',

    # ChangeName::Log::replace_language_object
    'Current language object is as follows...'                      =>  'Current language object is as follows...',
    'Leaving method prematurely due to no replacement provided.'    =>  'Leaving method prematurely due to no replacement provided.',
    'Proposed replacement language object is as follows...'         =>  'Proposed replacement language object is as follows...',
    'Proposed replacement was found to be a valid language object.' =>  'Proposed replacement was found to be a valid language object.',
    'Replacement operation performed.'                              =>  'Replacement operation performed.',

    # ChangeName::Log::dumper
    'Data dump prevented by no_dumper option.'  =>  'Data dump prevented by no_dumper option.',

    # ChangeName::Utilities::_multilingual_option_specification
    'Starting subroutine.'                                      =>  'Starting subroutine.',
    'Multilingual variations of [_1] are as dumped below...'    =>  'Multilingual variations of [_1] are as dumped below...',
    'Initial option translation...'                             =>  'Initial option translation...',
    'Option string is: [_1]'                                    =>  'Option string is: [_1]',
    'Leaving subroutine.'                                       =>  'Leaving subroutine.',

    'No list of translation values to add alongside codebase\'s existing option key "[_1]" for language [nest,language.name].'
    =>  'No list of translation values to add alongside codebase\'s existing option key "[_1]" for language [nest,language.name].', # [nest,language.name] is a function and parameter not to be translated.

    'Option translation as a list with codebase\'s existing option key "[_1]" omitted...'
    =>  'Option translation as a list with codebase\'s existing option key "[_1]" omitted...',


    # ChangeName::Utilities::_get_default_options
    'Default options set as follows...' =>  'Default options set as follows...',

    # ChangeName::Utilities::process_commandline_arguments
    'Validated copy of arguments is as follows...'                              =>  'Validated copy of arguments is as follows...',
    'Flattened list of default options are as follows...'                       =>  'Flattened list of default options are as follows...',
    'Option Specifications have been determined as being as follows...'         =>  'Option Specifications have been determined as being as follows...',
    'Options after processing the commandline arguments are now as follows...'  =>  'Options after processing the commandline arguments are now as follows...',
    'Arguments after processing the commandline arguments are as follows...'    =>  'Arguments after processing the commandline arguments are as follows...',
    'The no_input flag will be returned with the value: "[_1]".'                =>  'The no_input flag will be returned with the value: "[_1]".',

    'Passed in commandline arguments from which to derive both options and arguments from are as follows...'
    =>  'Passed in commandline arguments from which to derive both options and arguments from are as follows...',

    # ChangeName::Utilities::chunkify
    'Valid list object. Proceeding to chunkify using chunk size [_1]...'    =>  'Valid list object. Proceeding to chunkify using chunk size [_1]...',
    'Adding a chunk, from a list offset of [_1].'                           =>  'Adding a chunk, from a list offset of [_1].',

    'Invalid list object. Returning the default result - an empty list that will return false in scalar context.'
    =>  'Invalid list object. Returning the default result - an empty list that will return false in scalar context.',



    # ChangeName::Modulino::setup
    'Language set to [nest,language.name].'                             =>  'Language set to [nest,language.name].',
    'No specific language set. Using all supported languages: [_1].'    =>  'No specific language set. Using all supported languages: [_1].',

    # ChangeName::Operation::_set_search
    'Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.'
    =>  'Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.',

    # ChangeName::Operation::search
    'Found Results.'    =>  'Found Results.',

    # ChangeName::Operation::prepare
    'Narrowing search to a specific part...'    =>  'Narrowing search to a specific part...',



     # ChangeName::Operation::search
    'No Results Found.'         =>  'No Results Found.',
    'Searching fields [_1] ...' =>  'Searching fields [_1] ...',

    # ChangeName::Operation::_set_attributes
    'DRY RUN mode - no changes will be made.'                           =>  'DRY RUN mode - no changes will be made.',
    'LIVE mode - changes will be made at the end after confirmation.'   =>  'LIVE mode - changes will be made at the end after confirmation.',

    # ChangeName::Operation::display
    'Thank you for your patience. Your request is being processed...'   =>  'Thank you for your patience. Your request is being processed...',
    'Nothing was found to match.'                                       =>  'Nothing was found to match.',

                                            );                

my  $col                                =   81;
my  $col_calculation                    =   $col - 5;
my @array                               =   sort {fc $a cmp fc $b} keys %hash_to_sort;
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
                                            $hash_to_sort{$ARG}.
                                            $single_quote.
                                            ','.
                                            $new_line
    )                                       for @array;
    
# Phrases Formatting:
my  $output_for_english                 =   $new_line;
my  $skip_or_not                        =   0;
    ($output_for_english                .=  
                                            '    '. # four spaces
                                            sprintf(
                                                (length($ARG)>$col_calculation)? '%s    ':
                                                '%-'.$col_calculation.'s',
                                                $single_quote.$ARG.$single_quote
                                            ).
                                            '=>  '.
                                            $single_quote.
                                            $english_value_look_up{$ARG}.
                                            $single_quote.
                                            ','.
                                            $new_line
    )                                       for (
                                                    map {
                                                            my  $skip           =   $skip_or_not;
                                                            $skip_or_not    =   0
                                                                                if $skip_or_not;
                                                            $skip?  ():
                                                            $ARG
                                                        } @key_order_for_english
                                                );

say $output_for_english;


####
#New function:



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
    
    
=====

ENGLISH:

Massaged output - added some q{} for phrases with commas - will need to be checked against originals:

    'Constructed New Logger Object Instance.'                                   =>  'Constructed New Logger Object Instance.',
    'Generating lists, and setting values.'                                     =>  'Generating lists, and setting values.',
    'Find attribute set to ([_1]).'                                             =>  'Find attribute set to ([_1]).',
    'Configuration Values are...'                                               =>  'Configuration Values are...',
    'Starting subroutine.'                                                      =>  'Starting subroutine.',
    'Set initial instance attributes using params or defaults.'                 =>  'Set initial instance attributes using params or defaults.',
    'Checking if display lines have been shown.'                                =>  'Checking if display lines have been shown.',
    'About to call start method on ChangeName::Operation class'                 =>  'About to call start method on ChangeName::Operation class',
    'Matched "[_1]" in "[_2]" part of the following unique name...'             =>  'Matched "[_1]" in "[_2]" part of the following unique name...',
    'Creating object params for ChangeName::Operation'                          =>  'Creating object params for ChangeName::Operation',
    'Detected [nest,input.yes_letter].'                                         =>  'Detected [nest,input.yes_letter].',
    'Exited unique name loop.'                                                  =>  'Exited unique name loop.',
    'Changed our fresh result - this will be committed.'                        =>  'Changed our fresh result - this will be committed.',
    'Premature exit - Prerequisites not met.'                                   =>  'Premature exit - Prerequisites not met.',
    'Proposed replacement language object is as follows...'                     =>  'Proposed replacement language object is as follows...',
    'Search attribute set to ([_1]).'                                           =>  'Search attribute set to ([_1]).',
    'No match found.'                                                           =>  'No match found.',
    'Current language object is as follows...'                                  =>  'Current language object is as follows...',
    'Added details to what_to_change'                                           =>  'Added details to what_to_change',
    'Commandline Options are...'                                                =>  'Commandline Options are...',
    'Called display method.'                                                    =>  'Called display method.',
    'Initial option translation...'                                             =>  'Initial option translation...',
    'The no_input flag will be returned with the value: "[_1]".'                =>  'The no_input flag will be returned with the value: "[_1]".',
    'Displaying generated confirmation feedback.'                               =>  'Displaying generated confirmation feedback.',
    'Commandline Arguments are...'                                              =>  'Commandline Arguments are...',
    'Archive attribute of [_1] instance is now "[_2]".'                         =>  'Archive attribute of [_1] instance is now "[_2]".',
    q{Option translation as a list with codebase's existing option key "[_1]" omitted...}    =>  q{Option translation as a list with codebase's existing option key "[_1]" omitted...},
    'Language and Logger attributes set.'                                       =>  'Language and Logger attributes set.',
    'Options we will use are as follows...'                                     =>  'Options we will use are as follows...',
    'Returning localised display line as we leave the method.'                  =>  'Returning localised display line as we leave the method.',
    'Matched unique name.'                                                      =>  'Matched unique name.',
    'Called change method.'                                                     =>  'Called change method.',
    'Processing confirmation ([_1])'                                            =>  'Processing confirmation ([_1])',
    'Set search normally, as no --exact flag provided.'                         =>  'Set search normally, as no --exact flag provided.',
    'Name parts before we begin:'                                               =>  'Name parts before we begin:',
    'Language set to [nest,language.name].'                                     =>  'Language set to [nest,language.name].',
    'Proposed replacement was found to be a valid language object.'             =>  'Proposed replacement was found to be a valid language object.',
    'No Results Found.'                                                         =>  'No Results Found.',
    'Option string is: [_1]'                                                    =>  'Option string is: [_1]',
    'Thank you for your patience. Your request is being processed...'           =>  'Thank you for your patience. Your request is being processed...',
    'Params have been as follows...'                                            =>  'Params have been as follows...',
    'Changed our working result - this will not be committed.'                  =>  'Changed our working result - this will not be committed.',
    q{No list of translation values to add alongside codebase's existing option key "[_1]" for language [nest,language.name].}    =>  q{No list of translation values to add alongside codebase's existing option key "[_1]" for language [nest,language.name].},
    'Premature exit - no result passed in.'                                     =>  'Premature exit - no result passed in.',
    'Leaving subroutine.'                                                       =>  'Leaving subroutine.',
    'LIVE mode - changes will be made at the end after confirmation.'           =>  'LIVE mode - changes will be made at the end after confirmation.',
    'Premature exit - No search results to narrow down.'                        =>  'Premature exit - No search results to narrow down.',
    'About to add attributes from params...'                                    =>  'About to add attributes from params...',
    'Passed in commandline arguments from which to derive both options and arguments from are as follows...'    =>  'Passed in commandline arguments from which to derive both options and arguments from are as follows...',
    'Invalid list object. Returning the default result - an empty list that will return false in scalar context.'    =>  'Invalid list object. Returning the default result - an empty list that will return false in scalar context.',
    'Leaving confirm method.'                                                   =>  'Leaving confirm method.',
    'Now setting additional instance attributes from params...'                 =>  'Now setting additional instance attributes from params...',
    'Leaving method. Attribute display_lines is...'                             =>  'Leaving method. Attribute display_lines is...',
    'Generated confirmation feedback.'                                          =>  'Generated confirmation feedback.',
    'Object params as follows...'                                               =>  'Object params as follows...',
    'Default options set as follows...'                                         =>  'Default options set as follows...',
    'Leaving display method.'                                                   =>  'Leaving display method.',
    'Repository attribute of [_1] instance is not a blessed object. Dumped contents are as follows...'    =>  'Repository attribute of [_1] instance is not a blessed object. Dumped contents are as follows...',
    'Adding a chunk, from a list offset of [_1].'                               =>  'Adding a chunk, from a list offset of [_1].',
    'Setting confirmation'                                                      =>  'Setting confirmation',
    'Searching fields [_1] ...'                                                 =>  'Searching fields [_1] ...',
    'Match found for: [_1]'                                                     =>  'Match found for: [_1]',
    'Leaving prepare method.'                                                   =>  'Leaving prepare method.',
    'Processing search field: [_1]'                                             =>  'Processing search field: [_1]',
    'Arguments we will use are as follows...'                                   =>  'Arguments we will use are as follows...',
    'Using search settings...'                                                  =>  'Using search settings...',
    'Set display flags and added display line:'                                 =>  'Set display flags and added display line:',
    'No confirmation feedback generated.'                                       =>  'No confirmation feedback generated.',
    'Processing Unique name: [_1]'                                              =>  'Processing Unique name: [_1]',
    'Option Specifications have been determined as being as follows...'         =>  'Option Specifications have been determined as being as follows...',
    'Leaving method.'                                                           =>  'Leaving method.',
    'Premature exit - Unable to set valid Repository.'                          =>  'Premature exit - Unable to set valid Repository.',
    'Leaving method prematurely due to no replacement provided.'                =>  'Leaving method prematurely due to no replacement provided.',
    'Found params, and about to process them...'                                =>  'Found params, and about to process them...',
    'Data dump prevented by no_dumper option.'                                  =>  'Data dump prevented by no_dumper option.',
    'Params to be used for a new logger are as follows...'                      =>  'Params to be used for a new logger are as follows...',
    'Added record to confirmation feedback.'                                    =>  'Added record to confirmation feedback.',
    'Invalid name parts filter regex as follows...'                             =>  'Invalid name parts filter regex as follows...',
    'Multilingual variations of [_1] are as dumped below...'                    =>  'Multilingual variations of [_1] are as dumped below...',
    'Premature Exit - our operation is already specific to a name part.'        =>  'Premature Exit - our operation is already specific to a name part.',
    'Detected [nest,input.none].'                                               =>  'Detected [nest,input.none].',
    'Arguments after processing the commandline arguments are as follows...'    =>  'Arguments after processing the commandline arguments are as follows...',
    'Since unique names are unique, we can leave unique name loop now we have processed a match.'    =>  'Since unique names are unique, we can leave unique name loop now we have processed a match.',
    'Stringified names for use in a localised display line.'                    =>  'Stringified names for use in a localised display line.',
    'Called confirm method.'                                                    =>  'Called confirm method.',
    'Validated copy of arguments is as follows...'                              =>  'Validated copy of arguments is as follows...',
    'Set YAML configurations.'                                                  =>  'Set YAML configurations.',
    'Constructed New Object Instance.'                                          =>  'Constructed New Object Instance.',
    'DRY RUN mode - no changes will be made.'                                   =>  'DRY RUN mode - no changes will be made.',
    'In method.'                                                                =>  'In method.',
    'Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.'    =>  'Interpreting search term "[_1]" as exact (albeit case insensitive) string to find.',
    'Will check matches auto no result ([_1]) and matches auto yes result ([_2])...'    =>  'Will check matches auto no result ([_1]) and matches auto yes result ([_2])...',
    'Setting further self-referential attributes...'                            =>  'Setting further self-referential attributes...',
    'Set Repository.'                                                           =>  'Set Repository.',
    'Set name parts according to language localisation as follows...'           =>  'Set name parts according to language localisation as follows...',
    'Setting self-referential instance attributes...'                           =>  'Setting self-referential instance attributes...',
    'No specific language set. Using all supported languages: [_1].'            =>  'No specific language set. Using all supported languages: [_1].',
    'About to set Repository.'                                                  =>  'About to set Repository.',
    'Found Results.'                                                            =>  'Found Results.',
    'Narrowing search to a specific part...'                                    =>  'Narrowing search to a specific part...',
    'Set search-fields.'                                                        =>  'Set search-fields.',
    'Premature exit - name parts already populated.'                            =>  'Premature exit - name parts already populated.',
    'Replacement operation performed.'                                          =>  'Replacement operation performed.',
    'Nothing was found to match.'                                               =>  'Nothing was found to match.',
    'Entered method.'                                                           =>  'Entered method.',
    'In subroutine.'                                                            =>  'In subroutine.',
    'Entered method. Attribute display_lines is...'                             =>  'Entered method. Attribute display_lines is...',
    'Repository attribute of [_1] instance is now of class "[_2]".'             =>  'Repository attribute of [_1] instance is now of class "[_2]".',
    'Flattened list of default options are as follows...'                       =>  'Flattened list of default options are as follows...',
    'Entering method.'                                                          =>  'Entering method.',
    q{'Have determined that confirmation is not to be set automatically to yes or no. Instead we'll now prompt the user for a confirmation value.}    =>  q{Have determined that confirmation is not to be set automatically to yes or no. Instead we'll now prompt the user for a confirmation value.},
    'Valid list object. Proceeding to chunkify using chunk size [_1]...'        =>  'Valid list object. Proceeding to chunkify using chunk size [_1]...',
    'Detected [nest,input.all].'                                                =>  'Detected [nest,input.all].',
    'Premature exit - Nothing to change.'                                       =>  'Premature exit - Nothing to change.',
    'Options after processing the commandline arguments are now as follows...'  =>  'Options after processing the commandline arguments are now as follows...',