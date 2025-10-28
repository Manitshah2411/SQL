
SELECT * FROM sa.soh

CREATE SCHEMA IF NOT EXISTS practice;

DROP TABLE IF EXISTS practice.soh_bp
CREATE TABLE IF NOT EXISTS practice.soh_bp
(
	salesorderid INT NOT NULL,
	orderdate DATE NOT NULL,
	duedate DATE,
	shipdate DATE,
	subtotal NUMERIC,
	totaldue NUMERIC,
	PRIMARY KEY (salesorderid, orderdate) -- The partition 
) PARTITION BY RANGE (orderdate); 

SELECT * FROM practice.soh_bp

CREATE TABLE practice.soh_bp_2011
PARTITION OF practice.soh_bp 
FOR VALUES FROM ('2011-01-01') TO ('2012-01-01');

CREATE TABLE practice.soh_bp_2012
PARTITION OF practice.soh_bp 
FOR VALUES FROM ('2012-01-01') TO ('2013-01-01');

CREATE TABLE practice.soh_bp_2013
PARTITION OF practice.soh_bp
FOR VALUES FROM ('2013-01-01') TO ('2014-01-01');

CREATE TABLE practice.soh_bp_2014
PARTITION OF practice.soh_bp
FOR VALUES FROM ('2014-01-01') TO (MAXVALUE)

INSERT INTO practice.soh_bp (salesorderid,orderdate,duedate,shipdate,subtotal,totaldue)
SELECT salesorderid,orderdate,duedate,shipdate,subtotal,totaldue
FROM sa.soh



