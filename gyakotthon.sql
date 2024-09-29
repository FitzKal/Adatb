--101. List�zzuk ki a k�nyvek azonos�t�it, a k�nyvek c�meit �s a k�nyvekhez kapcsol�d� p�ld�nyok lelt�ri sz�mait. (Csak azokat a k�nyveket �s p�ld�nyokat
--list�zzuk, amelyeknek van a m�sik t�bl�ban megfelel?je.)
select kk.konyv_azon, kk.cim, kkv.leltari_szam
from konyvtar.konyv kk inner join konyvtar.konyvtari_konyv kkv
on kk.konyv_azon = kkv.konyv_azon;

--103. Milyen k�nyveket (azonons�t� �s c�m) k�lcs�nz�tt �csi Mil�n?
select kk.konyv_azon, kk.cim
from konyvtar.konyv kk inner join konyvtar.konyvtari_konyv kkv
on kk.konyv_azon = kkv.konyv_azon
inner join konyvtar.kolcsonzes kcs
on kkv.leltari_szam = kcs.leltari_szam
inner join konyvtar.tag kt
on kcs.tag_azon = kt.olvasojegyszam 
where kt.vezeteknev || ' ' || kt.keresztnev = '�csi Mil�n';

--102. Mi a lelt�ri sz�ma az �csi Mil�n nev? tag aktu�lisan kik�lcs�nz�tt k�nyveineknek
select kcs.leltari_szam, kt.vezeteknev || ' ' || kt.keresztnev
from konyvtar.tag kt inner join konyvtar.kolcsonzes kcs
on kt.olvasojegyszam = kcs.tag_azon
where kt.vezeteknev || ' ' || kt.keresztnev = '�csi Mil�n'
and kcs.visszahozasi_datum is null;

--104. List�zzuk a horror t�m�j� k�nyvek�rt kapott honor�riumokat.
select kk.tema, ksz.honorarium
from konyvtar.konyv kk inner join konyvtar.konyvszerzo ksz
on kk.konyv_azon = ksz.konyv_azon
where TEMA = 'horror';

--105. Ki �rta a Hasznos holmik c�m? k�nyvet?
select ksz.vezeteknev || ' ' || ksz.keresztnev, kk.cim
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon = kksz.konyv_azon
inner join konyvtar.szerzo ksz
on kksz.szerzo_azon = ksz.szerzo_azon
where kk.cim = 'Hasznos holmik';

--106. Mik a lelt�ri sz�mai a T�z kicsi n�ger c�m? k�nyvh�z tartoz� p�ld�nyoknak?
select kkv.leltari_szam
from konyvtar.konyv kk inner join konyvtar.konyvtari_konyv kkv
on kk.konyv_azon = kkv.konyv_azon
where kk.cim = 'T�z kicsi n�ger'; 

select leltari_szam
from konyvtar.konyvtari_konyv
where konyv_azon =(select konyv_azon
from konyvtar.konyv
where cim = 'T�z kicsi n�ger');

--107. Mi a sci-fi, krimi, horror t�m�j� k�nyvek c�me �s szerz?inek a neve?
select ksz.vezeteknev || ' ' || ksz.keresztnev, kk.tema
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon = kksz.konyv_azon
inner join konyvtar.szerzo ksz
on kksz.szerzo_azon = ksz.szerzo_azon
where kk.tema = 'sci-fi' or kk.tema = 'krimi' or kk.tema = 'horror';

--108. Mi a szerz? azonos�t�ja a sci-fi, krimi, horror t�m�j� k�nyvek szerz?inek? Minden azonos�t�t csak egyszer list�zzunk, a lista legyen rendezett.
select distinct(kksz.szerzo_azon)
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon = kksz.konyv_azon
where kk.tema in ('sci-fi','krimi','horror')
order by kksz.szerzo_azon asc;

--109. Mi a 40 �vesn�l fiatalabb olvas�k �ltal kik�lcs�nz�tt k�nyvek lelt�ri sz�ma?
select kcs.leltari_szam
from konyvtar.kolcsonzes kcs inner join konyvtar.tag kt
on kcs.tag_azon = kt.olvasojegyszam
where months_between(sysdate,szuletesi_datum)/12< 40;

--110. Mi a szerz? azonos�t�ja a T�z kicsi n�ger szerz?j�nek?
select kksz.szerzo_azon
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon = kksz.konyv_azon
where cim = 'T�z kicsi n�ger';

--112. Keress�nk olyan tagokat, akik hamarabb sz�lettek, mint Agyal� Gyula.
select  tg.vezeteknev, tg.keresztnev,
to_char(agy.szuletesi_datum,'yyyy.mm.dd'),
to_char(tg.szuletesi_datum,'yyyy.mm.dd')
from konyvtar.tag agy inner join konyvtar.tag tg
on tg.szuletesi_datum<agy.szuletesi_datum
where agy.Vezeteknev='Agyal�' and agy.keresztnev='Gyula';

--113. Melyik olvas� fiatalabb Agatha Christie �r�t�l?
select vezeteknev || ' ' || keresztnev,floor(months_between(sysdate, szuletesi_datum)/12)
from konyvtar.tag
where floor(months_between(sysdate, szuletesi_datum)/12) <
(select floor(months_between(sysdate, szuletesi_datum)/12)
from konyvtar.szerzo
where vezeteknev || ' ' || keresztnev = 'Christie Agatha');

--114. Kik azok a tagok, akik ugyanabban a v�rosban sz�lettek, mint Agyal� Gyula?
select vezeteknev || ' ' || keresztnev
from konyvtar.tag
where substr(cim,6, instr(cim, ',')-6)=
(select substr(cim,6, instr(cim, ',')-6)
from konyvtar.tag
where  vezeteknev || ' ' || keresztnev = 'Agyal� Gyula') and vezeteknev || ' ' || keresztnev != 'Agyal� Gyula';
--115. Hogy h�vj�k Neena Kochhar f?n�k�t? Haszn�ljuk a HR s�m�t.
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

--116. �rjuk ki az IT_PROG job_id-j� dolgoz�k f?n�k�nek a nev�t. Haszn�ljuk a HR s�m�t.
select  distinct bs.first_name, bs.last_name
from hr.employees emp inner join hr.employees bs
on emp.manager_id=bs.employee_id
where emp.job_id='IT_PROG';

--Az 5000-n�l olcs�bb (�r�) k�nyveknek h�ny k�l�nb�z? szerz?je van?
select count (distinct szerzo_azon)
from konyvtar.konyv kk inner join konyvtar.konyvszerzo kksz
on kk.konyv_azon= kksz.konyv_azon
where ar < 5000








