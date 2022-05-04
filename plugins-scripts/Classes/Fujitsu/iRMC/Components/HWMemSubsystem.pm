package Classes::Fujitsu::iRMC::Components::HWMemSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('FSC-SERVERCONTROL2-MIB', [
    ["mems", "sc2StatusComponentTable", "Classes::Fujitsu::iRMC::Components::HWMemSubsystem::Status"],
    ["memmodules", "sc2MemoryModuleTable", "Classes::Fujitsu::iRMC::Components::HWMemSubsystem::Memmodule", sub { my $o = shift; grep { $o->{sc2memModuleStatus} ne $_ } (qw(not-present)) }]
  ]);
}

package Classes::Fujitsu::iRMC::Components::HWMemSubsystem::Status;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "overall memory status is %s",
      $self->{sc2csStatusMemoryModule});
  if ($self->{sc2csStatusMemoryModule} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{sc2csStatusMemoryModule} eq "disabled") {
    $self->add_ok();
  } elsif ($self->{sc2csStatusMemoryModule} eq "ok") {
    $self->add_ok();
  } elsif ($self->{sc2csStatusMemoryModule} eq "error") {
    $self->add_critical();
  } elsif ($self->{sc2csStatusMemoryModule} eq "warning") {
    $self->add_warning();
  } elsif ($self->{sc2csStatusMemoryModule} eq "notManageable") {
    $self->add_ok();
  } elsif ($self->{sc2csStatusMemoryModule} eq "notPresent") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
}

package Classes::Fujitsu::iRMC::Components::HWMemSubsystem::Memmodule;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "memory %s status is %s",
      $self->{sc2memUnitId},
      $self->{sc2memModuleStatus});
  if ($self->{sc2memModuleStatus} eq "unknown") {
    $self->add_unknown();
  } elsif ($self->{sc2memModuleStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{sc2memModuleStatus} eq "error") {
    $self->add_warning();
  } elsif ($self->{sc2memModuleStatus} eq "failed") {
    $self->add_critical();
  } elsif ($self->{sc2memModuleStatus} =~ /prefailure/) {
    $self->add_warning();
  } elsif ($self->{sc2memModuleStatus} eq "missing-termination") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }

}

