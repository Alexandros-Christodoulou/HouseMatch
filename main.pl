% -------------------------------
% Φοιτητές: [ΒΑΛΕ ΟΝΟΜΑΤΑ & ΑΕΜ]
% Σέργιος Κυρατζιής 4483
% Αλέξανδρος Χριστοδούλου 4374
%
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
    write('Επιλογή:'),
    read(Choice),
    handle_choice(Choice),
    Choice == 0, !.

% Χειρισμός επιλογών μενού
handle_choice(1) :-
    writeln(' '),
    writeln('--- Διαδραστική λειτουργία πελάτη ---'),
    writeln(' '),
    interactive_mode, !.

handle_choice(2) :-
    writeln(' '),
    writeln('--- Μαζική λειτουργία πελατών ---'),
    writeln(' '),
    batch_mode, !.

handle_choice(3) :-
    writeln(' '),
    writeln('--- Λειτουργία δημοπρασίας ---'),
    writeln(' '),
    auction_mode, !.

handle_choice(0) :-
    writeln(' '),
    !.

handle_choice(_) :-
    writeln(' '),
    writeln('Επίλεξε έναν αριθμό μεταξύ 0 έως 3!'), nl,
    writeln(' ').

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
    write('Να επιτρέπονται κατοικίδια; (yes/no) '), read(Pets),
    write('Από ποιον όροφο και πάνω να υπάρχει ανελκυστήρας; '), read(FloorLimit),
    write('Ποιο είναι το μέγιστο ενοίκιο που μπορείς να πληρώσεις; '), read(MaxTotal),
    write('Πόσα θα έδινες για ένα διαμέρισμα στο κέντρο της πόλης (στα ελάχιστα τετραγωνικά); '), read(MaxCenter),
    write('Πόσα θα έδινες για ένα διαμέρισμα στα προάστια της πόλης (στα ελάχιστα τετραγωνικά); '), read(MaxSuburb),
    write('Πόσα θα έδινες για κάθε τετραγωνικό διαμερίσματος πάνω από το ελάχιστο; '), read(ExtraAreaPrice),
    write('Πόσα θα έδινες για κάθε τετραγωνικό κήπου; '), read(GardenPrice),
    Reqs = requirements(MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice, MaxTotal),writeln(' ').

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
% Μετατροπή request/10 σε requirements/10
request_to_requirements(
    request(_, MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice),
    requirements(MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice, MaxTotal)
).


batch_mode :-
    forall(
        request(Name, MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice),
        (
            format('Κατάλληλα διαμερίσματα για τον πελάτη: ~w:~n', [Name]),writeln('======================================='),
            request_to_requirements(
                request(Name, MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice),
                Reqs
            ),
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
                    writeln('Δεν υπάρχει κατάλληλο σπίτι!')
                ;
                    print_suitable_houses(SuitableHouses),
                    find_best_house(SuitableHouses, Best),
                    (
                        Best \= none ->
                            format('Προτείνεται η ενοικίαση του διαμερίσματος στην διεύθυνση: ~w~n~n', [Best])
                        ;
                            true
                    )
            )
        )
    ).



find_houses(Results) :-
    findall(
        result(Name, SuitableHouses, BestAddress),
        (
            request(Name, MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice),
            request_to_requirements(
                request(Name, MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice),
                Reqs
            ),
            findall(
                house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent),
                (
                    house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent),
                    compatible_house(Reqs, house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent))
                ),
                SuitableHouses
            ),
            (SuitableHouses = [] ->
                BestAddress = none
            ;
                find_best_house(SuitableHouses, BestAddress)
            )
        ),
        Results
    ).


find_bidders(HouseResults, BiddersList) :-
    findall(
        Address,
        (
            member(result(_, _, Address), HouseResults),
            Address \= none
        ),
        AddressesWithDuplicates
    ),
    sort(AddressesWithDuplicates, UniqueAddresses),
    findall(
        bidders(Address, Names),
        (
            member(Address, UniqueAddresses),
            findall(
                Name,
                member(result(Name, _, Address), HouseResults),
                Names
            )
        ),
        BiddersList
    ).


get_request_by_name(Name, Req) :-
    request(Name, MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice),
    Req = requirements(MinArea, MinRooms, Pets, FloorLimit, MaxTotal, MaxCenter, MaxSuburb, ExtraAreaPrice, GardenPrice, MaxTotal).

find_best_bidders(BiddersList, Winners) :-
    findall(
        winner(Address, BestName),
        (
            member(bidders(Address, Names), BiddersList),
            findall(
                offer(Name, Amount),
                (
                    member(Name, Names),
                    get_request_by_name(Name, Reqs),
                    house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent),
                    offer(Reqs, house(Address, Rooms, Area, Center, Floor, Elevator, PetsAllowed, Garden, Rent), Amount)
                ),
                Offers
            ),
            max_offer(Offers, BestName)
        ),
        Winners
    ).

max_offer([offer(Name, _)], Name).
max_offer([offer(Name1, Amount1), offer(Name2, Amount2) | Rest], BestName) :-
    (Amount1 >= Amount2 ->
        max_offer([offer(Name1, Amount1) | Rest], BestName)
    ;
        max_offer([offer(Name2, Amount2) | Rest], BestName)
    ).

remove_houses(Results, Winners, UpdatedResults) :-
    findall(
        result(Name, NewSuitable, NewBest),
        (
            member(result(Name, Suitable, _), Results),
            (
                member(winner(WonAddress, Name), Winners) ->
                    % Ο πελάτης είναι νικητής, κρατά μόνο το σπίτι που του ανατέθηκε
                    include([H]>>(H = house(WonAddress,_,_,_,_,_,_,_,_)), Suitable, Filtered),
                    NewSuitable = Filtered,
                    NewBest = WonAddress
                ;
                    % Δεν είναι νικητής – αφαιρεί από τη λίστα του όσα σπίτια έχουν ανατεθεί αλλού
                    findall(WonA, member(winner(WonA, _), Winners), WonAddresses),
                    exclude([H]>>(H = house(Address,_,_,_,_,_,_,_,_), member(Address, WonAddresses)), Suitable, NewSuitable),
                    (NewSuitable = [] -> NewBest = none ; find_best_house(NewSuitable, NewBest))
            )
        ),
        UpdatedResults
    ).

refine_houses(InitialResults, FinalResults) :-
    refine_loop(InitialResults, FinalResults).

refine_loop(CurrentResults, FinalResults) :-
    find_bidders(CurrentResults, Bidders),
    has_conflict(Bidders),  % αν υπάρχουν συγκρούσεις
    find_best_bidders(Bidders, Winners),
    remove_houses(CurrentResults, Winners, NewResults),
    refine_loop(NewResults, FinalResults).  % επαναληπτικά

refine_loop(CurrentResults, CurrentResults).  % τερματισμός: χωρίς συγκρούσεις

has_conflict(Bidders) :-
    member(bidders(_, Names), Bidders),
    length(Names, L),
    L > 1,
    !.


auction_mode :-
    find_houses(H),
    refine_houses(H, Final),
    forall(
        member(result(Name, _, Best), Final),
        (
            (Best == none ->
                format('O πελάτης ~w δεν θα νοικιάσει κάποιο διαμέρισμα!~n', [Name])
            ;
                format('O πελάτης ~w θα νοικιάσει το διαμέρισμα στην διεύθυνση: ~w~n', [Name, Best])
            )
        )
    ).




























