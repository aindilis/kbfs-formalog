md5(FullFileName,FileStatValue) :-
	shellCommandChomped(md5sum,[file(FullFileName)],Result),
	atomic_list_concat([FileStatValue,Tmp],'  ',Result).

sha1(FullFileName,FileStatValue) :-
	shellCommandChomped(sha1sum,[file(FullFileName)],Result),
	atomic_list_concat([FileStatValue,Tmp],'  ',Result).
