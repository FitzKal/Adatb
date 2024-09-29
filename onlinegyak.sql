--Exist, Any/All
--listazzuk ki azon konyvek cimet, kiadojat es arat melyeknek egyetlen peldanya sincs a konyvtarban

--allekerdezessel
select cim, kiado,  ar
from konyvtar.konyv
where konyv_azon not in(select konyv_azon from konyvtar.konyvtari_konyv);

--joinnal
select cim, kiado, ar, kkv.*
from konyvtar.konyv kv left join konyvtar.konyvtari_konyv kkv
on kv.konyv_azon =  kkv.konyv_azon
where kkv.leltari_szam is null;

--listazzuk ki azokat a konyveket amelyek tobbet ernek az osszes informatikai konyvnel
select *
from konyvtar.konyv
where ar > all
(select ar
from konyvtar.konyv
where tema = 'informatika');

--jelenitsuk meg a fekete kek is piros autokat
--kiveve azokat amelyeket telen kell szerelni
select *
from szerelo.sz_auto
where lower(szin) in ('piros',  'kék', 'fekete')
minus
select au.*
from szerelo.sz_auto au inner join szerelo.sz_szereles szer
on au.azon = szer.auto_azon
where to_char(szereles_kezdete, 'mm') in ('12', '1', '2');
--extract(month from szereles_kezdete) 
select *
from szerelo.sz_auto
where lower(szin) in ('piros',  'kék', 'fekete')
union
select au.*
from szerelo.sz_auto au inner join szerelo.sz_szereles szer
on au.azon = szer.auto_azon
where to_char(szereles_kezdete, 'mm') in ('12', '1', '2');

--mely konyveket adta ki az ABC sorrendbe az  utolso kiado
select * 
from konyvtar.konyv
order by kiado desc nulls last
fetch first row only;

--keressuk meg az elso 93 utani konyvet a konyvtarban
select *
from konyvtar.konyvtari_konyv
where konyv_azon in (select konyv_azon
from konyvtar.konyv
where extract (year from kiadas_datuma) > 1993
order by kiadas_datuma
fetch first row with ties);

--Azt a markat keressuk, amibol a legtobb van az adatbazisban
select marka, count(au.azon)
from szerelo.sz_autotipus typ inner join szerelo.sz_auto au
on typ.azon = au.tipus_azon
group by marka
order by count(au.azon) desc
fetch first row with ties;

create table autoszereles (
    azon number constraint auto_pk primary key,
    rendszam char(6) not null,
    ar number (10,2),
    leiras varchar2(50),
    kezdete date,
    vege date check (vege > to_date('1900.01.01', 'yyyy.mm.dd')),
    constraint au_rend_uq unique (rendszam)
);
alter table autoszereles
drop constraint au_rend_uq;

--drop table
--drop database;
--drop column de csak az alter table-el
alter table autoszereles
drop column vege;

rename autoszereles to autok;

alter table autok
rename column leiras to karelemzes;

alter table autok
modify rendszam varchar(7);

alter table autok
add loero number(3,10);

--drop table <table nev> cascade constrains; igy droppolunk tablat ahol vannak constraintek es kulcsok

revoke select on autok from panovics;
grant insert on autok to vagnera;
grant references on autok to vagnera;

delete
--select * 
from szakdolgozat
where oktato_id = 1;