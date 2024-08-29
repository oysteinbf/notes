-- Diverse window functions
with t as (
select 'LEE' team, 'Raphina' name, 7.8 price from dual union all
select 'TOT', 'Kane', 11.1 from dual union all
select 'TOT', 'Son', 9.5 from dual union all
select 'TOT', 'Lloris', 5.2 from dual union all
select 'LEE', 'Dallas', 5.1 from dual union all
select 'MCI', 'Sterling', 11.6 from dual union all
select 'MCI', 'Cancelo', 6.2 from dual union all
select 'MCI', 'Dias', 6.2 from dual union all
select 'MCI', 'Walker', null from dual union all
select 'LEE', 'Bamford', 5.1 from dual)
select name, team, price
      ,row_number() over (partition by team order by price nulls first) rn
      ,rank() over (partition by team order by price desc nulls first) r
      ,dense_rank() over (partition by team order by price nulls first) dr1
      ,dense_rank() over (partition by team order by price nulls last) dr2
      ,price - lag(price, 1, NULL) over (partition by team order by price) price_diff1
      ,price - lag(price, 1, 0) over (partition by team order by price) price_diff2
      ,avg(price) over (partition by team) avg_price -- sum, max, count, osv.
      ,to_char((100 * price / sum(price) over (partition by team)), 'FM99.0') price_contribution
      ,sum(price) over (order by name) dummy_cumsum
      ,count(distinct name) over (partition by team) n_players
      ,ntile(2) over (partition by team order by price) ntile_rank
      ,first_value(price) ignore nulls over (partition by team order by price) lowest
      ,last_value(price) ignore nulls over (partition by team order by price 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) highest
 from t;
 
 
-- Having (alternativ til window functions)
with t as (
select 'LEE' team, 'Raphina' name, 12.6 price from dual union all
select 'TOT', 'Kane', 11.1 from dual union all
select 'TOT', 'Son', 9.5 from dual union all
select 'TOT', 'Lloris', 5.2 from dual union all
select 'LEE', 'Dallas', 5.1 from dual union all
select 'MCI', 'Sterling', 11.6 from dual union all
select 'MCI', 'Cancelo', 6.2 from dual union all
select 'MCI', 'Dias', 6.2 from dual union all
select 'MCI', 'Walker', null from dual union all
select 'LEE', 'Bamford', 5.1 from dual)
select team, sum(price) total_price from t
group by team 
having team <> 'MCI' and sum(price) > 23;
 

-- Hent ut og slå sammen data fra flere rader med listagg
with t as (
select 'LEE' team, 'Raphina' name, 12.6 price from dual union all
select 'TOT', 'Kane', 11.1 from dual union all
select 'TOT', 'Son', 9.5 from dual union all
select 'TOT', 'Lloris', 5.2 from dual union all
select 'LEE', 'Dallas', 5.1 from dual union all
select 'MCI', 'Sterling', 11.6 from dual union all
select 'MCI', 'Cancelo', 6.2 from dual union all
select 'MCI', 'Dias', 6.2 from dual union all
select 'MCI', 'Walker', null from dual union all
select 'LEE', 'Bamford', 5.1 from dual)
SELECT
    team,
    LISTAGG(name, ', ') WITHIN GROUP(ORDER BY name) AS players
FROM t
GROUP BY team ORDER BY team;


-- Pivot
with t as (
select 'LEE' team, 'Raphina' name, 12.6 price, 'MID' position from dual union all
select 'TOT', 'Kane', 11.1, 'FWD' from dual union all
select 'TOT', 'Son', 9.5, 'MID' from dual union all
select 'TOT', 'Lloris', 5.2, 'GKP' from dual union all
select 'LEE', 'Dallas', 5.1, 'DEF' from dual union all
select 'MCI', 'Sterling', 11.6, 'MID' from dual union all
select 'MCI', 'Cancelo', 6.2, 'DEF' from dual union all
select 'MCI', 'Dias', 6.2, 'DEF' from dual union all
select 'MCI', 'Walker', null, 'DEF' from dual union all
select 'LEE', 'Bamford', 5.1, 'FWD' from dual)
select * from (select team, name, position from t)
pivot(
    count(name)
    for position in ('GKP' as "Goalkeeper", 'DEF' as "Defender", 'MID' as "Midfield", 'FWD' as "Forward")
    ) order by team;
    

