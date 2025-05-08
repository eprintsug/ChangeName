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
'language.name'                         =>  'English (United Kingdom)',
'language.error.set_language_handle'    =>  'Trouble finding a language to use.',

'nest.error.language'                   =>  'Not a valid language handle from which to call the maketext method.',
'nest.error.key'                        =>  'Error nesting a Lexicon value.',

'options.language'                      =>  'language lang',
'options.config'                        =>  'config configuration',
'options.live'                          =>  'live',
'options.verbose'                       =>  'verbose',
'options.debug'                         =>  'debug',
'options.trace'                         =>  'trace stacktrace',
'options.no_dumper'                     =>  'no_dumper no_dump nodumper nodump',
'options.no_trace'                      =>  'no_trace notrace no_stacktrace nostacktrace',
'options.exact'                         =>  'exact',
'options.help'                          =>  'help',

'input.yes_letter'                      =>  'Y',
'input.no_letter'                       =>  'N',
'input.all'                             =>  'ALL',
'input.none'                            =>  'NONE',
'input.given'                           =>  'given',
'input.family'                          =>  'family',
'input.1'                               =>  '1',
'input.2'                               =>  '2',

'name.given'                            =>  'Given Name',
'name.family'                           =>  'Family Name',
'name.honourific'                       =>  'Honorific Name',
'name.lineage'                          =>  'Lineage Name',

'display_line'                          =>  'Record [_1]: [_2].',

'log.type.verbose'                      =>  'verbose',
'log.type.log'                          =>  'log',
'log.type.debug'                        =>  'debug',
'log.type.dumper'                       =>  'dumper',
'log.type.trace'                        =>  'trace',

'finish.change'                         =>  '[quant,_1,change] out of [quant,_2,change] completed.',
'finish.no_change'                      =>  'No changes made.',
'finish.thank_you'                      =>  'Thank you for using this script.',

                                            );

my @array                               =   sort {$a cmp $b} keys %hash;
my  $single_quote                       =   q{'};
my  $new_line                           =   "\n";
say $ARG for @array;

my  $output                             =   $new_line;
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

say $output;

__END__

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

