
use strict;
use warnings;
use utf8;
{
package Other;

use English;
use v5.16;
use     CPAN::Meta::YAML qw(
            LoadFile
            Load
        ); # Standard module in Core Perl since Perl 5.14.
        use     Data::Dumper;
my $data = Load(                                           # Will die on any load error.
                                do                                          # 'do' returns last value of block.
                                {
                                    local $INPUT_RECORD_SEPARATOR = undef;  # Read until end of input.
                                    <ChangeNameOperationYAMLConfig::DATA>   # Input is __DATA__ at the bottom of this very file.
                                }
                            );

my  $matches_yes        =   qr/^(y|yes)$/i;

Dumper($data);

my $flag = $data->{'Force commit changes to database'} =~ $matches_yes;
say ($data->{'Force commit changes to database'} =~ $matches_yes);
say $flag;




1;

}
package ChangeNameOperationYAMLConfig;

1;

__DATA__
# This is a YAML Configuration File:
%YAML 1.2
# Three dashes to start new YAML document.
---

Fields to search:
    -   creators_name
    -   contributors_name

Dataset to use: eprint

Force commit changes to database: yes

# For the above, provide a yes or y (case insensitive) to force commit,
# or anything else (such as no) to not force commit.

...
# Three dots to end current YAML document.

