# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package scripts::DBUpdate::UpgradeDatabaseStructure;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Console::Command::Maint::Database::Check',
);

=head1 NAME

scripts::DBUpdate::UpgradeDatabaseStructure - Upgrades the database structure to OTRS 6.

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    # enable auto-flushing of STDOUT
    $| = 1;    ## no critic

    my $Verbose = $Param{CommandlineOptions}->{Verbose} || 0;

    my @Tasks = (
        {
            Message => 'Adds an index to the communication log table',
            Module  => 'CommunicationLogIndex',
        },
    );

    print "\n" if $Verbose;

    TASK:
    for my $Task (@Tasks) {

        next TASK if !$Task;
        next TASK if !$Task->{Module};

        print "       - $Task->{Message}\n" if $Verbose;

        my $ModuleName = "scripts::DBUpdate::UpgradeDatabaseStructure::$Task->{Module}";
        if ( !$Kernel::OM->Get('Kernel::System::Main')->Require($ModuleName) ) {
            next TASK;
        }

        # Run module.
        $Kernel::OM->ObjectParamAdd(
            "scripts::DBUpdate::UpgradeDatabaseStructure::$Task->{Module}" => {
                Opts => $Param{CommandlineOptions},
            },
        );

        my $Object = $Kernel::OM->Create($ModuleName);
        if ( !$Object ) {
            print "\n    Error: System was unable to create object for: $ModuleName.\n\n";
            return;
        }

        my $Success = $Object->Run(%Param);

        if ( !$Success ) {
            print "    Error.\n" if $Verbose;
            return;
        }
    }

    print "\n" if $Verbose;

    return 1;
}

=head2 CheckPreviousRequirement()

check for initial conditions for running this migration step.

Returns 1 on success

    my $Result = $DBUpdateObject->CheckPreviousRequirement();

=cut

sub CheckPreviousRequirement {
    my ( $Self, %Param ) = @_;

    my $Verbose = $Param{CommandlineOptions}->{Verbose} || 0;

    print "\n" if $Verbose;

    # Localize standard output and redirect it to a variable in order to decide whether should it be shown later.
    my $StandardOutput;
    my $ConnectionCheck;
    {
        local *STDOUT = *STDOUT;
        undef *STDOUT;
        open STDOUT, '>:utf8', \$StandardOutput;    ## no critic

        # Check if DB connection is possible.
        $ConnectionCheck = $Kernel::OM->Get('Kernel::System::Console::Command::Maint::Database::Check')->Execute();
    }

    print $StandardOutput if $Verbose;

    print "\n" if $Verbose;

    if ( !defined $ConnectionCheck || $ConnectionCheck ne 0 ) {
        print "\n    Error: Not possible to perform DB connection!\n\n";
        return;
    }

    return 1;
}

1;

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
