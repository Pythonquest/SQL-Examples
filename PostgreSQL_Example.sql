-- Implement your solution here
with
    e as (
        select * from elements
    ),

    qryFinal as 
    (
        select  
            sum(e.v) as v
        from e
    )

SELECT * from qryFinal;

==========================================

-- Implement your solution here
with
    e as (
        select * from events
    ),

    eventRanks as 
    (
        select 
            e.*,
            rank() over 
            (
                partition by e.event_type 
                order by time desc
            ) as event_rank
        from e
    ),

    eventCounts as 
    (
        select
            event_type,
            count(event_type) as event_count
        from e 
        group by event_type
    ),

    countDifferences as 
    (
        select
            eventRanks.event_type,
            (eventRanks.value - lead(eventRanks.value, 1) over (partition by eventRanks.event_type order by eventRanks.event_rank)) as value
        from
            eventRanks join
            eventCounts on
                eventRanks.event_type = eventCounts.event_type
        where
            eventCounts.event_count > 1 and
            eventRanks.event_rank <= 2
    ),

    qryFinal as 
    (
        SELECT * 
            from countDifferences
        where 
            value is not null
    )

select * from qryFinal
order by event_type;

======================================

-- Implement your solution here
with
    t as (
        select * from teams
    ),
    m as (
        select * from matches
    ),

    scores as 
    (
        select 
            m.host_team,
            case
                when m.host_goals > m.guest_goals
                    then 3
                when m.host_goals = m.guest_goals
                    then 1
                else 0
            end as host_score,
            m.guest_team,
            case
                when m.guest_goals > m.host_goals
                    then 3
                when m.guest_goals = m.host_goals
                    then 1
                else 0
            end as guest_score
        from m
    ),

    flattenedScores as 
    (
        select 
            host_team as team_id,
            host_score as num_points
        from scores
        union all
        select 
            guest_team as team_id,
            guest_score as num_points
        from scores
    ),

    summarizedScores as 
    (
        select
            team_id,
            sum(num_points) as num_points
        from flattenedScores
        group by team_id
    ),


    qryFinal as 
    (
        select
            t.team_id,
            t.team_name,
            coalesce(summarizedScores.num_points, 0) as num_points
        from
            t left join
            summarizedScores on
                t.team_id = summarizedScores.team_id
    )

SELECT * from qryFinal
order by num_points desc, team_id;
