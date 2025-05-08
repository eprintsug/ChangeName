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
    'Generating lists, and setting values.'                                 =>  'Derzeit werden Listen erstellt und Werte festgelegt.',
    'Leaving prepare method.'                                               =>  'Verlassen der „prepare“-Methode.',
    'Premature exit - No search results to narrow down.'                    =>  'Vorzeitiger Ausstieg – Keine Suchergebnisse zum Eingrenzen.',
    'Premature Exit - our operation is already specific to a name part.'    =>  'Vorzeitiger Ausstieg – unser Vorgang ist bereits spezifisch für einen Namensteil.',



                                            );

my @array                               =   sort {fc $a cmp fc $b} keys %hash;
my  $single_quote                       =   q{'};
my  $new_line                           =   "\n";
#say $ARG for @array;

# Phrases Formatting:
my  $output                             =   $new_line;
    ($output                            .=  '    '. # four spaces
                                            sprintf(
                                                "%-68s",
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
    'Premature exit - Prerequisites not met.'   =>  'Vorzeitiger Ausstieg – Voraussetzungen nicht erfüllt.',
    'Premature exit - no result passed in.'     =>  'Vorzeitiges Beenden – kein Ergebnis wird an die Unterroutine übergeben.',
    'Processing Unique name: [_1]'              =>  'Eindeutiger Name für die Verarbeitung: [_1]',
    'Processing search field: [_1]'             =>  'Suchfeld wird verarbeitet: [_1]',
    
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
    'Set Repository.'                                           =>  'Legen Sie das zu verwendende Repository fest.',
    'Set YAML configurations.'                                  =>  'Legen Sie YAML-Konfigurationen fest.',
    'Set initial instance attributes using params or defaults.' =>  'Legen Sie anfängliche Instanzattribute mithilfe von Parametern oder Standardwerten fest.',
    'Set search-fields.'                                        =>  'Legen Suchfelder.',
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