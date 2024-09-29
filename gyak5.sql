select vezeteknev, keresztnev, szuletesi_datum
from konyvtar.tag
where szuletesi_datum = (
select min (szuletesi_datum)
from konyvtar.tag);

--keressyk meg a konyvtarban a krimiket (konyvtar.konyvtari_konyv)
select *
from konyvtar.konyv
where konyv_azon in(
select konyv_azon
from konyvtar.konyvtari_konyv
where tema = 'krimi');
--keressuk meg a legdragabb krimit
select *
from konyvtar.konyv
where tema = 'krimi' and ar = 
(select max(ar)
from konyvtar.konyv
where tema = 'krimi');
--keressuk meg azokar a szerzoket akik meg nem irtak konyvet
select*
from konyvtar.szerzo
where szerzo_azon not in(
select szerzo_azon
from konyvtar.konyvszerzo);

--joinnal
select * 
from konyvtar.konyvszerzo ksz right outer join konyvtar.szerzo sz
on ksz.szerzo_azon = sz.szerzo_azon
where ksz.szerzo_azon = sz.szerzo_azon
where ksz_azon is null;

--felso n analizis
--fetch first n rows only/with ties

--listazzuk ki abc sorrendbe az elso 10 konyv arat
select ar
from konyvtar.konyv
order by cim asc
fetch first 10 rows only;

--listazzuk ki a masodik 10 konyv arat

select ar
from konyvtar.konyv
order by cim asc
offset 10 ROWS --ugrik 10 sort es utana irja ki a az elso 10 elemet
fetch first 10 rows only;

--keressunk 3db olyan konyvet amit diakok is szivesen kikolcsonoznek
select *
from konyvtar.konyv kv inner join konyvtar.konyvtari_konyv kkv
on kv.konyv_azon = kkv.konyv_azon
inner join konyvtar.kolcsonzes kcs
on kkv.leltari_szam = kcs.leltari_szam
inner join konyvtar.tag tg
on kcs.tag_azon = tg.olvasojegyszam
where tg.besorolas = 'diák'
fetch first 3 rows only;

--halmazmuveletek
--unio, intersect, minus

--union
--Minden olyan keresztnevet nezzunk meg amit szerzo vagy olvaso kapott

select keresztnev
from konyvtar.szerzo
union
select keresztnev
from konyvtar.tag;

--keressunk olyat. amit szerzo is es olvaso is kapott
--intersect
select keresztnev
from konyvtar.szerzo
intersect
select keresztnev
from konyvtar.tag;

--minus
--Olyan szerzok lesznek, amiknek olyank keresztneve van, ami egyik olvasonak sincs
select keresztnev
from konyvtar.szerzo
minus
select keresztnev
from konyvtar.tag;

--keressunk olyan konyveket amiket agatha kriszti irt de nem a tiz kicsi neger

select kv.cim
from konyvtar.konyv kv inner join konyvtar.konyvszerzo ksz
on kv.konyv_azon = ksz.konyv_azon
inner join konyvtar.szerzo sz
on ksz.szerzo_azon = sz.szerzo_azon
where sz.keresztnev = 'Agatha' and sz.vezeteknev = 'Christie'
minus
select cim
from konyvtar.konyv
where cim = 'Tíz kicsi néger';

--elzoz ora tartalmabol
--ki a legidosebb olvaso es mikr szuletett?
select*
from konyvtar.tag
order by szuletesi_datum asc
fetch first row only;

--keressuk meg a legdragabb krimit
select *
from konyvtar.konyv
where tema = 'krimi'
order by ar desc
fetch first rows only;

--ki magasabb a legmagasabb orknal
select * 
from zoo.zoo_allatok al inner join zoo.zoo_fajok fj
on al.faj_azon = fj.faj_azon
where fj.faj_nev = 'ork'
order by al.erkezes_mag desc
fetch first row only;

--olyan szerzok akik nem irtak krimit
select keresztnev, cim, tema
from konyvtar.konyv kv inner join konyvtar.konyvszerzo kksz
on kv.konyv_azon = kksz.konyv_azon
inner join konyvtar.szerzo ksz
on kksz.szerzo_azon = ksz.szerzo_azon
where tema not in 'krimi';
--masik megoldas
select vezeteknev, keresztnev
from konyvtar.szerzo
minus
select*
from konyvtar.konyv k inner join konyvrar.konyvszerzo ksz
on k.konyv_azon = sz.szerzo_azon
where k.tema = 'krimi';

--keressuk azokat a krimiket akiket meg nem vettek ki debreceniek
--halmazmegoldas
select cim
from konyvtar.konyv
where tema = 'krimi'
minus
select k.cim
from konyvtar.konyv k inner join konyvtar.konyvtari_konyv kt
on k.konyv_azon = kt.konyv_azon
inner join konyvtar.kolcsonzes kcs
on kt.leltari_szam = kcs.leltari_szam
inner join konyvtar.tag tg
on kcs.tag_azon = tg.olvasojegyszam
where tema = 'krimi' and
tg.cim like  '%Debrecen%' and tg.cim not like '%Debreceni%';
--keressuk azokat a konyveket amik sci-fik, horrorok vagy krimik vagy mora ferenc 2 legolcsobb konyve
select cim
from konyvtar.konyv
where tema in ('sci-fi','horror','krimi')
union
(select cim
from konyvtar.konyv kv inner join konyvtar.konyvszerzo ksz
on kv.konyv_azon = ksz.konyv_azon
inner join konyvtar.szerzo sz
on ksz.szerzo_azon = sz.szerzo_azon
where keresztnev = 'Ferenc' and vezeteknev = 'Móra'
order by kv.ar asc
fetch first 2 rows only);

--pici figyelemfelhivas
select keresztnev, vezeteknev
from konyvtar.szerzo
intersect
select keresztnev, vezeteknev
from konyvtar.tagx`


