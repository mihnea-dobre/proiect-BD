# Aplicatie pentru rezervarea locurilor de parcare



## 1. Descrierea proiectului

O aplicatie pentru rezervarea locurilor de parcare ofera utilizatorilor, in acest caz soferilor, oportunitatea de a cauta un spatiu liber pentru a isi parca masina. 

Fiecare masina identificata printr-un numar de inmatriculare poate sa ocupe doar un singur loc identificat printr-un id unic, de asemenea soferul isi ofera informatii de baza pentru a putea fi identificat ca unicul detinator al masinii. 

Locurile de parcare pot fi platite/gratuite, de asemenea pot fi normale, subterane de handicap sau pentru masini electrice. Un spatiu contine mai multe locuri de parcare si este identificat printr-o adresa, iar acesta are o capacitate maxima.

Desi este evident posibil ca un sofer sa detina mai multe masini, pentru conventie vom spune ca un sofer are o singura masina care ocupa un singur loc de parcare.

De asemenea, se vor oferi servicii care permite utilizatorului sa cunoasca exact care e rata pe un loc de parcare platit, deci trebuie sa avem o legatura cu municipiul care supravegheaza fiecare spatiu cu locuri de parcare.

Locuri de parcare de asemenea sunt separate in mai multe zone - zona albastra, zona galbena (rezidentiala), zona verde, care toate vor avea un efect asupra ratei locului de parcare. De exemplu zona verde are doar locuri de parcare gratis.

Pentru fiecare loc de parcare se va inregistra o rezervare care va avea o data si durata. Pentru fiecare rezervare vom avea si plata bazata pe durata.

In plus, se va permite lasarea recenziilor pentru a informa soferii unde se gasesc cele mai bune locuri de parcare, sau daca sunt posibile probleme cu spatiul respectiv. Se va mai si permite un abonament pentru utilizatori frecventi care ofera anumite bonusuri si reduceri.

## 2. Constrangeri

**Integritatea entitatilor**
- Toate tabelele au cheie primara diferita de NULL.


**Constrangeri de Unicitate**
- Toate cheile primare sunt unice.
In afara de chei primare, urmatoarele atribute trebuie sa fie marcate cu **UNIQUE**:
- nr_matricol (*Masina*), vrem un numar pe masina. Poate functiona ca o cheie primara teoretic dar id_masina este mai eficient.
- email (*User*), vrem sa putem identifica user-ul in mod unic.
- username (*User*), la fel ca mai sus, alternativa pentru logarea userului in cont.
- adresa (*Spatiu*), adresele se pot suprapune in viata reala dar nu vrem spatii duplicate.
- cod_fiscal (*Municipiu*), alt candidat pentru cheie primara pentru care folosim in schimb id_municipiu, dar in realitate este unic.
**Constrangeri de verificare**
Urmatoarele date trebuie sa fie valide, cu urmatoarele conditii:
- data_sfarsit > data_inceput (*Rezervare*), o rezervare nu se poate termina inainte sa inceapa.
- data_inceput >= CURRENT_DATE (*Rezervare*), nu putem incepe o rezervare in trecut.
- capacitate_maxima > 0 (*Spatiu*), un spatiu trebuie sa aiba macar un loc de parcare.
- suma >= 0 (*Plata*), nu putem avea plati negative.
- rating in (1,2,3,4,5) (*Recenzie*), avem un sistem pe stele.
- data_expirare > data_activare (*Abonament*), un abonament nu poate expira inainte sa fie activat.
- metoda_plata (*Plata*) in ('CARD', 'SMS', 'CASH', 'GIFTCARD'), doar aceste valori sunt valide; daca e NULL inseamna ca a fost loc gratis.
- nr_matricol (*Masina*) in format B-123-ABC sau AB-12-XYZ. Vom adauga un Regex.
- status (*Rezervare*) in ('Activa', 'Finalizata', 'Anulata').
**Constrangeri de suprapunere**
- disponibil (*LocParcare*) = TRUE pentru a putea fi rezervat. Doua masini nu pot inregistra acelasi loc de parcare.
- fk id_loc (*Masina*) trebuie sa fie NULL pentru ca o masina sa poata rezerva un loc. O masina nu poate inregistra doua locuri de parcare simultan.
- fk id_user (*Masina*) trebuie sa fie UNIQUE pentru conventia noastra de un user per masina. Astfel un user nu poate fi identificat dupa doua masini.
**Constrangeri FK**
- Daca un *USER* isi sterge contul se va face si stergere in cascada a tot istoricului, deci **CASCADE**. Alternativ, putem pune **RESTRICT** (nu isi poate sterge contul daca are o rezervare activa).
- Toate subentitatile necesita un pk+fk de la tabelul parinte; id_loc pentru subentitatile lui *LOC* si id_zona pentru subentitatile lui *ZONA*.
- fk id_user (*Abonament*) cu atributul 'activ' poate aparea o singura data <=> nu putem plati doua abonamente in acelasi timp.
**Constrangeri specifice**
- Daca avem un *LOC* in *ZONA_VERDE* => suma = 0 (*Plata*).
- Nr de inregistrari din *LOC* asociate lui id_spatiu nu trebuie sa depaseasca capacitate (*Spatiu*).
- Ne asiguram ca id_loc nu este simultan ocupat si in LocGratis si in LocPlatit. Un *LOC DE PARCARE* nu poate fi simultan gratis si platit.
- Doar o *MASINA* marcata ca Electric poate ocupa un LocElectric.
- Un *USER* poate lasa o *RECENZIE* daca si numai daca are cel putin o *REZERVARE* finalizata si platita: atributul status va identifica daca o rezervare este finalizata.



