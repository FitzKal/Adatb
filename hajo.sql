--1
select kontener, megrendeles, round(rakomanysuly,2)
from hajo.s_hozzarendel
where rakomanysuly > 15
order by rakomanysuly asc;

--2
select *
from hajo.s_kikoto
where leiras like ('%mobil daruk%') and leiras like ('%kiköt?méret: kicsi%');

--3rawr
select *
from hajo.s_ut
where round(extract (day from indulasi_ido)/1440,2) = 0
order by indulasi_ido asc;

select *
from hajo.s_ut
where to_char(indulasi_ido, 'MM:SS') not like ('__:00')
order by indulasi_ido asc;



--4(éve)

select hajo_tipus ,count(*)
from hajo.s_hajo
where max_sulyterheles > 500
group by hajo_tipus;

--5megolom magam
select to_char(megrendeles_datuma, 'yy.mm'), count(*)
from hajo.s_megrendeles
group by to_char(megrendeles_datuma, 'yy.mm')
having count(*) >= 6
order by to_char(megrendeles_datuma, 'yy.mm');


--6
select vezeteknev || ' ' || keresztnev as teljes_nev, telefon
from  hajo.s_ugyfel
where helyseg in (select helyseg_id
from hajo.s_helyseg
where orszag = 'Szíria');

--7
select haj.nev, haj.hajo_tipus, netto_suly
from hajo.s_hajo haj inner join hajo.s_hajo_tipus hajt
on haj.hajo_tipus = hajt.hajo_tipus_id
where hajt.hajo_tipus_id is not NULL
and netto_suly in((select min(netto_suly)
from hajo.s_hajo
where hajo_tipus = 2),
(select min(netto_suly)
from hajo.s_hajo
where hajo_tipus = 4),
(select min(netto_suly)
from hajo.s_hajo
where hajo_tipus = 3));

select hajt.nev, min(haj.netto_suly)
from hajo.s_hajo haj inner join hajo.s_hajo_tipus hajt
on haj.hajo_tipus = hajt.hajo_tipus_id
where hajt.hajo_tipus_id is not NULL
group by hajt.nev;

--8
select orszag, helysegnev
from hajo.s_helyseg
where helyseg_id in(select helyseg
from hajo.s_kikoto
where helyseg in(select helyseg_id
from hajo.s_helyseg
where orszag in (select orszag
from hajo.s_orszag
where foldresz = 'Ázsia')))
order by orszag,helysegnev;

--9
select nev, hajo_id, ut.indulasi_kikoto, erkezesi_kikoto, indulasi_ido, kikoto_id
from hajo.s_hajo haj inner join hajo.s_ut ut
on haj.hajo_id = ut.hajo
inner  join hajo.s_kikoto kik
on ut.indulasi_kikoto = kik.kikoto_id
where ut.indulasi_ido =(select max(indulasi_ido)
from hajo.s_ut);

--10
select kik.kikoto_id, he.helysegnev, he.orszag, ut.erkezesi_kikoto, kik.helyseg, ut.indulasi_ido
from hajo.s_ut ut inner join hajo.s_kikoto kik 
on ut.erkezesi_kikoto = kik.kikoto_id and ut.indulasi_kikoto='It_Cat'
inner join hajo.s_helyseg he
on kik.helyseg = he.helyseg_id
where ut.indulasi_ido = (select min(indulasi_ido)
from hajo.s_ut  
where indulasi_kikoto = 'It_Cat');


select u.indulasi_kikoto,u.erkezesi_kikoto,helyseg,orszag, indulasi_ido 
    from hajo.s_ut u JOIN hajo.s_kikoto k--nemenyim
    ON u.erkezesi_kikoto=k.kikoto_id and u.erkezesi_kikoto='It_Cat'
    JOIN hajo.s_helyseg h
    ON h.helyseg_id=k.helyseg
    where indulasi_ido=((select MIN(indulasi_ido)from hajo.s_ut where indulasi_kikoto='It_Cat')) 
    ;




--1
select rendszam,elso_vasarlas_idopontja
from szerelo.sz_auto
where rendszam like ('%1%1') or rendszam like('%11%')
order by elso_vasarlas_idopontja desc;

