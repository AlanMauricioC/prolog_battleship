:- dynamic(disparos/1).
:- dynamic(disparospc/1).
:- dynamic (barco /7).
:- dynamic (cantidad_barco /1).
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
					generarTableroPC(L,X),
					write("Tu tablero"),nl,
					mostrarTablero(T),
					write("PC tablero"),nl,
					mostrarTablero(X),
					write('10 proyectiles disponibles: '),nl,
					write("Inicias tu o PC? Tu:2 PC:1"),
					read(Usuario),
					%T= usuario X=PC
					(Usuario=1->juegaPC(10,T,X);juegaUsuario(10,T,X)).

juegaPC(0,_,_):-write('Se terminaron las balas'),nl.
juegaPC(C,T,X):-C1 is C-1,
	write(C),write(" Balas restantes"),nl,
	disparaPC(T,X,X1),
	dispara(T,X,T1),
	juegaPC(C1,T1,X1).

juegaUsuario(0,_,_):-write('Se terminaron las balas'),nl.
juegaUsuario(C,T,X):-C1 is C-1,
	dispara(T,X,X1),
	disparaPC(T,X,T1),
	juegaUsuario(C1,T1,X1).
				
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

%---------------------Tablero PC----------------------------------------%
% colocarb |dirección|fila inicial|columna inicial| tamaño| nombre| tablero de entrada| tablero de salida
generarTableroPC(Entrada,Salida):-
	colocarB('h',5,5,2,1,Entrada,Tmp1),
	colocarB('h',3,5,2,2,Tmp1,Tmp2),
	colocarB('v',1,5,2,3,Tmp2,Tmp3),
	colocarB('v',5,0,2,4,Tmp3,Tmp4),
	colocarB('v',6,1,2,5,Tmp4,Salida).
	


%------------------ función para que se dispare -----------------------%

dispara(T,X,Tsalida):-
	write('Fila: '), read(Fil),
	write('Columna: '), read(Col),
	%Le di?
	nth0(Fil,X,Temp1),
	nth0(Col,Temp1,Temp2),
	(Temp2='a'->falla(Fil,Col,T,Tsalida);herido(Fil,Col,X,Tsalida)),
	mostrarTablero(Tsalida).

disparaPC(T,X,Tsalida):-
	write("PC juega ::::::::::::::::::::::"),nl,
	nb_getval(filas, M),
	nb_getval(columnas, N),
	write('Fila: '), random(0,M,Fil), write(Fil),nl,%numeros aleatorios, que estén en el rango
	write('Columna: '), random(0,N,Col),write(Col),nl,%numeros aleatorios, que estén en el rango
	nth0(Fil,T,Temp1),
	nth0(Col,Temp1,Temp2),
	(Temp2='a'->falla(Fil,Col,X,Tsalida);herido(Fil,Col,T,Tsalida)).
	%mostrarTablero(Tsalida).

		
herido(Fil,Col,T,T1):-
	nb_getval(puntos, Puntos),
	Pun is Puntos+1,
	nb_setval(puntos, Pun),
	write('le has dado a uno de mis barcos, tienes: '),write(Pun),write(" Puntos"),nl,
	(Pun = 8->write("Has ganado");nl),
	colocarH(Fil,Col,1,'-',T,T1).
	
falla(Fil,Col,T,T1):-
	colocarH(Fil,Col,1,'|',T,T1),
	write('Ni un poco cerca'),nl.

%ataque contra un barco enemigo | indica que es un usuario quien lo llama _ indica PC
%indica que le dí a algo que no es awa
choque(S,[R|_],R1):-S=='|',R \= 'a',R1 = 'X'.
choque(S,[R|_],R1):-S=='|',R == 'a',R1 = '*'.
%ataque contra tu barco
choque(S,_,R1):-S=='-',R1 = S.
%impresipon normal
choque(S,_,R1):-R1 = S
.

% S indica el valor a insertar en el tablero
%funcion auxiliar para modificar valores en el tablero
modificar_lista(0,S,[_|R],[X|R]):-choque(S,R,X).
modificar_lista(N,S,[E|R],[E|L]):- N1 is N-1, choque(S,R,X),
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