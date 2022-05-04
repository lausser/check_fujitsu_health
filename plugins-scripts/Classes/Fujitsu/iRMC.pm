package Classes::Fujitsu::iRMC;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem('Classes::Fujitsu::iRMC::Components::MemSubsystem');
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_mem_subsystem('Classes::Fujitsu::iRMC::Components::CpuSubsystem');
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::Fujitsu::iRMC::Components::EnvironmentalSubsystem');
    $self->reduce_messages_short("hardware working fine");
  } else {
    $self->no_such_mode();
  }
}

