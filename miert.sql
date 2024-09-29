--Listázza ki ábécérendben azoknak a helységeknek az azonosítóját, országát és nevét, ahonnan származnak ügyfeleink, vagy ahol vannak kiköt?k!
--Egy helység csak egyszer szerepeljen az eredményben! A lista legyen országnév, azon belül helységnév szerint rendezett.
select  distinct(helysegnev),orszag,h.helyseg_id
from hajo.s_helyseg h left outer join hajo.s_ugyfel u
on h.helyseg_id = u.helyseg
where ugyfel_id is not null
union
select distinct(helysegnev),orszag,h.helyseg_id
from  hajo.s_helyseg h left outer join hajo.s_kikoto k
on h.helyseg_id = k.helyseg
where kikoto_id is not null
order by orszag, helysegnev asc;

--1
--Listázza ki az ügyfelek azonosítóját, teljes nevét, valamint a megrendeléseik azonosítóját! Azok az ügyfelek is szerepeljenek az eredményben,
--akik soha nem adtak le megrendeléseket. A lista legyen vezetéknév, azon belül megrendelés azonosítója szerint rendezve
select u.ugyfel_id, vezeteknev, keresztnev, megrendeles_id
from hajo.s_ugyfel u left outer join hajo.s_megrendeles m
on u.ugyfel_id = m.ugyfel
order by vezeteknev, megrendeles_id;

--2.
--Listázza ki a hajótípusok azonosítóját és nevét, valamint az adott típusú hajók azonosítóját és nevét! A hajótípusok nevét tartalmazó oszlop
--'típusnév', a hajók nevét tartalmazó oszlop pedig 'hajónév' legyen! Azok a hajótípusok is jelenjenek meg, amelyhez egyetlen hajó sem tartzoik.
--A lista legyen a hajótípus neve, azon belül a hajó neve alapján rendezve.
select t.hajo_tipus_id, t.nev as tipusnev, hajo_id, h.nev as hajonev
from hajo.s_hajo_tipus t left outer join hajo.s_hajo h
on t.hajo_tipus_id = h.hajo_tipus
order by t.hajo_tipus_id, h.nev;


--5.
--Listázza ki Magyarországénál kisebb lakossággal rendelkez? országok nevét, lakosságát, valamint a f?városuk nevét. Azokat az országokat is
--listázza, amelyeknek nem ismerjük a f?városát. Ezen országok esetében a f?város helyén "nem ismert" sztring szerepeljen. Rendezze az országokat
--a lakosság szerint csökken? sorrendben.
select o.orszag, h.lakossag, nvl(o.fovaros,0)
from hajo.s_helyseg h right outer join hajo.s_orszag o
on h.orszag = o.orszag
where o.lakossag < (select lakossag
from hajo.s_orszag
where orszag = 'Magyarország'
)
order by o.lakossag desc;

--6 
--Listázza ki azoknak az ügyfeleknek az azonosítóját és teljes nevét,
--akik adtak már fel olaszországi kiköt?b?l induló szállításra vonatkozó megrendelést! 
--Egy ügyfél csak egyszer szere- peljen az eredményben!

select distinct(u.ugyfel_id), vezeteknev || ' ' || keresztnev as teljesnev
from hajo.s_megrendeles m inner join hajo.s_ugyfel u
on m.ugyfel = u.ugyfel_id
where m.indulasi_kikoto in (select kikoto_id
from hajo.s_kikoto k inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
where orszag = 'Olaszország');

--7
--Listázza ki azoknak a hajóknak az azonosítóját és nevét, amelyek egyetlen út célállomásaként sem kötöttek ki francia kiköt?kben
select h.hajo_id, h.nev
from hajo.s_hajo h inner join hajo.s_ut u
on h.hajo_id = u.hajo
where erkezesi_kikoto not in (select kikoto_id
from hajo.s_helyseg h inner join hajo.s_kikoto k
on h.helyseg_id = k.helyseg
where orszag = 'Franciaország'
);

--8.
--Listázza ki azoknak a helységeknek az azonosítóját, országát és nevét, amelyeknek valamelyik kiköt?jéb?l
--indult már útra az SC Bella nev? hajó! Egy helység csak egyszer szerepeljen

select distinct (h.helyseg_id), orszag, helysegnev
from hajo.s_kikoto k inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
where kikoto_id in (select indulasi_kikoto
from hajo.s_hajo h inner join hajo.s_ut u
on h.hajo_id = u.hajo
where h.nev = 'SC Bella');

