--2017-11-06

-- Get the partition function for a table;

USE <databaseName>  -- change this to the correct database name

SELECT 
	d.name AS partitionSchemeName
	,pf.name AS partitionFunctionName
	,OBJECT_SCHEMA_NAME(i.object_id) AS schemaName	
	,OBJECT_NAME(i.object_id) AS tableName
	,t.create_date
	,SUM(rows) as recordCount
	,count(*) as numOfPartitions
	,convert(bit, max(case when p.data_compression = 3  then 1 else 0 end)) as pageCompressed
	,convert(bit, max(case when p.data_compression = 4  then 1 else 0 end)) as columnStoreCompressed
FROM    sys.tables t
	INNER JOIN sys.indexes i
		ON t.object_id = i.object_id
	INNER JOIN sys.partitions p
		ON i.object_id = p.object_id
		AND i.index_id = p.index_id
	INNER JOIN sys.data_spaces d
		on i.data_space_id = d.data_space_id 
	LEFT JOIN sys.partition_schemes ps
		ON i.data_space_id = ps.data_space_id 
	LEFT JOIN sys.partition_functions pf 
		ON ps.function_id = pf.function_id
WHERE i.index_id IN (0, 1)   -- a heap or a b-tree
AND  OBJECTPROPERTY(i.object_id,N'IsMSShipped')=0
GROUP BY i.object_id
	,object_name(i.object_id)
	,d.name
	,pf.name
	,t.create_date  
ORDER BY SUM(rows) desc
 