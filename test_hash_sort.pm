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
'language.name'                         =>  'Deutsch (Deutschland)',
'language.error.set_language_handle'    =>  'Probleme beim Finden einer zu verwendenden Sprache.',

'nest.error.language'                   =>  'Ungültiger Sprach-Handle zum Aufrufen der Methode „maketext“.',
'nest.error.key'                        =>  'Fehler beim Verschachteln eines Lexikonwerts.',

'options.language'                      =>  'sprache spr',
'options.config'                        =>  'konfig konfiguration',
'options.live'                          =>  'live',
'options.verbose'                       =>  'ausführlich ausführl',
'options.debug'                         =>  'debug',
'options.trace'                         =>  'stacktrace trace',
'options.no_dumper'                     =>  'kein_dumper kein_dump keindumper keindump',
'options.no_trace'                      =>  'kein_stacktrace keinstacktrace kein_trace keintrace',
'options.exact'                         =>  'exakt genau genaue',
'options.help'                          =>  'hilfe',

'input.yes_letter'                      =>  'J',
'input.no_letter'                       =>  'N',
'input.all'                             =>  'ALLE',
'input.none'                            =>  'KEINER',
'input.given'                           =>  'vorname',
'input.family'                          =>  'familienname',
'input.1'                               =>  '1',
'input.2'                               =>  '2',

'name.given'                            =>  'Vorname',
'name.family'                           =>  'Familienname',
'name.honourific'                       =>  'Ehrenname',
'name.lineage'                          =>  'Abstammungsname', # Unsure about this one - it's literally Ancestral Name

'display_line'                          =>  'Datensatz [_1]: [_2].',

'log.type.verbose'                      =>  'ausführlich',
'log.type.log'                          =>  'protokoll',
'log.type.debug'                        =>  'debug',
'log.type.dumper'                       =>  'dumper',
'log.type.trace'                        =>  'stacktrace',

'finish.change'                         =>  '[quant,_1,Änderung] von [quant,_2,Änderungen] abgeschlossen.',
'finish.no_change'                      =>  'Keine Änderungen vorgenommen.',
'finish.thank_you'                      =>  'Vielen Dank, dass Sie dieses Skript verwenden.',
                                            );

my @array                               =   sort {$a cmp $b} keys %hash;
my  $single_quote                       =   q{'};
my  $new_line                           =   "\n";
say $ARG for @array;

my  $output                             =   $new_line;
    ($output                            .=  sprintf(
                                                "%-41s",
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

'display_line'                           =>  'Datensatz [_1]: [_2].',

'finish.change'                          =>  '[quant,_1,Änderung] von [quant,_2,Änderungen] abgeschlossen.',
'finish.no_change'                       =>  'Keine Änderungen vorgenommen.',
'finish.thank_you'                       =>  'Vielen Dank, dass Sie dieses Skript verwenden.',

'input.1'                                =>  '1',
'input.2'                                =>  '2',
'input.all'                              =>  'ALLE',
'input.family'                           =>  'familienname',
'input.given'                            =>  'vorname',
'input.no_letter'                        =>  'N',
'input.none'                             =>  'KEINER',
'input.yes_letter'                       =>  'J',

'language.error.set_language_handle'     =>  'Probleme beim Finden einer zu verwendenden Sprache.',
'language.name'                          =>  'Deutsch (Deutschland)',

'log.type.debug'                         =>  'debug',
'log.type.dumper'                        =>  'dumper',
'log.type.log'                           =>  'protokoll',
'log.type.trace'                         =>  'stacktrace',
'log.type.verbose'                       =>  'ausführlich',

'name.family'                            =>  'Familienname',
'name.given'                             =>  'Vorname',
'name.honourific'                        =>  'Ehrenname',
'name.lineage'                           =>  'Abstammungsname',  # Unsure about this one - it's literally Ancestral Name

'nest.error.key'                         =>  'Fehler beim Verschachteln eines Lexikonwerts.',
'nest.error.language'                    =>  'Ungültiger Sprach-Handle zum Aufrufen der Methode „maketext“.',

'options.config'                         =>  'konfig konfiguration',
'options.debug'                          =>  'debug',
'options.exact'                          =>  'exakt genau genaue',
'options.help'                           =>  'hilfe',
'options.language'                       =>  'sprache spr',
'options.live'                           =>  'live',
'options.no_dumper'                      =>  'kein_dumper kein_dump keindumper keindump',
'options.no_trace'                       =>  'kein_stacktrace keinstacktrace kein_trace keintrace',
'options.trace'                          =>  'stacktrace trace',
'options.verbose'                        =>  'ausführlich ausführl',

