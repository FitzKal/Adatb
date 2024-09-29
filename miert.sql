--List�zza ki �b�c�rendben azoknak a helys�geknek az azonos�t�j�t, orsz�g�t �s nev�t, ahonnan sz�rmaznak �gyfeleink, vagy ahol vannak kik�t?k!
--Egy helys�g csak egyszer szerepeljen az eredm�nyben! A lista legyen orsz�gn�v, azon bel�l helys�gn�v szerint rendezett.
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
--List�zza ki az �gyfelek azonos�t�j�t, teljes nev�t, valamint a megrendel�seik azonos�t�j�t! Azok az �gyfelek is szerepeljenek az eredm�nyben,
--akik soha nem adtak le megrendel�seket. A lista legyen vezet�kn�v, azon bel�l megrendel�s azonos�t�ja szerint rendezve
select u.ugyfel_id, vezeteknev, keresztnev, megrendeles_id
from hajo.s_ugyfel u left outer join hajo.s_megrendeles m
on u.ugyfel_id = m.ugyfel
order by vezeteknev, megrendeles_id;

--2.
--List�zza ki a haj�t�pusok azonos�t�j�t �s nev�t, valamint az adott t�pus� haj�k azonos�t�j�t �s nev�t! A haj�t�pusok nev�t tartalmaz� oszlop
--'t�pusn�v', a haj�k nev�t tartalmaz� oszlop pedig 'haj�n�v' legyen! Azok a haj�t�pusok is jelenjenek meg, amelyhez egyetlen haj� sem tartzoik.
--A lista legyen a haj�t�pus neve, azon bel�l a haj� neve alapj�n rendezve.
select t.hajo_tipus_id, t.nev as tipusnev, hajo_id, h.nev as hajonev
from hajo.s_hajo_tipus t left outer join hajo.s_hajo h
on t.hajo_tipus_id = h.hajo_tipus
order by t.hajo_tipus_id, h.nev;


--5.
--List�zza ki Magyarorsz�g�n�l kisebb lakoss�ggal rendelkez? orsz�gok nev�t, lakoss�g�t, valamint a f?v�rosuk nev�t. Azokat az orsz�gokat is
--list�zza, amelyeknek nem ismerj�k a f?v�ros�t. Ezen orsz�gok eset�ben a f?v�ros hely�n "nem ismert" sztring szerepeljen. Rendezze az orsz�gokat
--a lakoss�g szerint cs�kken? sorrendben.
select o.orszag, h.lakossag, nvl(o.fovaros,0)
from hajo.s_helyseg h right outer join hajo.s_orszag o
on h.orszag = o.orszag
where o.lakossag < (select lakossag
from hajo.s_orszag
where orszag = 'Magyarorsz�g'
)
order by o.lakossag desc;

--6 
--List�zza ki azoknak az �gyfeleknek az azonos�t�j�t �s teljes nev�t,
--akik adtak m�r fel olaszorsz�gi kik�t?b?l indul� sz�ll�t�sra vonatkoz� megrendel�st! 
--Egy �gyf�l csak egyszer szere- peljen az eredm�nyben!

select distinct(u.ugyfel_id), vezeteknev || ' ' || keresztnev as teljesnev
from hajo.s_megrendeles m inner join hajo.s_ugyfel u
on m.ugyfel = u.ugyfel_id
where m.indulasi_kikoto in (select kikoto_id
from hajo.s_kikoto k inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
where orszag = 'Olaszorsz�g');

--7
--List�zza ki azoknak a haj�knak az azonos�t�j�t �s nev�t, amelyek egyetlen �t c�l�llom�sak�nt sem k�t�ttek ki francia kik�t?kben
select h.hajo_id, h.nev
from hajo.s_hajo h inner join hajo.s_ut u
on h.hajo_id = u.hajo
where erkezesi_kikoto not in (select kikoto_id
from hajo.s_helyseg h inner join hajo.s_kikoto k
on h.helyseg_id = k.helyseg
where orszag = 'Franciaorsz�g'
);

--8.
--List�zza ki azoknak a helys�geknek az azonos�t�j�t, orsz�g�t �s nev�t, amelyeknek valamelyik kik�t?j�b?l
--indult m�r �tra az SC Bella nev? haj�! Egy helys�g csak egyszer szerepeljen

select distinct (h.helyseg_id), orszag, helysegnev
from hajo.s_kikoto k inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
where kikoto_id in (select indulasi_kikoto
from hajo.s_hajo h inner join hajo.s_ut u
on h.hajo_id = u.hajo
where h.nev = 'SC Bella');

