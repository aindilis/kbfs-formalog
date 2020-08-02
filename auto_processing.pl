statHasCommand(sha1,prolog,sha1).
statHasCommand(md5,prolog,md5).
statHasCommand(crc32,shell,crc32).
statHasCommand(bn,prolog,file_base_name).
statHasCommand(fs,prolog,size_file).

shellCommandChomped(Command,Args,Result) :-
	Args = [file(FileName)],
	atomic_list_concat([Command,' "',FileName,'" 2>&1'],'',ShellCommand),
	shell_command_to_string(ShellCommand,Output),
	chomp2(Output,Result).

getAllFileStats(FullFileName) :-
	forall(member(FileStat,[sha1,md5,crc32,bn,fs]),
	       (   viewIf([fileStat,FileStat]),
		   getFileStat(FullFileName,FileStat))).

getFileStat(FullFileName,FileStat) :-
	getFileID(FullFileName,FileID),
	getFileStatHelper(FileStat,FileID,FileStatValue),
	viewIf([fileStat,FileStat,fileStatValue,FileStatValue]).

getFileStatHelper(FileStat,FileID,FileStatValue) :-
	FileStat = fn,
	viewIf([1]),
	Property =.. [FileStat,FileStatValue],
	md(f(FileID),Property).
getFileStatHelper(FileStat,FileID,FileStatValue) :-
	FileStat \= fn,
	viewIf([2]),
	getFileID(FullFileName,FileID),
	viewIf([fileStat,FileStat,fileID,FileID,fullFileName,FullFileName]),
	statHasCommand(FileStat,Environment,Command),
	viewIf([environment,Environment,command,Command]),
	(   (	Environment == shell) ->
	    (	
		viewIf([a]),
		shellCommandChomped(Command,[file(FullFileName)],FileStatValue),
		viewIf([x1])
	    ) ;   
	    (	(   Environment == prolog) ->
		(   
		    viewIf([b1]),
		    viewIf([command,Command,fullFileName,FullFileName,answer,FileStatValue]),
		    Pred =.. [Command,FullFileName,FileStatValue],
		    viewIf([pred,Pred]),
		    Pred
		) ;
		true)),
	viewIf([x]),
	Property =.. [FileStat,FileStatValue],
	viewIf([y]),
	kbfs_assert(md(f(FileID),Property)),
	viewIf([done]).
