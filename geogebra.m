:- module geogebra.

%  This is a proof-of-concept of an intuitive API between the 
%  Mercury computer language (https://www.mercurylang.org) and
%  an interactive geometrical modeling system such as Geogebra.

%  We currently support geogebra primitives:
%  point, line, perpendicularLine, circle, intersect
%  although support for other primitives is relatively straightforward
%  to add (feature requests?)

:- implementation.

%%----------------------User declarations-----------------------%%

%% Declare points using statements.  A point with label "B"
% is declared at (-1.0,1.0):
point("B",-1.0,1.0).

%A point with label "C" is declared at (2.0,4.3):
point("C",2.0,4.3).

%Declare the line "BC" adjoining them:
line("BC","B","C").

%Order does not matter.  We can declare the
%line "XY", before we know what X and Y are:

line("XY","X","Y").

% Supporting an "interesting" geogebra primitive
% (although we show later how to do this with a macro):
perpendicularLine("AB*_A","C","AB").
perpendicularLine("AB*_B","A","AB*_A").
% (A valid identifier must be a valid geogebra identifier
% two different objects must not share the same identifier.)

% We also support circle
circle("MyCircle","A","B").
% where A is center of the circle, and B is any point on it.

% Intersect takes a pair of curves and represents a logical
% primitive for producing the list of points of intersection.
intersect(["X"],"AB*_A","AB*_B").
intersect(["Y"],"AB*_A","BC").

% Hey, wait, you never declared "A" or the line "AB".
% Remember, order doesn't matter!  So,
% here you go:
point("A",0.0,1.0).
line("AB","A","B").

% Finally, we support macros written in the Mercury language.
% The only example currently written constructs the bisector
% of two points using a ruler-and-compass construction:

%bisectorMACRO("L1","A","B").

bisect_recursiveMACRO("L2",8,"A","B").



%%--------------------End declarations------------------------%%



%%-----------Advanced usage: MACROS and patterns---------%%


%% MACRO interface.
:- pred bisectorMACRO(key::out,
		      geogebraObjectReference/*Point*/::out,
		      geogebraObjectReference/*Point*/::out)
   is nondet.
bisectorMACRO(_,_,_) :- fail.

:- pred bisect_recursiveMACRO(key::out, int::out,
	      geogebraObjectReference/*Point*/::out,
	      geogebraObjectReference/*Point*/::out)
   is nondet.
bisect_recursiveMACRO(_,_,_,_) :- fail.


:- pred bisector(key::in,
	      geogebraObjectReference/*Point*/::in,
	      geogebraObjectReference/*Point*/::in,
	      set(geogebraDecl)::out)
   is det.


:- pred bisect_recursive(key::in, int::in,
	      geogebraObjectReference/*Point*/::in,
	      geogebraObjectReference/*Point*/::in,
	      set(geogebraDecl)::out)
   is nondet.

:- pred user_macros(set(geogebraDecl)::out) is nondet.
user_macros(S) :-
    (
	bisectorMACRO(L,A,B) -> bisector(L,A,B,S)
    ;  fail
    ).

user_macros(S) :-
    (
       %Other definitions:
       bisect_recursiveMACRO(K,N,A,B) -> bisect_recursive(K,N,A,B,S)
    ;  fail
    ).


%% MACRO implementation.
%  There are built-in patterns for each built-in type.
%  The patterns are pointFF, linePP, circlePP, perpendicularLinePL
%  and intersectCC.  These are pattern-predicates, pointFF(point,float,float),
%  linePP(line,point,point), intersectCC([list of points],curve,curve),
%  that support a declarative style as shown in the example below:

bisect_recursive(K, N, A, B, S) :-
    ( N < 1 -> S is set.from_list([])
    ; var("M",K,M),
      var("AB",K,AB),
      var("G",K,G),
      var("L",K,L),
      var("R",K,R),
      bisect_recursive(L, N-1, A, M, S1),
      bisect_recursive(R, N-1, M, B, S2),
      bisector(G,A,B,S3),
      S = set.union_list(
		  [S1,
		   S2,
		   S3,
		   set.from_list(
			   [
			       linePP(AB,A,B),
			       intersectCC([M],AB,G)
			   ])
		  ]
	      )
    ).


bisector(L,A,B,S) :-
	  var("X",L,X),
	  var("Y",L,Y),
	  var("P",L,P),
	  var("Q",L,Q),
          S=set.from_list(
		    [ circlePP(X,A,B),
	              circlePP(Y,B,A),
		      intersectCC([P,Q],X,Y),
		      linePP(L,P,Q)]
		).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%---------------END of user-modifiable section--------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%Messy, badly written internals:

:- interface.

:- import_module io.
:- pred main(io::di,io::uo) is det.




:- implementation.
:- import_module string, float, solutions,  list, set, int, require.

:- type key == string.
:- type geogebraObjectReference == key.


:- pred point(key::out,
	      float::out,
	      float::out
	     ) is nondet.
point(_,_,_):-fail.

:- pred line(key::out,
	     geogebraObjectReference/*Point*/::out,
	     geogebraObjectReference/*Point*/::out
	    ) is nondet.
line(_,_,_):-fail.

:- pred perpendicularLine(key::out,
			  geogebraObjectReference/*Point*/::out,
			  geogebraObjectReference/*Line*/::out
			 ) is nondet.
perpendicularLine(_,_,_):-fail.

:- pred conic( key::out,
	       geogebraObjectReference/*Point*/::out
	       ,geogebraObjectReference/*Point*/::out,
	       geogebraObjectReference/*Point*/::out,
	       geogebraObjectReference/*Point*/::out
	     ) is nondet.
conic(_,_,_,_,_):-fail.  %Not yet implemented

:- pred circle( key::out,
		geogebraObjectReference/*Point*/::out,
		geogebraObjectReference/*Point*/::out
	      ) is nondet.
circle(_,_,_):-fail.

:- pred intersect(list(key)::out,
		  geogebraObjectReference::out,
		  geogebraObjectReference::out
		 ) is nondet.
intersect(_,_,_):-fail.




:- pred var(string::in,key::in,key::out) is det.
var(Name,Context,Key) :-
    string.append("%",Name,Modifier),
    string.append(Context,Modifier,Key).

%%Core

:- type geogebraDecl
   ---> pointFF(key,float,float)
   ;    linePP(key,
	       geogebraObjectReference/*Point*/,
	       geogebraObjectReference/*Point*/)
   ;    perpendicularLinePL(key,
			    geogebraObjectReference/*Point*/,
			    geogebraObjectReference/*Line*/)
   ;    circlePP(key,
		 geogebraObjectReference/*Point*/,
		 geogebraObjectReference/*Point*/)
   ;    intersectCC(list(key),
		    geogebraObjectReference,
		    geogebraObjectReference).
%   ;    circleSSS(string,string,string)
%   ;    conicSSSSS(string,string,string,string,string,string)

:- pred geogebraKeys(geogebraDecl::in,
		     string      ::out,
		     list(string)::out
		    ) is nondet.

geogebraKeys(X,Key,Values) :-
    ( X = pointFF(Key,_,_), Values=[]
    ; X = circlePP(Key,V1,V2), Values=[V1,V2]
    ; X = linePP(Key,V1,V2), Values=[V1,V2]
    ; X = perpendicularLinePL(Key,V1,V2), Values=[V1,V2]
    ; X = intersectCC(L,V1,V2), list.member(Key,L), Values=[V1,V2]
    ).


:- pred geogebraCommands(list(geogebraDecl)::out) is det.
geogebraCommands(Commands0) :-
    solutions_set(pred(pointFF(A,X,Y)::out) is nondet :-
		      point(A,X,Y)
		 , Points),
    solutions_set(pred(linePP(L,A,B)::out) is nondet :-
		      line(L,A,B)
		 , Lines),
    solutions_set(pred(circlePP(C,A,B)::out) is nondet :- circle(C,A,B)
		 , Circles),
    solutions_set(pred(perpendicularLinePL(A,X,Y)::out) is nondet :-
		      perpendicularLine(A,X,Y)
		 , PerpendicularLines),
    solutions_set(pred(intersectCC(L,X,Y)::out) is nondet :-
		      intersect(L,X,Y)
		 , Intersections),
    solutions(user_macros,MACROSList),
    MACROS=union_list(MACROSList),
    GeogebraCommands = union_list([ Points,Lines,Circles,
				    PerpendicularLines,
				    Intersections, MACROS ]),
    solutions_set(pred(Commands::out) is nondet :-
		      topological_sort(GeogebraCommands,
				       geogebraCmp,
				       Commands)
		 , SortedCommandsSet),
    (
	is_empty(SortedCommandsSet) -> Commands0=[]
    ;	remove_least(Commands0,SortedCommandsSet,_)
    ;   error("Impossible.")).



:- pred printGeogebra(geogebraDecl::in,
		      io          ::di,
		      io          ::uo
		     ) is det.

printGeogebra(pointFF(A,X,Y),!IO):-
    write_strings(["
<element type=\"point\" label=\"", A,"\">
	<show object=\"true\" label=\"true\" ev=\"4\"/>
	<objColor r=\"68\" g=\"68\" b=\"68\" alpha=\"0.0\"/>
	<layer val=\"0\"/>
	<labelMode val=\"0\"/>
	<coords        x=\"", float_to_string(X),
		   "\" y=\"", float_to_string(Y),
		   "\" z=\"1.0\"/>
	<pointSize val=\"4\"/><pointStyle val=\"0\"/></element>"],!IO).

printGeogebra(linePP(Label,A,B),!IO):-
    write_strings(["
<command name=\"Line\">
	<input a0=\"",A,"\" a1=\"",B,"\"/>
	<output a0=\"",Label,"\"/>
</command>"],!IO).

printGeogebra(circlePP(Label,A,B),!IO):-
    write_strings(["
<command name=\"Circle\">
	<input a0=\"",A,"\" a1=\"",B,"\"/>
	<output a0=\"",Label,"\"/>
</command>"],!IO).

printGeogebra(perpendicularLinePL(Label,A,B),!IO):-
    write_strings(["
<command name=\"PerpendicularLine\">
	<input a0=\"",A,"\" a1=\"",B,"\"/>
	<output a0=\"",Label,"\"/>
</command>"],!IO).

:- pred intercalate( list(string)::in,
		     list(string)::in,
		     list(string)::out
		   ) is det.
intercalate(X,Y,Z) :-
    ( X is [] -> Y is Z
    ; Y is [] -> Y is Z
    ; X is [Hx|Tx], Y is [Hy|Ty], intercalate(Tx,Ty,Tz), Z is [Hx|[Hy|Tz]]
    ; error("Impossible.")
    ).

:- pred intercalate_indexed( list(string)::in,
			     string      ::in,
			     string      ::in,
			     string      ::in,
			     int         ::in,
			     list(string)::out
			   ) is det.

intercalate_indexed(X,Y0,Y1,Y2,N,Z) :-
    ( X is [] -> [] is Z
    ; X is [Hx|Tx],
      intercalate_indexed(Tx,Y0,Y1,Y2,N+1,Tz),
      Z is [Y0|[string.from_int(N)|[Y1|[Hx|[Y2|Tz]]]]]
    ; error("Impossible.")
    ).

printGeogebra(intersectCC(Labels,A,B),!IO):-
    intercalate_indexed(Labels,"a","=\"","\" ",0,LabelsList),
    list.foldl(
	     pred(Ac::in,Str::in,Output::out) is det:-
		 string.append(Str,Ac,Output),
			LabelsList,"",OutputString),
    write_strings(["
<command name=\"Intersect\">
	<input a0=\"", A,"\" a1=\"", B, "\"/>
	<output ", OutputString, "/>
</command>
"],!IO).



:- pred min_element(set(T),pred(T,T),T).
:- mode min_element(in,pred(in,in) is semidet,out) is nondet.
min_element(_,_,_):-fail.
min_element(S,P,X):-
    member(X,S),
    filter( pred(Y::in) is semidet :- P(Y,X)
	  , S
	  , LowerThanX
	  ),
    is_empty(LowerThanX).



:- pred topological_sort(set(T),pred(T,T),list(T),list(T)).
:- mode topological_sort(in,(pred((ground >> ground), (ground >> ground)) is semidet),in,out) is nondet.
:- pred topological_sort(set(T),pred(T,T),list(T)).
:- mode topological_sort(in,(pred((ground >> ground), (ground >> ground)) is semidet),out) is nondet.

topological_sort(S,P,Ac,L) :-
    (
	is_empty(S) -> L is Ac
    ;   solutions(
	    pred(X::out) is nondet:-
		min_element(S,P,X)
	 ,  Solutions
	),
	(
	    is_empty(Solutions) ->
	      error("No solution detected.\n")
	; delete_list(Solutions,S,Sprime),
	  append(Solutions,Ac,AcPrime),
	  topological_sort(Sprime,P,AcPrime,L)
	)
    ).

topological_sort(S,P,L) :- topological_sort(S,P,[],L).



:- pred geogebraCmp(geogebraDecl::in,geogebraDecl::in) is semidet.

geogebraCmp(X,Y) :-
    geogebraKeys(Y,Ky,_),
    geogebraKeys(X,_,Vx),
    member(Ky,Vx).



	   
main(!IO) :-
    geogebraCommands(SortedCommands),
    cat_file("GeogebraHeader.xml",!IO),
    list.foldl(printGeogebra,SortedCommands,!IO),
    cat_file("GeogebraFooter.xml",!IO),
    true.


%-- From samples/cat.m, public domain license:

:- pred cat_stream(io.input_stream::in, io::di, io::uo) is det.

cat_stream(Stream, !IO) :-
    io.set_input_stream(Stream, _OldStream, !IO),
    cat(!IO).


:- pred cat_file(string::in, io::di, io::uo) is det.
cat_file(File, !IO) :-
    io.open_input(File, Result, !IO),
    (
        Result = ok(Stream),
        cat_stream(Stream, !IO),
        io.close_input(Stream, !IO)
    ;
        Result = error(Error),
        io.progname("cat", Progname, !IO),
        io.error_message(Error, Message),
        io.write_strings([
            Progname, ": ",
            "error opening file `", File, "' for input:\n\t",
            Message, "\n"
        ], !IO)
    ).



:- pred cat(io::di, io::uo) is det.

cat(!IO) :-
    io.read_line_as_string(Result, !IO),
    (
        Result = ok(Line),
        io.write_string(Line, !IO),
        cat(!IO)
    ;
        Result = eof
    ;
        Result = error(Error),
        io.error_message(Error, Message),
        io.input_stream_name(StreamName, !IO),
        io.progname("cat", ProgName, !IO),
        io.write_strings([
            ProgName, ": ",
            "error reading input file `", StreamName, "': \n\t",
            Message, "\n"
        ], !IO)
    ).