--9.
--List�zza ki azokat a mmegrendel�seket (azonos�t�) amelyek�rt t�bbet fizettek, mint a 2021. �prilis�ban leadott megrendel�sek
--B�rmelyik��rt. A fizetett �sszeget is t�ntesse fel!
select megrendeles_id, fizetett_osszeg
from hajo.s_megrendeles
where fizetett_osszeg > any (select fizetett_osszeg
from hajo.s_megrendeles
where extract (year from megrendeles_datuma) = ('2021') and extract (month from megrendeles_datuma) = ('4'));

--10.
--List�zza ki azokat a megrendel�seknek az azonosit�j�t amelyekben ugyanannyi kont�ner ig�nyeltek, mint valamelyik 2021 feb. leadott megrendel�sben! 
--A megrendel�sek azonosit�juk mellet t�ntesse fel az ig�nyelt kont�nerek sz�m�t is.

select megrendeles_id, igenyelt_kontenerszam
from hajo.s_megrendeles
where igenyelt_kontenerszam =  any(select igenyelt_kontenerszam
from hajo.s_megrendeles
where extract (year from megrendeles_datuma) = ('2021') and extract (month from megrendeles_datuma) = ('2')
);

--11
--List�zza ki azoknak a haj�knak a nev�t, a maxim�lis s�lyterhel�s�t, valamint a tipus�nak a nev�t, amely egyetlen utat sem teljes�tett.
--A haj� nev�t megad� oszlop neve a 'haj�n�v' a tipusnev�t a 'tipusn�v'.
select h.nev as hajonev, max_sulyterheles, t.nev as tipusnev
from hajo.s_hajo h inner join hajo.s_hajo_tipus t
on h.hajo_tipus = t.hajo_tipus_id
left outer join hajo.s_ut u
on h.hajo_id = u.hajo
where ut_id is null;

--12.
--List�zza ki azoknak az �gyfeleknek a teljes nev�t �s sz�rmaz�si orsz�g�t, akiknek nincs 1milli�n�l nagyobb �rt�k? rendel�se!
--Azok is szerepeljenek, akiknek nem ismerj�k a sz�rmaz�s�t. Rendezze az eredm�nyt vezet�kn�v, azon bel�l keresztn�v szerint
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
--List�zza ki �b�c�rendben azoknak a kik�t?knek az azonos�t�j�t, amelyekbe vagy teljes�tett egy utat az It_Cat azonos�t�j� kik�t?b?l, vagy c�lpontja egy, az It_Cat
--azonos�t�j? kik�t?j? megrendel�snek!

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
--List�zza ki �b�c�rendben azoknak a kik�t?knek az azonos�t�j�t, melyekbe legal�bb egy haj� teljes�tett utat
--Az 'It_Cat' azonos�t�j� kik�t?b?l �s c�lpontja legal�bb egy, az 'It_Cat' kik�t?b?l indul� megrendel�snek. A kik�t? csak egyszer
--Szerepeljen a lek�rdez�sben

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
--List�zza ki �b�c�rendben azoknak a helys�geknek az azonos�t�j�t, orsz�g�t �s nev�t, ahonnan sz�rmaznak �gyfeleink, vagy ahol vannak kik�t?k!
--Egy helys�g csak egyszer szerepeljen az eredm�nyben! A lista legyen orsz�gn�v, azon bel�l helys�gn�v szerint rendezett.
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
--Hozzon l�tre egy s_szem�lyzet nev? t�bl�t, amelyben a haj�kon dolgoz� szem�lyzet adatai tal�lhat�ak!
--Minden szerel?nek van azonos�t�ja, maximum �t jegy? eg�sz sz�m, ez az els?dleges kulcs
--vezet�k �s keresztneve, mindkett? maximum negyven karakteres sztring
 --sz�let�si d�tuma
 --e-mail c�me (maximum 200 karakteres string)
 --hogy melyik haj� szem�lyzet�hez tartozik (maximum 10 karakteres sztring), hivatkoz�ssal az s_haj� t�bl�ra
 
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
--Hozzon l�tre egy 's_kikoto_email' nev? t�bl�t, amelyben a kik�t?k e-mail c�m�t t�roljuk! Legyen benne egy kikoto_id nev? oszlop
--(maximum 10 karakteres string), amely hivatkozik az s_kikoto t�bl�ra.
--Valamint egy email c�m, ami egy maximum 200 karakteres string!
--Egy kik�t?nek t�bb email c�me lehet, ez�rt a t�bla els?dleges kulcs�t a k�t oszlop egy�ttesen alkossa!
--Minden megszor�t�st nevezzen el!
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
--Hozzon l�tre egy s_hajo_javitas t�bl�t, ami a haj�k jav�t�si adatait tartalmazza! Legyen benne a jav�tott haj� azonos�t�ja, amely az s_haj� t�bl�ra hivatkozik, legfeljebb
--10 karakter hossz� sztring �s ne legyen null. Jav�t�s kezdete �s v�ge_ d�rumok. Jav�t�s �ra: egy legfeljebb 10 jegy? val�s sz�m, k�t tizedesjeggyel, valamint a hiba
--le�r�sa, 200 karakteres sztring (legfeljebb).
--A t�bla els?dleges kulcsa �s a jav�t�s kezd?d�tuma els?dlegesen alkossa. Tov�bbi megk�t�s, hogy a jav�t�s v�ge csak a jav�t�s kezdete
--n�l k�s?bbi d�tum lehet.
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
--T�r�lje az s_hajo �s az s_hajo tipus t�bl�kat! Vegye figyelembe az egyes t�bl�kra hivatkoz� k�ls? kulcsokat.
drop table s_hajo;
alter table s_hajo_javitas
drop CONSTRAINT hajo;


