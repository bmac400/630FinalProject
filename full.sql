--Build Updated Schema
drop table if exists publications2;
CREATE TABLE publications2 (
    pubid INT,
    year INT,
    venue VARCHAR(50)
);
--This is fine
INSERT INTO publications2 (pubid, year, venue)
SELECT pubid,
       year,
       CASE 
           WHEN pubkey LIKE '%conf/pods%' THEN 'PODS'
           WHEN pubkey LIKE '%sigmod%' THEN 'SIGMOD'
           ELSE NULL 
       END AS venue
FROM publication
WHERE pubkey LIKE '%conf/pods%' OR pubkey LIKE '%sigmod%';

drop table if exists author2;
CREATE TABLE author2 (
    id INT PRIMARY KEY,
    name TEXT,
    inst TEXT,
    dom TEXT
);
--TODO Update INST. For Example Currently http://researchER.ibm.com and http://www.research.ibm.com are different inst. But both should be just ibm.com
INSERT INTO author2 (id, name, inst, dom)
SELECT id,
       name,
       CASE 
           WHEN strpos(homepage, '.edu') > 0 THEN substring(homepage from '^(.*?)\.edu') || '.edu'
           WHEN strpos(homepage, '.com') > 0 THEN substring(homepage from '^(.*?)\.com') || '.com'
           ELSE NULL 
       END AS inst,
       CASE 
           WHEN strpos(homepage, '.edu') > 0 THEN 'edu'
           WHEN strpos(homepage, '.com') > 0 THEN 'com'
           ELSE NULL 
       END AS dom
FROM author;

DO $$ 
BEGIN
    FOR i IN 1..34 LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = format('c%s', i)) THEN
            EXECUTE format('DROP TABLE IF EXISTS %I', 'c'||i);
        END IF;
    END LOOP;
END $$;

DO $$ 
BEGIN
    FOR i IN 1..34 LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = format('u%s', i)) THEN
            EXECUTE format('DROP TABLE IF EXISTS %I', 'u'||i);
        END IF;
    END LOOP;
END $$;

drop table if exists resulttable cascade;

drop table if exists combined_table cascade;

DO $$
DECLARE
    doms text[] := ARRAY['com', 'edu'];
    v_nums int[] := ARRAY(SELECT generate_series(1, 34));
    i int;
    start_year int := 2000;
    end_year int := 2004;

BEGIN
    FOR i IN 1..2 LOOP
        FOR j IN 1..2 LOOP
            EXECUTE format('
                CREATE TABLE c%s AS
                SELECT COALESCE(x.inst,''EMPTY'') as inst, COALESCE(x.name,''EMPTY'') as name, COUNT(DISTINCT z.pubid) as v%s
                FROM Author2 x, Authored y, Publications2 z
                WHERE x.id = y.id 
                    AND y.pubid = z.pubid 
                    AND z.venue = ''SIGMOD'' 
                    AND x.dom = ''%s''
                    AND %s <= z.year AND z.year <= %s
                GROUP BY CUBE (x.inst, x.name)', (i-1)*2+j, (i-1)*2+j, doms[j], start_year, end_year);
        END LOOP;
        -- Increment start_year and end_year after each iteration of the outer loop
        start_year := start_year + 7; -- increment by 5
        end_year := end_year + 7;     -- increment by 5
    END LOOP;
END $$;

--Create U Table
DO $$
DECLARE
    doms text[] := ARRAY['com', 'edu'];
    v_nums int[] := ARRAY(SELECT generate_series(1, 34));
    i int;
    start_year int := 2000;
    end_year int := 2004;
BEGIN
    FOR i IN 1..2 LOOP
        FOR j IN 1..2 LOOP
            EXECUTE format('
                CREATE TABLE U%s AS
                SELECT COUNT(DISTINCT z.pubid) as u%s
                FROM Author2 x, Authored y, Publications2 z
                WHERE x.id = y.id 
                    AND y.pubid = z.pubid 
                    AND z.venue = ''SIGMOD'' 
                    AND x.dom = ''%s''
                    AND %s <= z.year AND z.year <= %s', (i-1)*2+j, (i-1)*2+j, doms[j], start_year, end_year);
        END LOOP;
        -- Increment start_year and end_year after each iteration of the outer loop
        start_year := start_year + 7; -- increment by 5
        end_year := end_year + 7;     -- increment by 5
    END LOOP;
END $$;

--Combine U Tables
DROP TABLE IF EXISTS combined_table;
CREATE TABLE combined_table AS 
SELECT 
    u1.u1 AS u1, u2.u2 AS u2, u3.u3 AS u3, u4.u4 AS u4
FROM 
    u1 
FULL JOIN 
    u2 ON true
FULL JOIN 
    u3 ON true
FULL JOIN 
    u4 ON true;

	
--Do Full Outer Join TODO MAKE THIS A LOOP IF WE CAN
CREATE TABLE resulttable AS
SELECT
    COALESCE(c1.inst, c2.inst, c3.inst, c4.inst) AS inst,
    COALESCE(c1.name, c2.name, c3.name, c4.name) AS name,
    COALESCE(c1.v1, 0) AS v1,
    COALESCE(c2.v2, 0) AS v2,
    COALESCE(c3.v3, 0) AS v3,
    COALESCE(c4.v4, 0) AS v4
FROM
    c1
FULL OUTER JOIN
    c2 ON c1.inst = c2.inst AND c1.name = c2.name
FULL OUTER JOIN
    c3 ON c1.inst = c3.inst AND c1.name = c3.name
FULL OUTER JOIN
    c4 ON c1.inst = c4.inst AND c1.name = c4.name;

	
--q1 : 2000,com
--q2 : 2011 com
--q3 : 2000 edu
--q4 : 2011 edu

--q1 com 2000 q2 edu 2000
--q3 com 2007 q4 edu 2007
drop view if exists result_view;
CREATE VIEW result_view AS
SELECT
    r.inst,
    r.name,
    r.v1,
	r.v2,
	r.v3,
	r.v4,
	(
        ((ct.u1::FLOAT - r.v1::FLOAT) / (ct.u2::FLOAT - r.v2::FLOAT)) * ((ct.u4::FLOAT - r.v4::FLOAT) / (ct.u3::FLOAT - r.v3::FLOAT))
    ) AS uint
FROM
    resulttable r,
    combined_table ct
WHERE
    ct.u3 != r.v3 
    AND ct.u4 != r.v4 
    AND ct.u1 != r.v1 
    AND ct.u2 != r.v2;
