--Afișați utilizatorii care nu au înregistrat rezervări.

select u.id_user, u.nume
from users u
where not exists(
    select *
    from masina m
    join rezervare r on m.id_masina = r.id_masina
    where m.id_user = u.id_user
)