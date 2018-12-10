# Base class
package Acme::GroundStation::Driver::AntennaVendor;
use Mojo::Base 'Mojo::EventEmitter', -signatures;

has config => sub { die qw{ "config" is a required attribute to new()} };
has ioloop => sub { Mojo::IOLoop->singleton };

1;