-- Diff mellom to tabeller/views (husk å ta minus fra begge sider)
with t1 as (
select 'LEE' team, 'Raphina' name, 12.6 price from dual union all
select 'TOT', 'Kane', 11.1 from dual union all
select 'TOT', 'Son', 9.5 from dual),
t2 as (
select 'LEE' team, 'Raphina' name, 12.8 price from dual union all
select 'TOT', 'Kane', 11.1 from dual union all
select 'TOT', 'Son', 9.5 from dual)
select * from t1 
minus 
select * from t2;


-- Div joins
with t1 as (
select 'LEE' team, 'Raphina' name, 12.6 price from dual union all
select 'TOT', 'Kane', 11.1 from dual union all
select 'TOT', 'Son', 9.5 from dual union all
select 'TOT', 'Lloris', 5.2 from dual union all
select 'LEE', 'Dallas', 5.5 from dual),
t2 as (
select 'LEE' team, 'Leeds' city from dual union all
select 'TOT' team, 'London' city from dual union all
select 'MUN' team, 'Manchester' city from dual)
select t1.*, t2.city from t1 
right join t2 on t1.team = t2.team; -- full outer, inner, left, right


-- Div joins
with books as (
select '111' book_id, 'Author1' author from dual union all
select '222', 'Author2' from dual union all
select '333', 'Author3' from dual),
genres as (
select '111' book_id, 'GENRE' key from dual union all
select '222', 'GENRE' from dual union all
select '444', 'GENRE' from dual)
SELECT BOOK_ID, NVL (books.author, 'Unknown') AUTHOR
--FROM books LEFT JOIN genres USING (BOOK_ID)
FROM books FULL OUTER JOIN genres USING (BOOK_ID);


-- Cross join
-- Fint for å legge til ekstra kolonner. NB, t2 bør bare ha én rad
with t1 as (
select 'Reodor' navn, 'Felgen' Etternavn from dual union all
select 'Solan',  'Gundersen' from dual union all
select 'Ben Redic', 'Fy Fasan' from dual),
t2 as (
select 'Flåklypa' adresse from dual
)
select * from t1 cross join t2;
-- Alternativ uten cross join:
--select * from t1 join t2 on t2.adresse = 'Flåklypa';


-- Full outer join
-- For store datasett er dette et (bedre) alternativ enn oppslag (from t1 where x not in t2)
-- Dette kan så kombineres med en merge into på en eller annen måte
with t1 as (
select '111' id, 'MCI' team, 'aa' col_t1 from dual union all
select '222', 'MCI', 'bb' from dual union all
select '333', 'MCI', 'cc' from dual),
t2 as (
select '111' id, 'TOT' team, 'dd' col_t2 from dual union all
select '222', 'MCI', 'ee' from dual union all
select '444', 'TOT', 'ff' from dual)
-- Antar at col_t1 og col_t2 ikke kan være NULL
select * from t1 full outer join t2 using (id, team) -- Oversikt over hele datasettet
--where col_t1 is not null and col_t2 is null; -- Alt som inngår i t1 og ikke i t2
-- Osv.


-- Tellinger. For å inkludere 0 må man velge en spesifikk kolonne i t2 (som helst ikke kan være NULL)
with t1 as (
select '1' country_pk, 'Norway' country_name from dual union all
select '2', 'Sweden' from dual union all
select '3', 'Denmark' from dual),
t2 as (
select '1' country_fk, 'Oslo' city from dual union all
select '2', 'Stockholm' from dual union all
select '2', 'Karlstad' from dual)
--select t1.country_pk, t1.country_name, count(*) tot from t1 left join t2 on t1.country_pk = t2.country_fk
--group by t1.country_pk, t1.country_name; -- Wrong!
select t1.country_pk, t1.country_name, count(t2.country_fk) tot from t1 left join t2 on t1.country_pk = t2.country_fk
group by t1.country_pk, t1.country_name; -- Correct!


