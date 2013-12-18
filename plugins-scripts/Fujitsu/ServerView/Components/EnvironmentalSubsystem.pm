package Fujitsu::ServerView::Components::EnvironmentalSubsystem;
our @ISA = qw(Fujitsu::ServerView);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub new {
  my $class = shift;
  my %params = @_;
  my $self = {
    blacklisted => 0,
    info => undef,
    extendedinfo => undef,
    subsystems => [],
  };
  bless $self, $class;
  $self->init(%params);
  return $self;
}

sub init {
  my $self = shift;
  $self->{sieStSystemStatusValue} = $self->get_snmp_object('SERVERVIEW-STATUS-MIB', 'sieStSystemStatusValue', 0);
  $self->{sieStSystemLastErrorMessage} = $self->get_snmp_object('SERVERVIEW-STATUS-MIB', 'sieStSystemLastErrorMessage', 0);
  foreach ($self->get_snmp_table_objects('SERVERVIEW-STATUS-MIB', 'sieStSubsystemTable')) {
    push(@{$self->{subsystems}}, Fujitsu::ServerView::Components::Subsystem->new(%{$_})) if $self->filter_name($_->{sieStSubsystemName});
  }
  foreach ($self->get_snmp_table_objects('SERVERVIEW-STATUS-MIB', 'sieStComponentTable')) {
    my $component = Fujitsu::ServerView::Components::SubsystemComponent->new(%{$_});
    foreach my $subsystem (@{$self->{subsystems}}) {
      foreach my $comp (split(/\s+/, $subsystem->{sieStSubsystemComponents})) {
        if ($component->{sieStComponentName} eq $comp) {
          push(@{$subsystem->{components}}, $component);
        }
      }
    }
  }
}

sub check {
  my $self = shift;
  my $info = sprintf 'global system status is %s', $self->{sieStSystemStatusValue};
  $self->add_info($info);
  if ($self->{sieStSystemLastErrorMessage} && $self->{sieStSystemLastErrorMessage} ne "<<not supported>>") {
    $info .= ', '.$self->{sieStSystemLastErrorMessage};
  }
  if ($self->{sieStSystemStatusValue} eq "warning") {
    $self->add_message(WARNING, $info);
  } elsif ($self->{sieStSystemStatusValue} eq "error") {
    $self->add_message(CRITICAL, $info);
  } elsif ($self->{sieStSystemStatusValue} eq "unknown") {
    # ignore
  }
  foreach (@{$self->{subsystems}}) {
    $_->check();
  }
  if (! $self->check_messages()) {
    $self->add_message(OK, "hardware working fine");
  }
}

sub dump {
  my $self = shift;
  printf "[GLOBAL]\n";
  foreach (qw(sieStSystemStatusValue sieStSystemLastErrorMessage)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  printf "info: %s\n", $self->{info};
  foreach (@{$self->{subsystems}}) {
    $_->dump();
  }
}


package Fujitsu::ServerView::Components::Subsystem;
our @ISA = qw(Fujitsu::ServerView::Components::EnvironmentalSubsystem);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub new {
  my $class = shift;
  my %params = @_;
  my $self = {
    blacklisted => 0,
    info => undef,
    extendedinfo => undef,
    components => [],
  };
  foreach (qw(sieStSubsystemNumber sieStSubsystemName sieStSubsystemStatusValue 
      sieStSubsystemLastErrorMessage sieStSubsystemComponents sieStSubsystemDisplayName)) {
    $self->{$_} = $params{$_};
  }
  bless $self, $class;
  return $self;
}

sub check {
  my $self = shift;
  $self->blacklist('sub', $self->{sieStSubsystemName});
  $self->add_info(sprintf 'checking subsystem %s', $self->{sieStSubsystemName});
  my $info = sprintf 'subsys %s status is %s', $self->{sieStSubsystemName}, $self->{sieStSubsystemStatusValue};
  $self->add_info($info);
  if ($self->{sieStSubsystemLastErrorMessage} && $self->{sieStSubsystemLastErrorMessage} ne "<<not supported>>") {
    $info .= ', '.$self->{sieStSubsystemLastErrorMessage};
  }
  if ($self->{sieStSubsystemStatusValue} eq "warning") {
    $self->add_message(WARNING, $info);
  } elsif ($self->{sieStSubsystemStatusValue} eq "error") {
    $self->add_message(CRITICAL, $info);
  } elsif ($self->{sieStSubsystemStatusValue} eq "unknown") {
    # DESCRIPTION "Subsystem status value:
    # unknown(5):  none of the components had a valid status (e.g. during initialization);
    #              this status can be ignored
  }
  foreach (@{$self->{components}}) {
    $_->check();
  }
}

sub dump {
  my $self = shift;
  printf "[SUBSYSTEM_%s]\n", $self->{sieStSubsystemName};
  foreach (qw(sieStSubsystemNumber sieStSubsystemName sieStSubsystemStatusValue 
      sieStSubsystemLastErrorMessage sieStSubsystemComponents sieStSubsystemDisplayName)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  printf "info: %s\n", $self->{info};
  foreach (@{$self->{components}}) {
    $_->dump();
  }
}


package Fujitsu::ServerView::Components::SubsystemComponent;
our @ISA = qw(Fujitsu::ServerView::Components::EnvironmentalSubsystem);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub new {
  my $class = shift;
  my %params = @_;
  my $self = {
    blacklisted => 0,
    info => undef,
    extendedinfo => undef,
  };
  foreach (qw(sieStComponentNumber sieStComponentName sieStComponentStatusValue
      sieStComponentLastErrorMessage sieStComponentConfirmFailure sieStComponentDisplayName)) {
    $self->{$_} = $params{$_};
  }
  $self->{sieStComponentDisplayName} ||= $self->{sieStComponentName};
  bless $self, $class;
  return $self;
}

sub check {
  my $self = shift;
  $self->blacklist('com', $self->{sieStComponentDisplayName});
  my $info = sprintf 'component %s status is %s', $self->{sieStComponentDisplayName}, $self->{sieStComponentStatusValue};
  $self->add_info($info);
  if ($self->{sieStComponentLastErrorMessage} && $self->{sieStComponentLastErrorMessage} ne "<<not supported>>") {
    $info .= ', '.$self->{sieStComponentLastErrorMessage};
  }
  if ($self->{sieStComponentStatusValue} eq "warning") {
    $self->add_message(WARNING, $info);
  } elsif ($self->{sieStComponentStatusValue} eq "error") {
    $self->add_message(CRITICAL, $info);
  } elsif ($self->{sieStComponentStatusValue} eq "unknown") {
  # can be ignored
  }
}

sub dump {
  my $self = shift;
  printf "[COMPONENT_%s]\n", $self->{sieStComponentName};
  foreach (qw(sieStComponentNumber sieStComponentName sieStComponentStatusValue
      sieStComponentLastErrorMessage sieStComponentConfirmFailure sieStComponentDisplayName)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  printf "info: %s\n", $self->{info};
}

