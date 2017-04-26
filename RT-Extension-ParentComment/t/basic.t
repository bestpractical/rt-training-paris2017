use strict;
use warnings;

use RT::Extension::ParentComment::Test tests => undef;

my $queue = RT::Queue->new(RT->SystemUser);
$queue->Load('General');
ok($queue->Id, 'loaded General queue');

my $cf = RT::CustomField->new(RT->SystemUser);
$cf->Load('Copy to Parent');
ok($cf->Id, 'loaded Copy to Parent custom field');
is($cf->LookupType, RT::Transaction->CustomFieldLookupType, 'lookup type matches');

# scalar <>;

done_testing;

