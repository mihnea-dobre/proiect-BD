CREATE SEQUENCE parcare_seq
  START WITH 100
  INCREMENT BY 1
  NOCACHE;

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