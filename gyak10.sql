--keszitsunk egy folkswagen tablat 
create table Folkswagenek (
    azon number,
    rendszam char(5),
    szin varchar2(15) default 'Pezsgometal',
    marka varchar2(20) not null,
    loero number,
    izesites varchar2(20)
);


--toroljuk az izesites attributumo
alter table Folkswagenek drop column izesites;
--nevezzuk at a tablat Volkswagenekte
rename Folkswagenek to Volkswagenek;
Select * 
from Volkswagenek;
--A marka attributumot irjuk at tipusra
alter table Volkswagenek rename column marka to tipus;
--rendszam legyen 6 karakteer hosszu
alter table Volkswagenek modify rendszam char(6);

--keszitsunk szekvenciat a volkswageneknek
create sequence Volkswagen_seq
    start with 1
    minvalue 0
    maxvalue 50 --nomaxvalue
    increment by 1
    cycle; --nocycle
    
--illesszunk be egy autot az DB-be
insert into Volkswagenek (azon, rendszam, tipus, loero)
values(Volkswagen_seq.nextval, 'NRY854','Golf', 75);

update Volkswagenek
set szin = 'Sotetkek', loero = 79
where rendszam = 'NRY854';

--keszitsunk egy indexet a tipusara
create index volkswagen_idx on Volkswagenek(tipus);
--tegyunk be meg volkswageneket a szerelo tablabol
--irjuk meg hozza a selectet

insert into  Volkswagenek(azon, szin, tipus, rendszam, loero)
select volkswagen_seq.nextval, szin, megnevezes, substr(rendszam, 0, 6), 120
from szerelo.sz_autotipus typ inner join szerelo.sz_auto au on
typ.azon = au.tipus_azon
where marka = 'Volkswagen';

Select * 
from Volkswagenek;

--javitsuk ki a null ertekeket pezsgometalra
update Volkswagenek
set szin = 'Pezsgometal'
where szin is null;

--szabaduljunk meg az pezsgometal autoktol
--ajanlott mindig egy selectet futtatni elotte hogy megnezzuk hogy jo ertekeket jeloltunk e ki
delete
from Volkswagenek
where szin = 'Pezsgometal';

commit; --checkpoint
delete
from Volkswagenek;

rollback; --back to base

create synonym vw for Volkswagenek;
--drop synonim vw;
select *
from vw;

--keszitsunk nezettablat a turanokrol
create view touran as
(
    select * 
    from vw
    where tipus = 'Touran'
);

drop view touran;

select * 
from touran;


--keszitsunk egy nezetet hogy melyik szerzo melyik konyvet irta 
create view konyvek_es_konyvszerzok as (
select cim, vezeteknev || ' ' || keresztnev as "Teljes nev"
from konyvtar.konyv kv inner join konyvtar.konyvszerzo ksz
on kv.konyv_azon = ksz.konyv_azon
inner join konyvtar.szerzo sz
on ksz.szerzo_azon = sz.szerzo_azon);

select *
from konyvek_es_konyvszerzok;

create synonym k_sz for konyvek_es_konyvszerzok;

select*
from k_sz;

commit;

truncate table Volkswagenek;

rollback;
select *
from vw;

drop table volkswagenek;
drop synonym vw;
drop sequence volkswagen_seq;
drop view touran;