--9.
--Listázza ki azokat a mmegrendeléseket (azonosító) amelyekért többet fizettek, mint a 2021. áprilisában leadott megrendelések
--Bármelyikéért. A fizetett összeget is tüntesse fel!
select megrendeles_id, fizetett_osszeg
from hajo.s_megrendeles
where fizetett_osszeg > any (select fizetett_osszeg
from hajo.s_megrendeles
where extract (year from megrendeles_datuma) = ('2021') and extract (month from megrendeles_datuma) = ('4'));

--10.
--Listázza ki azokat a megrendeléseknek az azonositóját amelyekben ugyanannyi konténer igényeltek, mint valamelyik 2021 feb. leadott megrendelésben! 
--A megrendelések azonositójuk mellet tüntesse fel az igényelt konténerek számát is.

select megrendeles_id, igenyelt_kontenerszam
from hajo.s_megrendeles
where igenyelt_kontenerszam =  any(select igenyelt_kontenerszam
from hajo.s_megrendeles
where extract (year from megrendeles_datuma) = ('2021') and extract (month from megrendeles_datuma) = ('2')
);

--11
--Listázza ki azoknak a hajóknak a nevét, a maximális súlyterhelését, valamint a tipusának a nevét, amely egyetlen utat sem teljesített.
--A hajó nevét megadó oszlop neve a 'hajónév' a tipusnevét a 'tipusnév'.
select h.nev as hajonev, max_sulyterheles, t.nev as tipusnev
from hajo.s_hajo h inner join hajo.s_hajo_tipus t
on h.hajo_tipus = t.hajo_tipus_id
left outer join hajo.s_ut u
on h.hajo_id = u.hajo
where ut_id is null;

--12.
--Listázza ki azoknak az ügyfeleknek a teljes nevét és származási országát, akiknek nincs 1milliónál nagyobb érték? rendelése!
--Azok is szerepeljenek, akiknek nem ismerjük a származását. Rendezze az eredményt vezetéknév, azon belül keresztnév szerint
select vezeteknev || ' ' || keresztnev as teljesnev, orszag
from hajo.s_ugyfel u left outer join hajo.s_helyseg h
on u.helyseg = h.helyseg_id
where ugyfel_id in(select m.ugyfel
from hajo.s_megrendeles m inner join hajo.s_ugyfel u
on m.ugyfel = u.ugyfel_id
group by m.ugyfel
having sum(fizetett_osszeg) < 10000000)
order by vezeteknev,keresztnev;

--13
--Listázza ki ábécérendben azoknak a kiköt?knek az azonosítóját, amelyekbe vagy teljesített egy utat az It_Cat azonosítójú kiköt?b?l, vagy célpontja egy, az It_Cat
--azonosítój? kiköt?j? megrendelésnek!

select erkezesi_kikoto as kikoto
from hajo.s_ut
where indulasi_kikoto = 'It_Cat' 
and
erkezesi_kikoto is not null
union
select indulasi_kikoto as kikoto
from hajo.s_megrendeles
where erkezesi_kikoto = 'It_Cat'
order by kikoto;

--14.
--Listázza ki ábécérendben azoknak a kiköt?knek az azonosítóját, melyekbe legalább egy hajó teljesített utat
--Az 'It_Cat' azonosítójú kiköt?b?l és célpontja legalább egy, az 'It_Cat' kiköt?b?l induló megrendelésnek. A kiköt? csak egyszer
--Szerepeljen a lekérdezésben

select distinct(erkezesi_kikoto)
from hajo.s_ut
where erkezesi_ido is not null
and indulasi_kikoto = 'It_Cat'
and erkezesi_kikoto in (select erkezesi_kikoto
from hajo.s_megrendeles
where indulasi_kikoto = 'It_Cat'
)
order by erkezesi_kikoto;

--15. 
--Listázza ki ábécérendben azoknak a helységeknek az azonosítóját, országát és nevét, ahonnan származnak ügyfeleink, vagy ahol vannak kiköt?k!
--Egy helység csak egyszer szerepeljen az eredményben! A lista legyen országnév, azon belül helységnév szerint rendezett.
select distinct(helysegnev), orszag, helyseg_id
from hajo.s_helyseg
where helyseg_id in(select helyseg_id
from hajo.s_helyseg h left outer join hajo.s_kikoto k
on h.helyseg_id = k.helyseg
where kikoto_id is not null) or
helyseg_id in(select helyseg_id
from hajo.s_helyseg h inner join hajo.s_ugyfel u
on h.helyseg_id = u.helyseg)
order by orszag, helysegnev;

