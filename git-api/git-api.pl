%% encode the logic of epistemic actions

indexGitDir(Directory,Tmp) :-
	getGitID(Directory,GitID),
	getDirectoryID(Directory,DirectoryID),
	kbfs_assert(md(g(GitID),d(DirectoryID))),

	%% get the latest revision.

md(g(GitID),rev(r(RevisionID))).

%% md(r(RevisionID1),after(r(RevisionID2))).

md(git,git1).
md(gitForGitRootDir,git1,gitrootdir1).
md(gitRootDir,gitrootdir1,file2).
md(filename,file2,'<REDACTED>').

md(gitForRevision,git1,rev1).
md(gitRevision,rev1,'<REDACTED>').
md(filename,file1,'<REDACTED>').
md(fileForRevFile,revfile1,file1).
md(gitRevisionForRevFile,revfile1,rev1).
md(sourceFile,text1,file1).
md(text,text1,'<REDACTED>'
       ).
md(revFileText,revfiletext1,revfile1).
md(textForRevFileText,revfiletext1,text1).
md(startPos,revfiletext1,313).
md(endPos,revfiletext1,466).

%% CONTEXT INFO
md(follows,revFileText1,revFileText0).
md(follows,revFileText2,revFileText1).

%% now do typical sayer type stuff.  write a prolog version of sayer2.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                   %% SEE INSTEAD library(git)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
