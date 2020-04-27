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
    my $recipients = [];
    push @$recipients, {
        address => $to,
        amount  => $amount,
        memo    => $memo,
    };
    $self->rpc->z_sendmany($from,$recipients);
}

# returns the balances of a zaddr: unconfirmed (confs=0), confirmed (confs=1) and notarized (confs=2)
sub balance
{
    my $self = shift;
    my ($z)  = @_;
    my $rpc         = $self->rpc;
    my $unconfirmed = $rpc->z_gettotalbalance($z,0);
    my $confirmed   = $rpc->z_gettotalbalance($z,1);
    my $notarized   = $rpc->z_gettotalbalance($z,2);

    return {
        unconfirmed => $unconfirmed,
        confirmed   => $confirmed,
        notarized   => $notarized,
    };
}

__PACKAGE__->meta->make_immutable;

1;
