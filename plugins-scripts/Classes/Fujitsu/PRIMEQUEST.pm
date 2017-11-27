package Classes::Fujitsu::PRIMEQUEST;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem');
  } else {
    $self->no_such_mode();
  }
}

sub pretty_sysdesc {
  my ($self) = @_;
  $self->get_snmp_objects('MMB-COM-MIB', qw(agentId agentCompany agentVersion
    localServerUnitId numberUnits  unitTableUpdateCount
    agentStatus
  ));
  $self->get_snmp_tables('MMB-COM-MIB', [
      ['units', 'unitTable', 'Monitoring::GLPlugin::SNMP::TableItem', undef, ['unitModelName', 'unitClass']],
      ['mmps', 'managementProcessorTable', 'Monitoring::GLPlugin::SNMP::TableItem', undef, ['spUnitId', 'spFirmwareVersion']],
  ]);
  my $infos = {};
  foreach my $unit (@{$self->{units}}) {
    if ($unit->{unitClass} eq "chassis") {
      $infos->{chassis_model} = $unit->{unitModelName};
      $infos->{chassis_index} = $unit->{flat_indices};
    } elsif ($unit->{unitClass} eq "mmb") {
      $infos->{mmb_model} = $unit->{unitModelName};
      $infos->{mmb_index} = $unit->{flat_indices};
    }
  }
  foreach my $mmp (@{$self->{mmps}}) {
    if ($mmp->{spUnitId} == $infos->{mmb_index}) {
      $infos->{mmb_firmware} = $mmp->{spFirmwareVersion};
    }
  }
  return sprintf "%s@%s (FW: %s)", $infos->{mmb_model},
      $infos->{chassis_model}, $infos->{mmb_firmware};
}

__END__
MMB-COM-MIB::unitClass.1 = chassis
MMB-COM-MIB::unitClass.136 = mmb
MMB-COM-MIB::unitClass.19 = sb
MMB-COM-MIB::unitClass.20 = sb
MMB-COM-MIB::unitClass.21 = sb
MMB-COM-MIB::unitClass.22 = sb
MMB-COM-MIB::unitClass.43 = iou
MMB-COM-MIB::unitClass.44 = iou
MMB-COM-MIB::unitClass.45 = iou
MMB-COM-MIB::unitClass.46 = iou

MMB-COM-MIB::unitDesignation.1 = MCH3AC111B
MMB-COM-MIB::unitDesignation.136 = MMB

MMB-COM-MIB::unitModelName.1 = PRIMEQUEST 2800B3
MMB-COM-MIB::unitModelName.19 = D3751
MMB-COM-MIB::unitModelName.20 = D3751
MMB-COM-MIB::unitModelName.21 = D3751
MMB-COM-MIB::unitModelName.22 = D3751
MMB-COM-MIB::unitModelName.43 = IOUL
MMB-COM-MIB::unitModelName.44 = IOUL
MMB-COM-MIB::unitModelName.136 = MMBU
MMB-COM-MIB::unitModelName.166 = D2714

MMB-COM-MIB::managementProcessorTable
MMB-COM-MIB::spUnitId.136.1 = 136
MMB-COM-MIB::spProcessorNr.136.1 = 1
MMB-COM-MIB::spModelName.136.1 = MMB
MMB-COM-MIB::spFirmwareVersion.136.1 = 30.44