-- Select med Exist og greier
with faktura as (
select '50' pk, '1111' ssn, '1' betalt_flg from dual union all
select '46' , '1111' , '1' from dual union all
select '49' , '2222' , '0' from dual union all
select '47' , '2222' , '1' from dual union all
select '41' , '2222' , '1' from dual union all
select '48' , '3333' , '1' from dual),
personer as (
select '1111' ssn, 'blabla1' info, '1' aktiv_flg from dual union all
select '2222', 'blabla2', '1' from dual union all
select '3333', 'blabla3', '1' from dual)
select personer.*,
    case when exists
        -- Henter siste faktura, max(faktura.pk), og sjekker at denne har status som betalt
        (select 1 from faktura
           where faktura.pk = (select max(faktura.pk)
                              from faktura
                              where faktura.ssn = personer.ssn)
                                   and faktura.betalt_flg = 1)
        then 1 else 0 end as siste_faktura_betalt_flg
from personer
    where personer.aktiv_flg = 1

  
-- Insert fra annen tabell
insert into books
(bok_id, tittel, forfatter, pris, beskrivelse)
select book_id, title, author, to_number(regexp_replace(price, '[^0-9]', '')), description 
from bookstore;


-- Inline PL/SQL, for eksempel legge til rader i en tabell
DECLARE
  dml_cmd  VARCHAR2 (255);
  kolonne  VARCHAR2 (30) := 'BLABLA';
  i INTEGER := 950;
