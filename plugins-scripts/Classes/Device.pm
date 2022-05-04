package Classes::Device;
our @ISA = qw(Monitoring::GLPlugin::SNMP);
use strict;

sub classify {
  my $self = shift;
  if (! ($self->opts->hostname || $self->opts->snmpwalk)) {
    $self->add_unknown('either specify a hostname or a snmpwalk file');
  } else {
    $self->check_snmp_and_model();
    if (! $self->check_messages()) {
      if ($self->opts->verbose && $self->opts->verbose) {
        printf "I am a %s\n", $self->{productname};
      }
      if ($self->implements_mib('MMB-COM-MIB')) {
        $self->rebless('Classes::Fujitsu::PRIMEQUEST');
      } elsif ($self->{sysobjectid} =~ /^\.*1\.3\.6\.1\.4\.1\.231\.1\.28\.1$/ ||
          $self->implements_mib("FSC-SERVERCONTROL2-MIB")) {
        $self->rebless('Classes::Fujitsu::iRMC');
      } elsif ($self->{productname} =~ /Fujitsu ServerView /) {
        $self->rebless('Classes::Fujitsu::ServerView');
      } elsif ($self->implements_mib('SERVERVIEW-STATUS-MIB')) {
        $self->rebless('Classes::Fujitsu::ServerView');
      } elsif ($self->get_snmp_object('SERVERVIEW-STATUS-MIB', 'sieStAgentId', 0)) {
        $self->rebless('Classes::Fujitsu::ServerView');
      } elsif ($self->implements_mib('FSC-RAID-MIB')) {
        $self->rebless('Classes::Fujitsu::FscRaid');
      } else {
        if (my $class = $self->discover_suitable_class()) {
          $self->rebless($class);
        } else {
          $self->rebless('Classes::Generic');
        }
      }
    }
  }
  return $self;
}


package Classes::Generic;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /something specific/) {
  } else {
    bless $self, 'Monitoring::GLPlugin::SNMP';
    $self->no_such_mode();
  }
}