--2
select rendszam, elso_vasarlas_idopontja
from szerelo.sz_auto
where elso_vasarlasi_ar > length(rendszam)*600000
order by extract(day from elso_vasarlas_idopontja), extract(month from elso_vasarlas_idopontja);

--3
select muhely_azon, to_char(szereles_kezdete,'yyyy.mm'), count(auto_azon) as ossz, extract(month from szereles_kezdete) as honap, extract(year from szereles_kezdete) as ev
from szerelo.sz_szereles
group by muhely_azon, to_char(szereles_kezdete,'yyyy.mm'),extract(year from szereles_kezdete),extract(month from szereles_kezdete)
order by extract(year from szereles_kezdete), extract(month from szereles_kezdete), muhely_azon;

--4
select substr(cim,1,instr(cim,',')-1), count(*)
from szerelo.sz_tulajdonos
group by substr(cim,1,instr(cim,',')-1)
having count(*) > 3;

--5
select rendszam, szin
from szerelo.sz_auto au inner join szerelo.sz_autofelertekeles fel
on au.azon = fel.auto_azon
where extract (year from datum) - extract (year from elso_vasarlas_idopontja) < 1;

--6


--hajo v2 
--1
select kontener, megrendeles, round(rakomanysuly, 2)
from hajo.s_hozzarendel
where rakomanysuly between 7 and 14
order by rakomanysuly desc;

--2
select vezeteknev | | ','|| keresztnev as teljesnev
from hajo.s_ugyfel
where helyseg is null
and keresztnev like '_____'
order by vezeteknev desc;

--3
select megrendeles_datuma, to_char(megrendeles_datuma,'hh.mi') as idopont, fizetett_osszeg, erkezesi_kikoto, indulasi_kikoto
from hajo.s_megrendeles
where extract(month from megrendeles_datuma) = 2 or extract(month from megrendeles_datuma) =4
order by fizetett_osszeg desc;

--4
select foldresz, sum(terulet)
from hajo.s_orszag
where foldresz is not null
group by foldresz
order by  sum(terulet) desc;

--5
select meg.ugyfel, fizetett_osszeg, vezeteknev,keresztnev
from hajo.s_megrendeles meg inner join hajo.s_ugyfel ugy
on meg.ugyfel = ugy.ugyfel_id
where fizetett_osszeg < 10000000 ;

--6
select * 
from hajo.s_hajo;

select distinct(nev)
from hajo.s_hajo_tipus;

--7
select to_char(megrendeles_datuma,'yyyy.mm'), count (*)
from hajo.s_megrendeles
where erkezesi_kikoto in(select kikoto_id
from hajo.s_kikoto
where leiras like ('%mobil daruk%'))
group by to_char(megrendeles_datuma,'yyyy.mm')
order by count (*) desc;

select kikoto_id
from hajo.s_kikoto
where leiras like ('%mobil daruk%');

--8
select unique(megrendeles)
from hajo.s_szallit
where ut in(select ut_id 
from hajo.s_ut
where hajo in (select hajo_id 
from hajo.s_hajo
where hajo_id in(select hajo 
from hajo.s_ut
where erkezesi_kikoto = 'It_Cat')
and nev = 'Asterix')
and erkezesi_kikoto = 'It_Cat');

select unique(megrendeles)
from hajo.s_hajo haj inner join hajo.s_ut u
on haj.hajo_id = u.hajo
inner join hajo.s_szallit m
on u.ut_id = m.ut
where nev = 'Asterix' and erkezesi_kikoto = 'It_Cat';

--9
select megrendeles_id, megrendeles_datuma, to_char(megrendeles_datuma,'hh:mi') as ideje, vezeteknev,keresztnev
from hajo.s_megrendeles m inner join hajo.s_ugyfel u
on m.ugyfel = u.ugyfel_id
order by megrendeles_datuma desc
fetch first row with ties;

--10
select vezeteknev, keresztnev, szul_dat
from hajo.s_helyseg h inner join hajo.s_ugyfel u
on h.helyseg_id = u.helyseg
where orszag = 'Olaszország'
order by szul_dat asc
fetch first row with ties;


















