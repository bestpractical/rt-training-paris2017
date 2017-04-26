package RT::Action::SendEmail;

use strict;
use warnings;
no warnings qw(redefine);

use base qw(RT::Action);

=head2 AddAttachments

Takes any attachments to this transaction and attaches them to the message
we're building.

Custom version to also look in RichTextUploads.

=cut

sub AddAttachments {
    my $self = shift;

    my $MIMEObj = $self->TemplateObj->MIMEObj;

    $MIMEObj->head->delete('RT-Attach-Message');

    my $attachments = AttachableFromTransaction($self->TransactionObj);

    # attach any of this transaction's attachments
    my $seen_attachment = 0;
    while ( my $attach = $attachments->Next ) {
        if ( !$seen_attachment ) {
            $MIMEObj->make_multipart( 'mixed', Force => 1 );
            $seen_attachment = 1;
        }
        $self->AddAttachment($attach);
    }

    # attach any attachments requested by the transaction or template
    # that aren't part of the transaction itself
    $self->AddAttachmentsFromHeaders;

    $self->AddRichTextAttachments;
}

=head2 AddRichTextAttachments

Add RichTextAttachments from this transaction.

=cut

sub AddRichTextAttachments {
    my $self = shift;
    my $MIMEObj = $self->TemplateObj->MIMEObj;

    my $rich_text;
    my $found_rich_text = 0;
    my $rich_text_link = 0;
    my @uploads;

    # Look at existing content to see if any emails have a rich text link
    # If found, create a multipart/related email, add the images as
    # attachments, and update the links to reference the attached images

    foreach my $part ( $MIMEObj->parts_DFS ) {
        next unless $part->mime_type eq 'text/html';

        my $body = $part->stringify_body;
        $rich_text_link = 1 if $body =~ m|\<img src=\".+id=(?:\d+)\"|;

        if ( $rich_text_link ){
            RT::Logger->debug("Found rich text link");
            $rich_text = MIME::Entity->build( Type => "multipart/related" );
            my $duplicate = $part->dup;
            $rich_text->add_part($duplicate);
            my $head = $part->head;
            $head->replace( 'X-Flagged-For-Removal', '1' );

            # Now add each image attachment part
            while( $body =~ m|\<img src=\".+id=(\d+)\"|g ){
                my $link_id = $1;
                my $upload = RT::RichTextUpload->new(RT->SystemUser);

                $upload->LoadByCols( id => $link_id );
                if ($upload->Id) {
                    RT::Logger->debug("Loaded rich text image $link_id");
                    $found_rich_text = 1;
                    push @uploads, $link_id;
                    $self->AddRichTextAttachment($upload, $rich_text);
                }
            }

            # Fix links in the email
            my $html = $rich_text->parts(0);
            my $html_body = $html->stringify_body;
            foreach my $link_id ( @uploads ){
                my $content_id = $self->TicketObj->Id . "-" . $self->TransactionObj->Id . "-" . $link_id;
                $html_body =~ s|\<img src=\".+id=$link_id.*\/\>|\<img src=\"cid:$content_id\" alt="attached image" \/\>|;
            }
            my $handle = $html->bodyhandle;
            my $IO = $handle->open("w") || RT::Logger->error("Unable to open body in SendEmail: $!");
            $IO->print($html_body);
            $IO->close;

            if ( $found_rich_text and $rich_text_link ){
                $MIMEObj->add_part($rich_text);
                $MIMEObj->make_multipart( 'mixed', Force => 1 );

                # Remove the original html part so we don't have two
                my $top_part = $MIMEObj->parts(0);
                my @keep = grep { FilterFlaggedParts($_) } $top_part->parts;
                $top_part->parts(\@keep);
            }
            return;
        }
    }
}

sub FilterFlaggedParts {
    my $part = shift;
    my $head = $part->head;
    return 0 if $head->get('X-Flagged-For-Removal');
    return 1;
}

sub AddRichTextAttachment {
    my $self    = shift;
    my $image = shift;
    my $MIMEObj = shift;

    return unless $image->Id;

    # ->attach expects just the disposition type; extract it if we have the header
    # or default to "attachment"
    my $disp = ($image->GetHeader('Content-Disposition') || '')
                    =~ /^\s*(inline|attachment)/i ? $1 : "attachment";
                    warn "Attaching image";
    $MIMEObj->attach(
        Type        => $image->ContentType,
        Charset     => $image->OriginalEncoding,
        Data        => $image->DecodedContent,
        Disposition => $disp,
        Filename    => $self->MIMEEncodeString( $image->Filename ),
        Id          => $image->GetHeader('Content-ID'),
        'Content-ID:' => '<'. $self->TicketObj->Id . "-"
            . $self->TransactionObj->Id . "-"
            . $image->id . '>',
        Encoding => '-SUGGEST',
    );
}

1;
