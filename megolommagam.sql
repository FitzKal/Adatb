--61
--Módosítsa a nagy terminálterülettel rendelkez? kiköt?k leírását úgy, 
--hogy az az elején tar- talmazza a kiköt? helységét is, 
--amelyet egy vessz?vel és egy sz?közzel válasszon el a leírás jelenlegi tartalmától! 
--A nagy terminálterülettel rendelkez? kiköt?k leírásában szerepel a 'terminálterület: nagy, sztring. 
--(Figyeljen a vessz?re, a nagyon nagy" terület? kiköt?ket nem szeretnénk módosítani!) 

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
    where leiras like '%terminálterület: nagy,%')
where leiras like '%terminálterület: nagy,%'; 


--62
--Alakítsa csuba nagybet?ssé azon ügyfelek vezetéknevét, akik eddig a legtöbbet fizették összesen a megrendeléseikért
update hajo.s_ugyfel
set vezeteknev = upper(vezeteknev)
where ugyfel_id in(
select ugyfel_id
from hajo.s_ugyfel u inner join hajo.s_megrendeles m
on u.ugyfel_id = m.ugyfel
order by fizetett_osszeg desc
fetch first row with ties);


--67.
--A francia kereskedelmi jogszabályoknak nemrég bevezetett változások jelent?s költségnövekedést okoztak a cégünk számára a francia 
--megrendelések leszállítását illet?en. Növelje meg 15%-al a franciaországból származó ügyfeleink utolsó megrendeléseiért fizetett összeget

update hajo.s_megrendeles
set fizetett_osszeg = fizetett_osszeg * (fizetett_osszeg*15 )/100
where ugyfel in(
    select ugyfel_id
    from hajo.s_ugyfel u inner join hajo.s_megrendeles m
    on u.ugyfel_id = m.ugyfel
    where ugyfel_id in(select ugyfel_id
        from hajo.s_ugyfel u inner join hajo.s_helyseg h
        on u.helyseg = h.helyseg_id
        where orszag = 'Franciaország')
        order by megrendeles_datuma desc
        fetch first row with ties);

--68
--A népességi adataink elavultak. 
--A frissítésük egyik lépéseként növelje meg 5%-kal az ázsiai országok településeinek lakosságát!
update hajo.s_helyseg
set lakossag = lakossag + (lakossag * 5)/100
where helysegnev in (
select helysegnev
from hajo.s_orszag o inner join hajo.s_helyseg h
on o.orszag = h.orszag
where foldresz = 'Ázsia');

--69
--Egy pusztító vírus szedte áldozatait Afrika nagyvárosaiban. Felezze meg azon afrikai települések lakosságát, amelyeknek aktuális
--lakossága meghaladja a félmillió f?t!
update hajo.s_helyseg
set lakossag = lakossag * 1/2
where helysegnev in(
select helysegnev
from hajo.s_orszag o inner join hajo.s_helyseg h
on o.orszag = h.orszag
where foldresz = 'Afrika' and h.lakossag > 500000);

--70.
--Cégünk adminisztrátora elkövetett egy nagy hibát. A 2021 júliusában Algeciras kiköt?jéb?l induló utakat tévesen
--Vitte be az adatbázisba, mintha azok Valenciából indultak volna. Valóban Valenciából egyetlen út sem indult a kérdéses id?pontban
--Korrigálja az adminisztrátor hibáját! Az egyszer?ség kedvéért feltételezzük, hogy 1-1 ilyen város létezik, egy kiköt?vel

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
--Hozzon létre nézetet, amely listázza az utak minden attribútumát, kiegészítve az indulási és érkezési kiköt? helység és országnevével.

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

--74. Hozzon létre nézetet, amely listázza a megrendelések összes attribútumát, kiegészítve az indulási és érkezési kiköt?
--helységnevével és országával
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
--Hozzon létre nézetet, amely listázza, hogy az egyes hajótípusokhoz tartozó hajók összesen hány utat teljesítettek! 
--A listában szerepeljen a hajótípusok azonosítója, neve és a teljesített utak száma! 
--Azokat a hajótípusokat is tüntesse fel az eredményben, amelyekhez egyetlen hajó sem tartozik, 
--és azokat is, amelyekhez tartozó hajók egyetlen utat sem teljesítettek! 
--A lista legyen a hajótípus neve szerint rendezett!

create view kys3 as
select t.nev, t.hajo_tipus_id, count(*) as xd
from hajo.s_hajo_tipus t left outer join hajo.s_hajo h
on t.hajo_tipus_id = h.hajo_tipus
left outer join hajo.s_ut u
on h.hajo_id = u.hajo
group by t.nev, t.hajo_tipus_id;


--76.
--Hozzon létre nézetet, amely listázza, hogy az egyes kiköt?knek hány telefonszáma van. A lista tartalmazza a kiköt?k azonosítóját,
--a helység nevét és oszágát és a telefonok számát. Azokat is tüntessük fel, aminek nincs telefonszáma
create view kikotom_magam as
select k.kikoto_id, orszag, helysegnev, telefon
from hajo.s_kikoto k left outer join hajo.s_kikoto_telefon t
on k.kikoto_id = t.kikoto_id
inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id;

--78.
--Hozzon létre nézetet, amely listázza, hogy az egyes kiköt?kre hány út vezetett: kiköt?k azonosítója, helységük neve, országa, utak száma
--Azokat is tüntessük fel, ahova egyetlen út sem vezetett!
select kikoto_id, orszag, helysegnev, count(ut_id) as megtettut
from hajo.s_kikoto k left outer join hajo.s_ut u
on k.kikoto_id = u.erkezesi_kikoto
inner join hajo.s_helyseg h
on k.helyseg = h.helyseg_id
group by kikoto_id, orszag, helysegnev;


--80
--Egy nézetet, amely kilistázza, hogy az egyes kiköt?k hány megrendelésben szerepeltek célpontként! A lista tartalmazza kiköt?k id-jét, helységek
--nevét és országát és a megrendelések számát
select kikoto_id, helysegnev, orszag, count(*)
from hajo.s_megrendeles m inner join hajo.s_kikoto k
on m.erkezesi_kikoto = k.kikoto_id
inner join hajo.s_helyseg h
on h.helyseg_id = k.helyseg
group by kikoto_id, helysegnev, orszag;

--81. 
--Hozzon létre nézetet, amely megadja a legnagyobb forgalmú kiköt?(k) azonosítóját, helységnevét és országát! A legnagyobb
--forgalmú kiköt? az, amelyik a legtöbb út indulási vagy érkezési kiköt?je volt.
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
--Adjon hivatkozási jogosultságot panovicsnak az ön s_ut táblájának indulasi_ido és hajo oszlopaiba
delete from U_VG8KS3.szakdolgozat where cim like '%SQL%';
commit;
