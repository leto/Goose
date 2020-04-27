package Command::Balance;
use feature 'say';

use Moo;
use strictures 2;

use namespace::clean;

use Exporter qw(import);
our @EXPORT_OK = qw(cmd_balance);

use Component::RPC;
use Redis;

has bot                 => ( is => 'ro' );
has discord             => ( is => 'lazy', builder => sub { shift->bot->discord } );
has log                 => ( is => 'lazy', builder => sub { shift->bot->log } );
has rpc                 => ( is => 'ro', default => sub { Component::RPC->new } );
has coin                => ( is => 'rw', default => 'HUSH' );
has redis               => ( is => 'ro', default => sub { Redis->new(reconnect=>2, every=>100_000 ) } );
has name                => ( is => 'ro', default => 'Tip' );
has access              => ( is => 'ro', default => 0 ); # 0 = Public, 1 = Bot-Owner Only
has description         => ( is => 'ro', default => 'Check Balance' );
has pattern             => ( is => 'ro', default => '^balance ?' );
has function            => ( is => 'ro', default => sub { \&cmd_balance } );
has usage               => ( is => 'ro', default => <<EOF
Check your wallet balance

Basic Usage: !balance
Advanced Usage: !balance coin
EOF
);

# We intend to support multiple coins but just HUSH for now
sub cmd_balance
{
    my ($self, $msg) = @_;
    my $channel      = $msg->{channel_id};
    my $author       = $msg->{author};
    my $args         = $msg->{content};
    # "$args" contains the command and the arguments the user typed.
    # Most of the time we'll want to strip the command out of $msg and just look at the arguments.
    # You can use $self->pattern to do this.
    my $pattern = $self->pattern;
    $args =~ s/$pattern//;
    # Data::Dumper is an easy way to dump any variable, including complex structures, to debug your command. 
    # You can send its output to the screen or to log files or both.
    $self->bot->log->debug('[Tip] [cmd_balance] ' . Data::Dumper->Dump([$msg], ['msg']));
    say Data::Dumper->Dump([$args], ['args']);

    # You know the channel the message came from and who sent it.
    # You can use that information to tailor your reply (eg, mention the user or not, look up other info on them, etc)
    my $reply = ( length $args ? "Your message was:\n```\n$args\n```" : "Your Discord ID is: " . $author->{'id'} );

    my $uid = $author->{id};

    # Look up discord uid to find it's zaddr, or make a new dedicated zaddr for
    # So we need a uid=>zaddr map
    # and then also a zaddr=>balance map, which redis autoexpires after X seconds
    # return cached balance or call z_getbalance 3 times with minconf=0,1,2
    # to get unconfirmed, confirmed and notarized balance
    # Redis key layout
    # "discord:$uid"       => $zaddr
    # "telegram:$uid"      => $zaddr # when we support TG
    # "unconfirmed:$zaddr" => $balance
    # "confirmed:$zaddr"   => $balance
    # "notarized:$zaddr"   => $balance

    my $coin        = $self->coin;
    my $balance     = $self->get_balance($uid);
    my $confirmed   = $balance->{confirmed};
    my $unconfirmed = $balance->{unconfirmed};
    $reply = "Your balance is: $confirmed $coin ($unconfirmed unconfirmed)";

    # Send a message back to the channel
    $self->discord->send_message($channel, $reply);
}

sub get_balance
{
    my ($self,$uid) = @_;

    my $rpc   = $self->rpc;
    my $zaddr;
    if ($zaddr = $self->redis->get("discord:$uid")) {
        say "Found $zaddr for $uid";
    } else {
        # this user has no zaddr, make one
        $zaddr = $rpc->new_zaddr();
        die "Unable to make new zaddr!" unless $zaddr;
        say "Created $zaddr for $uid";
        $self->redis->set( "discord:$uid" => $zaddr );
        $self->redis->set( "zaddr:$zaddr" => $uid );
    }

    return $self->rpc->balance($zaddr);
}

1;
