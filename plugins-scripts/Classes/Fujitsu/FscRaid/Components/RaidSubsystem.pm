package Classes::Fujitsu::FscRaid::Components::RaidSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects('FSC-RAID-MIB', qw(svrStatus svrStatusLogicalDrives 
      svrStatusPhysicalDevices svrStatusControllers svrStatusOverall
      svrControllerInfo));
  $self->get_snmp_tables('FSC-RAID-MIB', [
      ['controllers', 'svrCtrlTable', 'Classes::Fujitsu::FscRaid::Components::RaidSubsystem::Controller'],
      ['physical_devices', 'svrPhysicalDeviceTable', 'Classes::Fujitsu::FscRaid::Components::RaidSubsystem::PhysicalDevice'],
      ['logical_drives', 'svrLogicalDriveTable', 'Classes::Fujitsu::FscRaid::Components::RaidSubsystem::LogicalDrive'],
  ]);
}

sub check {
  my $self = shift;
  foreach (@{$self->{controllers}}) {
    $_->check();
  }
  foreach (@{$self->{logical_drives}}) {
    $_->check();
  }
  foreach (@{$self->{physical_devices}}) {
    $_->check();
  }
  if (! $self->check_messages()) {
    $self->add_ok('raid hardware working fine');
  }
return;
  my $info = sprintf 'global system status is %s', $self->{sieStSystemStatusValue};
  if ($self->{sieStSystemLastErrorMessage} && $self->{sieStSystemLastErrorMessage} ne "<<not supported>>") {
    $info .= ', '.$self->{sieStSystemLastErrorMessage};
  }
  $self->add_info($info);
  if ($self->{sieStSystemStatusValue} eq "warning") {
    $self->add_warning();
  } elsif ($self->{sieStSystemStatusValue} eq "error") {
    $self->add_critical();
  } elsif ($self->{sieStSystemStatusValue} eq "unknown") {
    # ignore
  }
}


package Classes::Fujitsu::FscRaid::Components::RaidSubsystem::Controller;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "BBU %s status is %s",
      $self->{flat_indices},
      $self->{svrCtrlBBUStatus});
  if ($self->{svrCtrlBBUStatus} eq "failed") {
    $self->add_critical();
  } elsif ($self->{svrCtrlBBUStatus} =~ /(on Battery Low)|(discharging)/) {
    $self->add_warning();
  }
  $self->add_info(sprintf "Controller %s status is %s",
      $self->{flat_indices},
      $self->{svrCtrlStatus});
  if ($self->{svrCtrlStatus} eq "failed") {
    $self->add_critical();
  } elsif ($self->{svrCtrlStatus} eq "prefailure") {
    $self->add_warning();
  }
}


package Classes::Fujitsu::FscRaid::Components::RaidSubsystem::LogicalDrive;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "logical drive %s (%s) status is %s",
      $self->{flat_indices},
      $self->{svrLogicalDriveRaidLevelStr},
      $self->{svrLogicalDriveStatus});
  if ($self->{svrLogicalDriveStatus} =~ /(redundancy lost)|(drive no longer available)/) {
    $self->add_critical();
  } if ($self->{svrLogicalDriveStatus} =~ /(reduced redundancy still available)|(is currently being modified)|(currently being initialized)|(rebuilding)/) {
    $self->add_warning();
  }
  if ($self->{svrLogicalDriveStatus} =~ /rebuilding/) {
    $self->add_ok(sprintf "%s%%", $self->{svrLogicalDriveProgress});
  }
}


package Classes::Fujitsu::FscRaid::Components::RaidSubsystem::PhysicalDevice;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "physical drive %s s.m.a.r.t status is %s",
      $self->{flat_indices},
      $self->{svrPhysicalDeviceSmartStatus});
  if ($self->{svrPhysicalDeviceSmartStatus} =~ /(failure)/) {
    $self->add_warning();
  }
  $self->add_info(sprintf "physical drive %s (%s) status is %s",
      $self->{flat_indices},
      $self->{svrPhysicalDeviceType},
      $self->{svrPhysicalDeviceStatus});
  if ($self->{svrPhysicalDeviceStatus} =~ /(no longer working)|(non-working state)|(a failure has occured)|(not available or not responding)/) {
    $self->add_critical();
  } elsif ($self->{svrPhysicalDeviceStatus} =~ /(rebuilding)/) {
    $self->add_warning();
  }
  
}


