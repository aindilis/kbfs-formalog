%% chomp(Input,Output) :-
%% 	normalize_space(atom(Output),Input).

chomp2(Input,Output) :-
	regex('(.+)', [], Input, [Res]),
	atom_string(Output,Res).

chase(File, Result) :-
	atomic_list_concat(['chase "',File,'"'],'',ShellCommand),
	shell_command_to_string(ShellCommand,Output),
	chomp2(Output,Result).

%% FIXME: have it extract the urls that are mentioned in all contained
%% documents
extract_urls(Document,URLs) :-
	atomic_list_concat(['extract-links -i',Document],' ',Command),
	shell_command_to_string(Command,String),
	split_string(String,'\n',URLs).

%% replace(X,Y,X,Y) :- !.
%% replace(X,Y,S,R) :-
%% 	S =.. [F|As], maplist(replace(X,Y),As,Rs), R =.. [F|Rs], !.
%% replace(_,_,U,U).
