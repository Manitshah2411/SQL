EXPLAIN ANALYSE SELECT * FROM person.emailaddress;
WHERE emailaddress = 'ken0@adventure-works.com';

/*
"Seq Scan on emailaddress  (cost=0.00..476.65 rows=1 width=60) (actual time=0.021..4.233 rows=1 loops=1)"
"Filter: ((emailaddress)::text = 'ken0@adventure-works.com'::text)"
"Rows Removed by Filter: 19971"
"Planning Time: 1.902 ms"
"Execution Time: 4.258 ms"
*/

DROP INDEX person.idx_email_address; 
CREATE INDEX idx_email_address;
ON person.emailaddress (emailaddress);

-- "Index Scan using idx_email_address on emailaddress  (cost=0.29..8.30 rows=1 width=60)
-- (actual time=0.030..0.031 rows=1 loops=1)"
-- "Planning Time: 0.368 ms"
-- "Execution Time: 0.046 ms"


EXPLAIN ANALYSE SELECT * FROM pr.p
WHERE pr.p.productnumber = 'BL-2036';





