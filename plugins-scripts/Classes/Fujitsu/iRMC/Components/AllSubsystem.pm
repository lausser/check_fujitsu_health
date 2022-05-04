package Classes::Fujitsu::iRMC::Components::AllSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
foreach my $table (qw(sc2UnitsTable sc2ManagementProcessorTable sc2ManagedUpsNodeTable sc2ServerTable sc2PerformanceTable sc2TimerOnOffTable sc2PowerMonitoringTable sc2UtilizationHistoryTable sc2PowerSourceInformationTable sc2VirtualIoManagerTable sc2PerformanceValuesTable sc2TemperatureSensorsTable sc2FanTable sc2AirflowTable sc2SystemBoardTable sc2VoltageTable sc2CPUTable sc2MemoryModuleTable sc2ComponentPowerConsumptionTable sc2TrustedPlatformModuleTable sc2PersistentMemoryModulesTable sc2MessageLogTable sc2WatchdogTable sc2RecoverySettingTable sc2MessageTextLogTable sc2MessageLogActionHintTable sc2StatusComponentTable sc2ComponentStatusSensorTable sc2FirmwareVersionTable sc2DeployInfoTable sc2OemDeployInfoTable sc2DeployLanInterfacesTable sc2DriverMonitorComponentTable sc2DriverMonitorMessageTable)) {
  $self->get_snmp_tables('FSC-SERVERCONTROL2-MIB', [
    [$table, $table, "Monitoring::GLPlugin::SNMP::TableItem", sub { my $o = shift; $o->{TABLE} = $table; }],
  ]);
}
}



