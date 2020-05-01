package Command::Withdraw;
use feature 'say';

use Moo;
use strictures 2;

use namespace::clean;

use Exporter qw(import);
our @EXPORT_OK = qw(cmd_withdraw);

use Component::RPC;
use Redis;

has bot                 => ( is => 'ro' );
has discord             => ( is => 'lazy', builder => sub { shift->bot->discord } );
has log                 => ( is => 'lazy', builder => sub { shift->bot->log } );
has rpc                 => ( is => 'ro', default => sub { Component::RPC->new } );
has name                => ( is => 'ro', default => 'Tip' );
has coin                => ( is => 'rw', default => 'HUSH' );
has redis               => ( is => 'ro', default => sub { Redis->new(reconnect=>2, every=>100_000 ) } );
has access              => ( is => 'ro', default => 0 ); # 0 = Public, 1 = Bot-Owner Only
has description         => ( is => 'ro', default => 'Withdraw Funds' );
has pattern             => ( is => 'ro', default => '^withdraw ?' );
has function            => ( is => 'ro', default => sub { \&cmd_withdraw } );
has usage               => ( is => 'ro', default => <<EOF
Withdraw funds to a zaddr

Basic Usage: !withdraw zaddr amount
Advanced Usage: !withdraw zaddr amount "Some comment"
EOF
);

sub cmd_withdraw
{
    my ($self, $msg) = @_;

    my $channel = $msg->{channel_id};
    my $author  = $msg->{author};
    my $args    = $msg->{content};
    my $pattern = $self->pattern;
    $args       =~ s/$pattern//;
    
    $self->bot->log->debug('[Tip] [cmd_withdraw] ' . Data::Dumper->Dump([$msg], ['msg']));
    say Data::Dumper->Dump([$args], ['args']);

    my $rpc = $self->rpc;
    my $opid;

    # HUSH is the default currency unless specified
    # TODO: lock down this regex to only required inputs
    if($args =~ m/(^[^ ]+) ([^ ]+) ([^ ]+)?$/) {
        my $zaddr  = $1;
        my $amount = $2;
        my $memo   = $3 || '';
        my $from   = $self->redis->get_or_create_zaddr_for_discord_user($author);
        $opid = $self->send_tip($from,$zaddr,$amount,$memo);
    } else {
        $opid = "INVALID";
    }

    # You know the channel the message came from and who sent it.
    # You can use that information to tailor your reply (eg, mention the user or not, look up other info on them, etc)
    my $reply = ( length $args ? "Your message was:\n```\n$args\n```" : "Your Discord ID is: " . $author->{'id'} );
    $opid .= "\nopid=$opid";

    # Send a message back to the channel
    $self->discord->send_message($channel, $reply);
}

1;
