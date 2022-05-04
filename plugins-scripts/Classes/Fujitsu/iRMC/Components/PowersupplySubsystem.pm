package Classes::Fujitsu::iRMC::Components::PowersupplySubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('FSC-SERVERCONTROL2-MIB', [
    ["poweronoffs", "sc2UnitPowerOnOffTable", "Classes::Fujitsu::iRMC::Components::PowersupplySubsystem::PowerOnOff"],
    ["powerredundancies", "sc2PowerSupplyRedundancyConfigurationTable", "Classes::Fujitsu::iRMC::Components::PowersupplySubsystem::PowerRedundancy"],
    ["powersupplies", "sc2PowerSupplyTable", "Classes::Fujitsu::iRMC::Components::PowersupplySubsystem::PowerSupply"],
  ]);
}


package Classes::Fujitsu::iRMC::Components::PowersupplySubsystem::PowerOnOff;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "power is %s and %sredundant",
      $self->{sc2PowerOnOffStatus},
      $self->{sc2PowerSupplyRedundancy} eq "true" ? "" : "not "
  );
  if ($self->{sc2PowerSupplyMatchStatus} eq "mismatch") {
    $self->add_info("power supply mismatch");
    $self->add_warning_mitigation();
  }
  if ($self->{sc2PowerSupplyRedundancy} eq "false") {
    $self->add_warning_mitigation();
  }
}


package Classes::Fujitsu::iRMC::Components::PowersupplySubsystem::PowerRedundancy;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "power redundancy status is %s",
      $self->{sc2PSRedundancyStatus}
  );
  if ($self->{sc2PSRedundancyStatus} eq "warning") {
    $self->add_warning_mitigation();
  } elsif ($self->{sc2PSRedundancyStatus} eq "error") {
    $self->add_critical_mitigation();
  }
}


package Classes::Fujitsu::iRMC::Components::PowersupplySubsystem::PowerSupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "power supply %s is %s",
      $self->{sc2psPowerSupplyNr},
      $self->{sc2PowerSupplyStatus}
  );
  # unknown(1), not-present(2), ok(3), failed(4), ac-fail(5), dc-fail(6), critical-temperature(7), not-manageable(8), fan-failure-predicted(9), fan-failure(10), power-safe-mode(11), non-redundant-dc-fail(12), non-redundant-ac-fail(13)
  # mapping shown in https://documentation.n-able.com/N-central/userguide/Content/Services/Fujitsu/Services_PowerSupply_Fujitsu.htm
  if ($self->{sc2PowerSupplyStatus} eq "not-present") {
    $self->add_ok();
  } elsif ($self->{sc2PowerSupplyStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{sc2PowerSupplyStatus} eq "not-manageable") {
    $self->add_warning();
  } elsif ($self->{sc2PowerSupplyStatus} eq "fan-failure-predicted") {
    $self->add_warning();
  } elsif ($self->{sc2PowerSupplyStatus} eq "unknown") {
    $self->add_unknown();
  } else {
    $self->add_critical();
  }
}

