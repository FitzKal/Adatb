--II.zh temai
--outer join
--all any eixst
--halmazmuveletek
--top n
--create table
--alter/drop table
--instert
--delete update
--create view
--grant and revoke
create sequence konyv_seq --droppal lehet droppolni alterrel valtoztatni
    start with 100
    minvalue 100
    maxvalue 9999
    increment by 100
    nocycle;
    
drop sequence konyv_seq;

insert into konyveles(azon)
values(konyv_seq.nextval);

create table konyveles(
azon number default konyv_seq.nextval,
tipus varchar2(50),
osszeg number,
datum date default sysdate

);

drop table konyveles;

select * 
from konyveles;

--A ceg autoja AT601, ha javitjak akkor azt a ceg fizeti
--konyveljuk le az auto javitasat a javitas vege datummal
--tipusa pedig legyen szereles

--keszitsuk el a lekerdezest
select *
from szerelo.sz_auto au inner join szerelo.sz_szereles szer
on au.azon =  szer.auto_azon
where rendszam = 'AIT601';

insert into konyveles (tipus, osszeg, datum)
select 'szerelés', munkavegzes_ara, szereles_vege
from szerelo.sz_auto au inner join szerelo.sz_szereles szer
on au.azon =  szer.auto_azon
where rendszam = 'AIT601'
and
szereles_vege is not null;

--illesszunk be altalanos konyvelest -1000 ertekkel
insert into konyveles(tipus,osszeg)
values('Altalanos konyveles', -1000);

--allitsuk az ertekeket pozitivra ahol negativak
update konyveles
set osszeg = osszeg * -1 
where osszeg  < 0;

--Mentsuk el az eddigi munkankat
commit;

delete
from konyveles
where tipus = 'Altalanos konyveles';

rollback;

--toroljuk az adatok a tablabol truncattel
commit;
truncate table konyveles;--TRUNCAT ET NEM LEHET ROLLBACKELNI
rollback;

--keszitsunk egy nezetet azokol a szerelesekro amiket VW-ken vegeztek
--es a neve legyen volkswagenek_szerelese

create view volkswagenek_szerelese as
select au.*, szer.*
from szerelo.sz_autotipus typ inner join szerelo.sz_auto au
on typ.azon = au.tipus_azon
inner join szerelo.sz_szereles szer
on szer.auto_azon = au.azon
where marka = 'Volkswagen';

drop view volkswagenek_szerelese;


select * 
from volkswagenek_szerelese
where szin =  'piros';

--keszitsunk egy nezetet a 2020-as lekerdezesekre
--a neve legyen konyvelesek_2020

create view konyvelesek_2020 as
select * 
from konyveles
where extract(year from datum) = 2020;

drop view konyvelesek_2020;

select * 
from konyvelesek_2020;

--keszitsunk szinonimat ezekre
create synonym kv2020 for konyvelesek_2020;
select * from kv2020;

--grant revoke
select * 
from U_UXF1FP.konyveles;

grant select on konyveles to U_UXF1FP;--egy szemelynek
--egyesevel kell elvenni mindenkitol ha kulon kulon szemelyeknek egyesevel adtuk meg a jogosultsagot
grant select on konyveles to public;

revoke select on konyveles from public;

grant insert on konyveles to public;
revoke insert on konyveles from public;


--toroljuk a tablat
drop table konyveles;

--toroljuk a szinonimakat
drop synonym kv2020;

--toroljuk a viewt;
drop view konyvelesek_2020;
