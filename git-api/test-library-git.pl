:- use_module(library(git)).

%% FIXME: untested, correct what follows...

%% test on a sample repository

repoDirs(['/var/lib/myfrdcsa/codebases/minor-data/kbfs-formalog/prolog-ludumdare44']).

run :-
	repoDirs(RepoDirs),
	member(RepoDir,RepoDirs),
	is_git_directory(RepoDir),
	true.