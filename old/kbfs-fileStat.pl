:- dynamic prolog_files/2, prolog_files/3, fileName/2, fullFileName/2,
md5sumForFile/2, hasArchiveFormat/1, possible/1.

:- multifile genlsDirectlyList/2.

:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').

:- prolog_use_module(library(julian)).
:- prolog_use_module(library(regex)).

:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/dates/frdcsa/sys/flp/autoload/dates.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/frdcsa/sys/flp/autoload/profile.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/internal/kbfs/systems/kbfs-formalog/compress_terms.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/kbs.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/counter2.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/projects/microtheories/microtheory.pl').


%% FACTS

isa(compressedFileFn(_),compressedArchiveFile).

hasArchiveFormats(['tgz','tar.gz','zip','Z','jar','deb','7z']).


%% RULES - SOLO PROCESSING

processFile([Dir,Head,Format],X) :-
	atomic_list_concat([Dir,'/',Head,'.',Format],NewFile),
	analyze([Dir,Head,Format],NewFile).

analyze([Dir,Head,Format],FileName) :-
	nl,
	getFileID(FileName,FileID1),
	chase(FileName,FullFileName),
	((FileName \== FullFileName) ->
	 (
	  getFileID(FullFileName,FileID2),
	  kbfs_assert(fileStat(symlink(FileID1,FileID2))),
	  md5sum(FullFileName,Sum1),
	  kbfs_assert(fileStat(md5sum,FileID2,Sum1)),
	  annotateCompressedFiles(Head,Format,FileID2)
	 ) ;
	 (
	  md5sum(FileName,Sum2),
	  kbfs_assert(fileStat(md5sum,FileID1,Sum2)),
	  annotateCompressedFiles(Head,Format,FileID1)
	 )).

getFileID(FileName,FileID) :-
	fileName(FileID,FileName),
	view(FileName),
	view([fileID,FileID]).

getFileID(FileName,FileID) :-
	not(fileName(_,FileName)),
	view(FileName),
	getNewCounter(file,ID,fileName(ID,_),FileID),
	view([fileID,FileID]),
 	kbfs_assert(fileStat(fileName,FileID,FileName)).

annotateCompressedFiles(Head,Format,FileID) :-
	(
	 Format == 'zip' ->
	 (
	  atom_concat(Head2,'-master',Head)
	 ->  
	  kbfs_assert(possible(isa(FileID,compressedArchiveFileFn(gitRepository))))
	 ;
	  kbfs_assert(possible(isa(FileID,compressedArchiveFile)))
	 ) ; kbfs_assert(possible(isa(FileID,compressedArchiveFile)))
	).

chase(File, Result) :-
	process_create(path(chase),[file(File)],
		       [stdout(pipe(Out))]),
	read_string(Out, _, Output),
	close(Out),
	regex('^(.+)\n$', [], Output, [TmpResult]),
	atom_string(Result,TmpResult).

kbfsProcessFile(FileName,Result) :-
	true.

kbfs_assert(Entry) :-
	tab(4),view(Entry),
	assert(Entry).

doOutput :-
	bash_command("echo banana | tr na bo", Output),
	view(Output).

md5sum(File, Sum) :-
	process_create(path(md5sum),[file(File)],
		       [stdout(pipe(Out))]),
	read_string(Out, _, Output),
	close(Out),
	regex('^([0-9a-z]+) ', [], Output, [TmpSum]),
	atom_string(Sum,TmpSum).



%% RULES - BULK PROCESSING

listTargets :-
	hasPotentialSourceOfNewSystems(Dir),
	analyzeDirectory(Dir),
	fail.
listTargets.

analyzeDirectory(Dir) :-
	exists_directory(Dir),
	nl,view(Dir),
	directory_files(Dir,Files),
	member(File,Files),
	File \= '.',
	File \= '..',
	hasArchiveFormat(Format),
	atom_concat(TmpHead,Format,File),
	atom_concat(Head,'.',TmpHead),
	atomic_list_concat([Dir,'/',Head,'.',Format],NewFile),
	analyze([Dir,Head,Format],NewFile).


%% Couple of things, fassert or kassert or whatever should try
%% asserting first to see if it causes a contradiction (be sure that
%% it checks that).  then actually assert it.

%% :- getFileID('test1',FileID1),getFileID('test2',FileID2),getFileID('test1',FileID1a),getFileID('test1',FileID1b),getFileID('test3',FileID3).
%% :- listTargets.
%% :- doOutput.

%% :- annotateCommands.

%% FIXME: implement persistence, like with FreeLifePlanner, where it
%% asserts it using fassert or kassert or something and then has it on
%% future loads, doesn't have to reassert.  generalize that pattern
%% for use elsewhere, make a library for it.

%% FIXME: have it extract the urls that are mentioned in all contained
%% documents

%% schema(kbfsEntry("FileID", "SHA-1","MD5","CRC32","FileName","FileSize")).

