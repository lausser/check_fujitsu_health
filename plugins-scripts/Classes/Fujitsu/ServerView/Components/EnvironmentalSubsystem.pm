package Classes::Fujitsu::ServerView::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->mult_snmp_max_msg_size(2);
  $self->get_snmp_objects('SERVERVIEW-STATUS-MIB', qw(sieStSystemStatusValue sieStSystemLastErrorMessage));
  $self->get_snmp_tables('SERVERVIEW-STATUS-MIB', [
      ['subsystems', 'sieStSubsystemTable', 'Classes::Fujitsu::ServerView::Components::Subsystem', sub { my $o = shift; $self->filter_name($o->{sieStSubsystemName})}],
      ['components', 'sieStComponentTable', 'Classes::Fujitsu::ServerView::Components::SubsystemComponent'],
  ]);
  foreach my $component (@{$self->{components}}) {
    foreach my $subsystem (@{$self->{subsystems}}) {
      foreach my $comp (split(/\s+/, $subsystem->{sieStSubsystemComponents})) {
        if ($component->{sieStComponentName} eq $comp) {
          push(@{$subsystem->{components}}, $component);
        }
      }
    }
  }
  delete $self->{components};
}

sub check {
  my $self = shift;
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
  foreach (@{$self->{subsystems}}) {
    $_->check();
  }
  if (! $self->check_messages()) {
    $self->add_ok('hardware working fine');
  }
}


package Classes::Fujitsu::ServerView::Components::Subsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'checking subsystem %s', $self->{sieStSubsystemName});
  my $info = sprintf 'subsys %s status is %s', $self->{sieStSubsystemName}, $self->{sieStSubsystemStatusValue};
  if ($self->{sieStSubsystemLastErrorMessage} && $self->{sieStSubsystemLastErrorMessage} ne "<<not supported>>") {
    $info .= ', '.$self->{sieStSubsystemLastErrorMessage};
  }
  $self->add_info($info);
  if ($self->{sieStSubsystemStatusValue} eq "warning") {
    $self->add_warning();
  } elsif ($self->{sieStSubsystemStatusValue} eq "error") {
    $self->add_critical();
  } elsif ($self->{sieStSubsystemStatusValue} eq "unknown") {
    # DESCRIPTION "Subsystem status value:
    # unknown(5):  none of the components had a valid status (e.g. during initialization);
    #              this status can be ignored
  }
  foreach (@{$self->{components}}) {
    $_->check();
  }
}


package Classes::Fujitsu::ServerView::Components::SubsystemComponent;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  my $info = sprintf 'component %s status is %s', $self->{sieStComponentDisplayName}, $self->{sieStComponentStatusValue};
  if ($self->{sieStComponentLastErrorMessage} && $self->{sieStComponentLastErrorMessage} ne "<<not supported>>") {
    $info .= ', '.$self->{sieStComponentLastErrorMessage};
  }
  $self->add_info($info);
  if ($self->{sieStComponentStatusValue} eq "warning") {
    $self->add_warning();
  } elsif ($self->{sieStComponentStatusValue} eq "error") {
    $self->add_critical();
  } elsif ($self->{sieStComponentStatusValue} eq "unknown") {
  # can be ignored
  }
}