--42
-- A helys�gek lakoss�gi adata nem fontos sz�munkra.
--T�r�lje az 's_helyseg' t�bla 'lakossag' oszlop�t!
ALTER TABLE s_hajo_javitas
DROP COLUMN ar;
ALTER TABLE s_hajo_javitas
DROP COLUMN hiba;

--44
--T�r�lje az 's_kikoto_telefon' t�bla els?dleges kulcs megszor�t�s�t!
alter table s_kikoto
drop constraint bruhh;

--49.
--az s_kik�t? telefon t�bl�t egy email nev?, amx 200 karakter hossz� sztringel, melyben alap�rtelmezetten a 'nem ismert' sztring legyen
alter table s_kikoto
add (email varchar2(200) default 'nem ismert');
select * 
from s_kikoto;

alter table s_kikoto
drop column email;

--50.
--M�dos�tsa az s_ugyfel t�bla email oszlop�nak maxim�lis hossz�t 50 karakterre, az utca_hsz oszlop hossz�t pedig 100 karakterre!
create table s_ugyfel(
 email varchar2(10),
 utca_hsz varchar2(10)
);
drop table s_ugyfel;

alter table s_ugyfel
modify(email varchar2(50))
modify(utca_hsz varchar2(100));

--53
--Sz�rja be a haj� s�m�b�l a saj�t s�m�j�nak s_ugyfel t�bl�j�ba az olaszorsz�gi �gyfeleket!

select * 
from s_ugyfel;

insert into s_ugyfel(
select email, utca_hsz
from hajo.s_ugyfel u inner join hajo.s_helyseg h
on u.helyseg = h.helyseg_id
where orszag = 'Olaszorsz�g'
);


--54
--Sz�rja be a gaj� s�m�b�l a saj�t s�m�j�nak s:haj� t�bl�j�ba a small feeder tipus� haj�k k�z�l azokat,
--amelyeknek nett� s�lya legal�bb 250 tonna
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
--Sz�rja be a 'haj�' s�m�b�l a saj�t s�m�j�nak s_hajo t�bl�j�ba azokat a 'Small Feeder"' t�pus� hja�kat, amelyek legfeljebb 10 kont�nert
--tudnak sz�ll�tani egyszerre;
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
--T�r�lje a sz�razdokkal rendelkez? olaszorsz�gi �s ib�riai kik�t?ket! Azok a kik�t?k rendelkeznek sz�razdokkal, amelyeknek a le�r�s�ban
--szerepel a sz�razdokk sz�.

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
where orszag in('Olaszorsz�g', 'Ib�ria')
and leiras like ('%sz�razdokk%'));


--59.
--T�r�lje azokata 2021 j�n. indul� utakat,amelyek 20 n�l kevesebb kont�nert sz�ll�tott a haj�.
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
--M�dos�tsa a nagy termin�lter�lettel rendelkez? kik�t?k le�r�s�t �gy, 
--hogy az az elej�n tar- talmazza a kik�t? helys�g�t is, 
--amelyet egy vessz?vel �s egy sz?k�zzel v�lasszon el a le�r�s jelenlegi tartalm�t�l! 
--A nagy termin�lter�lettel rendelkez? kik�t?k le�r�s�ban szerepel a 'termin�lter�let: nagy, sztring. 
--(Figyeljen a vessz?re, a nagyon nagy" ter�let? kik�t?ket nem szeretn�nk m�dos�tani!) 

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


