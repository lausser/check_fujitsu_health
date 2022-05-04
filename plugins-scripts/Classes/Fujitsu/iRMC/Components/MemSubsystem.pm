package Classes::Fujitsu::iRMC::Components::MemSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('FSC-SERVERCONTROL2-MIB', [
    ["memories", "sc2PerformanceTable", "Classes::Fujitsu::iRMC::Components::MemSubsystem::Mem", sub { my $o = shift; return $o->{sc2PerformanceType} eq "memory-percent" ? 1 : 0; }],
    ["memories", "sc2PerformanceTable", "Classes::Fujitsu::iRMC::Components::MemSubsystem::Mem", sub { my $o = shift; return $o->{sc2PerformanceType} eq "memory-percent" ? 1 : 0; }],
  ]);
}


package Classes::Fujitsu::iRMC::Components::MemSubsystem::Mem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "Physical memory usage is %s%%",
      # $self->{sc2PerformanceName}, = "Physical memory (%)"
      $self->{sc2PerformanceValue});
  $self->set_thresholds(metric => "memory_usage",
      warning => 85, critical => 95,
  );
  $self->add_message($self->check_thresholds(metric => "memory_usage",
      value => $self->{sc2PerformanceValue}
  ));
  $self->add_perfdata(label => "memory_usage",
      value => $self->{sc2PerformanceValue},
      uom => "%",
  );
}

