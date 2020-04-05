package Component::RPC;

use feature 'say';
use Moo;

use Mojo::UserAgent;
use Mojo::AsyncAwait;
use Data::Dumper;
use namespace::clean;
use Bitcoin::RPC::Client;

use Exporter qw(import);
our @EXPORT_OK = qw(weather);

has username    => ( is => 'rw', default => 'hush' );
has password    => ( is => 'rw', default => 'hush' );
has port        => ( is => 'rw', default => 18031  );
has host        => ( is => 'rw', default => 'localhost' );
has ua          => ( is => 'rw', default => sub { Mojo::UserAgent->new } );
has rpc         => ( is => 'rw', lazy => 1 };


sub BUILD
{
    my $self = shift;
   
    $self->ua->connect_timeout(5);
    $self->ua->inactivity_timeout(120);
    $self->rpc = Bitcoin::RPC::Client->new(
                                port     => $self->port,
                                host     => $self->host,
                                user     => $self->username,
                                password => $self->password,
                                debug    => $self->debug,
                            );

    say $self->rpc->getinfo;
}

sub new_zaddr
{
    my $self = shift;
    return $self->rpc->z_getnewaddress();
}

sub send
{
    my $self = shift;
    my ($from,$to,$amount,$memo) = @_;
    # TODO: do this correctly
    $self->rpc->z_sendmany($from,$to,$amount,$memo);
}

sub balance
{
    my $self = shift;
    my ($zaddr) = @_;
    # TODO: support unconfirmed, confirmed, notarized

    return (0,0,0);
}



__PACKAGE__->meta->make_immutable;

1;
