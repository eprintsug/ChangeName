
package ChangeNameOperation::Languages;

# Always:
use     strict;
use     warnings;

# UTF-8:
use     utf8;
use     v5.16;

# Specific:
use     English;
use     Locale::Maketext;

ChangeNameOperation::Languages->try_or_die('en-GB');

sub try_or_die {

    my  ($self, $language)  =   @ARG;
    $language               //= 'en-GB';
    my  $error={
        language            =>  'Trouble finding a language to use.',
    };

    return  Locale::Maketext->get_handle($language)
            #ChangeNameOperation::Languages::en_gb->new()
            || die  $error->{'language'};
}

#sub get_handle {
#    say "Test handle";
#}

1;



