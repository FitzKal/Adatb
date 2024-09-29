--101. Listázzuk ki a könyvek azonosítóit, a könyvek címeit és a könyvekhez kapcsolódó példányok leltári számait. (Csak azokat a könyveket és példányokat
--listázzuk, amelyeknek van a másik táblában megfelel?je.)
select kk.konyv_azon, kk.cim, kkv.leltari_szam
from konyvtar.konyv kk inner join konyvtar.konyvtari_konyv kkv
on kk.konyv_azon = kkv.konyv_azon;

--103. Milyen könyveket (azononsító és cím) kölcsönzött Ácsi Milán?
select kk.konyv_azon, kk.cim
from konyvtar.konyv kk inner join konyvtar.konyvtari_konyv kkv
on kk.konyv_azon = kkv.konyv_azon
inner join konyvtar.kolcsonzes kcs
on kkv.leltari_szam = kcs.leltari_szam
inner join konyvtar.tag kt
on kcs.tag_azon = kt.olvasojegyszam 
where kt.vezeteknev || ' ' || kt.keresztnev = 'Ácsi Milán';

--102. Mi a leltári száma az Ácsi Milán nev? tag aktuálisan kikölcsönzött könyveineknek
select kcs.leltari_szam, kt.vezeteknev || ' ' || kt.keresztnev
from konyvtar.tag kt inner join konyvtar.kolcsonzes kcs
on kt.olvasojegyszam = kcs.tag_azon
where kt.vezeteknev || ' ' || kt.keresztnev = 'Ácsi Milán'
and kcs.visszahozasi_datum is null;

--104. Listázzuk a horror témájú könyvekért kapott honoráriumokat.
select kk.tema, ksz.honorarium
from konyvtar.konyv kk inner join konyvtar.konyvszerzo ksz
on kk.konyv_azon = ksz.konyv_azon
where TEMA = 'horror';

--105. Ki írta a Hasznos holmik cím? könyvet?
select ksz.vezeteknev || ' ' || ksz.keresztnev, kk.cim
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon = kksz.konyv_azon
inner join konyvtar.szerzo ksz
on kksz.szerzo_azon = ksz.szerzo_azon
where kk.cim = 'Hasznos holmik';

--106. Mik a leltári számai a Tíz kicsi néger cím? könyvhöz tartozó példányoknak?
select kkv.leltari_szam
from konyvtar.konyv kk inner join konyvtar.konyvtari_konyv kkv
on kk.konyv_azon = kkv.konyv_azon
where kk.cim = 'Tíz kicsi néger'; 

select leltari_szam
from konyvtar.konyvtari_konyv
where konyv_azon =(select konyv_azon
from konyvtar.konyv
where cim = 'Tíz kicsi néger');

--107. Mi a sci-fi, krimi, horror témájú könyvek címe és szerz?inek a neve?
select ksz.vezeteknev || ' ' || ksz.keresztnev, kk.tema
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon = kksz.konyv_azon
inner join konyvtar.szerzo ksz
on kksz.szerzo_azon = ksz.szerzo_azon
where kk.tema = 'sci-fi' or kk.tema = 'krimi' or kk.tema = 'horror';

--108. Mi a szerz? azonosítója a sci-fi, krimi, horror témájú könyvek szerz?inek? Minden azonosítót csak egyszer listázzunk, a lista legyen rendezett.
select distinct(kksz.szerzo_azon)
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon = kksz.konyv_azon
where kk.tema in ('sci-fi','krimi','horror')
order by kksz.szerzo_azon asc;

--109. Mi a 40 évesnél fiatalabb olvasók által kikölcsönzött könyvek leltári száma?
select kcs.leltari_szam
from konyvtar.kolcsonzes kcs inner join konyvtar.tag kt
on kcs.tag_azon = kt.olvasojegyszam
where months_between(sysdate,szuletesi_datum)/12< 40;

--110. Mi a szerz? azonosítója a Tíz kicsi néger szerz?jének?
select kksz.szerzo_azon
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon = kksz.konyv_azon
where cim = 'Tíz kicsi néger';

--112. Keressünk olyan tagokat, akik hamarabb születtek, mint Agyalá Gyula.
select  tg.vezeteknev, tg.keresztnev,
to_char(agy.szuletesi_datum,'yyyy.mm.dd'),
to_char(tg.szuletesi_datum,'yyyy.mm.dd')
from konyvtar.tag agy inner join konyvtar.tag tg
on tg.szuletesi_datum<agy.szuletesi_datum
where agy.Vezeteknev='Agyalá' and agy.keresztnev='Gyula';

--113. Melyik olvasó fiatalabb Agatha Christie írótól?
select vezeteknev || ' ' || keresztnev,floor(months_between(sysdate, szuletesi_datum)/12)
from konyvtar.tag
where floor(months_between(sysdate, szuletesi_datum)/12) <
(select floor(months_between(sysdate, szuletesi_datum)/12)
from konyvtar.szerzo
where vezeteknev || ' ' || keresztnev = 'Christie Agatha');

--114. Kik azok a tagok, akik ugyanabban a városban születtek, mint Agyalá Gyula?
select vezeteknev || ' ' || keresztnev
from konyvtar.tag
where substr(cim,6, instr(cim, ',')-6)=
(select substr(cim,6, instr(cim, ',')-6)
from konyvtar.tag
where  vezeteknev || ' ' || keresztnev = 'Agyalá Gyula') and vezeteknev || ' ' || keresztnev != 'Agyalá Gyula';
--115. Hogy hívják Neena Kochhar f?nökét? Használjuk a HR sémát.
select first_name, last_name, employee_id
from hr.employees
where employee_id =
(select manager_id
from hr.employees
where first_name  = 'Neena' and last_name = 'Kochhar');

select fonok.first_name, fonok.last_name
from hr.employees nk inner join hr.employees fonok
on nk.manager_id=fonok.employee_id
where nk.first_name='Neena' and nk.last_name='Kochhar';

--116. Írjuk ki az IT_PROG job_id-jú dolgozók f?nökének a nevét. Használjuk a HR sémát.
select  distinct bs.first_name, bs.last_name
from hr.employees emp inner join hr.employees bs
on emp.manager_id=bs.employee_id
where emp.job_id='IT_PROG';

--Az 5000-nél olcsóbb (árú) könyveknek hány különböz? szerz?je van?
select count (distinct szerzo_azon)
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon= kksz.konyv_azon
where ar < 5000








