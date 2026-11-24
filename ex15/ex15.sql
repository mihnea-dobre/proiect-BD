--1. Outer-join pe minim 4 tabele
--Cerinta: Afisati toti utilizatorii si, pentru fiecare, rezervarile active (daca exista), 
--impreuna cu masina si locul de parcare.
--Utilizatorii fara masina sau fara rezervari active vor aparea cu valori nule.

select u.id_user,
       u.nume,
       u.email,
       m.nr_matricol,
       r.id_rezervare,
       r.data_inceput,
       r.data_sfarsit,
       l.nr_loc
from users u
left join masina m on u.id_user = m.id_user 
left join rezervare r on m.id_masina = r.id_masina and r.status = 'Activa'
left join loc_parcare l on r.id_loc = l.id_loc 
order by u.id_user;

-- natural join: match exact (daca nu e nu se afiseaza)
-- outer join: match si NULL unde nu exista

--2. Diviziune (cu NOT EXISTS)
--Gasiti utilizatorii care au efectuat cel putin o rezervare
--intr-un loc din *fiecare* zona de parcare existenta

select u.id_user, u.nume
from users u
where not exists(
    select z.id_zona
    from zona_parcare z
    where not exists(
        select *
        from masina m 
        join rezervare r on m.id_masina = r.id_masina
        join loc_parcare l on r.id_loc = l.id_loc 
        where m.id_user = u.id_user and l.id_zona = z.id_zona 
    )
)
order by u.id_user;

--traducere: tabelul users = U si tabelul zona = Z
--x = id_user, y = id_zona
--U(id_user, id_zona) div Z(id_zona)

--alternative: having count (distinct l.id_zona) = (select count(*) from zona_parcare)
--alternative 2: cross join si except
/* 
select * from U
where id_user not in (
    select id_user from (
    select id_user, id_zona from (select id_zona from Z) as p cross join (select distinct id_user from U) as zp)
    except (select id_user, id_zona from U)) as u
*/


--3. Analiza top-n
--Determinati primii 3 utilizatori cu cel mai mare numar de rezervari.
--In caz de egalitate, afisati toti cei care se califica in top 3. 

select id_user, nume, numar_rezervari, pozitie
from(
    select u.id_user, u.nume,
           count(r.id_rezervare) as numar_rezervari,
           rank() over (order by count(r.id_rezervare) desc) as pozitie
    from users u
    left join masina m on u.id_user = m.id_user 
    left join rezervare r on m.id_masina = r.id_masina 
    group by u.id_user, u.nume
) where pozitie <= 3
order by pozitie;
-- obs: functional rank, dense_rank si row_number vor face acelasi lucru pentru datele cu care lucram
-- dar e important ca NU sunt echivalent functionale in general