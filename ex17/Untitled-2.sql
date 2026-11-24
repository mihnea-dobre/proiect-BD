--Adaugam coloanele.
ALTER TABLE USERS ADD (ultima_rezervare TIMESTAMP);
ALTER TABLE USERS ADD (numar_rezervari INT DEFAULT 0);

--Initializam datele existente.
UPDATE USERS u
SET (ultima_rezervare, numar_rezervari) = (
    SELECT MAX(r.data_inceput), COUNT(r.id_rezervare)
    FROM MASINA m
    LEFT JOIN REZERVARE r ON m.id_masina = r.id_masina
    WHERE m.id_user = u.id_user
);

--Trigger
CREATE OR REPLACE TRIGGER trg_rezervare_denormalizare
AFTER INSERT OR DELETE ON REZERVARE
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE USERS
        SET numar_rezervari = NVL(numar_rezervari, 0) + 1,
            ultima_rezervare = :NEW.data_inceput
        WHERE id_user IN (
            SELECT m.id_user
            FROM MASINA m
            WHERE m.id_masina = :NEW.id_masina
        );
    ELSIF DELETING THEN
        UPDATE USERS
        SET numar_rezervari = NVL(numar_rezervari, 0) - 1,
            ultima_rezervare = (
                SELECT MAX(r.data_inceput)
                FROM MASINA m2
                JOIN REZERVARE r ON m2.id_masina = r.id_masina
                WHERE m2.id_user = (
                    SELECT m.id_user FROM MASINA m WHERE m.id_masina = :OLD.id_masina
                )
            )
        WHERE id_user IN (
            SELECT m.id_user
            FROM MASINA m
            WHERE m.id_masina = :OLD.id_masina
        );
    END IF;
END;
/

--Interogarea echivalenta, dupa denormalizare
SELECT nume, ultima_rezervare, numar_rezervari
FROM USERS;