## 3. Entitati

*Entitatile* noastre, in format de entitate -> cheie_primara: 
- **LocParcare** -> id_loc
- **Masina** -> id_masina
- **User** -> id_user
- **Spatiu** -> id_spatiu
- **Rezervare** -> id_rezervare
- **Municipiu** -> id_municipiu
- **ZonaParcare** -> id_zona
- **Recenzie** -> id_recenzie
- **Abonament** -> id_abonament
- **Plata** -> id_plata

*Subentitatile* noastre, grupate dupa entitatea respectiva:
### LocParcare -> id_loc (pk+fk)
- **LocPlatit**
- **LocGratis**
- **LocSubteran**
- **LocHandicap**
- **LocElectric**
### ZonaParcare -> id_zona (pk+fk)
- **ZonaAlbastra**
- **ZonaRezidentiala**
- **ZonaVerde**

*Avem si tabelul asociativ **SpatiuParcare** -> __**id_spatiu+id_zona**__ (pk+fk).*

## 4. Relatii

- USER(1)-->ABONAMENT(1|0) Un *USER* **poate** avea un *ABONAMENT*; un *ABONAMENT* **trebuie** sa fie detinut de un *USER*.
- USER(1)-->RECENZIE(M|0) Un *USER* **poate** lasa o *RECENZIE*; o *RECENZIE* **trebuie** sa fie lasata de un *USER*.
- USER(1)-->MASINA(1|1) Un *USER* **trebuie** sa aibe o *MASINA*; o *MASINA* **trebuie** sa fie detinuta de un *USER*.
- MASINA(1|1)-->REZERVARE(M|0) O *MASINA* **poate** sa aibe mai multe *REZERVARI*; o *REZERVARE* **trebuie** sa aibe o *MASINA* inregistrata.
- REZERVARE(1|1)-->PLATA(1|0) O *REZERVARE* **poate** fi *PLATITA*; o *PLATA* trebuie sa fie inregistrata pentru o *REZERVARE*.
- REZERVARE(M|0)-->LOC_PARCARE(1|1) Mai multe *REZERVARI* **trebuie** inregistrate intr-un *LOC DE PARCARE*; un *LOC DE PARCARE* **poate** avea mai multe *REZERVARI*.
- RECENZIE(M|0)-->SPATIU(1|1) Mai multe *RECENZII* **trebuie** alocate unui *SPATIU*; un *SPATIU* **poate** avea mai multe *RECENZII*.
- SPATIU(M|1)-->MUNICIPIU(1|1) Mai multe *SPATII* **trebuie** monitorizate de un *MUNICIPIU*; un *MUNICIPIU* **trebuie** sa monitorizeze mai multe *SPATII*.
- SPATIU(M)-->ZONA_PARCARE(M) Mai multe *SPATII* **trebuie** sa aibe mai multe *ZONE DE PARCARE*; mai multe *ZONE DE PARCARE* **trebuie** sa se afle intr-un *SPATIU*.
- ZONA_PARCARE(1|1)-->LOC_PARCARE(M|1) O *ZONA DE PARCARE* **trebuie** sa aibe mai multe *LOCURI DE PARCARE*; mai multe *LOCURI DE PARCARE* **trebuie** sa se afle intr-o *ZONA DE PARCARE*.

