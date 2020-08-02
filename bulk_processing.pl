%% RULES - BULK PROCESSING

%% doOutput :-
%% 	bash_command("echo banana | tr na bo", Output),
%% 	view(Output).
%% listTargets :-
%% 	hasPotentialSourceOfNewSystems(Dir),
%% 	analyzeDirectory(Dir),
%% 	fail.
%% listTargets.
%% analyzeDirectory(Dir) :-
%% 	exists_directory(Dir),
%% 	nl,view(Dir),
%% 	directory_files(Dir,Files),
%% 	member(File,Files),
%% 	File \= '.',
%% 	File \= '..',
%% 	hasArchiveFormat(Format),
%% 	atom_concat(TmpHead,Format,File),
%% 	atom_concat(Head,'.',TmpHead),
%% 	atomic_list_concat([Dir,'/',Head,'.',Format],NewFile),
%% 	analyze([Dir,Head,Format],NewFile).
