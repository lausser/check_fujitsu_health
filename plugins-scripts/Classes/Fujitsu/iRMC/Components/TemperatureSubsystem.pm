package Classes::Fujitsu::iRMC::Components::TemperatureSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('FSC-SERVERCONTROL2-MIB', [
    ["temperatures", "sc2StatusComponentTable", "Classes::Fujitsu::iRMC::Components::TemperatureSubsystem::Status"],
    # es gibt noch sc2ComponentStatusSensorTable mit
    # sc2cssSensorDesignation: Temp, aber auch die haben lediglich ok oder nicht
    # einen echten temperaturwert gibt es nicht
    ["templogs", "sc2MessageTextLogTable", "Classes::Fujitsu::iRMC::Components::TemperatureSubsystem::Templog", sub { my $o = shift; return $o->{sc2msgTextLogMessage} =~ /Temperature/ ? 1 : 0; }],
  ]);
}


package Classes::Fujitsu::iRMC::Components::TemperatureSubsystem::Templog;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my $self = shift;
  $self->{sc2msgTextLogTimestampHuman} = scalar localtime $self->{sc2msgTextLogTimestamp};
}

package Classes::Fujitsu::iRMC::Components::TemperatureSubsystem::Status;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "overall temperature status is %s",
      $self->{sc2csStatusTemperature});
  if ($self->{sc2csStatusTemperature} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{sc2csStatusTemperature} eq "disabled") {
    $self->add_ok();
  } elsif ($self->{sc2csStatusTemperature} eq "ok") {
    $self->add_ok();
  } elsif ($self->{sc2csStatusTemperature} eq "error") {
    $self->add_critical();
  } elsif ($self->{sc2csStatusTemperature} eq "warning") {
    $self->add_warning();
  } elsif ($self->{sc2csStatusTemperature} eq "notManageable") {
    $self->add_ok();
  } elsif ($self->{sc2csStatusTemperature} eq "notPresent") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
}