## 5. Atribute

| ENTITATE | ATRIBUT | TIP DATE | CONSTRANGERI | VALORI IMPLICITE (daca sunt) |
|----------|---------|----------|--------------|------------------------------|
| **USER** | id_user | INT | PK, Auto-increment | |
| | nume | VARCHAR(50) | NOT NULL | |
| | email | VARCHAR(100) | NOT NULL, UNIQUE | |
| | username | VARCHAR(30) | NOT NULL, UNIQUE | |
| | data_reg | DATETIME | NOT NULL | CURRENT_TIMESTAMP |
| **MASINA** | id_masina | INT | PK, Auto-increment | |
| | nr_matricol | VARCHAR(15) | NOT NULL, UNIQUE | ex. 'B123ABC' |
| | este_elec | BOOLEAN | NOT NULL | FALSE |
| | id_user | INT | FK, UNIQUE | |
| **MUNICIPIU** | id_municipiu | INT | PK, Auto-increment | |
| | nume | VARCHAR(255) | NOT NULL | |
| | judet | VARCHAR(50) | NOT NULL | |
| | cod_fiscal | INT | NOT NULL, UNIQUE | |
| **SPATIU** | id_spatiu | INT | PK, Auto-increment | |
| | adresa | VARCHAR(255) | NOT NULL, UNIQUE | |
| | capacitate | INT | NOT NULL, CHECK(capacitate>0) | |
| | id_municipiu | INT | FK | | 
| **REZERVARE** | id_rezervare | INT | PK, Auto-increment | |
| | data_inceput | DATETIME | NOT NULL, CHECK (data_inceput>=CURRENT_DATE) | |
| | data_sfarsit | DATETIME | NOT NULL, CHECK (data_sfarsit>data_inceput) | |
| | status | VARCHAR(20) | NOT NULL | 'Activa', 'Finalizata', 'Anulata' |
| | id_masina | INT | FK | |
| | id_loc | INT | FK | |
| **PLATA** | id_plata | INT | PK, Auto-increment | |
| | suma | DECIMAL(10,2) | CHECK(suma>=0) | |
| | data_plata | DATETIME | NOT NULL, CHECK(data_plata>=CURRENT_DATE) | |
| | metoda | VARCHAR(20) | | 'CARD', 'SMS', 'CASH', 'GIFTCARD' |
| | id_rezervare | INT | FK, UNIQUE | |
| **ZONA** | id_zona | INT | PK, Auto-increment | |
| | tarif_ora | DECIMAL(5,2) | NOT NULL | |
| | tip_zona | VARCHAR(20) | NOT NULL | 'Albastra', 'Verde', 'Rezidentiala' |
| **LOC** | id_loc | INT | PK, Auto-increment | |
| | nr_loc | VARCHAR(10) | NOT NULL | |
| | disponibil | BOOLEAN | NOT NULL | TRUE |
| | tip_special | VARCHAR(20) | NOT NULL | 'Normal', 'Handicap', 'Electric' |
| | id_zona | INT | FK | |
| **SPATIU_PARCARE** | id_spatiu | INT | PK, FK | |
| | id_zona | INT | PK, FK | |
| **RECENZIE** | id_recenzie | INT | PK, Auto-increment | |
| | rating | INT | CHECK(rating BETWEEN 1 AND 5) | |
| | comentariu | VARCHAR(255) | | |
| | id_user | INT | FK | |
| | id_spatiu | INT | FK | |
| **ABONAMENT** | id_abonament | INT | PK, Auto-increment | |
| | tip | VARCHAR(20) | NOT NULL | 'Lunar', 'Anual' |
| | pret | DECIMAL(10,2) | NOT NULL | |
| | data_activare | DATE | NOT NULL, CHECK (data_activare>=CURRENT_DATE) | |
| | data_exp | DATE | NOT NULL, CHECK (data_exp>data_activare) | |
| **LOC_PLATIT** | id_loc | INT | PK,FK | |
| | tarif_suplimentar | DECIMAL(10,2) | | |
| **LOC_GRATIS** | id_loc | INT | PK,FK | |
| | timp_max_loc | INT | NOT NULL | |
| **LOC_HANDICAP** | id_loc | INT | PK, FK | |
| | doc_necesar | VARCHAR(50) | NOT NULL | ex. Seria autorizatiei necesare | 
| **LOC_ELECTRIC** | id_loc | INT | PK, FK | |
| | putere | INT | NOT NULL, CHECK(putere>0) | |
| **LOC_SUBTERAN** | id_loc | INT | PK, FK | |
| | nivel | INT | CHECK (nivel<0) | |   
| **ZONA_VERDE** | id_zona | INT | PK,FK | |
| | timp_max | INT | NOT NULL, CHECK(timp_max<=120) | |
| **ZONA_ALBASTRA** | id_zona | INT | PK,FK | |
| | interval_max | INT | NOT NULL, CHECK(interval_max<=120) | |
| | penalizare | DECIMAL(5,2) | CHECK (penalizare>tarif_ora) | | 
| **ZONA_REZIDENTIALA** | id_zona | INT | PK, FK | |
| | id_permis_necesar | INT | NOT NULL | |
## 6. Diagrama ERD


