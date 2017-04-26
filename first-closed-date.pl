# Condition: On Close
# Action: User Defined
# Template: Blank

# Prepare code:
if ($self->TicketObj->FirstCustomFieldValue('First Closed') eq "") {
    return 1;
}

return 0;

# Commit code:
my $date = $self->TicketObj->ResolvedObj->AsString;

$self->TicketObj->AddCustomFieldValue(Field => 'First Closed', Value => $date);
