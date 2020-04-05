#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

binmode STDOUT, ":utf8";

use FindBin 1.51 qw( $RealBin );
use lib "$RealBin/lib";

use Config::Tiny;
use Bot::Sybil;

use Command::Avatar;
use Command::Define;
use Command::Help;
use Command::Hook;
use Command::Info;
use Command::Leave;
use Command::Pick;
use Command::Roll;
use Command::Say;
use Command::Tip;
use Command::Uptime;
use Data::Dumper;

# Fallback to "config.ini" if the user does not pass in a config file.
my $config_file = $ARGV[0] // 'config.ini';
my $config = Config::Tiny->read($config_file, 'utf8');
say localtime(time) . " Loaded Config: $config_file";

# Initialize the bot
my $bot = Bot::Sybil->new('config' => $config);

# Register the commands
# The new() function in each command will register with the bot.
$bot->add_command( Command::Avatar->new         ('bot' => $bot) );
$bot->add_command( Command::Define->new         ('bot' => $bot) );
$bot->add_command( Command::Help->new           ('bot' => $bot) );
$bot->add_command( Command::Hook->new           ('bot' => $bot) );
$bot->add_command( Command::Info->new           ('bot' => $bot) );
$bot->add_command( Command::Leave->new          ('bot' => $bot) );
$bot->add_command( Command::Pick->new           ('bot' => $bot) );
$bot->add_command( Command::Roll->new           ('bot' => $bot) );
$bot->add_command( Command::Say->new            ('bot' => $bot) );
$bot->add_command( Command::Tip->new            ('bot' => $bot) );
$bot->add_command( Command::Uptime->new         ('bot' => $bot) );

# Start the bot
$bot->start();
