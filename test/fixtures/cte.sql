with recent as (select id, amount from orders where created_at > now() - interval '7 days')
select r.id, coalesce(sum(r.amount),0) as total, case when sum(r.amount) > 1000 then 'big' else 'small' end as bucket from recent r left join customers c on c.id=r.id where c.status in ('active','trial') group by r.id having sum(r.amount) > 10 order by total desc;
