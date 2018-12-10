package Acme::GroundStation::Driver::AntennaVendor::Client;
use Mojo::Base 'Acme::GroundStation::Driver::AntennaVendor', -signatures;

has _client => sub ($self) {
  state $client = Mojo::IOLoop->client(
    $self->config => sub ($loop, $err, $stream) {

      # Capture the read bytes and trigger parsing
      $stream->on(
        read => sub { $self->{_buffer} .= $_[1]; $self->_parse_buffer; });
    }
  );
};

# The fields in the status packet
has _packed_fields => sub {
  $packed_fields = [
    qw {
      field1
      field2
      timestamp
      }
  ];
};


sub new {
  my $class = shift;
  my $self  = $class->SUPER::new(@_);
  $self->_client;
  return $self;
}

sub _parse_buffer($self) {
  my $buffer = $self->{_buffer};
  $self->{_buffer} = undef;

  # Sanity check to prevent a malicious server from use up all memory
  # Set to something sane
  if (length $buffer < 2048) {
    while ($buffer =~ s/\002(.*?)\003//msx) {
      my @unpacked = unpack("A[10]A[10]I", $1);
      my %status;
      @status{$self->packed_fields->@*} = @unpacked;
      $self->emit(status => \%status);
    }
    $self->{_buffer} = $buffer;
  }
  else {
    $self->emit(error => "Buffer too large, discarding");
  }
}

1;
