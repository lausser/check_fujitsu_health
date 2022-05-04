package Classes::Fujitsu::iRMC::Components::CpuSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('FSC-SERVERCONTROL2-MIB', [
    ["cpus", "sc2PerformanceTable", "Classes::Fujitsu::iRMC::Components::CpuSubsystem::Cpu", sub { my $o = shift; return $o->{sc2PerformanceType} eq "cpu-overall" ? 1 : 0; }],
  ]);
}


package Classes::Fujitsu::iRMC::Components::CpuSubsystem::Cpu;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "%s is %s%%", $self->{sc2PerformanceName},
      $self->{sc2PerformanceValue});
  $self->set_thresholds(metric => "cpu_usage",
      warning => 85, critical => 95,
  );
  $self->add_message($self->check_thresholds(metric => "cpu_usage",
      value => $self->{sc2PerformanceValue}
  ));
  $self->add_perfdata(label => "cpu_usage",
      value => $self->{sc2PerformanceValue},
      uom => "%",
  );
}

