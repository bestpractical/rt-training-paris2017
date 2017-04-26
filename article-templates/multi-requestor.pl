Hello {
    my $requestors = $Ticket->Requestors->UserMembersObj;
    my @names;
    while (my $requestor = $requestors->Next) {
        push @names, $requestor->RealName || $requestor->EmailAddress;
    }

    join ", ", @names
},

Did you restart your laptop?

Can you bring it in?

Thanks,
{ $Ticket->Owner == RT->Nobody->Id ? "" : $Ticket->OwnerObj->RealName }
