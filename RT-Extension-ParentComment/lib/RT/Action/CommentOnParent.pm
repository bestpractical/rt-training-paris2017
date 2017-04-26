package RT::Action::CommentOnParent;

use strict;
use warnings;
use base qw(RT::Action);

sub Prepare {
    my $self = shift;
    if (($self->TransactionObj->FirstCustomFieldValue('Copy to Parent') || '') ne 'Yes') {
        return 0;
    }
    
    my $parents = $self->TicketObj->MemberOf;
    
    if ($parents->Count != 1) {
        return 0;
    }
    
    my $parent = $parents->First;
    
    if (!$parent->TargetObj || $parent->TargetObj->isa('RT::Ticket')) {
        return 0;
    }
    
    return 1;
}

sub Commit {
    my $self = shift;
    my $link = $self->TicketObj->MemberOf->First;
    my $parent_as_system = $link->TargetObj;
    
    my $parent_as_user = RT::Ticket->new($self->TransactionObj->CreatorObj);
    $parent_as_user->Load($parent_as_system->Id);
    
    $parent_as_user->Comment(Content => $self->TransactionObj->Content);
    
    return 1;
}

1;

