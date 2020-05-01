package Component::Redis;

use feature 'say';
use Moo;

use Mojo::UserAgent;
use Mojo::AsyncAwait;
use Data::Dumper;
use namespace::clean;
use Bitcoin::RPC::Client;

use Exporter qw(import);
our @EXPORT_OK = qw();

has username    => ( is => 'rw', default => 'hush' );
has password    => ( is => 'rw', default => 'hush' );
has port        => ( is => 'rw', default => 18031  );
has host        => ( is => 'rw', default => 'localhost' );
has ua          => ( is => 'rw', default => sub { Mojo::UserAgent->new } );
has redis       => ( is => 'ro', default => sub { Redis->new(reconnect=>2, every=>100_000) };
has rpc         => ( is => 'rw', lazy => 1 };


sub BUILD
{
    my $self = shift;
    $self->redis = Redis->new(reconnect=>2, every=>100_000);
    say $self->rpc->getinfo;
}

sub get_or_create_zaddr_for_discord_user
{
    my $self   = shift;
    my ($user) = @_;
    my $key    = "discord:$user";
    my $zaddr;
    if ($zaddr = $self->redis->get($key)) {
        say "Found $zaddr for $user";
    } else {
        # that discord user has no zaddr, make one
        $zaddr = $self->rpc->new_zaddr();
        die "Unable to make new zaddr for $user!" unless $zaddr;
        say "Created $zaddr for $user";
    }
    return $zaddr;
}

__PACKAGE__->meta->make_immutable;

1;
