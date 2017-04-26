Set($rtname, 'example.com');
Set($WebDomain, 'localhost');
Set($WebPort, 8888);
Set($LogToFile, 'debug');
Set($MailCommand, 'mbox');
Set($LogoLinkURL, "/");
Set($DevelMode, 1);
Set($StatementLog, 'debug');
#Set($LogStackTraces, 'warning');

Plugin('RT::Extension::ArticleTemplates');
Plugin('RT::Extension::AttachmentZip');
Plugin('RT::Extension::AdminConditionsAndActions');
Plugin('RT::Extension::ParentComment');

Set(@CustomFieldValuesSources, qw(RT::CustomFieldValues::CountryArticle));

Set(%CustomFieldGroupings,
    'RT::Ticket' => [
        'Dates'             => ['First Closed', 'First Comment'],
    ],
);

# Set($EnableReminders, 0);

1;

