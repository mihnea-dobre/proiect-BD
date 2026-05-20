--Marcati ca indisponibile toate locurile de parcare 
--aflate in spatii administrate de municipiul Bucuresti.
update loc_parcare
set disponibil = 0
where id_zona in (
    select id_zona
    from spatiu_parcare 
    where id_spatiu in(
        select id_spatiu
        from spatiu
        where id_municipiu = (
            select id_municipiu
            from municipiu 
            where nume_municipiu = 'Bucuresti'
        )
    )
);
--Majorati cu 10% tariful orar al zonelor in care s-a efectuat cel putin o plata cu cardul.
update zona_parcare 
set tarif_ora = tarif_ora*1.1
where id_zona in (
    select distinct l.id_zona
    from loc_parcare l 
    join rezervare r on l.id_loc = r.id_loc 
    join plata p on r.id_rezervare = p.id_rezervare 
    where p.metoda = 'CARD'
);

--Eliminati recenziile scrise de utilizatorii care nu au nicio rezervare cu statusul „Finalizata”.
delete from recenzie
where id_user in (
    select u.id_user
    from users u
    where u.id_user not in(
        select distinct m.id_user
        from masina m
        join rezervare r on m.id_masina = r.id_masina 
        where r.status = 'Finalizata'
    )
);

ROLLBACK;