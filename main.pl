% -------------------------------
% Φοιτητές: [ΒΑΛΕ ΟΝΟΜΑΤΑ & ΑΕΜ]
% Μάθημα: Υπολογιστική Λογική & Λογικός Προγραμματισμός
% Αρχείο: main.pl
% Περιγραφή: Πρόγραμμα επιλογής διαμερίσματος
% -------------------------------

% Φόρτωση δεδομένων
:- consult('houses.pl').
:- consult('requests.pl').

% Εκκίνηση προγράμματος
run :-
    repeat,
    nl, writeln('Μενού:'),
    writeln('======'),
    writeln('1 - Προτιμήσεις ενός πελάτη'),
    writeln('2 - Μαζικές προτιμήσεις πελατών'),
    writeln('3 - Επιλογή πελατών μέσω δημοπρασίας'),
    writeln('0 - Έξοδος'),
    write('Επιλογή: '),
    read(Choice),
    handle_choice(Choice),
    Choice == 0, !.

% Χειρισμός επιλογών μενού
handle_choice(1) :-
    writeln(' '),
    writeln('--- Διαδραστική λειτουργία πελάτη ---'),
    interactive_mode, !.

handle_choice(2) :-
    writeln('--- Μαζική λειτουργία πελατών ---'),
    batch_mode, !.

handle_choice(3) :-
    writeln(' '),
    writeln('--- Λειτουργία δημοπρασίας ---'),
    auction_mode, !.

handle_choice(0) :-
    writeln(' '),
    writeln('Έξοδος από το πρόγραμμα...'), !.

handle_choice(_) :-
    writeln(' '),
    writeln('Επίλεξε έναν αριθμό μεταξύ 0 έως 3!'), nl.

% ================================
% Διαδραστική λειτουργία πελάτη
% ================================
interactive_mode :-
    get_user_requirements(Reqs),
    findall(
        house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent),
        (
            house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent),
            compatible_house(Reqs, house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent))
        ),
        SuitableHouses
    ),
    (
        SuitableHouses = [] ->
            writeln(' '),writeln('Δεν υπάρχει κατάλληλο σπίτι!')
        ;
            print_suitable_houses(SuitableHouses),
            find_best_house(SuitableHouses, Best),
            (
                Best \= none ->
                    format('Προτείνεται η ενοικίαση του διαμερίσματος στην διεύθυνση: ~w~n', [Best])
                ;
                    true
            )
    ).


% Είσοδος απαιτήσεων από χρήστη
get_user_requirements(Reqs) :-
    writeln('Δώσε τις παρακάτω πληροφορίες:'),
    writeln('=============================='),
    write('Ελάχιστο Εμβαδόν '), read(MinArea),
    write('Ελάχιστος αριθμός υπνοδωματίων  '), read(MinRooms),
    write('Να επιτρέπονται κατοικίδια; (yes/no) |: '), read(Pets),
    write('Από ποιον όροφο και πάνω να υπάρχει ανελκυστήρας; '), read(FloorLimit),
    write('Ποιο είναι το μέγιστο ενοίκιο που μπορείς να πληρώσεις; '), read(MaxTotal),
    write('Πόσα θα έδινες για ένα διαμέρισμα στο κέντρο της πόλης (στα ελάχιστα τετραγωνικά); '), read(MaxCenter),
    write('Πόσα θα έδινες για ένα διαμέρισμα στα προάστια της πόλης (στα ελάχιστα τετραγωνικά); '), read(MaxSuburb),
    write('Πόσα θα έδινες για κάθε τετραγωνικό διαμερίσματος πάνω από το ελάχιστο; |: '), read(ExtraAreaPrice),
    write('Πόσα θα έδινες για κάθε τετραγωνικό κήπου; '), read(GardenPrice),
    Reqs = requirements(MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice, MaxTotal).

% Εκτύπωση συμβατών σπιτιών

print_suitable_houses([house(Address, Rooms, Area, Center, Floor, _, Pets, Garden, Rent)|Rest]) :-
    format('Κατάλληλο σπίτι στην διεύθυνση: ~w~n', [Address]),
    format('Υπνοδωμάτια: ~d~n', [Rooms]),
    format('Εμβαδόν: ~d~n', [Area]),
    format('Εμβαδόν κήπου: ~d~n', [Garden]),
    format('Είναι στο κέντρο της πόλης: ~w~n', [Center]),
    format('Επιτρέπονται κατοικίδια: ~w~n', [Pets]),
    format('Όροφος: ~d~n', [Floor]),
    format('Ενοίκιο: ~d~n~n', [Rent]),
    print_suitable_houses(Rest).

print_suitable_houses([]) :-
    writeln(' ').


% ================================
% Επιλογή & συμβατότητα σπιτιού
% ================================

compatible_house(
    requirements(MinArea, MinRooms, Pets, FloorLimit, _, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice, MaxAllowed),
    house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent)
) :-
    Area >= MinArea,
    Rooms >= MinRooms,
    (Pets == yes -> PetsAllowed == yes ; true),
    (Floor >= FloorLimit -> Elevator == yes ; true),
    offer(requirements(MinArea, MinRooms, Pets, FloorLimit, _, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice, MaxAllowed),
          house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent),
          Offer),
    Rent =< Offer.

% Υπολογισμός προσφοράς πελάτη
offer(requirements(MinArea, _, _, _, _, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice, MaxAllowed),
      house(_, _, Area, Center, _, _, _, Garden, _),
      Offer) :-

    (Center == yes -> Base is MaxCenter ; Base is MaxSuburb),
    ExtraArea is max(0, Area - MinArea),
    ExtraAreaCost is ExtraArea * ExtraAreaPrice,
    GardenCost is Garden * GardenPrice,
    OfferTemp is Base + ExtraAreaCost + GardenCost,
    Offer is min(OfferTemp, MaxAllowed).

% Προτείνει το καλύτερο σπίτι από τη λίστα
find_best_house(Houses, BestAddress) :-
    find_cheaper(Houses, Cheapest),
    find_biggest_garden(Cheapest, GardenBiggest),
    find_biggest_house(GardenBiggest, [house(BestAddress, _, _, _, _, _, _, _, _)]).

find_cheaper(Houses, Cheapest) :-
    findall(R, (member(house(_, _, _, _, _, _, _, _, R), Houses)), Rents),
    min_list(Rents, MinRent),
    include(
        [house(_, _, _, _, _, _, _, _, Rent)] >> (Rent =:= MinRent),
        Houses,
        Cheapest
    ).

find_biggest_garden(Houses, Biggest) :-
    findall(G, (member(house(_, _, _, _, _, _, _, G, _), Houses)), Gardens),
    max_list(Gardens, MaxGarden),
    include(
        [house(_, _, _, _, _, _, _, G, _)] >> (G =:= MaxGarden),
        Houses,
        Biggest
    ).

find_biggest_house(Houses, Biggest) :-
    findall(A, (member(house(_, _, A, _, _, _, _, _, _), Houses)), Areas),
    max_list(Areas, MaxArea),
    include(
        [house(_, _, A, _, _, _, _, _, _)] >> (A =:= MaxArea),
        Houses,
        Biggest
    ).


% ================================
% Υπόλοιπα κατηγορήματα θα υλοποιηθούν στα επόμενα βήματα
% ================================

batch_mode :-
    writeln('[Υπό κατασκευή]').

auction_mode :-
    writeln('[Υπό κατασκευή]').


































