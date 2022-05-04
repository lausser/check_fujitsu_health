package Classes::Fujitsu::iRMC::Components::FanSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('FSC-SERVERCONTROL2-MIB', [
    ["fans", "sc2FanTable", "Classes::Fujitsu::iRMC::Components::FanSubsystem::Fan"],
    ["airflows", "sc2AirflowTable", "Classes::Fujitsu::iRMC::Components::FanSubsystem::Airflow"],
  ]);
}


package Classes::Fujitsu::iRMC::Components::FanSubsystem::Fan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my $self = shift;
  $self->{name} = lc $self->{sc2fanDesignation};
  $self->{name} =~ s/ /_/g;
}

sub check {
  my $self = shift;
  $self->add_info(sprintf "%s is %s", $self->{sc2fanDesignation},
      $self->{sc2fanStatus});
  if ($self->{sc2fanStatus} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{sc2fanStatus} eq "disabled") {
    $self->add_ok();
  } elsif ($self->{sc2fanStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{sc2fanStatus} eq "failed") {
    $self->add_critical();
  } elsif ($self->{sc2fanStatus} =~ /prefailure/) {
    $self->add_warning();
  } elsif ($self->{sc2fanStatus} eq "redundant-fan-failed") {
    $self->add_warning();
  } elsif ($self->{sc2fanStatus} eq "not-manageable") {
    $self->add_ok();
  } elsif ($self->{sc2fanStatus} eq "not-present") {
    $self->add_ok();
  }
}

package Classes::Fujitsu::iRMC::Components::FanSubsystem::Airflow;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;


