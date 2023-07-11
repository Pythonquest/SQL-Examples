with
    o as (
        select * from opinions
    ),

    opinionCounts as 
    (
        select distinct 
            o.place,
            o.opinion,
            count(o.place) as opinion_count
        from o
        group by
            o.place,
            o.opinion
        order by 
            place,
            opinion desc
    ),

    totals as 
    (
        select distinct
            place,
            opinion_count
        from
            opinionCounts
        where 
            opinion = 'recommended'
        union all
        select distinct
            place,
            opinion_count * -1
        from
            opinionCounts
        where 
            opinion = 'not recommended'
    ),

    opinionSums as 
    (
        select
            place,
            sum(opinion_count) as opinion_sum
        from totals
        group by 
            place
    ),

    qryFinal as 
    (
        select place
        from opinionSums
        where   
            opinion_sum > 0
    )

SELECT * from qryFinal
order by place;
