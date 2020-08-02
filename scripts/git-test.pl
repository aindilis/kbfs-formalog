#!/usr/bin/perl -w

use Git;

my $version = Git::command_oneline('version');

git_cmd_try { Git::command_noisy('update-server-info') }
  '%s failed w/ code %d';

my $repo = Git->repository (Directory => '/var/lib/myfrdcsa/codebases/minor/kbfs-formalog/scripts/test.git');

my @revs = $repo->command('rev-list', '--since=last monday', '--all');

my ($fh, $c) = $repo->command_output_pipe('rev-list', '--since=last monday', '--all');
my $lastrev = <$fh>; chomp $lastrev;
$repo->command_close_pipe($fh, $c);

my $lastrev = $repo->command_oneline( [ 'rev-list', '--all' ],
					STDERR => 0 );

my $sha1 = $repo->hash_and_insert_object('file.txt');
my $tempfile = tempfile();
my $size = $repo->cat_blob($sha1, $tempfile);
