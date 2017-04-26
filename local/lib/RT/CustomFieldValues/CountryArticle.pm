package RT::CustomFieldValues::CountryArticle;

use strict;
use warnings;

use base qw(RT::CustomFieldValues::External);

sub SourceDescription {
    return 'Pulls values from Country article';
}

sub ExternalValues {
    my $self = shift;

    my @res;
    my $i = 0;
    my $article = RT::Article->new( $self->CurrentUser );
    $article->LoadByCols(Name => 'Country');
    my $cf = RT::CustomField->new($self->CurrentUser);
    $cf->LoadByCols(Name => 'Values');

    my $values = $cf->ValuesForObject($article);

    while( my $ocfv = $values->Next ) {
        push @res, {
            name        => $ocfv->Content,
            sortorder   => $i++,
        };
    }
    return \@res;
}

RT::Base->_ImportOverlays();

1;

