:- dynamic ':-'/2, md/2, metaData/2.

:- discontiguous arg1Isa/2, arg2Isa/2, arg3Isa/2.

:- consult('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').
:- consult('/var/lib/myfrdcsa/codebases/minor/kbfs-formalog/compress_terms_data.pl').

expandFact(Pre,Post) :-
        %% view([pre,Pre]),
        (   is_list(Pre) ->
	    (	findall(Item,(member(SubPre,Pre),expandFact(SubPre,Item)),Post)) ;
	    (	not(nonvar(Pre)) ->
		(   Post = Pre ); 
		(   atomic(Pre) ->
		    (	Post = Pre) ;
		    Pre =.. [ShortPredicateName|Args] ->
		    (	
			findall(Item,(member(SubArgs,Args),expandFact(SubArgs,Item)),Items),
			relatePredicateNames(ShortPredicateName,PredicateName),
			%% view([predicateName,PredicateName]),
			Post =.. [PredicateName|Items]
		    ) ; true))).

relatePredicateNames(ShortPredicateName,PredicateName) :-
	hasExpanded(List),
	member([ShortPredicateName,Arity,PredicateName],List).

contractFact(Pre,Post) :-
        %% view([pre,Pre]),
        (   is_list(Pre) ->
	    (	findall(Item,(member(SubPre,Pre),contractFact(SubPre,Item)),Post)) ;
	    (	not(nonvar(Pre)) ->
		(   Post = Pre ); 
		(   atomic(Pre) ->
		    (	Post = Pre) ;
		    Pre =.. [PredicateName|Args] ->
		    (	
			findall(Item,(member(SubArgs,Args),contractFact(SubArgs,Item)),Items),
			relatePredicateNames(ShortPredicateName,PredicateName),
			%% view([predicateName,PredicateName]),
			Post =.. [ShortPredicateName|Items]
		    ) ; true))).

assertExpanded :-
	expandFacts(NewFacts),
	forall(member(NewFact,NewFacts),(view(NewFact),assert(NewFact))).

testCompressTerms :-
	assertExpanded,
	contractFacts(NewFacts),
	view([NewFacts]).

%% tmpView(Item) :-
%% 	write_term(Item,[quoted(true)]).

%% expandShortToLongPredicateNames :-
%% 	hasExpanded(List),
%% 	member([ShortPredicateName,Arity,LongPredicateName],List),
%% 	length(ArgList,Arity),
%% 	ShortPredicate =.. [ShortPredicateName|ArgList],
%% 	LongPredicate =.. [LongPredicateName|ArgList],
%% 	assert(LongPredicate :- ShortPredicate).


%% integrate this with KBFS and the book metadata system.  also
%% integrate with the system for ocr, etc.

%% FIXME: figure out what other systems to integrate here.  probably
%% torrent system, etc.  Academician, Digilib, NLU-MF, etc.

%% recursively convert

%% term_contains_subterm_nonvar(SubTerm, Term) :-
%%         not(compound(Term)),
%%         nonvar(Term),
%%         SubTerm=Term.
%% term_contains_subterm_nonvar(SubTerm, Term) :-
%%         compound(Term),
%%         nonvar(Term),
%%         compound_name_arguments(Term, SubTerm, _).
%% term_contains_subterm_nonvar(SubTerm, Term) :-
%%         compound(Term),
%%         nonvar(Term),
%%         arg(_, Term, SubSubTerm),
%%         term_contains_subterm_nonvar(SubTerm, SubSubTerm).
