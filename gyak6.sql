--listazzuk azokat a szerzoket akiknek a neveben 2 darab a betu van es a diak olvasokat 
--mindkettejuket szuletesi datumamal egyutt
select keresztnev || vezeteknev, szuletesi_datum
from konyvtar.szerzo 
where lower(keresztnev || vezeteknev) like '%a%a%' and lower(vezeteknev || keresztnev) not like '%a%a%a'
union
select keresztnev || vezeteknev, szuletesi_datum
from konyvtar.tag
where besorolas = 'diák';
--listazzuk ki a kolcsonzeseket besorolasuk szama szerint ahhol nincs kolcsonzes 0 at akarunk latni
select tg.besorolas, count(*)
from konyvtar.kolcsonzes kcs right outer join konyvtar.tag tg
on kcs.tag_azon = tg.olvasojegyszam
group by tg.besorolas;
--listazzuk kia a hallgatok adatait
select * 
from all_users
where username like 'U_%' escape'\';

--Listazzuk ki azokat  a szereleseket amelyeket kek, piros, fekete autokon vegeztek
--a Féktelent BT. muhelyeben es a befejezett szereles hossza tobb mint 3 nap
select *
from szerelo.sz_auto au inner join szerelo.sz_szereles szer
on au.azon = szer.auto_azon
where szin in('kék','piros','fekete')
and szer.szereles_vege is not null
and szer.muhely_azon = (
select azon
from szerelo.sz_szerelomuhely
where nev = 'Féktelenül Bt.'
)
and szer.szereles_vege - szer.szereles_kezdete >3;

--Ki a BBB230-as auto utolso tulaja
select nev
from szerelo.sz_tulajdonos
where azon =(
select tulaj_azon
from szerelo.sz_auto_tulajdonosa
where auto_azon =(select azon
from szerelo.sz_auto
where rendszam = 'BBB230')
order by vasarlas_ideje desc
fetch first row only);

--melyik szerelo munkaviszonya a leghosszabb?
select *
from szerelo.sz_dolgozik dol inner join szerelo.sz_szerelo szer
on dol.szerelo_azon = szer.azon
order by nvl(dol.munkaviszony_vege, sysdate) - dol.munkaviszony_kezdete desc
fetch first row only;
--keressunk olyan debreceni autosokat akik 2010 utan piros autot vettek
select*
from szerelo.sz_auto au inner join szerelo.sz_auto_tulajdonosa autul
on au.azon = autuol.auto_azon
inner join szerelo.sz tulajdonos tul
on autul.tulaj_azon  = tul.azon;
--keressunk meg a legdragabb felertekelt vw-t
select rendszam
from szerelo.sz_autofelertekeles fel inner join szerelo.sz_auto au
on fel.auto_azon = au.azon
where tipus_azon in (
select azon
from szerelo.sz_autotipus
where marka = 'Volkswagen'
)
order by ertek desc
fetch first row only;
/*Kik azok akik olyan autot vettek amit a leghosszab ideig kellett szerelni*/
select * 
from szerelo.sz_auto au inner join szerelo.sz_szereles szer
on au.azon = szer.auto_azon
order by nvl(szer.szereles_vege, sysdate) - szer.szereles_kezdete desc
fetch first row only
--mit vasaroltak tobbszorm vw-t vagy skodat?
select *
from szelero.sz_autotipus typ inner join szerelo.sz_auto au
on au.tipus_azon = typ.azon
inner join szerelo.sz_auto_tulajdonosa autul
on au.azon = autul.auto_azon
where marka = 'Skoda';
--kik azok akiknek soha nem volt opel autoja
--melyek azok az autok melyeknek atlagos felertekelese tobb mint 1m?
--melyek azok az autok amiket legalabb 1 szer tobb mint 1 milliora ertekeltek
--melyek azok az autok melyeket csak 1m fole ertekeltek


--hajo
select *
from hajo.s_ut ut inner join hajo.s_kikoto ki
on ut.indulasi_kikoto = ki.kikoto_id
