package Acme::GroundStation::Driver::AntennaVendor::Server;
use Mojo::Base 'Acme::GroundStation::Driver::AntennaVendor', -signatures;

has _server => sub ($self) {
  state $server = Mojo::IOLoop->server(
    $self->config => sub ($loop, $stream, $id) {

      # For each client connected we print a
      # simple binary stream of data, every second
      my $write_loop = Mojo::IOLoop->recurring(
        1 => sub {

          # We often deal with structs, and this is
          # a simple example with some ASCII and an integer
          $stream->write(
            chr(2) . pack("a[10]a[10]I", ("mojo", "advent", time())) . chr(3));
        }
      );

      # When connection closes for whatever reason
      # make sure the loop above is halted
      $stream->on(close => sub { Mojo::IOLoop->remove($write_loop) });
    }
  );
  return $server;
};

sub new {
  my $class = shift;
  my $self  = $class->SUPER::new(@_); # Inherit the constructor
  $self->_server;    # Lazy loaded so we need to force it
  return $self;
}

1;