%% kbfsEntry(dataFile3,'000000206738748EDD92C4E3D2E823896700F849','392126E756571EBF112CB1C1CDEDF926','EBD105A0','I05002T2.PFB',98865).
%% kbfsEntry(dataFile4,'0000002D9D62AEBE1E0E9DB6C4C4C7C16A163D2C','1D6EBB5A789ABD108FF578263E1F40F3','FFFFFFFF','_sfx_0024._p',4109).
%% kbfsEntry(dataFile5,'0000004DA6391F7F5D2F7FCCF36CEBDA60C6EA02','0E53C14A3E48D94FF596A2824307B492','AA6A7B16','00br2026.gif',2226).
%% kbfsEntry(dataFile6,'000000A9E47BD385A0A3685AA12C2DB6FD727A20','176308F27DD52890F013A3FD80F92E51','D749B562','femvo523.wav',42748).
%% kbfsEntry(dataFile7,'00000142988AFA836117B1B572FAE4713F200567','9B3702B0E788C6D62996392FE3C9786A','05E566DF','J0180794.JPG',32768).
%% kbfsEntry(dataFile8,'00000142988AFA836117B1B572FAE4713F200567','9B3702B0E788C6D62996392FE3C9786A','05E566DF','J0180794.JPG',32768).
%% kbfsEntry(dataFile9,'00000142988AFA836117B1B572FAE4713F200567','9B3702B0E788C6D62996392FE3C9786A','05E566DF','J0180794.JPG',32768).
%% kbfsEntry(dataFile10,'00000142988AFA836117B1B572FAE4713F200567','9B3702B0E788C6D62996392FE3C9786A','05E566DF','J0180794.JPG',32768).
%% kbfsEntry(dataFile11,'00000142988AFA836117B1B572FAE4713F200567','9B3702B0E788C6D62996392FE3C9786A','05E566DF','J0180794.JPG',32768).

%% fileStat(sha1,dataFile1,'000000206738748EDD92C4E3D2E823896700F849').
%% fileStat(md5,dataFile1,'392126E756571EBF112CB1C1CDEDF926').
%% fileStat(crc32,dataFile1,'EBD105A0').
%% fileStat(baseName,dataFile1,"I05002T2.PFB").
%% fileStat(fileSize,dataFile1,98865).

%% kbfsEntry(FileID,SHA1,MD5,CRC32,BaseName,FileSize) :-
%% 	getFileStat(sha1,FileID,SHA1),
%% 	getFileStat(md5,FileID,MD5),
%% 	getFileStat(crc32,FileID,CRC32),
%% 	getFileStat(baseName,FileID,BaseName),
%% 	getFileStat(fileSize,FileID,FileSize).

%% 	%% getFileStat(baseName,FileID,BaseName),
%% 	%% getFileStat(fileSize,FileID,FileSize).

%% statHasCommand(sha1,shell,sha1sum).
%% statHasCommand(md5,shell,md5sum).
%% statHasCommand(crc32,shell,crc32).
%% statHasCommand(baseName,prolog,file_base_name).
%% statHasCommand(fileSize,prolog,size_file).

%% shellCommandChomped(Command,Args,Result) :-
%% 	process_create(path(Command),Args,
%% 		       [stdout(pipe(Out))]),
%% 	read_string(Out, _, Output),
%% 	close(Out),
%% 	%% view([output,Output]),
%% 	regex('^([0-9a-z]+)', [], Output, [TmpResult]),
%% 	atom_string(Result,TmpResult).


%% basename(File,BaseName) :-
%% 	regex('^\\/([^\\/]+)$', [], File, [BaseName]),
%% 	view(BaseName).

%% dirname(File,DirName) :-
%% 	regex('^(.+?)(\\/)?([^\\/]+)$', [], File, [DirName,SeparatorIfAny,BaseName]),
%% 	view(DirName).

%% fileStat(fullFileName,dataFile2,'/var/lib/myfrdcsas/versions/myfrdcsa-1.0/codebases/minor/packager-agent/packager_agent.pl').

%% getFileStat(Type,FileID,Stat) :-
%% 	Type = fullFileName,
%% 	fileStat(fullFileName,FileID,Stat).
%% getFileStat(Type,FileID,Stat) :-
%% 	Type \= fullFileName,
%% 	getFileStat(fullFileName,FileID,FullFileName),
%% 	%% view([fullFileName,FullFileName]),
%% 	%% view([Type,Environment,Command]),
%% 	statHasCommand(Type,Environment,Command),
%% 	%% view([command,Command,environment,Environment]),
%% 	((Environment == shell) ->
%% 	(
%% 	 %% view(shellCommandChomped(Command,[file(FullFileName)],Stat)),
%% 	 shellCommandChomped(Command,[file(FullFileName)],Stat)
%% 	)
%% 	;
%% 	((Environment == prolog) ->
%% 	(
%% 	 %% view([list,[Command,FullFileName,answer]]),
%% 	 Pred =.. [Command,FullFileName,answer],
%% 	 %% view([pred,Pred]),
%% 	 replace(answer,Stat,Pred,Ready),
%% 	 %% view([ready,Ready]),
%% 	 Ready
%% 	 %% view([stat,Stat])
%% 	)
%% 	;
%% 	true)). %% throw an error here

%% replace(X,Y,X,Y) :- !.
%% replace(X,Y,S,R) :-
%% 	S =.. [F|As], maplist(replace(X,Y),As,Rs), R =.. [F|Rs], !.
%% replace(_,_,U,U).

%% %% :- kbfsEntry(dataFile2,A,B,C,D,E).

testKBFS :-
	processFile(['<REDACTED>','<REDACTED>','pdf'],X).

:- log_message('DONE LOADING KBFS.').

formalogModuleLoaded(kbfs).