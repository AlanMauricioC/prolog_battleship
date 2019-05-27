:- dynamic(disparos/1).
:- dynamic(disparospc/1).

%--------------localización de barcos -----------------------%

jugar:- crearTablero.
crearTablero:- 
					write('Num. de Filas(10 o 15): '),read(M), nb_setval(filas, M),
					write('Num. de Columnas(10 o 15): '),read(N), nb_setval(columnas, N),
					write('Cant. de Barcos: '),read(B),
					nb_setval(puntos, 0),
					nb_setval(pc, 0),
					assert(cantidad_barco(B)),
					tableroInicial(M,N,L),
					crearBarcos(B,L,T),
					mostrarTablero(T),
					write('10 proyectiles disponibles: '),nl,
					dispara(10,T).
					
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

dispara(0,T).
dispara(C,T):-
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
				falla(Fil,Col,T,T1))
			);
			(Fil == 5 -> 
				(Col == 0 -> 
					falla(Fil,Col,T,T1);
					(Col == 1 -> 
						falla(Fil,Col,T,T1);
						(Col == 6 -> 
							falla(Fil,Col,T,T1);
							(Col == 9 -> 
								falla(Fil,Col,T,T1);
								herido(Fil,Col,C1)
							)
						)
					)
				); 
				falla(Fil,Col,T,T1)
			)
		)),
		mostrarTablero(T1),
		dispara(C1,T1).
		
		
		
herido(A,B,Con):-
	nb_getval(puntos, Puntos),
	Pun is Puntos+1,
	write('le has dado a uno de mis barcos'),nl,
	(puntos == 8 -> write('Ganaste. Has undido todos mis barcos :(')),nl,
	Fam = disparos([A,B]),
	asert(Fam),
	findall(C, (disparos(C)), L), write(L), nl,
	dispara(Con).
	
falla(Fil,Col,T,T1):-
	colocarH(Fil,Col,1,'|',T,T1),
	write('Ni un poco cerca'),nl.

%ataque contra un barco enemigo
choque(S,[R|_],R1):-S=='|',R \= 'a',R1 = 'X',write("Term").
choque(S,[R|_],R1):-S=='|',R == 'a',R1 = '*',write("Term").
%ataque contra tu barco
choque(S,_,R1):-S=='-',R1 = S,write("Term").
%impresipon normal
choque(S,[R|_],R1):-R1 = S,write(E),write("Term")
.

% S indica el valor a insertar en el tablero
%funcion auxiliar para modificar valores en el tablero
modificar_lista(0,S,[_|R],[X|R]):-choque(S,R,X),nl.
modificar_lista(N,S,[E|R],[E|L]):- N1 is N-1, choque(S,R,X),nl,
									modificar_lista(N1, X, R, L).
%coloca los barcos ya sea horizontal o verticalmente 
colocarB('h',Fini,Cini,Tam,N,L,T):- colocarH(Fini,Cini,Tam,N,L,T).
colocarB('v',Fini,Cini,Tam,N,L,T):- colocarV(Fini,Cini,Tam,N,L,T).
%colocar barcos horizontales
colocarH_aux(_,0,_,T,T).	
colocarH_aux(C,Tam,S,E,L):-  	Tam>0,
										modificar_lista(C,S,E,L2),
										Tam1 is Tam-1, 
										C1 is C+1,
										colocarH_aux(C1,Tam1,S,L2,L).
colocarH(0,C,Tam,S,[E|R],[L|R]):- Tam>0, colocarH_aux(C,Tam,S,E,L).
colocarH(N,C,Tam,S,[E|R],[E|P]):- N1 is N-1, colocarH(N1,C,Tam,S,R,P).
%colocar barcos verticales
colocarV_aux(C,1,S,[E|R],[L|R]):- 		modificar_lista(C,S,E,L).
colocarV_aux(C,Tam,S,[E|R],[L|P]):- 	Tam>0, modificar_lista(C,S,E,L),
													N is Tam-1,
													colocarV_aux(C,N,S,R,P).
colocarV(0,C,Tam,S,[E|R],[L|P]):- colocarV_aux(C,Tam,S,[E|R],[L|P]).
colocarV(N,C,Tam,S,[E|R],[E|P]):- 	N1 is N-1, 
												colocarV(N1,C,Tam,S,R,P).