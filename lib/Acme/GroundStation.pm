package Acme::GroundStation;
use Mojo::Base 'Mojolicious', -signatures;
use Acme::GroundStation::Driver::AntennaVendor::Server;
use Acme::GroundStation::Driver::AntennaVendor::Client;

has simulator => sub ($app) {
  state $server = Acme::GroundStation::Driver::AntennaVendor::Server->new(
    $app->config->{simulator});
  $server;
};

has client => sub ($app) {
  state $client = Acme::GroundStation::Driver::AntennaVendor::Client->new(
    $app->config->{client});
  $client;
};


# This method will run once at server start
sub startup {

  # -- boilerplate starts --

  my $self = shift;

  # Load configuration from hash returned by config file
  my $config = $self->plugin('Config');

  # Configure the application
  $self->secrets($config->{secrets});

  # -- boilerplate ends --

  # has is lazy, so call them here to start them
  $self->app->simulator if exists($config->{simulator});
  $self->app->client;

  $self->app->client->on(
    status => sub ($client, $status) {
      use DDP; p $status;
    }
  );

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
}

1;