![Diagrama ERD](./erd/erd.png)


## 7. Diagrama conceptuala


![Diagrama ERD Conceptuala](./erd/erd_concept.png)

## 8. Scheme relationale

Format: ENTITATE (**PK**, *FK*, __**PK+FK**__, atribute)

1. USER (**id_user**, nume, email, username, parola, data_reg)
2. MASINA (**id_masina**, nr_matricol, este_elec, *id_user*)
3. MUNICIPIU (**id_municipiu**, nume, judet, cod_fiscal)
4. SPATIU (**id_spatiu**, adresa, capacitate, *id_municipiu*)
5. REZERVARE (**id_rezervare**, data_inceput, data_sfarsit, status, *id_masina*, *id_loc*)
6. PLATA (**id_plata**, suma, data_plata, metoda, *id_rezervare*)
7. ZONA (**id_zona**, tarif_ora, tip_zona)
8. LOC (**id_loc**, nr_loc, disponibil, tip_special, *id_zona*)
9. SPATIU_PARCARE (__**id_spatiu**__, __**id_zona**__)
10. RECENZIE (**id_recenzie**, rating, comentariu, *id_user*, *id_spatiu*)
11. ABONAMENT (**id_abonament**, tip, pret, data_activare, data_exp)
12. LOC_PLATIT (__**id_loc**__, tarif_suplimentar)
13. LOC_GRATIS (__**id_loc**__, timp_max_loc)
14. LOC_HANDICAP (__**id_loc**__, doc_necesar)
15. LOC_ELECTRIC (__**id_loc**__, putere)
16. LOC_SUBTERAN (__**id_loc**__, nivel)
17. ZONA_VERDE (__**id_zona**__, timp_max)
18. ZONA_ALBASTRA (__**id_zona**__, interval_max, penalizare)
19. ZONA_REZIDENTIALA (__**id_zona**__, id_permis_necesar)



## 9. Normalizare

# FN1

Fiecare atribut este atomic, adica avem o sigura valoare in fiecare celula.
De exemplu, in loc sa avem in mod generic 'date_user' in tabelul USER, am separat pe mai multi identificatori: email, nume, adresa.
Un atribut care in teorie ar putea incalca FN1 ar fi 'adresa', dar fiindca este facut UNIQUE actioneaza ca un identificator unic si deci este atomic.

# FN2

Tabelul este in FN1 si toate atributele non-cheie depind de intreaga cheie primara. Se aplica mai ales la tabele cu cheie compuse.
Se observa in tabelul de intersectie SPATIU_PARCARE cu cheia compusa (id_spatiu, id_zona); fiindca nu am adaugat nici un atribut non-cheie in afara tabelelor respective. Daca am fi adaugat nume_zona, aceasta ar depinde de id_zona si nu de id_spatiu, ceea ce ar incalca FN2.
In rest, este clar FN2.

# FN3

Tabelul este in FN2, si nu exista dependente tranzitive, adica niciun atribut non-cheie nu depinde de o cheie primara prin intermediul unui alt atribut non-cheie.
La conceputalizarea proiectului, entitatea SPATIU avea forma (**id_spatiu**, adresa, id_municipiu, *nume_municipiu*).
Aici clar nume_muncipiu depinde de **id_spatiu** in mod tranzitiv prin id_municipiu. Spargand in doua tabele SPATIU si MINICPIU s-a realizat FN3.

