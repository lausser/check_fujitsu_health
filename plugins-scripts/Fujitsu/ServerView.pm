package Fujitsu::ServerView;

use strict;

use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

our @ISA = qw(Fujitsu::Device);

sub init {
  my $self = shift;
  $self->SUPER::init();
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_environmental_subsystem();
    $self->check_environmental_subsystem();
  } else {
    $self->no_such_mode();
  }
}

sub analyze_environmental_subsystem {
  my $self = shift;
  $self->{components}->{environmental_subsystem} = Fujitsu::ServerView::Components::EnvironmentalSubsystem->new();
}

sub dump {
  my $self = shift;
  printf "[GLOBAL]\n";
  foreach (qw(sieStSystemStatusValue sieStSystemLastErrorMessage)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  printf "info: %s\n", $self->{info};
  printf "\n";
}

