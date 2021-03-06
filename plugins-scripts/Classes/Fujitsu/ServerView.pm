package Classes::Fujitsu::ServerView;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::Fujitsu::ServerView::Components::EnvironmentalSubsystem');
    if ($self->implements_mib('FSC-RAID-MIB')) {
      $self->analyze_and_check_environmental_subsystem('Classes::Fujitsu::FscRaid::Components::RaidSubsystem');
    }
  } else {
    $self->no_such_mode();
  }
}

