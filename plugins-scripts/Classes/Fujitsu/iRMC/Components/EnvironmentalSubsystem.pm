package Classes::Fujitsu::iRMC::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->init_subsystems([
      #["all_subsystem", "Classes::Fujitsu::iRMC::Components::AllSubsystem"],
      ["power_subsystem", "Classes::Fujitsu::iRMC::Components::PowersupplySubsystem"],
      ["fan_subsystem", "Classes::Fujitsu::iRMC::Components::FanSubsystem"],
      ["temperature_subsystem", "Classes::Fujitsu::iRMC::Components::TemperatureSubsystem"],
      ["memory_subsystem", "Classes::Fujitsu::iRMC::Components::HWMemSubsystem"],
      ["cpu_subsystem", "Classes::Fujitsu::iRMC::Components::HWCpuSubsystem"],
  ]);
  if (! $self->opts->subsystem() || $self->opts->subsystem() eq "raid_subsystem") {
    if ($self->implements_mib('FSC-RAID-MIB')) {
      $self->analyze_and_check_environmental_subsystem('Classes::Fujitsu::FscRaid::Components::RaidSubsystem');
    } else {
      $self->add_unknown("FSC-RAID-MIB not implemented");
    }
  }
}



sub check {
  my ($self) = @_;
  $self->check_subsystems();
}

sub dump {
  my ($self) = @_;
  $self->dump_subsystems();
  $self->SUPER::dump();
}

__END__
#  sc2UnitsTable
#  sc2ManagementProcessorTable
#  sc2ManagedUpsNodeTable
#  sc2ServerTable
# PowersupplySubsystem sc2UnitPowerOnOffTable
# CpuSubsystem sc2PerformanceTable
#  sc2TimerOnOffTable
#  sc2PowerMonitoringTable
#  sc2UtilizationHistoryTable
#  sc2PowerSourceInformationTable
#  sc2VirtualIoManagerTable
# PowersupplySubsystem sc2PowerSupplyRedundancyConfigurationTable
#  sc2PerformanceValuesTable
# TemperatureSubsystem sc2TemperatureSensorsTable
# FanSubsystem sc2AirflowTable
#  sc2SystemBoardTable
# PowersupplySubsystem sc2PowerSupplyTable
#  sc2VoltageTable
#  sc2CPUTable nur speed, size, stepping
#  sc2MemoryModuleTable
#  sc2ComponentPowerConsumptionTable
#  sc2TrustedPlatformModuleTable
#  sc2PersistentMemoryModulesTable
#  sc2MessageLogTable
#  sc2WatchdogTable
#  sc2RecoverySettingTable
#  sc2MessageTextLogTable, nur info fuer temps
#  sc2MessageLogActionHintTable
# TemperatureSubsystem sc2StatusComponentTable, enthealt global temp
#  sc2ComponentStatusSensorTable
#  sc2FirmwareVersionTable
#  sc2DeployInfoTable
#  sc2OemDeployInfoTable
#  sc2DeployLanInterfacesTable
#  sc2DriverMonitorComponentTable
#  sc2DriverMonitorMessageTable
# FanSubsystem sc2FanTable