--32
--Hozzon létre egy s_személyzet nev? táblát, amelyben a hajókon dolgozó személyzet adatai találhatóak!
--Minden szerel?nek van azonosítója, maximum öt jegy? egész szám, ez az els?dleges kulcs
--vezeték és keresztneve, mindkett? maximum negyven karakteres sztring
 --születési dátuma
 --e-mail címe (maximum 200 karakteres string)
 --hogy melyik hajó személyzetéhez tartozik (maximum 10 karakteres sztring), hivatkozással az s_hajó táblára
 
 create table s_szemelyzet(
 szerelo_azon number(5),
 vezeteknev varchar2(40),
 keresztnev varchar2(40),
 szul_dat date,
 email varchar2(200),
 hajo_id varchar2(10),
constraint pk_szemelyzet primary key(szerelo_azon),
constraint fk_szemelyzet foreign key(hajo_id) references hajo.s_hajo(hajo_id),
constraint uq_szemelyzet unique(vezeteknev, keresztnev, szul_dat)
 );
 
 
--33
--Hozzon létre egy 's_kikoto_email' nev? táblát, amelyben a kiköt?k e-mail címét tároljuk! Legyen benne egy kikoto_id nev? oszlop
--(maximum 10 karakteres string), amely hivatkozik az s_kikoto táblára.
--Valamint egy email cím, ami egy maximum 200 karakteres string!
--Egy kiköt?nek több email címe lehet, ezért a tábla els?dleges kulcsát a két oszlop együttesen alkossa!
--Minden megszorítást nevezzen el!
 create table s_kikoto(
 azon varchar2(6),
 constraint bruhh primary key(azon)
 );
 drop table s_kikoto;
 
 create table s_kikoto_email(
  kikoto_id varchar2(10),
  email varchar2(200),
  constraint pk_kikid foreign key(kikoto_id) references s_kikoto(azon),
  constraint pk_kkikid primary key(kikoto_id,email)
 );
 drop table s_kikoto_email;

alter table s_kikoto_email
drop constraint pk_kikid;
--35.
--Hozzon létre egy s_hajo_javitas táblát, ami a hajók javítási adatait tartalmazza! Legyen benne a javított hajó azonosítója, amely az s_hajó táblára hivatkozik, legfeljebb
--10 karakter hosszú sztring és ne legyen null. Javítás kezdete és vége_ dárumok. Javítás ára: egy legfeljebb 10 jegy? valós szám, két tizedesjeggyel, valamint a hiba
--leírása, 200 karakteres sztring (legfeljebb).
--A tábla els?dleges kulcsa és a javítás kezd?dátuma els?dlegesen alkossa. További megkötés, hogy a javítás vége csak a javítás kezdete
--nél kés?bbi dátum lehet.
 create table s_hajo(
 azon varchar2(6),
 constraint bruh primary key(azon)
 );

create table s_hajo_javitas (
    hajo_id varchar2(10),
    javitas_kezdete date,
    javitas_vege date,
    ar number(10,2),
    hiba varchar2(200),
    CONSTRAINT hajo FOREIGN key(hajo_id) references s_hajo(azon),
    constraint jav check (javitas_kezdete < javitas_vege),
     CONSTRAINT pk PRIMARY key  (javitas_kezdete)
);
drop TABLE s_hajo_javitas;

--43
--Törölje az s_hajo és az s_hajo tipus táblákat! Vegye figyelembe az egyes táblákra hivatkozó küls? kulcsokat.
drop table s_hajo;
alter table s_hajo_javitas
drop CONSTRAINT hajo;


--42
-- A helységek lakossági adata nem fontos számunkra.
--Törölje az 's_helyseg' tábla 'lakossag' oszlopát!
ALTER TABLE s_hajo_javitas
DROP COLUMN ar;
ALTER TABLE s_hajo_javitas
DROP COLUMN hiba;

--44
--Törölje az 's_kikoto_telefon' tábla els?dleges kulcs megszorítását!
alter table s_kikoto
drop constraint bruhh;

--49.
--az s_kiköt? telefon táblát egy email nev?, amx 200 karakter hosszú sztringel, melyben alapértelmezetten a 'nem ismert' sztring legyen
alter table s_kikoto
add (email varchar2(200) default 'nem ismert');
select * 
from s_kikoto;

