-- Cerinta 20. Implementare completa a fiecarui trigger lipsa.

--1. Doar masinile electrice pot ocupa un loc electric.
CREATE OR REPLACE TRIGGER trg_rezervare_electric
BEFORE INSERT OR UPDATE ON REZERVARE
FOR EACH ROW
DECLARE
    v_electric_loc NUMBER(1) := 0;
    v_electric_car NUMBER(1);
BEGIN
    -- Verificam daca locul este electric
    BEGIN
        SELECT 1 INTO v_electric_loc FROM LOC_ELECTRIC WHERE id_loc = :NEW.id_loc;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;

    IF v_electric_loc = 1 THEN
        SELECT este_elec INTO v_electric_car FROM MASINA WHERE id_masina = :NEW.id_masina;
        IF v_electric_car = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Doar masinile electrice pot rezerva locuri electrice.');
        END IF;
    END IF;
END;
/

-- 2. Suprapunerea rezervarilor pe acelasi loc

CREATE OR REPLACE TRIGGER trg_rezervare_suprapunere
BEFORE INSERT OR UPDATE ON REZERVARE
FOR EACH ROW
DECLARE
    v_count NUMBER;
    v_disponibil NUMBER(1);
BEGIN
    -- Verifica disponibilitatea locului
    SELECT disponibil INTO v_disponibil FROM LOC_PARCARE WHERE id_loc = :NEW.id_loc;
    IF v_disponibil = 0 AND :NEW.status = 'Activa' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Locul nu este disponibil.');
    END IF;

    -- Verifica suprapunerea cu rezervari active existente
    SELECT COUNT(*) INTO v_count
    FROM REZERVARE
    WHERE id_loc = :NEW.id_loc
      AND status = 'Activa'
      AND id_rezervare != NVL(:NEW.id_rezervare, -1)
      AND :NEW.data_inceput < data_sfarsit
      AND :NEW.data_sfarsit > data_inceput;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Intervalul se suprapune cu o rezervare activa pe acelasi loc.');
    END IF;
END;
/

-- 3. O masina nu poate avea doua rezervari active simultan

CREATE OR REPLACE TRIGGER trg_masina_rezervare_unica
BEFORE INSERT OR UPDATE ON REZERVARE
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    IF :NEW.status = 'Activa' THEN
        SELECT COUNT(*) INTO v_count
        FROM REZERVARE
        WHERE id_masina = :NEW.id_masina
          AND status = 'Activa'
          AND id_rezervare != NVL(:NEW.id_rezervare, -1)
          AND :NEW.data_inceput < data_sfarsit
          AND :NEW.data_sfarsit > data_inceput;

        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Masina are deja o rezervare activa in intervalul specificat.');
        END IF;
    END IF;
END;
/

-- 4. Plata zero pentru locuri din zona verde

CREATE OR REPLACE TRIGGER trg_plata_zona_verde
BEFORE INSERT OR UPDATE ON PLATA
FOR EACH ROW
DECLARE
    v_verde NUMBER(1) := 0;
BEGIN
    SELECT COUNT(*) INTO v_verde
    FROM ZONA_VERDE zv
    JOIN LOC_PARCARE l ON l.id_zona = zv.id_zona
    JOIN REZERVARE r ON r.id_loc = l.id_loc
    WHERE r.id_rezervare = :NEW.id_rezervare;

    IF v_verde > 0 AND :NEW.suma != 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Locurile din zona verde trebuie sa aiba plata 0.');
    END IF;
END;
/

-- 5. Un loc nu poate fi simultan gratis si platit

CREATE OR REPLACE TRIGGER trg_loc_platit_exclusiv
BEFORE INSERT OR UPDATE ON LOC_PLATIT
FOR EACH ROW
DECLARE
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM LOC_GRATIS WHERE id_loc = :NEW.id_loc;
    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Locul este deja inregistrat ca gratuit.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_loc_gratis_exclusiv
BEFORE INSERT OR UPDATE ON LOC_GRATIS
FOR EACH ROW
DECLARE
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM LOC_PLATIT WHERE id_loc = :NEW.id_loc;
    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Locul este deja inregistrat ca platit.');
    END IF;
END;
/

-- 6. nr_loc<=capacitate

CREATE OR REPLACE TRIGGER trg_capacitate_spatiu
AFTER INSERT OR UPDATE ON LOC_PARCARE
BEGIN
    FOR rec IN (
        SELECT sp.id_spatiu, sp.capacitate, COUNT(l.id_loc) AS total_locuri
        FROM SPATIU sp
        JOIN SPATIU_PARCARE spz ON sp.id_spatiu = spz.id_spatiu
        JOIN ZONA_PARCARE z ON spz.id_zona = z.id_zona
        LEFT JOIN LOC_PARCARE l ON l.id_zona = z.id_zona
        GROUP BY sp.id_spatiu, sp.capacitate
        HAVING COUNT(l.id_loc) > sp.capacitate
    ) LOOP
        RAISE_APPLICATION_ERROR(-20008,
            'Spatiul ' || rec.id_spatiu || ' depaseste capacitatea maxima de ' || rec.capacitate || ' locuri.');
    END LOOP;
END;
/

-- 7. Recenzii doar de la utilizatori cu rezervari platite/finalizate
CREATE OR REPLACE TRIGGER trg_recenzie_eligibilitate
BEFORE INSERT OR UPDATE ON RECENZIE
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM MASINA m
    JOIN REZERVARE r ON m.id_masina = r.id_masina
    JOIN PLATA p ON r.id_rezervare = p.id_rezervare
    WHERE m.id_user = :NEW.id_user
      AND r.status = 'Finalizata';

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20009,
            'Doar utilizatorii cu cel putin o rezervare finalizata si platita pot lasa recenzii.');
    END IF;
END;
/

-- 8. Abonament unic activ per utilizator

CREATE OR REPLACE TRIGGER trg_abonament_unic_activ
BEFORE INSERT OR UPDATE ON ABONAMENT
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM ABONAMENT
    WHERE id_user = :NEW.id_user
      AND id_abonament != NVL(:NEW.id_abonament, -1)
      AND data_activare <= SYSDATE
      AND data_exp >= SYSDATE;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Utilizatorul are deja un abonament activ. Nu pot exista doua abonamente active simultan.');
    END IF;
END;
/

-- 9. Username default

CREATE OR REPLACE TRIGGER trg_users_username_default
BEFORE INSERT ON USERS
FOR EACH ROW
WHEN (NEW.username IS NULL)
BEGIN
    :NEW.username := 'Guest_' || :NEW.id_user;
END;
/

DROP TRIGGER trg_rezervare_electric;
DROP TRIGGER trg_rezervare_suprapunere;
DROP TRIGGER trg_masina_rezervare_unica;
DROP TRIGGER trg_plata_zona_verde;
DROP TRIGGER trg_loc_platit_exclusiv;
DROP TRIGGER trg_loc_gratis_exclusiv;
DROP TRIGGER trg_capacitate_spatiu;
DROP TRIGGER trg_recenzie_eligibilitate;
DROP TRIGGER trg_abonament_unic_activ;
DROP TRIGGER trg_users_username_default;