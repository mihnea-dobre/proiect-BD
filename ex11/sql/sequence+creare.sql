
DROP TABLE ZONA_VERDE;
DROP TABLE ZONA_ALBASTRA;
DROP TABLE ZONA_REZIDENTIALA;
DROP TABLE LOC_ELECTRIC;
DROP TABLE LOC_GRATIS;
DROP TABLE LOC_HANDICAP;
DROP TABLE LOC_PLATIT;
DROP TABLE LOC_SUBTERAN;
DROP SEQUENCE parcare_seq;
DROP TABLE PLATA;
DROP TABLE REZERVARE;
DROP TABLE SPATIU_PARCARE;
DROP TABLE RECENZIE;
DROP TABLE SPATIU;
DROP TABLE ABONAMENT;
DROP TABLE MASINA;
DROP TABLE MUNICIPIU;
DROP TABLE USERS;
DROP TABLE LOC_PARCARE;
DROP TABLE ZONA_PARCARE;

CREATE SEQUENCE parcare_seq
  START WITH 100
  INCREMENT BY 1
  NOCACHE;

CREATE TABLE MUNICIPIU (
    id_municipiu INT PRIMARY KEY,
    nume_municipiu VARCHAR2(50) NOT NULL,
    judet VARCHAR2(50) NOT NULL,
    cod_fiscal VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE USERS (
    id_user INT PRIMARY KEY,
    nume VARCHAR2(50) DEFAULT 'Guest',
    email VARCHAR2(100) UNIQUE,
    username VARCHAR2(50),
    nr_tel VARCHAR2(30),
    parola VARCHAR2(30),
    data_reg TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);


CREATE TABLE ZONA_PARCARE (
    id_zona INT PRIMARY KEY,
    tarif_ora NUMBER(5,2) NOT NULL
);

CREATE TABLE SPATIU (
    id_spatiu INT PRIMARY KEY,
    adresa VARCHAR2(255) UNIQUE NOT NULL,
    capacitate INT CHECK (capacitate > 0) NOT NULL,
    id_municipiu INT NOT NULL,
    CONSTRAINT fk_spatiu_muni FOREIGN KEY (id_municipiu) REFERENCES MUNICIPIU(id_municipiu)
);

CREATE TABLE MASINA (
    id_masina INT PRIMARY KEY,
    nr_matricol VARCHAR2(15) UNIQUE NOT NULL,
    este_elec NUMBER(1) DEFAULT 0 NOT NULL,
    id_user INT UNIQUE NOT NULL,
    CONSTRAINT fk_masina_user FOREIGN KEY (id_user) REFERENCES USERS(id_user) ON DELETE CASCADE
);

CREATE TABLE LOC_PARCARE (
    id_loc INT PRIMARY KEY,
    nr_loc VARCHAR2(10) NOT NULL,
    disponibil NUMBER(1) DEFAULT 1 NOT NULL,
    id_zona INT NOT NULL,
    CONSTRAINT fk_loc_zona FOREIGN KEY (id_zona) REFERENCES ZONA_PARCARE(id_zona)
);

CREATE TABLE REZERVARE (
    id_rezervare INT PRIMARY KEY,
    data_inceput TIMESTAMP NOT NULL,
    data_sfarsit TIMESTAMP NOT NULL,
    status VARCHAR2(20) DEFAULT 'Activa' NOT NULL,
    id_masina INT NOT NULL,
    id_loc INT NOT NULL,
    CONSTRAINT fk_rez_masina FOREIGN KEY (id_masina) REFERENCES MASINA(id_masina) ON DELETE CASCADE,
    CONSTRAINT fk_rez_loc FOREIGN KEY (id_loc) REFERENCES LOC_PARCARE(id_loc),
    CONSTRAINT chk_status_rez CHECK (status in ('Activa','Finalizata','Anulata')),
    CONSTRAINT chk_data_rez CHECK (data_sfarsit>data_inceput)
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
    id_user INT NOT NULL,
    CONSTRAINT fk_abon_user FOREIGN KEY (id_user) REFERENCES USERS(id_user) ON DELETE CASCADE,
    CONSTRAINT chk_abon_date CHECK (data_exp > data_activare),
    CONSTRAINT chk_abon_tip CHECK (tip in ('LUNAR','ANUAL'))
);

CREATE TABLE PLATA (
    id_plata INT PRIMARY KEY,
    suma DECIMAL(10,2) CHECK (suma >= 0),
    data_plata DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    metoda VARCHAR2(20) DEFAULT 'CARD',
    id_rezervare INT UNIQUE NOT NULL,
    CONSTRAINT fk_plata_rez FOREIGN KEY (id_rezervare) REFERENCES REZERVARE(id_rezervare) ON DELETE CASCADE,
    CONSTRAINT chk_metoda_plat CHECK(metoda in ('CARD','SMS','CASH','GIFTCARD'))
);

CREATE TABLE RECENZIE (
    id_recenzie INT PRIMARY KEY,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comentariu VARCHAR2(255),
    data_postare DATE DEFAULT CURRENT_TIMESTAMP,
    id_user INT NOT NULL,
    id_spatiu INT NOT NULL,
    CONSTRAINT fk_rec_user FOREIGN KEY (id_user) REFERENCES USERS(id_user) ON DELETE CASCADE,
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