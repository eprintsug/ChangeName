package ScriptOne;

use     strict;
use     warnings;

use     File::Basename;
use     lib dirname(__FILE__).'/../../perl_lib';

use     v5.32;

say hello();

sub hello {
    my  $message = "Hello World";
    return $message;
}

1;