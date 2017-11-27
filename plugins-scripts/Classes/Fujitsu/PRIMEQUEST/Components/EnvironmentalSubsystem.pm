package Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects('MMB-COM-MIB', qw(agentId agentCompany agentVersion 
      localServerUnitId numberUnits  unitTableUpdateCount
      agentStatus 
  ));
  $self->get_snmp_tables('MMB-COM-MIB', [
      #['units', 'unitTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['unitparents', 'unitParentTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['unitchilds', 'unitChildTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['managementnodes', 'managementNodeTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      ['managementprocessors', 'managementProcessorTable', 'Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::ManagementProcessor'],
      ##['ups', 'managedUpsNodeTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['servers', 'serverTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['poweronoffs', 'unitPowerOnOffTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['performances', 'performanceTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['powermonitorings', 'powerMonitoringTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['powersources', 'powerSourceInformationTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      ['temperatures', 'temperatureSensorTable', 'Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Temperature'],
      ['fans', 'fanTable', 'Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Fan'],
      ##['airflows', 'airflowTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['systemboards', 'systemBoardTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      ['powersupplies', 'powerSupplyTable', 'Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::PowerSupply'],
      ['voltages', 'voltageTable', 'Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Voltage'],
      ['cpus', 'cpuTable', 'Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Cpu'],
      ['memorymodules', 'memoryModuleTable', 'Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::MemoryModule'],
      #['componentpowerconsumptions', 'componentPowerConsumptionTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['logs', 'messageLogTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['msgtexts', 'messageTextLogTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      ['componentstatus', 'statusComponentTable', 'Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Component'],
      #['componentsensors', 'componentStatusSensorTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['firmwares', 'firmwareVersionTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['deploys', 'deployInfoTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['oemdeploys', 'oemDeployInfoTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['landeploys', 'deployLanInterfaceTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
      #['msgtexts', 'messageTextLogTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
  ]);
  foreach my $key (keys %{$self}) {
    if (ref($self->{$key}) eq "ARRAY") {
      foreach my $item (@{$self->{$key}}) {
        $item->{origin} = $key;
      }
    }
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'agent status is %s', $self->{agentStatus});
  if ($self->{agentStatus} eq "degraded") {
    $self->add_warning();
  } elsif ($self->{agentStatus} eq "error") {
    $self->add_critical();
  } elsif ($self->{agentStatus} eq "failed") {
    $self->add_critical();
  } elsif ($self->{agentStatus} eq "unknown") {
    $self->add_unknown();
  } else {
    $self->add_ok();
  }
  $self->SUPER::check();
  if (! $self->check_messages()) {
    $self->add_ok('hardware working fine');
  }
}


package Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::ManagementProcessor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  # batteryzeugs
  $self->add_info(
      sprintf 'service processor %s at unit %s battery status is %s',
      $self->{spProcessorNr}, $self->{spUnitId}, $self->{spBatteryStatus});
  if ($self->{spBatteryStatus} eq "not-present") {
  } elsif ($self->{spBatteryStatus} eq "ok" ||
      $self->{spBatteryStatus} eq "recharging" ||
      $self->{spBatteryStatus} eq "on-battery") { # oder warning?
    $self->add_ok();
  } elsif ($self->{spBatteryStatus} eq "discharging") {
    $self->add_warning();
  } elsif ($self->{spBatteryStatus} eq "failed") {
    $self->add_critical();
  } else {
    $self->add_unknown();
  }
}


package Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Temperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'temperature %s is %s',
      $self->{tempSensorDesignation}, $self->{tempSensorStatus});
  if ($self->{tempSensorStatus} eq "ok" ||
      $self->{tempSensorStatus} eq "not-available") {
    $self->add_ok();
  } elsif ($self->{tempSensorStatus} eq "temperature-warning") {
    $self->add_warning();
  } elsif ($self->{tempSensorStatus} eq "temperature-critical" ||
      $self->{tempSensorStatus} eq "failed") {
    $self->add_critical();
  } else {
    $self->add_unknown();
  }
  $self->add_perfdata(
    label => 'temp_'.$self->{tempSensorDesignation},
    value => $self->{tempCurrentTemperature},
    warning => $self->{tempWarningLevel},
    critical => $self->{tempCriticalLevel},
  );
}


package Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Fan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'fan %s status is %s',
      $self->{fanDesignation}, $self->{fanStatus});
  if ($self->{fanStatus} eq "not-present") {
  } elsif ($self->{fanStatus} eq "ok" ||
      $self->{fanStatus} eq "not-manageable" || # koennte auch ein error sein
      $self->{fanStatus} eq "disabled") {
    $self->add_ok();
  } elsif ($self->{fanStatus} eq "prefailed-predicted" ||
      $self->{fanStatus} eq "redundant-fan-failed") {
    $self->add_warning();
  } elsif ($self->{fanStatus} eq "failed") {
    $self->add_critical();
  } else {
    $self->add_unknown();
  }
}


package Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::PowerSupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'ps %s status is %s',
      $self->{powerSupplyDesignation}, $self->{powerSupplyStatus});
  if ($self->{powerSupplyStatus} eq "not-present") {
  } elsif ($self->{powerSupplyStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{powerSupplyStatus} eq "predictive-fail" ||
      $self->{powerSupplyStatus} eq "ac-fail" ||
      $self->{powerSupplyStatus} eq "critical-temperature") {
    $self->add_warning();
  } elsif ($self->{powerSupplyStatus} eq "failed" ||
      $self->{powerSupplyStatus} eq "not-manageable" ||
      $self->{powerSupplyStatus} eq "dc-fail") {
    $self->add_critical();
  } else {
    $self->add_unknown();
  }
}


package Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Voltage;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'voltage %s status is %s',
      $self->{voltageDesignation}, $self->{voltageStatus});
  if ($self->{voltageStatus} eq "not-available") {
  } elsif ($self->{voltageStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{voltageStatus} eq "low-warning" ||
      $self->{voltageStatus} eq "high-warning") {
    $self->add_warning();
  } elsif ($self->{voltageStatus} eq "too-low" ||
      $self->{voltageStatus} eq "too-high" ||
      $self->{voltageStatus} eq "sensor-failed") {
    $self->add_critical();
  } else {
    $self->add_unknown();
  }
}


package Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Cpu;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'cpu %s status is %s',
      $self->{cpuDesignation}, $self->{cpuStatus});
  if ($self->{cpuStatus} eq "not-present") {
  } elsif ($self->{cpuStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{cpuStatus} eq "disabled" ||
      $self->{cpuStatus} eq "prefailed-warning" ||
      $self->{cpuStatus} eq "missing-termination") {
    $self->add_warning();
  } elsif ($self->{cpuStatus} eq "error" ||
      $self->{cpuStatus} eq "failed") {
    $self->add_critical();
  } else {
    $self->add_unknown();
  }
}


package Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::MemoryModule;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'memModule %s status is %s',
      $self->{memModuleDesignation}, $self->{memModuleStatus});
  if ($self->{memModuleStatus} eq "not-present") {
  } elsif ($self->{memModuleStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{memModuleStatus} eq "failed-disabled" ||
      $self->{memModuleStatus} eq "warning" ||
      $self->{memModuleStatus} eq "hot-spare") {
    $self->add_warning();
  } elsif ($self->{memModuleStatus} eq "error" ||
      $self->{memModuleStatus} eq "configuration-error") {
    $self->add_critical();
  } else {
    $self->add_unknown();
  }
}


package Classes::Fujitsu::PRIMEQUEST::Components::EnvironmentalSubsystem::Component;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf '%s component status is %s',
      $self->{csType}, $self->{componentStatusValue});
  if ($self->{componentStatusValue} eq "ok") {
    $self->add_ok();
  } elsif ($self->{componentStatusValue} eq "failed" ||
      $self->{componentStatusValue} eq "degraded") {
    $self->add_warning();
  } elsif ($self->{componentStatusValue} eq "error") {
    $self->add_critical();
  } else {
    $self->add_unknown();
  }
}