## 10. Secventa pentru inregistrare

secventa pentru generarea identificatorilor folositi in inserarea datelor (nu neaparat pentru toate)

```sql CREATE SEQUENCE parcare_seq

  START WITH 100

  INCREMENT BY 1

  NOCACHE;
```

![Exercitiul 10](./ex10/ex10.png)

## 11. Crearea tabelelor si inserarea

# a. Creare tabele
```sql
CREATE TABLE MUNICIPIU (
    id_municipiu INT PRIMARY KEY,
    nume_municipiu VARCHAR2(50) NOT NULL,
    judet VARCHAR2(50) NOT NULL,
    cod_fiscal VARCHAR2(20) UNIQUE
);

CREATE TABLE USERS (
    id_user INT PRIMARY KEY,
    nume VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    username VARCHAR2(30) UNIQUE,
    data_reg DATE DEFAULT CURRENT_DATE
);

CREATE TABLE ZONA_PARCARE (
    id_zona INT PRIMARY KEY,
    tarif_ora NUMBER(5,2) NOT NULL,
    tip_zona VARCHAR2(20)
);

CREATE TABLE SPATIU (
    id_spatiu INT PRIMARY KEY,
    adresa VARCHAR2(255) UNIQUE,
    capacitate INT CHECK (capacitate > 0),
    id_municipiu INT,
    CONSTRAINT fk_spatiu_muni FOREIGN KEY (id_municipiu) REFERENCES MUNICIPIU(id_municipiu)
);

CREATE TABLE MASINA (
    id_masina INT PRIMARY KEY,
    nr_matricol VARCHAR2(15) UNIQUE,
    este_elec NUMBER(1) DEFAULT 0,
    id_user INT UNIQUE,
    CONSTRAINT fk_masina_user FOREIGN KEY (id_user) REFERENCES USERS(id_user)
);

CREATE TABLE LOC_PARCARE (
    id_loc INT PRIMARY KEY,
    nr_loc VARCHAR2(10) NOT NULL,
    disponibil NUMBER(1) DEFAULT 1,
    id_zona INT,
    CONSTRAINT fk_loc_zona FOREIGN KEY (id_zona) REFERENCES ZONA_PARCARE(id_zona)
);

CREATE TABLE REZERVARE (
    id_rezervare INT PRIMARY KEY,
    data_inceput TIMESTAMP NOT NULL,
    data_sfarsit TIMESTAMP NOT NULL,
    status VARCHAR2(20) DEFAULT 'Activa',
    id_masina INT,
    id_loc INT,
    CONSTRAINT fk_rez_masina FOREIGN KEY (id_masina) REFERENCES MASINA(id_masina),
    CONSTRAINT fk_rez_loc FOREIGN KEY (id_loc) REFERENCES LOC_PARCARE(id_loc)
);

CREATE TABLE SPATIU_PARCARE (
    id_spatiu INT,
    id_zona INT,
    PRIMARY KEY (id_spatiu, id_zona),
    CONSTRAINT fk_sp_pc_spatiu FOREIGN KEY (id_spatiu) REFERENCES SPATIU(id_spatiu),
    CONSTRAINT fk_sp_pc_zona FOREIGN KEY (id_zona) REFERENCES ZONA_PARCARE(id_zona)
);

CREATE TABLE ABONAMENT (
    id_abonament INT PRIMARY KEY,
    tip VARCHAR2(20) NOT NULL,
    pret NUMBER(10,2) NOT NULL,
    data_activare DATE NOT NULL,
    data_exp DATE NOT NULL,
    id_user INT,
    CONSTRAINT fk_abon_user FOREIGN KEY (id_user) REFERENCES USERS(id_user),
    CONSTRAINT chk_abon_date CHECK (data_exp > data_activare)
);

CREATE TABLE PLATA (
    id_plata INT PRIMARY KEY,
    suma DECIMAL(10,2) CHECK (suma >= 0),
    data_plata DATE DEFAULT CURRENT_TIMESTAMP,
    metoda VARCHAR2(20),
    id_rezervare INT UNIQUE,
    CONSTRAINT fk_plata_rez FOREIGN KEY (id_rezervare) REFERENCES REZERVARE(id_rezervare)
);

CREATE TABLE RECENZIE (
    id_recenzie INT PRIMARY KEY,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comentariu VARCHAR2(255),
    data_postare DATE DEFAULT CURRENT_DATE,
    id_user INT,
    id_spatiu INT,
    CONSTRAINT fk_rec_user FOREIGN KEY (id_user) REFERENCES USERS(id_user),
    CONSTRAINT fk_rec_spatiu FOREIGN KEY (id_spatiu) REFERENCES SPATIU(id_spatiu)
);

--subentitati loc
CREATE TABLE LOC_PLATIT (
    id_loc INT PRIMARY KEY,
    tarif_suplimentar NUMBER(10,2),
    CONSTRAINT fk_lp_parent FOREIGN KEY (id_loc) REFERENCES LOC_PARCARE(id_loc)
);

CREATE TABLE LOC_GRATIS (
    id_loc INT PRIMARY KEY,
    timp_max_loc INT NOT NULL,
    CONSTRAINT fk_lg_parent FOREIGN KEY (id_loc) REFERENCES LOC_PARCARE(id_loc)
);

CREATE TABLE LOC_HANDICAP (
    id_loc INT PRIMARY KEY,
    doc_necesar VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_lh_parent FOREIGN KEY (id_loc) REFERENCES LOC_PARCARE(id_loc)
);

CREATE TABLE LOC_ELECTRIC (
    id_loc INT PRIMARY KEY,
    putere INT NOT NULL CHECK (putere > 0),
    CONSTRAINT fk_le_parent FOREIGN KEY (id_loc) REFERENCES LOC_PARCARE(id_loc)
);

CREATE TABLE LOC_SUBTERAN (
    id_loc INT PRIMARY KEY,
    nivel INT CHECK (nivel < 0),
    CONSTRAINT fk_ls_parent FOREIGN KEY (id_loc) REFERENCES LOC_PARCARE(id_loc)
);

--subentitati zona
CREATE TABLE ZONA_VERDE (
    id_zona INT PRIMARY KEY,
    timp_max INT NOT NULL CHECK (timp_max <= 120),
    CONSTRAINT fk_zv_parent FOREIGN KEY (id_zona) REFERENCES ZONA_PARCARE(id_zona)
);

CREATE TABLE ZONA_ALBASTRA (
    id_zona INT PRIMARY KEY,
    interval_max INT NOT NULL CHECK (interval_max <= 120),
    penalizare NUMBER(5,2),
    CONSTRAINT fk_za_parent FOREIGN KEY (id_zona) REFERENCES ZONA_PARCARE(id_zona)
);

CREATE TABLE ZONA_REZIDENTIALA (
    id_zona INT PRIMARY KEY,
    id_permis_necesar INT NOT NULL,
    CONSTRAINT fk_zr_parent FOREIGN KEY (id_zona) REFERENCES ZONA_PARCARE(id_zona)
);
```
[!ex11 creare part 1](./ex11/creare/ex11creare1.png)
[!ex11 creare part 2](./ex11/creare/ex11creare2.png)
[!ex11 creare part 3](./ex11/creare/ex11creare3.png)
[!ex11 creare part 4](./ex11/creare/ex11creare4.png)
[!ex11 creare part 5](./ex11/creare/ex11creare5.png)
[!ex11 creare prat 6](./ex11/creare/ex11creare6.png)
[!ex11 creare part 7](./ex11/creare/ex11creare7.png)
[!ex11 creare part 8](./ex11/creare/ex11creare8.png)
[!ex11 dovada ca a mers crearea](./ex11/creare/ex11dovadacreare.png)

