--Interogare: Afisati utilizatorii cu rezervari active in locuri de parcare
--disponibile.


--SQL initial, neoptimizat
SELECT u.nume, m.nr_matricol, r.data_inceput
FROM USERS u, MASINA m, REZERVARE r, LOC_PARCARE l
WHERE u.id_user = m.id_user
  AND m.id_masina = r.id_masina
  AND r.id_loc = l.id_loc
  AND r.status = 'Activa'
  AND l.disponibil = 1;


/* Expresia algebrica initiala:
π nume, nr_matricol, data_inceput (
  σ status='Activa' ∧ disponibil=1 (
    USERS ⋈ MASINA ⋈ REZERVARE ⋈ LOC_PARCARE
  )
)
*/

/* Arbore algebric initial
         π
         |
         σ
         |
         ⋈
       /   \
     ⋈     LOC_PARCARE
    /  \
  ⋈    REZERVARE
 /  \
USERS MASINA
*/

--Cum putem optimiza?
--Coboram selectiile σ (where) status = 'Activa' si σ disponibil=1 pe
--REZERVARE, respectiv LOC_PARCARE
--Reordonam joinurile, incepand cu tabelele reduse de selectii

/* Expresie algebrica optimizata
π nume, nr_matricol, data_inceput (
  (σ disponibil=1 LOC_PARCARE)
  ⋈ (σ status='Activa' REZERVARE)
  ⋈ MASINA
  ⋈ USERS
)
*/

/* Arbore algebric optimizat
       π
       |
       ⋈
     /   \
    ⋈    USERS
   /  \
  ⋈   MASINA
 /  \
σ     σ
|     |
LOC   REZERVARE
*/


-- SQL optimizat
SELECT u.nume, m.nr_matricol, r.data_inceput
FROM (SELECT * FROM LOC_PARCARE WHERE disponibil = 1) l
JOIN (SELECT * FROM REZERVARE WHERE status = 'Activa') r ON l.id_loc = r.id_loc
JOIN MASINA m ON r.id_masina = m.id_masina
JOIN USERS u ON m.id_user = u.id_user;

-- Nu avem foarte multe date, totusi se observa ca interogarile difera prin viteza
-- cu ~0.017 secunde.

