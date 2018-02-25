# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $Home = $Kernel::OM->Get('Kernel::Config')->Get('Home');

# Set up an OTRS 6 database.
my @DatabaseXMLFiles = (
    "$Home/scripts/test/sample/DBUpdate/otrs6-schema.xml",
    "$Home/scripts/test/sample/DBUpdate/otrs6-initial_insert.xml",
);

my $Success = $Helper->ProvideTestDatabase(
    DatabaseXMLFiles => \@DatabaseXMLFiles,
);
if ( !$Success ) {
    $Self->False(
        0,
        'Test database could not be provided, skipping test',
    );
    return 1;
}
$Self->True(
    $Success,
    'ProvideTestDatabase - Load and execute XML files',
);

my $DBUpdateObject = $Kernel::OM->Get('scripts::DBUpdate');

# Run DB update script consecutively.
for my $Count ( 1 .. 2 ) {

    $Success = $DBUpdateObject->Run(
        CommandlineOptions => {
            NonInteractive => 1,

            # Verbose => 1,
        },
    );

    $Self->Is(
        $Success,
        1,
        "DBUpdate ran without problems (Run $Count)",
    );
}

# set up a OTRS 6 database
@DatabaseXMLFiles = (
    "$Home/scripts/database/otrs-schema.xml",
    "$Home/scripts/database/otrs-initial_insert.xml",
);

$Success = $Helper->ProvideTestDatabase(
    DatabaseXMLFiles => \@DatabaseXMLFiles,
);
if ( !$Success ) {
    $Self->False(
        0,
        'Test database could not be provided, skipping test',
    );
    return 1;
}
$Self->True(
    $Success,
    'ProvideTestDatabase - Load and execute XML files',
);

# Run DB update script consecutively.
for my $Count ( 1 .. 2 ) {

    $Success = $DBUpdateObject->Run(
        CommandlineOptions => {
            NonInteractive => 1,

            # Verbose => 1,
        },
    );

    $Self->Is(
        $Success,
        1,
        "DBUpdate ran without problems (Run $Count)",
    );
}

# Cleanup is done by TmpDatabaseCleanup().

1;
