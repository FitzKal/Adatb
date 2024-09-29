--145. Melyek azok a szerz?k, akik nem szereztek könyvet?
select *
from konyvtar.szerzo
where szerzo_azon not in 
(select szerzo_azon
from konyvtar.konyvszerzo);
--146. Ki a legid?sebb szerz??
select *
from konyvtar.szerzo
where szuletesi_datum = 
(select min(szuletesi_datum)
from konyvtar.szerzo);
--147. Kérdezzük le a Napóleon cím? könyvek leltári számát!
select leltari_szam
from konyvtar.konyvtari_konyv
where konyv_azon in(
select konyv_azon
from konyvtar.konyv
where cim = 'Napóleon');

--148. A diák besorolású tagok között ki a legid?sebb?
select vezeteknev,keresztnev ,min(szuletesi_datum)
from konyvtar.tag
where besorolas in
(select besorolas
from konyvtar.tag
where besorolas = 'diák');

--149. A n?i tagok között mi a legfiatalabb tagnak a neve?
select vezeteknev, keresztnev
from konyvtar.tag
where szuletesi_datum =(
select max(szuletesi_datum)
from konyvtar.tag
where nem = 'n')
and nem = 'n';

--150. Témánként mi a legdrágább árú könyv címe?
select cim, ar, tema
from konyvtar.konyv
where (tema, ar) in(
select tema, max(ar)
from konyvtar.konyv
group by tema);

--151. Mi a legdrágább érték? könyv címe?
select cim
from konyvtar.konyv
where konyv_azon in(
select konyv_azon
from konyvtar.konyvtari_konyv
where ertek =(
select max(ertek)
from konyvtar.konyvtari_konyv
)
);

--152. Melyik könyvb?l nincs példány?
select cim
from konyvtar.konyv
where konyv_azon in(
select konyv_azon
from konyvtar.konyvtari_konyv
where leltari_szam in(
select leltari_szam
from konyvtar.kolcsonzes
where visszahozasi_datum is null)
);
select *
from konyvtar.konyv
where konyv_azon not in (select konyv_azon from konyvtar.konyvtari_konyv);

--153. A krimi témájú könyvekb?l melyik a legdrágább?
select *
from konyvtar.konyv
where ar = (
select max(ar)
from konyvtar.konyv
where tema = 'krimi')
and tema = 'krimi';

--154. Melyik szerz? kapta a legnagyobb összhonoráriumot?
select *
from konyvtar.szerzo
where szerzo_azon =(
select szerzo_azon
from konyvtar.konyvszerzo
where honorarium = (
select max(honorarium)
from konyvtar.konyvszerzo)
);

select *
from konyvtar.konyvszerzo kksz inner join konyvtar.szerzo ksz
on kksz.szerzo_azon = ksz.szerzo_azon
where kksz.honorarium = (
select max(honorarium)
from konyvtar.konyvszerzo
);

--155. Melyik könyvhöz tartozik a legkevesebb példány?;
select distinct(count(leltari_szam))
from konyvtar.konyvtari_konyv;

--Listazzuk ki azokat  a szereleseket amelyeket kek, piros, fekete autokon vegeztek
--a Féktelent BT. muhelyeben es a befejezett szereles hossza tobb mint 3 nap
select *
from szerelo.sz_szereles
where auto_azon in(select azon
from szerelo.sz_auto
where szin in ('kék','prios','fekete'))
and
muhely_azon = (select azon
from szerelo.sz_szerelomuhely
where nev = 'Féktelenül Bt.')
and szereles_vege - szereles_kezdete > 3;

select * 
from szerelo.sz_auto au inner join szerelo.sz_szereles sz
on au.azon = sz.auto_azon
where szin in ('piros','kék','fekete')
and sz.szereles_vege is not null
and sz.muhely_azon = (
select azon
from szerelo.sz_szerelomuhely
where nev = 'Féktelenül Bt.')and
szereles_vege - szereles_kezdete > 3;


