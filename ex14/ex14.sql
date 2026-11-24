CREATE OR REPLACE VIEW VW_REZERVARI_DETALII AS
SELECT r.id_rezervare,
       r.data_inceput,
       r.data_sfarsit,
       r.status,  
       u.nume AS nume_user,
       u.email,
       m.nr_matricol,
       l.nr_loc,
       l.disponibil,
       z.id_zona,
       z.tarif_ora
FROM REZERVARE r
JOIN MASINA m ON r.id_masina = m.id_masina
JOIN USERS u ON m.id_user = u.id_user
JOIN LOC_PARCARE l ON r.id_loc = l.id_loc
JOIN ZONA_PARCARE z ON l.id_zona = z.id_zona;

/* Operatie LMD permisa 
Putem schimba statusul direct prin view doarece coloana status previne direct din REZERVARE. */

UPDATE VW_REZERVARI_DETALII
SET status = 'Anulata'
WHERE id_rezervare = 1;

/* Operatie LMD nepermisa 
Nu putem insera direct prin view, deoarece ORACLE nu permite inserarea pe
un view complex cu coloane din mai multe tabele simultan.
*/

INSERT INTO VW_REZERVARI_DETALII
  (id_rezervare, data_inceput, data_sfarsit, status,
   nume_user, email, nr_matricol, nr_loc, id_zona)
VALUES
  (99, SYSTIMESTAMP, SYSTIMESTAMP + INTERVAL '1' HOUR, 'Activa',
   'Test', 'test@email.com', 'B99ZZZ', 'A-01', 1);

-- Eroare: "cannot modify more than one base table through a join view"

SELECT table_name, column_name, insertable, deletable, updatable
from USER_UPDATABLE_COLUMNS
where table_name = 'VW_REZERVARI_DETALII';