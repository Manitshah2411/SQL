select * from sales.ordersarchive;
select * from sales.orders;



SELECT
	'Order' as SourceTable, -- A new static column called SourceTable so that we can know the data is from which table  
	*
FROM sales.orders AS o

UNION

SELECT 
	'OrderArchive' as SourceTable,
	*
FROM sales.ordersarchive AS oa
ORDER BY orderid ASC






	