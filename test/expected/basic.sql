SELECT  a
       ,b
       ,c
FROM t1
JOIN t2
ON t1.id = t2.id
WHERE x = 1
AND y = 2
ORDER BY a desc;