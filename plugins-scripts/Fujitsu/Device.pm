package Fujitsu::Device;
our @ISA = qw(GLPlugin::SNMP);

use strict;
use IO::File;
use File::Basename;
use Digest::MD5  qw(md5_hex);
use Errno;
use AutoLoader;
our $AUTOLOAD;

use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };


sub new {
  my $class = shift;
  my %params = @_;
  my $self = {
    productname => 'unknown',
  };
  bless $self, $class;
  if (! ($self->opts->hostname || $self->opts->snmpwalk)) {
    $self->add_message(UNKNOWN, 'either specify a hostname or a snmpwalk file');
  } else {
    $self->check_snmp_and_model();
    if (! $self->check_messages()) {
      if ($self->opts->verbose && $self->opts->verbose) {
        printf "I am a %s\n", $self->{productname};
      }
      if ($self->{productname} =~ /Fujitsu ServerView /) {
        bless $self, 'Fujitsu::ServerView';
        $self->debug('using Fujitsu::ServerView');
      } elsif ($self->implements_mib('SERVERVIEW-STATUS-MIB')) {
        bless $self, 'Fujitsu::ServerView';
        $self->debug('using Fujitsu::ServerView');
      } elsif ($self->get_snmp_object('SERVERVIEW-STATUS-MIB', 'sieStAgentId', 0)) {
        bless $self, 'Fujitsu::ServerView';
        $self->debug('using Fujitsu::ServerView');
      } else {
        if (my $class = $self->discover_suitable_class()) {
          bless $self, $class;
          $self->debug('using '.$class);
        } elsif ($self->mode =~ /device::uptime/) {
          bless $self, 'GLPlugin::SNMP';
        } else {
          $self->add_message(CRITICAL,
              sprintf('unknown device%s', $self->{productname} eq 'unknown' ?
                  '' : '('.$self->{productname}.')'));
        }
      }
    }
  }
  return $self;
}



