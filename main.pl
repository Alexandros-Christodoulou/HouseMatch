% main.pl
% Ονόματα και ΑΕΜ:
% ΑΕΜ1 - Όνομα1
% ΑΕΜ2 - Όνομα2
% (Προσθέστε όσους χρειάζεται)

:- consult('houses.pl').
:- consult('requests.pl').
:- consult('compatibility.pl').
% Εκκίνηση του συστήματος
run :-
    repeat,
    nl,
    write('Μενού:'), nl,
    write('======'), nl,
    write('1 - Προτιμήσεις ενός πελάτη'), nl,
    write('2 - Μαζικές προτιμήσεις πελατών'), nl,
    write('3 - Επιλογή πελατών μέσω δημοπρασίας'), nl,
    write('0 - Έξοδος'), nl,
    nl,
    write('Επιλογή: '),
    read(Choice),
    handle_choice(Choice),
    Choice == 0, !.  % Τερματισμός όταν η επιλογή είναι 0

% Διαχείριση επιλογών μενού
handle_choice(1) :-
    writeln('--- Διαδραστική λειτουργία πελάτη ---'), nl,
    get_user_requirements(Reqs),
    nl, writeln('Συμβατά σπίτια:'),
    house(Address, Rooms, Floor, Area, Rent, Garden, Elevator, Center, Pets),
    compatible_house(Reqs, house(Address, Rooms, Floor, Area, Rent, Garden, Elevator, Center, Pets)),
    format("- ~w (~w€)~n", [Address, Rent]),
    fail.


handle_choice(2) :-
    % Θα συμπληρωθεί αργότερα με batch mode
    writeln('--- Μαζικές προτιμήσεις πελατών ---'), nl,
    fail.

handle_choice(3) :-
    % Θα συμπληρωθεί αργότερα με λειτουργία δημοπρασίας
    writeln('--- Επιλογή μέσω δημοπρασίας ---'), nl,
    fail.

handle_choice(0) :-
    writeln('Έξοδος από το σύστημα.'), nl.

handle_choice(_) :-
    writeln('Επίλεξε έναν αριθμό μεταξύ 0 έως 3!'), nl,
    fail.

