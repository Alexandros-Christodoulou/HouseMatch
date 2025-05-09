% compatibility.pl
% Περιλαμβάνει κατηγορήματα για είσοδο απαιτήσεων και έλεγχο συμβατότητας

% === Είσοδος απαιτήσεων χρήστη ===
get_user_requirements(Reqs) :-
    writeln('Δώσε τις παρακάτω πληροφορίες:'),
    writeln('=============================='),

    write('Ελάχιστο Εμβαδόν: |: '), read(MinArea),
    write('Ελάχιστος αριθμός υπνοδωματίων: |: '), read(MinRooms),
    write('Να επιτρέπονται κατοικίδια; (yes/no) |: '), read(Pets),
    write('Από ποιον όροφο και πάνω να υπάρχει ανελκυστήρας; |: '), read(ElevFloor),
    write('Ποιο είναι το μέγιστο ενοίκιο που μπορείς να πληρώσεις; |: '), read(MaxRent),
    write('Πόσα θα έδινες για ένα διαμέρισμα στο κέντρο της πόλης (στα ελάχιστα τετραγωνικά); |: '), read(CenterRent),
    write('Πόσα θα έδινες για ένα διαμέρισμα στα προάστια της πόλης (στα ελάχιστα τετραγωνικά); |: '), read(SuburbRent),
    write('Πόσα θα έδινες για κάθε τετραγωνικό διαμερίσματος πάνω από το ελάχιστο; |: '), read(ExtraSqm),
    write('Πόσα θα έδινες για κάθε τετραγωνικό κήπου; |: '), read(ExtraGarden),
    write('Ποιο είναι το ανώτατο ποσό που μπορείς να δώσεις συνολικά; |: '), read(MaxFinal),

    Reqs = requirements(MinArea, MinRooms, Pets, ElevFloor, MaxRent, CenterRent, SuburbRent, ExtraSqm, ExtraGarden, MaxFinal).

% === Υπολογισμός προσφοράς χρήστη ===
offer(
    requirements(MinArea, _, _, _, _, CenterRent, SuburbRent, ExtraPerSqm, ExtraGarden, _),
    house(_, _, Area, Center, _, _, _, Garden, _),
    Offer
) :-
    (Center == yes -> BaseOffer = CenterRent ; BaseOffer = SuburbRent),
    ExtraArea is max(0, Area - MinArea),
    ExtraCost is ExtraArea * ExtraPerSqm + Garden * ExtraGarden,
    Offer is BaseOffer + ExtraCost.


% === Έλεγχος συμβατότητας σπιτιού με απαιτήσεις ===
compatible_house(
    requirements(MinArea, MinRooms, WantsPets, ElevMinFloor,
                 _MaxRent, CenterRent, SuburbRent, ExtraPerSqm, ExtraGarden, MaxFinal),
    house(_, Rooms, Area, Center, Floor, Elevator, Pets, Garden, Rent)
) :-
    Area >= MinArea,
    Rooms >= MinRooms,
    (WantsPets == yes -> Pets == yes ; true),
    (Floor >= ElevMinFloor -> Elevator == yes ; true),
    offer(requirements(MinArea, _, _, _, _, CenterRent, SuburbRent, ExtraPerSqm, ExtraGarden, MaxFinal),
          house(_, Rooms, Area, Center, Floor, Elevator, Pets, Garden, Rent),
          OfferedAmount),
    Rent =< OfferedAmount,
    Rent =< MaxFinal.