BEGIN
for x in (select column_value as country_id from table(sys.dbms_debug_vc2coll('6', '7', '8'))) -- også mulig
--for x in (select distinct country_id from countries)
    loop
        dml_cmd := 'INSERT INTO COUNTRIES (pk, name, country_id, continent, foo)
         VALUES ( '
        || i || ', ''' || kolonne || ''', ' || x.country_id || ', EUR, NULL)';
        i := i + 1;
        dbms_output.put_line(dml_cmd);
        --EXECUTE IMMEDIATE dml_cmd;
    end loop;
END;


-- Backup av tabell
create table mytable_backup as 
select * from mytable


-- Sett inn i tabell
insert into mytable_new (col_1, col_2)
select col_1, to_number(regexp_replace(col_2, '[^0-9]', '')) 
from mytable_backup order by col_1;


-- Hent ut rader som inneholder bokstaver, altså ikke tall
SELECT kolonne FROM min_tabell
     WHERE REGEXP_LIKE (kolonne, '[[:alpha:]]');


-- Gjør om til tall, dersom det er mulig
-- https://community.oracle.com/tech/developers/discussion/861288/locating-row-with-invalid-number-from-table-with-few-million-rows
SELECT to_number(kolonne)
  FROM min_tabell
 WHERE kolonne NOT IN (SELECT kolonne
                    FROM min_tabell
                   WHERE REGEXP_LIKE (kolonne, '[[:alpha:]]'));


-- Hent ut fra datofelt
with f as (
    select to_date('03.08.1968', 'dd.mm.yyyy') mydate from dual)
        select lpad(extract(day from mydate), 2, '0') "day", -- 3 blir 03
        extract(month from mydate) "month",
        extract (year from mydate) "year"
from f;


-- Dato til tekst
with t1 as (
select to_date('18031968', 'ddmmyyyy') dato from dual union all
select to_date('06082021', 'ddmmyyyy') dato from dual)
select dato, to_char(dato, 'ddmmyyyy') dato_char from t1;


-- Regex
select 1 from dual where regexp_like('Y99S', 'Y\d\d[A-Z]?$');


-- NOT IN issue
-- https://stackoverflow.com/questions/11548267/not-in-operator-issue-oracle
-- https://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:442029737684
with t1 as (
select 'LEE' team, 'Raphina' name, 12.6 price from dual union all
select 'TOT', 'Kane', 11.1 from dual union all
select 'TOT', 'Son', 9.5 from dual union all
select 'TOT', 'Lloris', 5.2 from dual union all
select NULL, 'Salah', 5.2 from dual union all
select 'LEE', 'Dallas', 5.5 from dual)
select * from t1 where team not in ('TOT', NULL); -- Ingen rader returneres!
--select * from t1 where team not in ('TOT'); 
--select * from t1 where team not in ('TOT') or team is null-- Dette er vel best
-- Hvis NULL er inkludert i det det spørres om blir det trøbbel!


-- Tabell med inkrementell kolonne
-- https://docs.oracle.com/en/database/other-databases/nosql-database/22.1/sqlreferencefornosql/creating-tables-identity-column.html
-- GENERATED ALWAYS AS IDENTITY - The sequence generator always supplies an IDENTITY value. You cannot specify a value for the column.
-- GENERATED BY DEFAULT AS IDENTITY - The sequence generator supplies an IDENTITY value any time you do not supply a column value.
-- GENERATED BY DEFAULT ON NULL AS IDENTITY - The sequence generator supplies the next IDENTITY value if you specify a NULL columnn value.
create table t1 (
    c1 NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    c2 VARCHAR2(10)
    );


-- Hent ut diverse metadata
select * from sys.all_views where owner = 'OWNER_NAME' and view_name like '%_OLD';


-- Finn kolonner
select * from all_tab_columns where owner = 'FOO' and lower(column_name) like '%bar%';


-- Søke etter tekst i alle views
create table zzz_all_view_20230328 as
select  av.owner, av.view_name,av.owner ||'.'|| av.view_name AS OWNER_VIEW, to_lob(text) as text_clob
from    ALL_VIEWS av;

select * from zzz_all_view_20230328
where upper(text_clob) like '%MY_PATTERN%';


-- Boolean, sjekke for to negative krav (skal ikke være både age=80 og code=Y)
with t1 as (
select '111' ssn, '80' age, 'Y' code from dual union all
select '222', '79', 'Y' from dual union all
select '333', '80', 'H' from dual)
select * from t1 where code || age != 'Y80'; -- OK, gir ønskelig resultat, men er treigt?
--select * from t1 where age != '80' or code != 'Y'; --OK, gir ønskelig resultat
--select * from t1 where age != '80' and code != 'Y'; -- Ikke OK


-- Boolean og NULL, vær forsiktig! (not equal to, samme utfordringer som not in)
with t1 as (
select '111' col1, 'aa' col2 from dual union all
select '222', NULL from dual union all
select '333', 'bb' from dual)
--select * from t1;
--select * from t1 where col2 != 'bb'; -- Inkluderer ikke raden med NULL!
select * from t1 where (col2 != 'bb' or col2 is null) -- Sånn må det gjøres 


-- Join gotcha
-- Left join kan overstyres av et WHERE-filter
-- Eksempel:
-- Finn alle byer i Norge og Sverige som heter "Oslo". Hvis en slik by ikke finnes,
-- så skal NULL returneres
with countries as (
    select 'NO' as country_code, 'Norway' as country_name from dual union all
    select 'SE' as country_code, 'Sweden' as country_name from dual),
cities as (
    select 'Oslo' AS city_name, 'NO' AS country_code from dual union all
    select 'Stockholm' AS city_name, 'SE' AS country_code from dual union all
    select 'Gothenburg' AS city_name, 'SE' AS country_code FROM dual)
--select c.country_name, ci.city_name
--from countries c
--left join cities ci on ci.country_code = c.country_code
--where (ci.city_name = 'Oslo' or ci.city_name is null);
-- Vil ikke fungere, ingen av de svenske byene matcher dette filteret,
-- og Sverige blir ikke tatt med (det blir i praksis en inner join?)
-- Dette fungerer:
select c.country_name, ci.city_name
from countries c
left join cities ci on ci.country_code = c.country_code
and (ci.city_name = 'Oslo' or ci.city_name is null)
-- Filteret blir nå anvendt under joinen, og ikke etter, og da blir alle
-- rader fra countries inkludert, dvs. LEFT JOIN som tiltenkt


-- Dato-stuff
-- Første dag i neste måned
select trunc(add_months(sysdate, 1),'MON') foo from dual;

-- Siste dag i neste måned
select trunc(last_day(add_months(sysdate, 1))) foo from dual;

-- Siste dag i forrige måned
select trunc(last_day(add_months(sysdate, -1))) foo from dual;

-- Den 15. i forrige måned
select trunc(add_months(sysdate, -1), 'MON') +14 foo from dual;

-- Den 15. i neste måned
select trunc(add_months(sysdate, 1), 'MON') +14 foo from dual;

-- Den 15. i denne måneden
select trunc(sysdate, 'MON') +14 foo from dual;

-- Siste dag i året
select TRUNC(SYSDATE, 'YEAR') + INTERVAL '12' MONTH - INTERVAL '1' DAY END_DT from dual;


-- Eksempel på oppdatering av tabell (MERGE INTO er raskere enn UPDATE)
MERGE INTO table_name t
USING (SELECT primary_key,
              modified_date    valid_from_date,
              NVL (
                    LEAD (modified_date)
                        OVER (PARTITION BY owner_id ORDER BY modified_date)
                  - (1 / 24 / 60 / 60),
                  TO_DATE ('01.01.2200', 'DD.MM.YYYY')
              )                valid_to_date,
              CASE
                  WHEN LEAD (modified_date)
                           OVER (PARTITION BY owner_id ORDER BY modified_date)
                           IS NULL
                  THEN '1' ELSE '0'
              END              active_flag
         FROM table_name) updated
     ON (t.primary_key = updated.primary_key)
WHEN MATCHED
THEN
    UPDATE SET
        t.valid_from_date = updated.valid_from_date,
        t.valid_to_date = updated.valid_to_date,
        t.active_flag = updated.active_flag;


-- Hvis Merge into fra eksternt skript (f.eks. Python) er treigt så kan man muligens skrive 
-- delresultatet til en dummy-tabell, som så brukes til å oppdatere t1.
UPDATE mytable
SET mytable.column1 = (
    SELECT dummy.column1
    FROM dummy
    WHERE mytable.join_column = dummy.join_column
);   

-- Slette rader fra tabell hvor det ikke er noen PK (bruk group by på alle kolonner)
-- https://stackoverflow.com/questions/529098/removing-duplicate-rows-from-table-in-oracle
delete from loggtabell
where rowid not in
(select min(rowid) from loggtabell
group by batch_id, navn, verdi);


-- Regne ut alder
select to_date('17031987', 'ddmmyyyy') birthdate, TRUNC (MONTHS_BETWEEN (SYSDATE, to_date('17031987', 'ddmmyyyy')) / 12) age from dual;


-- Alder og group by
with personer as (
select to_date('12.03.1992', 'dd.mm.yyyy') fodselsdato_dt from dual union all
select to_date('08.11.1992', 'dd.mm.yyyy') from dual union all
select to_date('28.11.1990', 'dd.mm.yyyy') from dual union all
select to_date('29.11.1990', 'dd.mm.yyyy') from dual union all
select to_date('03.05.1990', 'dd.mm.yyyy') from dual union all
select to_date('30.11.1990', 'dd.mm.yyyy') from dual),
t1 AS
(select trunc (months_between (sysdate, fodselsdato_dt) / 12)    as alder
    from personer)
select alder, count(*) antall
  from t1
  group by alder order by alder;


-- Gruppér per måned og år
with personer as (
select to_date('12.03.1992', 'dd.mm.yyyy') fodselsdato_dt from dual union all
select to_date('08.11.1992', 'dd.mm.yyyy') from dual union all
select to_date('28.11.1990', 'dd.mm.yyyy') from dual union all
select to_date('29.11.1990', 'dd.mm.yyyy') from dual union all
select to_date('03.05.1990', 'dd.mm.yyyy') from dual union all
select to_date('30.11.1990', 'dd.mm.yyyy') from dual)
select extract(year from fodselsdato_dt) as aar, extract(month from fodselsdato_dt) as mnd,
       count(*) antall
from personer
group by extract(year from fodselsdato_dt), extract(month from fodselsdato_dt)
order by aar desc, mnd desc;


-- Hvis det finnes noe i stage, bruk dette
-- Hvis stage er tom, hent eksisterende data (fallback)
with stage as (
    select 'A' as col1, 'B' as col2 from dual union all
    select 'C' as col1, 'D' as col2 from dual),
eksisterende_data as (
    select 'E' as col1, 'F' as col2 from dual union all
    select 'G' as col1, 'H' as col2 from dual),
final as (
    select * from stage
    union all
    select * from eksisterende_data
    where (select count(*) from stage) = 0
)
select * from final;


-- Finn de som har epost i to firmaer, og ulik epost i disse. Finn ut hvor ulike de er.
with t1 as (
select 1111 ssn, 'alpha@alpha.com' epost, 'AAA' firma from dual union all
select 2222, 'beta@beta.com', 'AAA' from dual union all
select 3333, 'gamma@gamma.com', 'AAA' from dual union all
select 3333, 'Gamma@Gamma.com', 'BBB' from dual union all
select 4444, 'delta98@delta.com', 'AAA' from dual union all
select 4444, 'delta980@delta.com', 'BBB' from dual union all
select 5555, 'epsilon@epsilon.com', 'AAA' from dual union all
select 5555, 'zeta@zeta.com', 'BBB' from dual),
t2 as (
select t1.*,
       row_number() over (partition by ssn order by epost) rn, -- Løpetall
       count(distinct lower(epost)) over (partition by ssn) n_distinkt_epost
from t1),
t3 as (
    select * from t2 where n_distinkt_epost = 2),
t4 as (
    select * from (select ssn, epost, rn from t3)
        pivot (max(epost) for rn in (1 as "epost1", 2 as "epost2"))
    order by ssn),
final as (
    select t4.*, 
      utl_match.edit_distance("epost1", "epost2") likhet,
      utl_match.edit_distance_similarity("epost1", "epost2") likhet_normalisert
    from t4)
select * from final;    
    

-- Dataprofilering (kopier output, lim inn i vim for videre redigering, f.eks. legge til filter på tabell)
SELECT 'select '
           SS,
       '''' || table_name || ''' tab,'
           AS Table_name,
       '''' || column_name || ''' col,'
           AS Column_name,
       'to_char(count(distinct ' || column_name || ')) num_distinct,'
           C2,
       'to_char(sum(decode(' || column_name || ',null,1,0))) num_nulls,'
           C3,
       'to_char(max(length(' || column_name || '))) max_len,'
           C4,
       'to_char(min(' || column_name || ')) min_val,'
           C5,
       'to_char(max(' || column_name || ')) max_val'
           C6,
       'from ' || owner || '.' || table_name || ' union all'
           FF
  FROM all_tab_columns
 WHERE owner = 'FOO' AND table_name LIKE 'MYTABLE'; -- and column_name in (...)


-- Eksempel på rekursjon
with EMP as (
SELECT 1 emp_id, 'Greg' emp_name, NULL manager_id FROM DUAL UNION ALL
SELECT 2, 'Fiona', 1 FROM DUAL UNION ALL
SELECT 3, 'Liz', 1 FROM DUAL UNION ALL
SELECT 4, 'Rob', 2 FROM DUAL UNION ALL
SELECT 5, 'Fred', 4 FROM DUAL),
CompanyHierarchy (emp_id, emp_name, manager_id, nivaa) AS (
  SELECT EMP_ID, EMP_NAME, MANAGER_ID, 1 AS NIVAA
    FROM EMP 
    WHERE MANAGER_ID IS NULL
  UNION ALL 
  SELECT EMP.EMP_ID, EMP.EMP_NAME, EMP.MANAGER_ID, CompanyHierarchy.NIVAA+1
    FROM EMP
    INNER JOIN CompanyHierarchy on EMP.MANAGER_ID=CompanyHierarchy.EMP_ID
    WHERE EMP.MANAGER_ID IS NOT NULL)
SELECT * FROM CompanyHierarchy;


-- "Manuell" rekursjon for et hierarki
with t1 as (
SELECT 47 id, 'Norge' name, 47 parent_id FROM DUAL UNION ALL
SELECT 1, 'Viken', 47 FROM DUAL UNION ALL
SELECT 2, 'Vestland', 47 FROM DUAL UNION ALL
SELECT 101, 'Drammen', 1 FROM DUAL UNION ALL
SELECT 202, 'Voss', 2 FROM DUAL UNION ALL
SELECT 8, 'Nordland', 47 FROM DUAL),
level1 as (
    select id, name, parent_id, 1 as nivaa
     from t1 where id=parent_id),
level2 as (
    select id, name, parent_id, 2 as nivaa
     from t1 where parent_id in (select id from level1) and id <> parent_id),
level3 as (
    select id, name, parent_id, 3 as nivaa
     from t1 where parent_id in (select id from level2))
select * from level1 union all select * from level2 union all select * from level3;


-- Endre på kolonnerekkefølge (https://stackoverflow.com/questions/4939735/re-order-columns-of-table-in-oracle)
-- Når en kolonne gjøres usynlig, blir den inkludert i tabellens kolonnerekkefølge som den siste kolonnen.
CREATE TABLE zz_foo (a INT, b INT, d INT, e INT);

ALTER TABLE zz_foo ADD (c INT);

ALTER TABLE zz_foo MODIFY(d INVISIBLE, e INVISIBLE); -- Flyttes nå til enden

ALTER TABLE zz_foo MODIFY(d VISIBLE, e VISIBLE);


-- Kan/bør oppdatere statistikk på tabellgrunnlaget etter større oppdateringer (for å hjelpe query planneren?)
-- Kan også kjøre dette i stedet for Analyze table: exec dbms_stats.gather_schema_stats(ownname => 'SCHEMA_OWNER', estimate_percent => 10)
-- Burde bruke dbms_stats, ref. http://www.dba-oracle.com/concepts/tables_optimizer_statistics.htm
-- (kan også kjøre tabell for tabell med dbms_stats.gather_table_stats)

BEGIN
dbms_stats.gather_table_stats(ownname => 'MY_SCHEMA', tabname => 'STG_TABLE1', estimate_percent => 10, cascade => true);
dbms_stats.gather_table_stats(ownname => 'MY_SCHEMA', tabname => 'STG_TABLE2', estimate_percent => 10, cascade => true);
END;


-- Inkrementell kolonne
-- Ved last av store datasett burde man sette f.eks. CACHE 200. Dette kan derimot føre til at det gjøres hopp i verdiene
-- For å unngå dette sett NOCACHE (det vil da settes inn 1,2,3,4... uten gap)
-- Nja, det er nok ikke så lett, kan bli gap likevel. For å være helt trygg må man selv sette ID ved insert
CREATE TABLE MY_TABLE
(
  ID              NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY ( START WITH 1 MINVALUE 1 NOCYCLE NOCACHE ORDER NOKEEP NOSCALE) NOT NULL,
  FODSELSNUMMER   VARCHAR2(11 BYTE),
  HAR_AVTALE      CHAR(1 BYTE),
  ENDRET_DT       DATE,
  OPPRETTET_DT    DATE
);


-- Div tips ------------------------------------------------------------

-- Ytelse:
-- Bruk indekser! (se på hva som brukes i JOIN og WHERE)
-- Gjør filtrering så tidlig som mulig
-- Analyze table 
-- For store datasett, gjør JOIN i stedet for oppslag (where x not in t2)
-- Del opp views og bruk heller mellomlagringstabeller eller materialiserte view
-- (som refreshes ved jevne mellomrom, eller før/etter ETL-last)

-- Lag alltid en PK-kolonne på nye tabeller (f.eks. inkrementell).
-- Det koster lite, og sparer mye trøbbel for senere UPDATEs og DELETEs og slik (mye lettere å identifisere rader med PK)
-- (For noen tabeller kan rader identifiseres unikt på annet vis, f.eks. komposittnøkler. Sett gjerne opp en PK-constraint for å tydeliggjøre dette)

-- Diverse ressurser
--https://use-the-index-luke.com/
--https://news.ycombinator.com/item?id=30001964 (se lenker)
--https://www.youtube.com/playlist?list=PLSE8ODhjZXjbohkNBWQs_otTrBTrjyohi
--https://www.interdb.jp/pg/ (Postgres)