:- dynamic(disparos/1).
:- dynamic(disparospc/1).

%--------------localización de barcos -----------------------%

jugar:- crearTablero.
crearTablero:- 
					write('Num. de Filas(5 o 10): '),read(M), nb_setval(filas, M),
					write('Num. de Columnas(5 o 10): '),read(N), nb_setval(columnas, N),
					write('Cant. de Barcos: '),read(B),
					nb_setval(puntos, 0),
					nb_setval(pc, 0),
					assert(cantidad_barco(B)),
					tableroInicial(M,N,L),
					crearBarcos(B,L,T),
					mostrarTablero(T),
					write('10 proyectiles disponibles: '),nl,
					dispara(10).
					
%------------ Crea tablero inicial (todas las posiciones son agua) ------------%
tableroInicial(M,N,T):-crearT_aux(M,N,[],T), mostrarTablero(T).
crearT_aux(_,0,A,A).
crearT_aux(M,N,A,R):- N > 0,N1 is N-1,crearFila(M,L),crearT_aux(M,N1,[L|A],R).
% crear una lista con N elementos 'a'
crearFila(N,L):- crearF_aux(N,[],L).
crearF_aux(0,A,A).
crearF_aux(N,A,R):- N > 0, N1 is N-1, crearF_aux(N1,['a'|A],R).
%-------------------------- Muestra el tablero --------------------------------%
% imprime los elementos de una lista
mostrar_lista([]).
mostrar_lista([E|R]):- write(E), write(' '), mostrar_lista(R).
% imprime los elementos de una lista de listas (tablero)
mostrarTablero([]).
mostrarTablero([O|R]):- mostrar_lista(O), nl, mostrarTablero(R).
%-------------------------- Crear Barcos --------------------------------------%
%barco(Id,Tam,Dir,Fini,Cini,Status).
crearBarcos(0,T,T).
crearBarcos(N,L,T):- N1 is N-1,
							write('Informacion del Barco'),nl,
							write('Tamano: '),read(Tam),
							write('Direccion: '),read(Dir),
							write('Fila Inicial: '),read(Fini),
							write('Columna Inicial: '),read(Cini),
							assert(barco(N,Tam,Dir,Fini,Cini,0,'f')),						
							colocarB(Dir,Fini,Cini,Tam,N,L,A),
							crearBarcos(N1,A,T).
%------------------ función para que se dispare -----------------------%

dispara(C):-
	C1 is C-1,
	(C == 0 ->  
		write('Se terminaron las balas'); 
		write('Fila: '), read(Fil),
		write('Columna: '), read(Col),
		(Fil == 2 -> 
			(Col == 4 -> 
				herido(Fil,Col,C1) ; 
				(Col == 5 -> 
					herido(Fil,Col,C1); 
					falla())
			);
			(Fil == 5 -> 
				(Col == 0 -> 
					falla(); 
					(Col == 1 -> 
						falla(); 
						(Col == 6 -> 
							falla(); 
							(Col == 9 -> 
								falla(); 
								herido(Fil,Col,C1)
							)
						)
					)
				); 
				falla()
			)
		)).
		
		
		
herido(A,B,Con):-
	nb_getval(puntos, Puntos),
	Pun is Puntos+1,
	write('le has dado a uno de mis barcos'),nl,
	(puntos == 8 -> write('Ganaste. Has undido todos mis barcos :(')),nl,
	Fam = disparos([A,B]),
	asert(Fam),
	findall(C, (disparos(C)), L), write(L), nl,
	dispara(Con).
	
falla():-
	write('Ni un poco cerca'),nl.
