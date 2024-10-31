:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(main)).

:- initialization(main, main).


count_valencies([], [], []).

count_valencies([u(X1,X2)|T], [X2|IV], [X1|OV]) :-
	count_valencies(T, IV, OV)
.

valencies(U, IVClumped, OVClumped) :-
	count_valencies(U, IV, OV),
	msort(IV, IVSorted),
	clumped(IVSorted, IVClumped),
	msort(OV, OVSorted),
	clumped(OVSorted, OVClumped)
.

vertices([V-_], [V]).

vertices([V-_|TVal], [V|TVert]) :- vertices(TVal, TVert).


eulerian_result(eulerian) :-     write("Эйлеров, ").
eulerian_result(partEulerian) :- write("Полуэйлеров, ").
eulerian_result(notEulerian) :-  write("Не эйлеров, ").

hamiltonian_result(hamiltonian) :-     write("гамильтонов\n").
hamiltonian_result(partHamiltonian) :- write("полугамильтонов\n").
hamiltonian_result(notHamiltonian) :-  write("не гамильтонов\n").


check_valencies(undirected, [], _, OddVert, _, partEulerian) :- OddVert #> 0.

check_valencies(undirected, [], _, 0, _, eulerian).

check_valencies(undirected, [_-Val|T], _, OddVert, _, Result) :-
	Val #= _*2,
	check_valencies(undirected, T, _, OddVert, _, Result)
.

check_valencies(undirected, [_-Val|T], _, OddVert, _, Result) :-
	Val #= _*2+1,
	AddedOddVert #= OddVert+1,
	AddedOddVert #=< 2,
	check_valencies(undirected, T, _, AddedOddVert, _, Result)
.

check_valencies(directed, [], [], 0, 0, eulerian).

check_valencies(directed, [], [], 1, 1, partEulerian).

check_valencies(directed, [_-IVal|IT], [_-OVal|OT], StartVert, EndVert, Result) :-
	IVal #= OVal,
	check_valencies(directed, IT, OT, StartVert, EndVert, Result)
.

check_valencies(directed, [_-IVal|IT], [_-OVal|OT], StartVert, EndVert, Result) :-
	IVal #= OVal+1,
	AddedEndVert #= EndVert+1,
	check_valencies(directed, IT, OT, StartVert, AddedEndVert, Result)
.

check_valencies(directed, [_-IVal|IT], [_-OVal|OT], StartVert, EndVert, Result) :-
	IVal #= OVal-1,
	AddedStartVert #= StartVert+1,
	check_valencies(directed, IT, OT, AddedStartVert, EndVert, Result)
.

is_eulerian(MainId, Type, IV, OV) :-
	(
	  check_valencies(Type, IV, OV, 0, 0, Result)
	  ; Result = notEulerian
	),
	thread_send_message(MainId, eul(Result))
.


is_crossable(Vertice, U, [Last|T]) :-
	member(u(Last,Vertice), U),
	\+ member(Vertice, T)
.

build_hamiltonian_path(seekCycle, U, [], [Last|_], _, First, hamiltonian) :- member(u(Last,First), U).

build_hamiltonian_path(seekPath,  _, [], _, _, _, partHamiltonian).

build_hamiltonian_path(SeekType, U, [Vertice|VT], Used, VertShift, First, Result) :-
	(
		is_crossable(Vertice, U, Used),
		build_hamiltonian_path(SeekType, U, VT, [Vertice|Used], 0, First, Result)
	)
	; (
		NextVertShift #= VertShift+1,
		append(VT, [Vertice], ShiftedX),
		\+ length(ShiftedX, NextVertShift),
		build_hamiltonian_path(SeekType, U, ShiftedX, Used, NextVertShift, First, Result)
	  )
.

build_hamiltonian_path_start(_, X, VertShift, notHamiltonian) :- length(X, VertShift).

build_hamiltonian_path_start(U, [First|T], VertShift, Result) :- 
	(
		build_hamiltonian_path(seekCycle, U, T, [First], 0, First, Result)
		; build_hamiltonian_path(seekPath, U, T, [First], 0, First, Result)
	    ; (
		    NextVertShift #= VertShift+1,
			append(T, [First], ShiftedX),
			build_hamiltonian_path_start(U, ShiftedX, NextVertShift, Result)
	      )
	)
.

is_hamiltonian(MainId, U, X) :-
	(
	  build_hamiltonian_path_start(U, X, 0, Result)
	  ; Result = notHamiltonian
	),
	thread_send_message(MainId, ham(Result))
.


get_graph_from_file(FileName, Type, U) :-
	setup_call_cleanup(
		open(FileName, read, InStream),
		read_term(InStream, g(Type, U), []),
		( is_stream(InStream) -> close(InStream) ; true )
	)
.



join_and_check(Id) :-
	thread_join(Id, Status),
	(  exception(Ex) = Status
	-> (
		 print_message(error, Ex),
		 abort()
	   )
	;  !
	)
.


main(Argv) :-
	argv_options(Argv, [FilePath|_], _),
	get_graph_from_file(FilePath, Type, U),

	valencies(U, IV, OV),
	vertices(IV, X),

	thread_self(MainId),
	thread_create(
		is_eulerian(MainId, Type, IV, OV),
		EId
	),
	thread_create(
		is_hamiltonian(MainId, U, X),
		HId
	),

	%% На всякий пожарный
	join_and_check(EId),

	thread_get_message(eul(EResult)),
	
	join_and_check(HId),

	thread_get_message(ham(HResult)),

	eulerian_result(EResult),
	hamiltonian_result(HResult)
.
