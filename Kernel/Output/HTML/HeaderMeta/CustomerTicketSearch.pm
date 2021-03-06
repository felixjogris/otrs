# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::HeaderMeta::CustomerTicketSearch;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Title = $Kernel::OM->Get('Kernel::Config')->Get('ProductName');
    $Title .= ' - ' . $LayoutObject->{LanguageObject}->Translate('Customer');
    $Title .= ' (' . $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Hook') . ')';
    $LayoutObject->Block(
        Name => 'MetaLink',
        Data => {
            Rel   => 'search',
            Type  => 'application/opensearchdescription+xml',
            Title => $Title,
            Href  => $LayoutObject->{Baselink} . 'Action=' . $Param{Config}->{Action}
                . ';Subaction=OpenSearchDescription',
        },
    );

    return 1;
}

1;