alter table s_kikoto
drop column email;

--50.
--Módosítsa az s_ugyfel tábla email oszlopának maximális hosszát 50 karakterre, az utca_hsz oszlop hosszát pedig 100 karakterre!
create table s_ugyfel(
 email varchar2(10),
 utca_hsz varchar2(10)
);
drop table s_ugyfel;

alter table s_ugyfel
modify(email varchar2(50))
modify(utca_hsz varchar2(100));

--53
--Szúrja be a hajó sémából a saját sémájának s_ugyfel táblájába az olaszországi ügyfeleket!

select * 
from s_ugyfel;

insert into s_ugyfel(
select email, utca_hsz
from hajo.s_ugyfel u inner join hajo.s_helyseg h
on u.helyseg = h.helyseg_id
where orszag = 'Olaszország'
);


--54
--Szúrja be a gajó sémából a saját sémájának s:hajó táblájába a small feeder tipusú hajók közül azokat,
--amelyeknek nettó súlya legalább 250 tonna
select hajo_id
from hajo.s_hajo h inner join hajo.s_hajo_tipus t
on h.hajo_tipus = t.hajo_tipus_id
where t.nev = 'Small feeder' and
netto_suly >= 250;

insert into s_hajo(
select hajo_id
from hajo.s_hajo h inner join hajo.s_hajo_tipus t
on h.hajo_tipus = t.hajo_tipus_id
where t.nev = 'Small feeder' and
netto_suly >= 250);
select *
from s_hajo;

--55.
--Szúrja be a 'hajó' sémából a saját sémájának s_hajo táblájába azokat a 'Small Feeder"' típusú hjaókat, amelyek legfeljebb 10 konténert
--tudnak szállítani egyszerre;
select hajo_id
from hajo.s_hajo h inner join hajo.s_hajo_tipus t
on h.hajo_tipus = t.hajo_tipus_id
where max_kontener_dbszam <= 10;

insert into s_hajo(select hajo_id
from hajo.s_hajo h inner join hajo.s_hajo_tipus t
on h.hajo_tipus = t.hajo_tipus_id
where max_kontener_dbszam <= 10
);

--57
--Törölje a szárazdokkal rendelkez? olaszországi és ibériai kiköt?ket! Azok a kiköt?k rendelkeznek szárazdokkal, amelyeknek a leírásában
--szerepel a szárazdokk szó.

select * 
from s_kikoto;

alter table s_kikoto
modify (leiras varchar2(1000));

alter table s_kikoto
modify (azon varchar2(10));

insert into s_kikoto
select kikoto_id, leiras
from hajo.s_kikoto;
commit;

delete 
from s_kikoto
where azon in (
select kikoto_id
from hajo.s_kikoto k inner join hajo.s_helyseg h 
on k.helyseg = h.helyseg_id
where orszag in('Olaszország', 'Ibéria')
and leiras like ('%szárazdokk%'));


--59.
--Törölje azokata 2021 jún. induló utakat,amelyek 20 nál kevesebb konténert szállított a hajó.
create table s_ut(
 id number (10)
 );
 
 insert into s_ut
 select ut_id
 from hajo.s_ut;

delete
from s_ut
where id in ( select ut_id
from hajo.s_ut u inner join hajo.s_szallit s
on u.ut_id = s.ut
where extract (year from indulasi_ido) = '2021' and extract (month from indulasi_ido) = '6'
and kontener < 20);

--61
--Módosítsa a nagy terminálterülettel rendelkez? kiköt?k leírását úgy, 
--hogy az az elején tar- talmazza a kiköt? helységét is, 
--amelyet egy vessz?vel és egy sz?közzel válasszon el a leírás jelenlegi tartalmától! 
--A nagy terminálterülettel rendelkez? kiköt?k leírásában szerepel a 'terminálterület: nagy, sztring. 
--(Figyeljen a vessz?re, a nagyon nagy" terület? kiköt?ket nem szeretnénk módosítani!) 

select *
from s_kikoto;
commit;

alter table s_kikoto
add (helysegnev varchar2(500));

select helysegnev
from hajo.s_kikoto k inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
where kikoto_id in (select azon
from s_kikoto);

insert into s_kikoto (helysegnev)
(select helysegnev
from hajo.s_kikoto k inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
where kikoto_id in (select azon
from s_kikoto));


alter table s_kikoto
drop column helysegnev;

delete
from s_kikoto
where azon is null;


