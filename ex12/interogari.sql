--Afisati pentru fiecare loc de parcare 
--tariful zonei, pozitia in zona si pozitia globala (window function), 
--starea (Liber/Ocupat).

select z.id_zona, z.tarif_ora, l.nr_loc,
row_number() over (partition by l.id_zona order by l.nr_loc) as pozitie_in_zona,
row_number() over (order by l.id_zona, l.nr_loc) as poz_globala,
case when l.disponibil = 1 then 'Liber' else 'Ocupat' end as disponibilitate
from loc_parcare l
join zona_parcare z ON l.id_zona = z.id_zona
order by poz_globala, pozitie_in_zona, l.id_zona;

--Determinati zonele cu numar de locuri peste medie, tipul real al zonei si anul primei rezervari. 
--Precalculati tipul zonei si numarul locurilor.

with tipZona as(
    select z.id_zona,
    case
        when za.id_zona is not null then 'Albastra'
        when zv.id_zona is not null then 'Verde'
        when zr.id_zona is not null then 'Rezidentiala'
    end as tip_zona
    from zona_parcare z
    left join zona_albastra za on z.id_zona = za.id_zona 
    left join zona_verde zv on z.id_zona = zv.id_zona
    left join zona_rezidentiala zr on z.id_zona = zr.id_zona
), 
zoneCount as (
    select l.id_zona, count(*) as nr_locuri
    from loc_parcare l
    group by l.id_zona
)
select z.id_zona, z.tarif_ora, zc.nr_locuri, tz.tip_zona, extract(year from min(r.data_inceput)) as an_prima_rezervare
from zona_parcare z
join tipZona tz on z.id_zona = tz.id_zona
join zoneCount zc on z.id_zona = zc.id_zona
left join loc_parcare l on l.id_zona = z.id_zona
left join rezervare r on r.id_loc = l.id_loc
group by z.id_zona, z.tarif_ora, zc.nr_locuri, tz.tip_zona
having zc.nr_locuri > (select avg(nr_locuri) from zoneCount)
order by z.id_zona;

--Gasiti utilizatorii care au facut o rezervare platita cu cardul pe un loc electric.

select u.id_user, initcap(u.nume) as nume_formatat, u.email
from users u
where exists(
    select *
    from masina m 
    join rezervare r on m.id_masina = r.id_masina 
    join plata p on r.id_rezervare = p.id_rezervare 
    join loc_electric le on r.id_loc = le.id_loc 
    where m.id_user = u.id_user and p.metoda='CARD'
)
order by u.nume;

--Calculati capacitatea totala a municipiilor cu cel putin 2 spatii.
--Pentru fiecare municipiu selectat afisati numele si categorizati capacitatatile spatiilor.
select m.nume_municipiu, nvl(capacitate_totala, 0) as capacitate_totala,
case when capacitate_totala >= 100 then 'Mare'
when capacitate_totala >= 50 then 'Mediu'
else 'Mic'
end as categorie
from municipiu m
join (
    select id_municipiu, sum(capacitate) as capacitate_totala
    from spatiu 
    group by id_municipiu
    having count(*)>=2
) s on m.id_municipiu = s.id_municipiu 
order by capacitate_totala DESC;

--Listati rezervarile cu data formatata (TO_CHAR), status decodificat (DECODE), 
--o coloana concatenata (nr_matricol si status) si 
--perioada (ultima luna / mai vechi) folosind ADD_MONTHS si CASE.
select r.id_rezervare,
       to_char(r.data_inceput, 'DD-MON-YYYY HH24:MI') as inceput_formatat,
       decode(r.status,
              'Activa', 'In desfasurare',
              'Finalizata', 'Incheiata',
              'Anulata', 'Anulata',
              'Necunoscut') as status_descriere,
       concat(concat(m.nr_matricol, ' - '), r.status) as masina_status,
       case when r.data_inceput >= add_months(sysdate, -1)
            then 'Ultima luna'
            else 'Mai vechi'
       end as perioada,
       nvl(p.metoda, 'N/A') as metoda_plata
from rezervare r
join masina m on r.id_masina = m.id_masina
left join plata p on r.id_rezervare = p.id_rezervare
order by r.data_inceput desc;