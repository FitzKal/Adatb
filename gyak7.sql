--kik azok az olvasok akik idosebbel Frei Tamasnal
select *
from konyvtar.tag
where szuletesi_datum < ( select szuletesi_datum
from konyvtar.szerzo
where vezeteknev = 'Frei' and keresztnev = 'Tamás');

--hany olyan konyv van, ami 1990 es 2000 kozott vagy az ara 1000 es 2000 kozott esik
select konyv_azon
from konyvtar.konyv
where ar between 1000 and 2000;

select konyv_azon
from konyvtar.konyv
where kiadas_datuma between to_date('1990.01.01','yyy.mm.dd') and to_date('2000.12.31','yyy.mm.dd');

/*kik azok akik a tulajok akiknek 3nal tobb autoja van?
csoportosisuk */
select tul.azon, count(autul.auto_azon)
from szerelo.sz_tulajdonos tul inner join szerelo.sz_auto_tulajdonosa autul
on tul.azon = autul.tulaj_azon
group by tul.azon
having count (autul.auto_azon) > 3
order by count (autul.auto_azon)desc;

--melyek azok az autok amelyek elso vasarlasi ara tobb mint a piros autok elso vasarlasi ara atlaga

--keressuk meg a Vodafonet hasznalo szereloket (70es)
select *
from szerelo.sz_szerelo
where substr(telefon, instr(telefon, '+36')+3,2 ) = '70';

--keressunk olyanikat, akik kesobb erkeztek az allatkertbe mint 'Safranek',
--hanyan vannak? Csoportositsuk fajonkent, es csak azokat irjuk ki, akik nem egyediek, tehat tobb mint 2 ilyen tartozik a fajhoz
select faj_nev, count(*)
from zoo.zoo_allatok al inner join zoo.zoo_fajok faj
on al.faj_azon = faj.faj_azon
where erkezes_dat > (select erkezes_dat
from zoo.zoo_allatok
where allat_nev = 'Safranek')
group by faj_nev
having count(*)>1;--having count csoportra, vagy ha atlag alapjan keresunk valamire

--DDL - data definiton language
--drop, create, alter, truncake

--constraints
    --primary key
    --not null
    --foreign key reference
    --check
    --default
    
    create table hallgato(
    neptun char(5),
    nev varchar(50),
    szul_dat date,
    email varchar(50)unique
    );
    
    insert into hallgato values('MG319M','Vesa Bence',to_date('2004.05.09','yyyy.mm.dd'),'vesabence@gmai.com');
    
    alter table hallgato
    modify neptun char(6)
    add constraint halg_pk primary key (neptun)
    
   -- drop table hallgato;
    
    create table szakdolgozat(
    hallgato_id char(6) references hallgato(neptun),
    oktato_id number,
    cim varchar(50),
    
    constraint szd_pk primary key(hallgato_id, cim)
    );
    
    --drop table szakdolgozat;
    
    create table oktato(
    oktato_id number primary key,
    nev varchar(50),
    brutto_ber number check(brutto_ber > 0)
    );
    --drop table oktato;
    insert into oktato values(1,'Dr.Vagner Aniko Szilvia',1000000);
    
    --insert into szakdolgozat values ('QIXKoP', 2, 'Sakkprogram mest inttel');
    --insert into szakdolgozat values ('QIXK1P', 2, 'Sakkprogram mest inttel');
    insert into szakdolgozat values ('MG319M', 1, 'Sakkprogram mest inttel'); 
    insert into szakdolgozat values ('MG319M', 2, 'bruh');
    select *
    from oktato;
    
    alter table szakdolgozat
    add constraint szg_okt_fk foreign key (oktato_id) references oktato(oktato_id);
    
    truncate table szakdolgozat;
    select * 
    from hallgato;
    
    select *
    from szakdolgozat;
    
    insert into oktato values (2,'Kek Tibor', 10000);
    select *
    from hallgato h inner join szakdolgozat szk
    on h.neptun = szk.hallgato_id;
    
    select * 
    from user_constraints;
    select *
    from user_tables;
    