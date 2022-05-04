package Classes::Fujitsu::iRMC::Components::HWCpuSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('FSC-SERVERCONTROL2-MIB', [
    ["ocpus", "sc2StatusComponentTable", "Classes::Fujitsu::iRMC::Components::HWCpuSubsystem::Status"],
    ["cpus", "sc2CPUTable", "Classes::Fujitsu::iRMC::Components::HWCpuSubsystem::Cpu"],
  ]);
}

package Classes::Fujitsu::iRMC::Components::HWCpuSubsystem::Status;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "overall cpu status is %s",
      $self->{sc2csStatusCpu});
  if ($self->{sc2csStatusCpu} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{sc2csStatusCpu} eq "disabled") {
    $self->add_ok();
  } elsif ($self->{sc2csStatusCpu} eq "ok") {
    $self->add_ok();
  } elsif ($self->{sc2csStatusCpu} eq "error") {
    $self->add_critical();
  } elsif ($self->{sc2csStatusCpu} eq "warning") {
    $self->add_warning();
  } elsif ($self->{sc2csStatusCpu} eq "notManageable") {
    $self->add_ok();
  } elsif ($self->{sc2csStatusCpu} eq "notPresent") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
}

package Classes::Fujitsu::iRMC::Components::HWCpuSubsystem::Cpu;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "cpu %s status is %s",
      $self->{sc2cpuUnitId},
      $self->{sc2cpuStatus});
  if ($self->{sc2cpuStatus} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{sc2cpuStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{sc2cpuStatus} eq "error") {
    $self->add_warning();
  } elsif ($self->{sc2cpuStatus} eq "failed") {
    $self->add_critical();
  } elsif ($self->{sc2cpuStatus} =~ /prefailure/) {
    $self->add_warning();
  } elsif ($self->{sc2cpuStatus} eq "missing-termination") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}
