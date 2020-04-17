package Command::Info;
use feature 'say';

use Moo;
use strictures 2;
use namespace::clean;

use Exporter qw(import);
our @EXPORT_OK = qw(cmd_info);

has bot                 => ( is => 'ro' );
has discord             => ( is => 'lazy', builder => sub { shift->bot->discord } );
has log                 => ( is => 'lazy', builder => sub { shift->bot->log } );

has name                => ( is => 'ro', default => 'Info' );
has access              => ( is => 'ro', default => 0 ); # 0 = Public, 1 = Bot-Owner Only
has description         => ( is => 'ro', default => 'Display information about the bot, including framework, creator, and source code links"' );
has pattern             => ( is => 'ro', default => '^info ?' );
has function            => ( is => 'ro', default => sub { \&cmd_info } );
has usage               => ( is => 'ro', default => <<EOF
Basic Usage: `!info`
EOF
);

sub cmd_info
{
    my ($self, $msg) = @_;

    my $channel = $msg->{'channel_id'};
    my $author = $msg->{'author'};
    my $args = $msg->{'content'};

    my $info;
    my $join_url = "https://discordapp.com/oauth2/authorize?client_id=XXX&scope=bot&permissions=YYY";
    my $discord_url = "https://myhush.org/discord";

    $info = "**Info**\n" .
            'I am a Sybil Bot by Duke Leto, based on Goose Bot by vsTerminus' . "\n" .
            "I provide useful services such as `!tip`, `!deposit`, and `!withdraw`\n".
            "Try the `!help` command for a complete listing.\n\n" .
            "**Source Code**\n" .
            "I am open source! I am written in Perl, and am built on the Mojo::Discord library `[1]`\n" .
            "My source code is available on GitHub `[2]`\n\n" .
            "**Add Me**\n" .
            "You can add me to your own server(s) by clicking the link below `[3]` or by sharing it with your server admin.\n\n".
            "**Join My Server**\n" .
            "I have a public Discord server you can join where you can monitor my github feed and mess with the bot without irritating all your friends. Check it out below! `[4]`\n\n" .
            "**Links**\n".
            "`[1]` <https://github.com/vsTerminus/Mojo-Discord>\n".
            "`[2]` <https://github.com/leto/sybil>\n".
            "`[3]` <$join_url>\n" .
            "`[4]` <$discord_url>\n";

    $self->discord->send_ack_dm($channel, $msg->{'id'}, $author->{'id'}, $info);
}

1;
