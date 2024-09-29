--tablajogok es rendszerjogok
/*tablajogok
select
delete
insert
update
references
gyujtoneven all

Rendszerjogok:
create table jog
barmit megtehessunk az adatb-ben

with grant option (olyan jog amit tovabb tudsz adni)
*/
create table szabasmintak
(
    azon number(6) constraint szab_pk primary key,
    tipus varchar2(30)default 'korszoknya',
    min_meret number(2),
    max_meret number (2),
    nev varchar(30),
    szarmazas varchar(50),
    constraint szabcheck check( min_meret < max_meret),
    CONSTRAINT szab_uq unique (tipus,nev)
);

insert into szabasmintak(azon, min_meret, max_meret, nev, szarmazas)
values(1, 34, 48, 'Daisy longskirt', 'Burda');
insert into szabasmintak(azon,tipus,min_meret, max_meret, nev, szarmazas)
values(2,'Beleletlen  noi blezer', 36, 44, 'Flowery baiser', 'Burda');
insert into szabasmintak(azon,tipus,min_meret, max_meret, nev, szarmazas)
values(3,'hosszuujju bluz', 35, 36, 'Rosemary shirt', 'Szerkesztes eredmenye');
insert into szabasmintak(azon,tipus,min_meret, max_meret, nev, szarmazas)
values(4,'A vonalu bluz', 30, 38, 'Daisy Longf', 'Szerkesztes eredmenye');

--toroljuk a unique megszoritast
alter table szabasmintak
drop unique (tipus, nev);

--masik modszer
alter table szabasmintak
drop constraint szab_uq;

drop table szabasmintak;

select *
from szabasmintak;

create table kesztermek (
szabasminta_id number(6) references U_UXF1FP.szabasmintak,
szabo_id char(6),
anyag  varchar (20),
keszult date default sysdate,
meret number(2),
constraint kesz_pk primary key(szabasminta_id, szabo_id, keszult)
);

select*
from U_UXF1FP.kesztermek;

insert into U_UXF1FP.kesztermekek(szabasminta_id, szabo_id, anyag, meret)
values (2,'MG319M','pamut', 46);
commit;

--keszitsunk nezetet olyan szoknyakra amiket meg lehet varrni 36 os meretre
create view szoknyak_36 as
select *
from szabasmintak
where tipus like '%szoknya%'
and (min_meret <= 36 and max_meret >= 36 ); 

--adjunk lekerdezesi jogot U_UXF1FP felh.-nak hogy lekerdezze a nezetet
grant select on szoknyak_36 to U_UXF1FP;

select * 
from szoknyak_36;

--adjunk ra a kesztermekek tablankra panovics felhasznalonak tovabbadasi joggal

grant insert on kesztermek to panovics with grant option;
grant insert on kesztermek to vagnera with grant option;
grant all on kesztermek to vagnera;
--vegyuk el panovics osszes jogat
revoke all on kesztermek from panovics;

--outer join
--keressuk meg azokat az autokat amelyeket nem kellett meg szerelni

select au.*
from szerelo.sz_auto au left outer join szerelo.sz_szereles szer
on au.azon = szer.auto_azon
where szer.auto_azon is null;

--all / any / exist

select erkezes_mag
from zoo.zoo_allatok al inner join zoo.zoo_fajok faj
on al.faj_azon =  faj.faj_azon
where faj.faj_nev = 'ork';

select * 
from zoo.zoo_allatok
where erkezes_mag > any (
select erkezes_mag
from zoo.zoo_allatok al inner join zoo.zoo_fajok faj
on al.faj_azon =  faj.faj_azon
where faj.faj_nev = 'ork'
);

--keressunk olyan allatokat amelyek magasabbal minden orknal
select * 
from zoo.zoo_allatok
where erkezes_mag > all (
select erkezes_mag
from zoo.zoo_allatok al inner join zoo.zoo_fajok faj
on al.faj_azon =  faj.faj_azon
where faj.faj_nev = 'ork'
);

--delete
--toroljuk ki a szoknyaknak a szabasmintait
commit;
delete
from szabasmintak
where tipus like '%szoknya%';

--mindenki updatelje a sajat ruhajanak varrasi idejet a szuletesnapjara

update U_UXF1FP.kesztermekek
set keszult = to_date('2004.05.09', 'yyyy.mm.dd')
where szabo_id = 'MG319M';
commit;