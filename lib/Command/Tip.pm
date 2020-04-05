package Command::Tip;
use feature 'say';

use Moo;
use strictures 2;

use namespace::clean;

use Exporter qw(import);
our @EXPORT_OK = qw(cmd_tip);

use Component::RPC;

has bot                 => ( is => 'ro' );
has discord             => ( is => 'lazy', builder => sub { shift->bot->discord } );
has log                 => ( is => 'lazy', builder => sub { shift->bot->log } );

has name                => ( is => 'ro', default => 'Tip' );
has access              => ( is => 'ro', default => 0 ); # 0 = Public, 1 = Bot-Owner Only
has description         => ( is => 'ro', default => 'Tip another user' );
has pattern             => ( is => 'ro', default => '^tip ?' );
has function            => ( is => 'ro', default => sub { \&cmd_tip } );
has usage               => ( is => 'ro', default => <<EOF
Tip another Discord user to their zaddr

Basic Usage: !tip @user amount
Advanced Usage: !tip @alice @bob amount
EOF
);

sub cmd_tip
{
    my ($self, $msg) = @_;

    my $channel = $msg->{'channel_id'};
    my $author = $msg->{'author'};

    my $args = $msg->{'content'};
    # "$args" contains the command and the arguments the user typed.
    # Most of the time we'll want to strip the command out of $msg and just look at the arguments.
    # You can use $self->pattern to do this.
    
    my $pattern = $self->pattern;
    $args =~ s/$pattern//;
    
    # Data::Dumper is an easy way to dump any variable, including complex structures, to debug your command. 
    # You can send its output to the screen or to log files or both.
    $self->bot->log->debug('[Tip] [cmd_tip] ' . Data::Dumper->Dump([$msg], ['msg']));
    say Data::Dumper->Dump([$args], ['args']);

    my $rpc = Component::RPC->new;

    # You know the channel the message came from and who sent it.
    # You can use that information to tailor your reply (eg, mention the user or not, look up other info on them, etc)
    my $reply = ( length $args ? "Your message was:\n```\n$args\n```" : "Your Discord ID is: " . $author->{'id'} );

    # Send a message back to the channel
    $self->discord->send_message($channel, $reply);
}

1;