# b. Inserare tabele 
```sql
INSERT INTO USERS (id_user, nume, email, username) VALUES (parcare_seq.NEXTVAL, 'Andrei Ionescu', 'andrei@email.com', 'andrei_i');
INSERT INTO USERS (id_user, nume, email, username) VALUES (parcare_seq.NEXTVAL, 'Walter White', 'waltuh@email.com', 'walter_w');
INSERT INTO USERS (id_user, nume, email, username) VALUES (parcare_seq.NEXTVAL, 'Mihai Dan', 'mihai@email.com', 'mihai_d');
INSERT INTO USERS (id_user, nume, email, username) VALUES (parcare_seq.NEXTVAL, 'Ioana Stan', 'ioana@email.com', 'ioana_s');
INSERT INTO USERS (id_user, nume, email, username) VALUES (parcare_seq.NEXTVAL, 'Cristi Vlad', 'cristi@email.com', 'cristi_v');

INSERT INTO MUNICIPIU VALUES (1, 'Bucuresti', 'B', 'RO123');
INSERT INTO MUNICIPIU VALUES (2, 'Cluj-Napoca', 'CJ', 'RO456');
INSERT INTO MUNICIPIU VALUES (3, 'Timisoara', 'TM', 'RO789');
INSERT INTO MUNICIPIU VALUES (4, 'Iasi', 'IS', 'RO101');
INSERT INTO MUNICIPIU VALUES (5, 'Brasov', 'BV', 'RO202');



INSERT INTO MASINA VALUES (1, 'B101ABC', 1, 100);
INSERT INTO MASINA VALUES (2, 'CJ20XYZ', 0, 101);
INSERT INTO MASINA VALUES (3, 'TM30PRO', 0, 102);
INSERT INTO MASINA VALUES (4, 'IS40ELC', 1, 103);
INSERT INTO MASINA VALUES (5, 'BV50RRR', 0, 104);


INSERT INTO SPATIU VALUES (1, 'Str. Victoriei 10', 50, 1);
INSERT INTO SPATIU VALUES (2, 'Str. Republicii 5', 30, 2);
INSERT INTO SPATIU VALUES (3, 'Bvd. Revolutiei 22', 100, 3);
INSERT INTO SPATIU VALUES (4, 'Str. Palat 1', 40, 4);
INSERT INTO SPATIU VALUES (5, 'Piata Sfatului 3', 20, 5);


INSERT INTO ZONA_PARCARE VALUES (1, 10.00, 'Albastra');
INSERT INTO ZONA_ALBASTRA VALUES (1, 120, 25.00);
INSERT INTO ZONA_PARCARE VALUES (2, 5.00, 'Verde');
INSERT INTO ZONA_VERDE VALUES (2, 120);
INSERT INTO ZONA_PARCARE VALUES (3, 2.00, 'Rezidentiala');
INSERT INTO ZONA_REZIDENTIALA VALUES (3, 999);
INSERT INTO ZONA_PARCARE VALUES (4, 15.00, 'Albastra');
INSERT INTO ZONA_ALBASTRA VALUES (4, 90, 32.35);
INSERT INTO ZONA_PARCARE VALUES (5, 0.00, 'Verde');
INSERT INTO ZONA_VERDE VALUES (5, 120);

INSERT INTO LOC_PARCARE VALUES (1, 'A-01', 1, 1);
INSERT INTO LOC_ELECTRIC VALUES (1, 50);
INSERT INTO LOC_PARCARE VALUES (2, 'B-05', 1, 2);
INSERT INTO LOC_HANDICAP VALUES (2, 'CERT-8822');
INSERT INTO LOC_PARCARE VALUES (3, 'C-10', 1, 4);
INSERT INTO LOC_SUBTERAN VALUES (3, -1);
INSERT INTO LOC_PARCARE VALUES (4, 'D-02', 0, 1);
INSERT INTO LOC_PLATIT VALUES (4, 5.00);
INSERT INTO LOC_PARCARE VALUES (5, 'E-08', 1, 5);
INSERT INTO LOC_GRATIS VALUES (5, 60);


INSERT INTO SPATIU_PARCARE VALUES (1, 1);
INSERT INTO SPATIU_PARCARE VALUES (1, 2);
INSERT INTO SPATIU_PARCARE VALUES (2, 1);
INSERT INTO SPATIU_PARCARE VALUES (2, 3);
INSERT INTO SPATIU_PARCARE VALUES (3, 2);
INSERT INTO SPATIU_PARCARE VALUES (3, 4);
INSERT INTO SPATIU_PARCARE VALUES (4, 4);
INSERT INTO SPATIU_PARCARE VALUES (4, 5);
INSERT INTO SPATIU_PARCARE VALUES (5, 5);
INSERT INTO SPATIU_PARCARE VALUES (5, 1);



INSERT INTO REZERVARE (id_rezervare, data_inceput, data_sfarsit, status, id_masina, id_loc)
VALUES (1, TO_TIMESTAMP('2025-11-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-11-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Finalizata', 1, 1);
INSERT INTO REZERVARE (id_rezervare, data_inceput, data_sfarsit, status, id_masina, id_loc)
VALUES (2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '2' HOUR, 'Activa', 2, 2);
INSERT INTO REZERVARE (id_rezervare, data_inceput, data_sfarsit, status, id_masina, id_loc)
VALUES (3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1' DAY, 'Activa', 3, 3);
INSERT INTO REZERVARE (id_rezervare, data_inceput, data_sfarsit, status, id_masina, id_loc)
VALUES (4, TO_TIMESTAMP('2025-11-02 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-11-02 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Finalizata', 4, 4);
INSERT INTO REZERVARE (id_rezervare, data_inceput, data_sfarsit, status, id_masina, id_loc)
VALUES (5, CURRENT_TIMESTAMP + INTERVAL '5' HOUR, CURRENT_TIMESTAMP + INTERVAL '7' HOUR, 'Activa', 5, 5);

INSERT INTO ABONAMENT VALUES (parcare_seq.NEXTVAL, 'Lunar', 150.00, SYSDATE, SYSDATE + 30, 100);
INSERT INTO ABONAMENT VALUES (parcare_seq.NEXTVAL, 'Anual', 1200.00, SYSDATE - 10, SYSDATE + 355, 101);
INSERT INTO ABONAMENT VALUES (parcare_seq.NEXTVAL, 'Lunar', 150.00, SYSDATE - 5, SYSDATE + 25, 102);
INSERT INTO ABONAMENT VALUES (parcare_seq.NEXTVAL, 'Lunar', 150.00, SYSDATE, SYSDATE + 30, 103);
INSERT INTO ABONAMENT VALUES (parcare_seq.NEXTVAL, 'Anual', 1200.00, SYSDATE - 100, SYSDATE + 265, 104);

INSERT INTO PLATA VALUES (parcare_seq.NEXTVAL, 20.00, CURRENT_TIMESTAMP, 'CARD', 1);
INSERT INTO PLATA VALUES (parcare_seq.NEXTVAL, 45.50, CURRENT_TIMESTAMP, 'SMS', 2);
INSERT INTO PLATA VALUES (parcare_seq.NEXTVAL, 10.00, CURRENT_TIMESTAMP, 'CASH', 3);
INSERT INTO PLATA VALUES (parcare_seq.NEXTVAL, 5.00, CURRENT_TIMESTAMP, 'CARD', 4);
INSERT INTO PLATA VALUES (parcare_seq.NEXTVAL, 12.00, CURRENT_TIMESTAMP, 'GIFTCARD', 5);

INSERT INTO RECENZIE VALUES (parcare_seq.NEXTVAL, 5, 'Locatie excelenta!', CURRENT_DATE, 100, 1);
INSERT INTO RECENZIE VALUES (parcare_seq.NEXTVAL, 4, 'Sigur si curat.', CURRENT_DATE, 101, 2);
INSERT INTO RECENZIE VALUES (parcare_seq.NEXTVAL, 2, 'Prea aglomerat.', CURRENT_DATE, 102, 3);
INSERT INTO RECENZIE VALUES (parcare_seq.NEXTVAL, 5, 'Recomand!', CURRENT_DATE, 103, 4);
INSERT INTO RECENZIE VALUES (parcare_seq.NEXTVAL, 3, 'Greu de gasit.', CURRENT_DATE, 104, 5);

COMMIT;
```

[!ex11 inserare part 1](./ex11/insert/ex11inserare1.png)
[!ex11 inserare part 2](./ex11/insert/ex11inserare2.png)
[!ex11 inserare part 3](./ex11/insert/ex11inserare3.png)
[!ex11 inserare part 4](./ex11/insert/ex11inserare4.png)
[!ex11 dovada ca a mers insertul](./ex11/insert/ex11dovadainsert.png)

## 12. Cerinte SQL

# subcereri sincronizate cu 3 tabele; subcereri nesincronizate cu FROM; grupari de date, functii grup, filtrare la nivel de grupuri cu subcereri nesincronizate (HAVING); ordonari si folosirea functiilor NVL si DECODE; cel putin 2 functii pe siruri de caractere, 2 fc pe date calendaristice, cel putin o expresie CASE; utilizarea a cel putin unui bloc de cerere (WITH)

# a.
# b.
# c.
# d.
# e.

## 13. Operatii de actualizare