:- dynamic prolog_files/2, prolog_files/3, md/2, possible/1, currentKBFSContext/1.

:- multifile genlsDirectlyList/2.

:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').

:- prolog_use_module(library(julian)).
:- prolog_use_module(library(regex)).
:- prolog_use_module(library(sha)).

:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/interactive-execution-monitor/frdcsa/sys/flp/autoload/args.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/dates/frdcsa/sys/flp/autoload/dates.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/frdcsa/sys/flp/autoload/profile.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/kbfs-formalog/compress_terms.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/kbfs-formalog/file_stat_commands.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/kbfs-formalog/bulk_processing.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/kbfs-formalog/auto_processing.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/kbfs-formalog/util.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/cyclone/frdcsa/sys/flp/autoload/kbs.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/counter2.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/projects/microtheories/microtheory.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/internal/clear/frdcsa/sys/flp/autoload/clear_helpers.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/internal/clear/frdcsa/sys/flp/autoload/next_unread.pl').

md(f(f1),fns('/')).

%% FACTS

isa(compressedFileFn(_),compressedArchiveFile).
hasArchiveFormats(['tgz','tar.gz','zip','Z','jar','deb','7z']).

flpFlag(not(debug)).

viewIf(Item) :-
 	(   flpFlag(debug) -> 
	    view(Item) ;
	    true).

%% RULES - SOLO PROCESSING

processFile(FullFileName,NewFileID) :-
	analyze(FullFileName,NewFileID).

analyze(FullFileName,RetFileID) :-
	nl,
	getFileID(FullFileName,FileID1),
	chase(FullFileName,ChasedFullFileName),
	viewIf([full,ChasedFullFileName]),
	NewFileName = ChasedFullFileName,
	((FullFileName \== ChasedFullFileName) ->
	 (
	  getFileID(ChasedFullFileName,FileID2),
	  kbfs_assert(md(f(FileID1),sl(f(FileID2)))),
	  %% annotateCompressedFiles(Head,Format,FileID2)
	  RetFileID = FileID2
	 ) ;
	 (   RetFileID = FileID1 )),
	getAllFileStats(NewFileName).

getFileID(FileName,FileID) :-
	md(f(FileID),fns(FileName)),
	viewIf([fileName,FileName]),
	viewIf([fileID,FileID]).
getFileID(FileName,FileID) :-
	not(md(_,fns(FileName))),
	viewIf([fileName,FileName]),
	%% getNewCounter(task,ID,task(ID,Task,Importance),TaskID),
	getNewCounter(f,ID,md(f(ID),fns(FNS)),FileID),
	viewIf([fileID,FileID]),
 	kbfs_assert(md(f(FileID),fns(FileName))).

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

kbfs_assert(Entry) :-
	tab(4),viewIf([entry,Entry]),
	not(Entry),
	currentKBFSContext(Context),
	fassert_argt('KBFS-Agent1','KBFS-Yaswi1',[term(Entry),context(Context)],Result),
	viewIf([result,Result]).
kbfs_assert(Entry).


%% schema(kbfsEntry("FileID", "SHA-1","MD5","CRC32","FileName","FileSize")).
%% kbfsEntry(dataFile11,'00000142988AFA836117B1B572FAE4713F200567','9B3702B0E788C6D62996392FE3C9786A','05E566DF','J0180794.JPG',32768).
kbfsEntry(FileID,SHA1,MD5,CRC32,BaseName,FileSize) :-
	md(f(FileID),sha1(SHA1)),
	md(f(FileID),md5(MD5)),
	md(f(FileID),crc32(CRC32)),
	md(f(FileID),bn(BaseName)),
	md(f(FileID),fs(FileSize)),
	!.

testKBFS :-
	retrieveFileIDs('<REDACTED>',X).

:- assert(currentKBFSContext('Org::FRDCSA::KBFS')).

setKBFSContext(Context) :-
	retractall(currentKBFSContext(_)),
	assert(currentKBFSContext(Context)).

retrieveFileIDs(FullFileName,FileIDs,Context) :-
	currentKBFSContext(CurrentContext),
	setKBFSContext(Context),
	retrieveFileIDs(FullFileName,FileIDs),
	setKBFSContext(CurrentContext).
	
retrieveFileIDs(FullFileName,FileIDs) :-
	processFile(FullFileName,NewFileID),
	findClosestMatches(NewFileID,FileIDs),
	view([fileIDs,FileIDs]).

convertFullFileNameToDirHeadFormat(FullFileName,[Dir,Head,Format]) :-
	file_directory_name(FullFileName,Dir),
	file_base_name(FullFileName,BaseName),
	regex('(.+)\\.([^.]+)$', [], BaseName, [TmpHead,TmpFormat]),
	atom_string(TmpHead,Head),
	atom_string(TmpFormat,Format).

findClosestMatches(NewFileID,FileIDs) :-
	viewIf([1]),
	retrieveUsableFactsAboutFileID(NewFileID,UsableFacts),
	viewIf([usableFacts,UsableFacts]),
	matchingFileIDs(UsableFacts,FileIDs),
	viewIf([4]).

retrieveUsableFactsAboutFileID(NewFileID,UsableFacts) :-
	retrieveFactsAboutFileID(NewFileID,Facts),
	viewIf([facts,Facts]),
	findall(Fact,(member(Fact,Facts),Fact \= fn(_),Fact \= fns(_),Fact \= bn(_)),UsableFacts),
	viewIf([usableFacts,UsableFacts]).

retrieveFactsAboutFileID(FileID,Facts) :-
	findall(Fact,md(f(FileID),Fact),TmpFacts),
	setof(TmpFact,(member(TmpFact,TmpFacts)),Facts).

matchingFileIDs(UsableFacts,FileIDs) :-
	setof(TmpFileID,A^md(f(TmpFileID),A),TmpFileIDs),
	viewIf([tmpFileIDs,TmpFileIDs]),
	findall(FileID,(member(FileID,TmpFileIDs),retrieveUsableFactsAboutFileID(FileID,MoreFacts),foreach(member(UsableFact,UsableFacts),(viewIf([usableFact,UsableFact]),member(UsableFact,MoreFacts)))),Tmp2FileIDs),
	setof(TmpFileID,(member(TmpFileID,Tmp2FileIDs)),FileIDs).


entryview :-
	kbfsEntry(A,B,C,D,E,F),
	viewIf(kbfsEntry(A,B,C,D,E,F)).
	
:- log_message('DONE LOADING KBFS.').
formalogModuleLoaded(kbfs).
