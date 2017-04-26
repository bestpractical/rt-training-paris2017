package RT::Action::SetDateCustomField;

use strict;
use warnings;
use base qw(RT::Action);

sub Prepare {
    my $self = shift;
    if ($self->TicketObj->FirstCustomFieldValue($self->Argument) eq "") {
        return 1;
    }
    
    return 0;
}

sub Commit {
    my $self = shift;
    my $date = $self->TransactionObj->CreatedObj->AsString;
    $self->TicketObj->AddCustomFieldValue(Field => $self->Argument, Value => $date);
}

1;
