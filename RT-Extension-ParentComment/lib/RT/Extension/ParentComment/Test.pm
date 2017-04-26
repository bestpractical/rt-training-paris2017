use strict;
use warnings;

### after: use lib qw(@RT_LIB_PATH@);
use lib qw(/opt/rt/local/lib /opt/rt/lib);

package RT::Extension::ParentComment::Test;

use base qw(RT::Test);

sub import {
    my $class = shift;
    my %args  = @_;

    $args{'requires'} ||= [];
    if ( $args{'testing'} ) {
        unshift @{ $args{'requires'} }, 'RT::Extension::ParentComment';
    } else {
        $args{'testing'} = 'RT::Extension::ParentComment';
    }

    $class->SUPER::import( %args );
    $class->export_to_level(1);

    require RT::Extension::ParentComment;
}

1;

