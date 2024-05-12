DO $$ 
BEGIN
    FOR i IN 1..20 LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = format('c%s', i)) THEN
            EXECUTE format('DROP TABLE IF EXISTS %I', 'c'||i);
        END IF;
    END LOOP;
END $$;

DO $$ 
BEGIN
    FOR i IN 1..20 LOOP
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
    v_nums int[] := ARRAY(SELECT generate_series(1, 20));
    i int;
    start_year int := 1991;
    end_year int := 1995;
BEGIN
    FOR i IN 1..10 LOOP
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
        start_year := start_year + 1; -- increment by 5
        end_year := end_year + 1;     -- increment by 5
    END LOOP;
END $$;

--Create U Table
DO $$
DECLARE
    doms text[] := ARRAY['com', 'edu'];
    v_nums int[] := ARRAY(SELECT generate_series(1, 20));
    i int;
    start_year int := 1991;
    end_year int := 1995;
BEGIN
    FOR i IN 1..10 LOOP
        FOR j IN 1..2 LOOP
            EXECUTE format('
                CREATE TABLE U%s AS
                SELECT COUNT(DISTINCT z.pubid) as u%s
                FROM Author4 x, Authored y, Publications2 z
                WHERE x.id = y.id 
                    AND y.pubid = z.pubid 
                    AND z.venue = ''SIGMOD'' 
                    AND x.dom = ''%s''
                    AND %s <= z.year AND z.year <= %s', (i-1)*2+j, (i-1)*2+j, doms[j], start_year, end_year);
        END LOOP;
        -- Increment start_year and end_year after each iteration of the outer loop
        start_year := start_year + 1; -- increment by 5
        end_year := end_year + 1;     -- increment by 5
    END LOOP;
END $$;

--Combine U Tables
DROP TABLE IF EXISTS combined_table;
CREATE TABLE combined_table AS 
SELECT 
    u1.u1 AS u1, u2.u2 AS u2, u3.u3 AS u3, u4.u4 AS u4, u5.u5 AS u5, 
    u6.u6 AS u6, u7.u7 AS u7, u8.u8 AS u8, u9.u9 AS u9, u10.u10 AS u10, 
    u11.u11 AS u11, u12.u12 AS u12, u13.u13 AS u13, u14.u14 AS u14, 
    u15.u15 AS u15, u16.u16 AS u16, u17.u17 AS u17, u18.u18 AS u18, 
    u19.u19 AS u19, u20.u20 AS u20 
FROM 
    u1 
FULL JOIN 
    u2 ON true
FULL JOIN 
    u3 ON true
FULL JOIN 
    u4 ON true
FULL JOIN 
    u5 ON true
FULL JOIN 
    u6 ON true
FULL JOIN 
    u7 ON true
FULL JOIN 
    u8 ON true
FULL JOIN 
    u9 ON true
FULL JOIN 
    u10 ON true
FULL JOIN 
    u11 ON true
FULL JOIN 
    u12 ON true
FULL JOIN 
    u13 ON true
FULL JOIN 
    u14 ON true
FULL JOIN 
    u15 ON true
FULL JOIN 
    u16 ON true
FULL JOIN 
    u17 ON true
FULL JOIN 
    u18 ON true
FULL JOIN 
    u19 ON true
FULL JOIN 
    u20 ON true;
	
--Do Full Outer Join TODO MAKE THIS A LOOP IF WE CAN
CREATE TABLE resulttable AS
SELECT
    COALESCE(c1.inst, c2.inst, c3.inst, c4.inst, c5.inst, c6.inst, c7.inst, c8.inst, c9.inst, c10.inst,
             c11.inst, c12.inst, c13.inst, c14.inst, c15.inst, c16.inst, c17.inst, c18.inst, c19.inst, c20.inst) AS inst,
    COALESCE(c1.name, c2.name, c3.name, c4.name, c5.name, c6.name, c7.name, c8.name, c9.name, c10.name,
             c11.name, c12.name, c13.name, c14.name,  c15.name, c16.name, c17.name, c18.name, c19.name, c20.name) AS name,
    COALESCE(c1.v1, 0) AS v1,
    COALESCE(c2.v2, 0) AS v2,
    COALESCE(c3.v3, 0) AS v3,
    COALESCE(c4.v4, 0) AS v4,
    COALESCE(c5.v5, 0) AS v5,
    COALESCE(c6.v6, 0) AS v6,
    COALESCE(c7.v7, 0) AS v7,
    COALESCE(c8.v8, 0) AS v8,
    COALESCE(c9.v9, 0) AS v9,
    COALESCE(c10.v10, 0) AS v10,
    COALESCE(c11.v11, 0) AS v11,
    COALESCE(c12.v12, 0) AS v12,
    COALESCE(c13.v13, 0) AS v13,
    COALESCE(c14.v14, 0) AS v14,
    COALESCE(c15.v15, 0) AS v15,
    COALESCE(c16.v16, 0) AS v16,
    COALESCE(c17.v17, 0) AS v17,
    COALESCE(c18.v18, 0) AS v18,
    COALESCE(c19.v19, 0) AS v19,
    COALESCE(c20.v20, 0) AS v20
FROM
    c1
FULL OUTER JOIN
    c2 ON c1.inst = c2.inst AND c1.name = c2.name
FULL OUTER JOIN
    c3 ON c1.inst = c3.inst AND c1.name = c3.name
FULL OUTER JOIN
    c4 ON c1.inst = c4.inst AND c1.name = c4.name
FULL OUTER JOIN
    c5 ON c1.inst = c5.inst AND c1.name = c5.name
FULL OUTER JOIN
    c6 ON c1.inst = c6.inst AND c1.name = c6.name
FULL OUTER JOIN
    c7 ON c1.inst = c7.inst AND c1.name = c7.name
FULL OUTER JOIN
    c8 ON c1.inst = c8.inst AND c1.name = c8.name
FULL OUTER JOIN
    c9 ON c1.inst = c9.inst AND c1.name = c9.name
FULL OUTER JOIN
    c10 ON c1.inst = c10.inst AND c1.name = c10.name
FULL OUTER JOIN
    c11 ON c1.inst = c11.inst AND c1.name = c11.name
FULL OUTER JOIN
    c12 ON c1.inst = c12.inst AND c1.name = c12.name
FULL OUTER JOIN
    c13 ON c1.inst = c13.inst AND c1.name = c13.name
FULL OUTER JOIN
    c14 ON c1.inst = c14.inst AND c1.name = c14.name
FULL OUTER JOIN
    c15 ON c1.inst = c15.inst AND c1.name = c15.name
FULL OUTER JOIN
    c16 ON c1.inst = c16.inst AND c1.name = c16.name
FULL OUTER JOIN
    c17 ON c1.inst = c17.inst AND c1.name = c17.name
FULL OUTER JOIN
    c18 ON c1.inst = c18.inst AND c1.name = c18.name
FULL OUTER JOIN
    c19 ON c1.inst = c19.inst AND c1.name = c19.name
FULL OUTER JOIN
    c20 ON c1.inst = c20.inst AND c1.name = c20.name;
	
--Create Result View
CREATE VIEW result_view AS
SELECT r.inst,
       r.name,
	   (ct.u1 - r.v1 + ct.u2 - r.v2 + ct.u3 - r.v3 + ct.u4 - r.v4
        + COALESCE(ct.u5, 0) - COALESCE(r.v5, 0)
        + COALESCE(ct.u6, 0) - COALESCE(r.v6, 0)
        + COALESCE(ct.u7, 0) - COALESCE(r.v7, 0)
        + COALESCE(ct.u8, 0) - COALESCE(r.v8, 0)
        + COALESCE(ct.u9, 0) - COALESCE(r.v9, 0)
        + COALESCE(ct.u10, 0) - COALESCE(r.v10, 0)
        + COALESCE(ct.u11, 0) - COALESCE(r.v11, 0)
        + COALESCE(ct.u12, 0) - COALESCE(r.v12, 0)
        + COALESCE(ct.u13, 0) - COALESCE(r.v13, 0)
        + COALESCE(ct.u14, 0) - COALESCE(r.v14, 0)
        + COALESCE(ct.u15, 0) - COALESCE(r.v15, 0)
        + COALESCE(ct.u16, 0) - COALESCE(r.v16, 0)
        + COALESCE(ct.u17, 0) - COALESCE(r.v17, 0)
        + COALESCE(ct.u18, 0) - COALESCE(r.v18, 0)
        + COALESCE(ct.u19, 0) - COALESCE(r.v19, 0)
        + COALESCE(ct.u20, 0) - COALESCE(r.v20, 0)
       ) AS uint
FROM ResultTable r
CROSS JOIN (SELECT * FROM combined_table LIMIT 1) ct;
