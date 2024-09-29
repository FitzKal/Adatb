--61
--M�dos�tsa a nagy termin�lter�lettel rendelkez? kik�t?k le�r�s�t �gy, 
--hogy az az elej�n tar- talmazza a kik�t? helys�g�t is, 
--amelyet egy vessz?vel �s egy sz?k�zzel v�lasszon el a le�r�s jelenlegi tartalm�t�l! 
--A nagy termin�lter�lettel rendelkez? kik�t?k le�r�s�ban szerepel a 'termin�lter�let: nagy, sztring. 
--(Figyeljen a vessz?re, a nagyon nagy" ter�let? kik�t?ket nem szeretn�nk m�dos�tani!) 

create table s_kikoto (
    azon varchar2(50),
    leiras varchar2(1000)
    
);
drop table s_kikoto;

insert into s_kikoto
select kikoto_id, leiras
from hajo.s_kikoto;

select * 
from s_kikoto;

alter table s_kikoto
add (helysegnev varchar2(50));

delete 
from s_kikoto
where azon is null;

update s_kikoto
set leiras = (select helysegnev || ',  ' ||leiras as ujleiras
    from hajo.s_kikoto k inner join hajo.s_helyseg h
    on k.helyseg = h.helyseg_id
    where leiras like '%termin�lter�let: nagy,%')
where leiras like '%termin�lter�let: nagy,%'; 


--62
--Alak�tsa csuba nagybet?ss� azon �gyfelek vezet�knev�t, akik eddig a legt�bbet fizett�k �sszesen a megrendel�seik�rt
update hajo.s_ugyfel
set vezeteknev = upper(vezeteknev)
where ugyfel_id in(
select ugyfel_id
from hajo.s_ugyfel u inner join hajo.s_megrendeles m
on u.ugyfel_id = m.ugyfel
order by fizetett_osszeg desc
fetch first row with ties);


--67.
--A francia kereskedelmi jogszab�lyoknak nemr�g bevezetett v�ltoz�sok jelent?s k�lts�gn�veked�st okoztak a c�g�nk sz�m�ra a francia 
--megrendel�sek lesz�ll�t�s�t illet?en. N�velje meg 15%-al a franciaorsz�gb�l sz�rmaz� �gyfeleink utols� megrendel�sei�rt fizetett �sszeget

update hajo.s_megrendeles
set fizetett_osszeg = fizetett_osszeg * (fizetett_osszeg*15 )/100
where ugyfel in(
    select ugyfel_id
    from hajo.s_ugyfel u inner join hajo.s_megrendeles m
    on u.ugyfel_id = m.ugyfel
    where ugyfel_id in(select ugyfel_id
        from hajo.s_ugyfel u inner join hajo.s_helyseg h
        on u.helyseg = h.helyseg_id
        where orszag = 'Franciaorsz�g')
        order by megrendeles_datuma desc
        fetch first row with ties);

--68
--A n�pess�gi adataink elavultak. 
--A friss�t�s�k egyik l�p�sek�nt n�velje meg 5%-kal az �zsiai orsz�gok telep�l�seinek lakoss�g�t!
update hajo.s_helyseg
set lakossag = lakossag + (lakossag * 5)/100
where helysegnev in (
select helysegnev
from hajo.s_orszag o inner join hajo.s_helyseg h
on o.orszag = h.orszag
where foldresz = '�zsia');

--69
--Egy puszt�t� v�rus szedte �ldozatait Afrika nagyv�rosaiban. Felezze meg azon afrikai telep�l�sek lakoss�g�t, amelyeknek aktu�lis
--lakoss�ga meghaladja a f�lmilli� f?t!
update hajo.s_helyseg
set lakossag = lakossag * 1/2
where helysegnev in(
select helysegnev
from hajo.s_orszag o inner join hajo.s_helyseg h
on o.orszag = h.orszag
where foldresz = 'Afrika' and h.lakossag > 500000);

--70.
--C�g�nk adminisztr�tora elk�vetett egy nagy hib�t. A 2021 j�lius�ban Algeciras kik�t?j�b?l indul� utakat t�vesen
--Vitte be az adatb�zisba, mintha azok Valenci�b�l indultak volna. Val�ban Valenci�b�l egyetlen �t sem indult a k�rd�ses id?pontban
--Korrig�lja az adminisztr�tor hib�j�t! Az egyszer?s�g kedv��rt felt�telezz�k, hogy 1-1 ilyen v�ros l�tezik, egy kik�t?vel

update hajo.s_ut
set indulasi_kikoto = (select kikoto_id
from hajo.s_kikoto k inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
where helysegnev = 'Algeciras'
)
where indulasi_kikoto in (
select kikoto_id 
from hajo.s_kikoto k inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
where helysegnev = 'Valencia')
and extract (year from indulasi_ido) = 2021 and extract(month from indulasi_ido) = 7;

--71.
--Hozzon l�tre n�zetet, amely list�zza az utak minden attrib�tum�t, kieg�sz�tve az indul�si �s �rkez�si kik�t? helys�g �s orsz�gnev�vel.

create view utak as
select u.*, orszag, helysegnev
from hajo.s_ut u inner join hajo.s_kikoto k
on u.indulasi_kikoto = k.kikoto_id
inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
union
select u.*, orszag, helysegnev
from hajo.s_ut u inner join hajo.s_kikoto k
on u.erkezesi_kikoto = k.kikoto_id
inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id;


select * 
from utak;

drop view utak;

--74. Hozzon l�tre n�zetet, amely list�zza a megrendel�sek �sszes attrib�tum�t, kieg�sz�tve az indul�si �s �rkez�si kik�t?
--helys�gnev�vel �s orsz�g�val
create view bruh as
select mg.*, indh.helysegnev || ', ' || indh.orszag as kys1, erkh.helysegnev || ', ' || erkh.orszag as kys2
from hajo.s_megrendeles mg inner join hajo.s_kikoto ind_k
on mg.indulasi_kikoto = ind_k.kikoto_id inner join hajo.s_helyseg indh
on ind_k.helyseg = indh.helyseg_id inner join hajo.s_kikoto erk_kik
on erk_kik.kikoto_id = mg.erkezesi_kikoto inner join hajo.s_helyseg erkh
on erk_kik.helyseg = erkh.helyseg_id;
select * 
from bruh;

drop view bruh;
--75
--Hozzon l�tre n�zetet, amely list�zza, hogy az egyes haj�t�pusokhoz tartoz� haj�k �sszesen h�ny utat teljes�tettek! 
--A list�ban szerepeljen a haj�t�pusok azonos�t�ja, neve �s a teljes�tett utak sz�ma! 
--Azokat a haj�t�pusokat is t�ntesse fel az eredm�nyben, amelyekhez egyetlen haj� sem tartozik, 
--�s azokat is, amelyekhez tartoz� haj�k egyetlen utat sem teljes�tettek! 
--A lista legyen a haj�t�pus neve szerint rendezett!

create view kys3 as
select t.nev, t.hajo_tipus_id, count(*) as xd
from hajo.s_hajo_tipus t left outer join hajo.s_hajo h
on t.hajo_tipus_id = h.hajo_tipus
left outer join hajo.s_ut u
on h.hajo_id = u.hajo
group by t.nev, t.hajo_tipus_id;


--76.
--Hozzon l�tre n�zetet, amely list�zza, hogy az egyes kik�t?knek h�ny telefonsz�ma van. A lista tartalmazza a kik�t?k azonos�t�j�t,
--a helys�g nev�t �s osz�g�t �s a telefonok sz�m�t. Azokat is t�ntess�k fel, aminek nincs telefonsz�ma
create view kikotom_magam as
select k.kikoto_id, orszag, helysegnev, telefon
from hajo.s_kikoto k left outer join hajo.s_kikoto_telefon t
on k.kikoto_id = t.kikoto_id
inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id;

--78.
--Hozzon l�tre n�zetet, amely list�zza, hogy az egyes kik�t?kre h�ny �t vezetett: kik�t?k azonos�t�ja, helys�g�k neve, orsz�ga, utak sz�ma
--Azokat is t�ntess�k fel, ahova egyetlen �t sem vezetett!
select kikoto_id, orszag, helysegnev, count(ut_id) as megtettut
from hajo.s_kikoto k left outer join hajo.s_ut u
on k.kikoto_id = u.erkezesi_kikoto
inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
group by kikoto_id, orszag, helysegnev;


--80
--Egy n�zetet, amely kilist�zza, hogy az egyes kik�t?k h�ny megrendel�sben szerepeltek c�lpontk�nt! A lista tartalmazza kik�t?k id-j�t, helys�gek
--nev�t �s orsz�g�t �s a megrendel�sek sz�m�t
select kikoto_id, helysegnev, orszag, count(*)
from hajo.s_megrendeles m inner join hajo.s_kikoto k
on m.erkezesi_kikoto = k.kikoto_id
inner join hajo.s_helyseg h
on h.helyseg_id = k.helyseg
group by kikoto_id, helysegnev, orszag;

--81. 
--Hozzon l�tre n�zetet, amely megadja a legnagyobb forgalm� kik�t?(k) azonos�t�j�t, helys�gnev�t �s orsz�g�t! A legnagyobb
--forgalm� kik�t? az, amelyik a legt�bb �t indul�si vagy �rkez�si kik�t?je volt.
create view xd as
select kikoto_id, helysegnev, orszag    
from hajo.s_helyseg h inner join hajo.s_kikoto k
on h.helyseg_id = k.helyseg
where kikoto_id in (
select kikoto_id
from hajo.s_ut u inner join hajo.s_kikoto k 
on k.kikoto_id = u.erkezesi_kikoto or u.indulasi_kikoto = k.kikoto_id
group by kikoto_id
order by count(*) desc
fetch first row with ties
);


--92.
--Adjon hivatkoz�si jogosults�got panovicsnak az �n s_ut t�bl�j�nak indulasi_ido �s hajo oszlopaiba
delete from U_VG8KS3.szakdolgozat where cim like '%SQL%';
commit;