--Ki a BBB230-as auto utolso tulaja
select *
from szerelo.sz_tulajdonos
where azon = (select tulaj_azon
from szerelo.sz_auto_tulajdonosa
where auto_azon = (select azon
from szerelo.sz_auto
where rendszam = 'BBB230')
order by vasarlas_ideje desc
fetch first row only);

select *
from szerelo.sz_auto_tulajdonosa autul inner join szerelo.sz_tulajdonos tul
on autul.tulaj_azon = tul.azon
where auto_azon = (select azon 
from szerelo.sz_auto
where rendszam = 'BBB230')
order by vasarlas_ideje desc
fetch first row only;


--melyik szerelo munkaviszonya a leghosszabb?
select*
from szerelo.sz_szerelo
where azon = (select szerelo_azon
from szerelo.sz_dolgozik
where munkaviszony_vege - munkaviszony_kezdete = (select max(munkaviszony_vege-munkaviszony_kezdete) 
from szerelo.sz_dolgozik));

--keressunk olyan debreceni autosokat akik 2010 utan piros autot vettek
select *
from szerelo.sz_tulajdonos
where cim like 'Debrecen%';
select *
from szerelo.sz_auto_tulajdonosa;
where ;

/*kik azok akik a tulajok akiknek 3nal tobb autoja van?
csoportosisuk */

select * 
from szerelo.sz_tulajdonos 
where azon in (
select tulaj_azon
from szerelo.sz_auto_tulajdonosa
group by tulaj_azon
having count (auto_azon) > 3
);

--melyek azok az autok amelyek elso vasarlasi ara tobb mint a piros autok elso vasarlasi ara atlaga
select * 
from szerelo.sz_auto
where elso_vasarlasi_ar > (
select avg(elso_vasarlasi_ar)
from szerelo.sz_auto
where szin = 'piros');

--keressunk olyanokat, akik kesobb erkeztek az allatkertbe mint 'Safranek',
--hanyan vannak? Csoportositsuk fajonkent, es csak azokat irjuk ki, akik nem egyediek, tehat tobb mint 2 ilyen tartozik a fajhoz
select erkezes_dat
from zoo.zoo_allatok
where allat_nev = 'Safranek';


select faj_nev, count(*)
from zoo.zoo_allatok al inner join zoo.zoo_fajok fa
on al.faj_azon = fa.faj_azon
where al.erkezes_dat > (
select erkezes_dat
from zoo.zoo_allatok
where allat_nev = 'Safranek'
)
group by faj_nev
having count(*) >1;

/*Keressünk olyan debreceni autósokat akik 2010 után piros autót vettek*/
select * 
from szerelo.sz_tulajdonos
where azon in(select tulaj_azon 
from szerelo.sz_auto_tulajdonosa
where auto_azon in (select azon
from szerelo.sz_auto
where azon in(
select auto_azon
from szerelo.sz_auto_tulajdonosa
where tulaj_azon in (select azon
from szerelo.sz_tulajdonos
where cim like ('Debrecen%'))) and 
szin = 'piros')
 and vasarlas_ideje > to_date ('2010.01.01','yyyy.mm.dd'));
 
select nev, tul.azon
from szerelo.sz_auto au inner join szerelo.sz_auto_tulajdonosa autul
on au.azon = autul.auto_azon
inner join szerelo.sz_tulajdonos tul
on autul.tulaj_azon = tul.azon
where tul.cim like '%Debrecen,%'and
au.szin = 'piros' and
extract(year from autul.vasarlas_ideje) >= 2010 --to_date('2010.01.01', 'yyyy.mm.dd')
order by azon;

/*Keressük meg a legdrágábbra felértékelt VW-t*/
select * 
from szerelo.sz_auto au inner join szerelo.sz_autofelertekeles fel
on au.azon = fel.auto_azon
inner join szerelo.sz_autotipus tip
on au.tipus_azon = tip.azon
where tip.marka = 'Volkswagen'
order by ertek desc
fetch first row only;

select rendszam
from szerelo.sz_autofelertekeles fel inner join szerelo.sz_auto au
on  fel.auto_azon = au.azon
where tipus_azon in (
select azon 
from szerelo.sz_autotipus
where marka = 'Volkswagen'
)
order by ertek desc
fetch first row only;