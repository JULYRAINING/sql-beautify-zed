WITH recent AS
(
	SELECT  id
	       ,amount
	FROM orders
	WHERE created_at > now() - interval '7 days'
)
SELECT  r.id
       ,coalesce(SUM(r.amount),0)                                   AS total
       ,CASE WHEN SUM(r.amount) > 1000 THEN 'big'  ELSE 'small' END AS bucket
FROM recent r
LEFT JOIN customers c
ON c.id = r.id
WHERE c.status IN ('active', 'trial')
GROUP BY  r.id
HAVING SUM(r.amount) > 10
ORDER BY total desc;