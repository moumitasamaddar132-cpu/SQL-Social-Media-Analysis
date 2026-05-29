use ig_clone;
                             -- Objective Questions
-- O1: Are there any tables with duplicate or missing null values? if so, how would you handle them?

select * from users;
select 
username,count(*) as User_cnt 
from users
group by username 
having count(*) >1;   -- no duplicates
    
select * from users
where username is null; -- not null   

select * from photos;
select id, count(*) as count 
from photos 
group by id
having count > 1;  -- no duplicates

select * from photos
where image_url is null; -- not null

select * from comments;
select id, count(*) as count
from comments
group by id 
having count > 1; -- no duplicates;

select comment_text 
from comments
where comment_text is null; -- not null

select * from likes;
select  user_id, photo_id, created_at, count(*) as count
from likes
group by user_id, photo_id, created_at 
having count > 1; --  no duplicates;

select user_id, photo_id, created_at 
from likes
where user_id is null; -- not null

select * from follows;
select follower_id, followee_id, created_at, count(*) as count from follows 
group by follower_id, followee_id, created_at
having count > 1; --  no duplicates

select follower_id
from follows
where follower_id is null; -- no null

select * from tags;
select tag_name,count(*) as count 
from tags
group by tag_name
having count > 1; -- no duplicates

select tag_name 
from tags
where tag_name is null;  -- not null

select * from photo_tags;
select photo_id , count(*) as count 
from photo_tags
group by photo_id
having count > 1;  -- no duplicates

select photo_id 
from photo_tags
where photo_id is null; -- no null

-- O2.what is the distribution of user activity levels (e.g., number of posts, likes, comments) across the user base? 

Select
        u.id AS user_id,
        u.username,
        count(distinct p.id) AS total_posts,
        count(distinct l.photo_id) AS total_likes,
        count(distinct c.id) AS total_comments,
        (count(distinct p.id) + count(distinct l.photo_id) + count(distinct c.id)) AS total_interactions
    from users u
    Left Join photos p ON u.id = p.user_id
    Left Join likes l ON u.id = l.user_id
    Left Join comments c ON u.id = c.user_id
    Group by  u.id, u.username
    limit 15 ;
    
-- O3. Calculate the average number of tags per post (photo_tags and photos tables).

With post_tag_counts as (
    Select
        p.id, 
        count(pt.tag_id) as tag_count
    from photos p
    Left Join photo_tags pt on p.id = pt.photo_id
    Group by p.id
)
Select avg(tag_count) from post_tag_counts;   

-- O4.Identify the top users with the highest engagement rates (likes, comments) on their posts and rank them.

select u.id,
u.username,
count(distinct l.user_id) as num_likes,
count(distinct c.id) as num_comments,
((count(distinct l.user_id) + count(distinct c.id)) / nullif(count(p.id),0)) as engaement_rate,
rank() over (order by (count(distinct l.user_id) + count(distinct c.id)) / nullif(count(p.id), 0) desc) as rn
from users u 
join photos p on u.id= p.user_id
left join likes l on p.id = l.photo_id
left join comments c on p.id = c.photo_id
group by u.id, u.username
order by rn
limit 10;



-- O5.Which users have the highest number of followers and followings?

select 
    u.id,
    u.username,
    count(distinct f.follower_id) as num_followers,         
    count(distinct ff.followee_id) as num_followings
from users u
left join follows f on u.id = f.followee_id
left join follows ff on u.id = ff.follower_id
group by u.id, u.username
order by num_followers desc, num_followings desc;


    


-- O6.Calculate the average engagement rate (likes, comments) per post for each user. 

With likes_cte as (
    Select photo_id, count(*) AS likes_count 
    from likes 
    group by  photo_id
), 
comments_cte as (
    Select photo_id, count(*) AS comments_count 
    from comments 
    group by  photo_id
), 
avg_rate as (
    Select 
        u.id, 
        u.username, 
        count(p.id) AS total_photos, 
        round(avg(coalesce(l.likes_count, 0) + coalesce(c.comments_count, 0)), 2) as avg_engagement_rate 
    from users u 
    join photos p ON u.id = p.user_id 
    Left Join likes_cte l ON p.id = l.photo_id 
    Left Join comments_cte c ON p.id = c.photo_id 
    Group by u.id, u.username
) 
Select * from avg_rate
order by  avg_engagement_rate DESC;

-- O7. Get the list of users who have never liked any post (users and likes tables)

select id, 
username
from users 
where id not in(
select user_id 
from likes);

-- O8.How can you leverage user-generated content (posts, hashtags, photo tags) to create more personalized and engaging ad campaigns?

with top as (
select u.id as user_id,
u.username, p.id as post_id,
p.image_url,
p.created_dat as created_date,
count(distinct l.user_id) as likes_count,
count(distinct c.id) as comments_count
from users u 
join photos p on u.id = p.user_id
left join likes l on p.id = l.photo_id 
left join comments c on p.id = c.photo_id 
group by u.id, u.username, p.id, p.image_url,p.created_dat
)
select user_id, username,
sum(likes_count) as total_likes,
sum(comments_count) as total_comments,
sum(likes_count+comments_count) as total_engagement
from top 
group by user_id, username
order by total_engagement desc 
limit 10;

-- O9. Are there any correlations between user activity levels and specific content types (e.g., photos, videos, reels)? How can this information guide content creation and curation strategies?

select u.id as user_id,
u.username,
count(p.id) as total_photos,
coalesce(sum(l.likes_count), 0) as total_likes,
coalesce(sum(c.comments_count), 0) as total_comments,
round(avg(coalesce(l.likes_count, 0) + coalesce(c.comments_count, 0)),2) as avg_engagement_per_post
from users u
join photos p on u.id = p.user_id
left join (
select photo_id, 
count(*) as likes_count 
from likes group by photo_id) l 
on p.id = l.photo_id
left join (
select photo_id, 
count(*) as comments_count 
from comments group by photo_id) c on p.id = c.photo_id
group by u.id, u.username
order by avg_engagement_per_post desc;

-- 10. Calculate the total number of likes, comments, and photo tags for each user.

select u.id as user_id, 
u.username, 
count(distinct l.user_id) as total_likes, 
count(distinct c.id) as total_comments, 
count(distinct pt.tag_id) as total_photo_tags 
from users u 
join photos p on u.id = p.user_id 
left join likes l on p.id = l.photo_id 
left join comments c on p.id = c.photo_id 
left join photo_tags pt on p.id = pt.photo_id 
group by u.id, u.username 
order by total_likes desc, total_comments desc, total_photo_tags desc;

-- 11. rank users based on their total engagement (likes, comments, shares) over a month.

with engagement as (
select u.id, u.username,
count(distinct l.photo_id) + count(distinct c.id) as total_engagement
from users u
left join likes l 
on u.id = l.user_id 
and l.created_at >= date_sub(current_date, interval 1 month)
left join comments c 
on u.id = c.user_id and 
c.created_at >= date_sub(current_date, interval 1 month)
group by u.id, u.username
)
select id,username,
total_engagement,
rank() over (order by total_engagement desc) as engagement_rank
from engagement
order by engagement_rank;
    
   --  12. Retrieve the hashtags that have been used in posts with the highest average number of likes. Use a CTE to calculate the average likes for each hashtag first.
   
with hashtag_likes as (
select t.tag_name,
avg(l.likes) as avg_likes
from photo_tags pt
join tags t on pt.tag_id = t.id
join (
select photo_id, count(*) as likes
from likes
group by photo_id
) l on pt.photo_id = l.photo_id
group by t.tag_name
),
max_avg as (
select max(avg_likes) as max_likes
from hashtag_likes
)
select tag_name,
round(avg_likes, 2) as avg_likes
from hashtag_likes
where avg_likes = (select max_likes from max_avg);

-- 13. Retrieve the users who have started following someone after being followed by that person.

select 
    f1.follower_id as user_id,
    f1.followee_id as followee_id,
    f1.created_at as follow_time
from follows f1
join follows f2 
on f2.follower_id = f1.followee_id
and f2.followee_id = f1.follower_id
and f2.created_at < f1.created_at;

                                  -- Subjective Questions
 -- 1.Based on user engagement and activity levels, which users would you consider the most loyal or valuable? How would you reward or incentivize these users?                                 
                                  
with total as (
select u.id as user_id, u.username,
count(distinct p.id) as total_posts,
count(distinct c.id) as total_comments,
count(distinct l.photo_id) as total_likes
from users u
left join photos p on u.id = p.user_id
left join comments c on u.id = c.user_id
left join likes l on u.id = l.user_id
group by u.id,u.username
)
select *,
sum(total_posts+total_comments+total_likes) as total_activity,
rank() over(order by (total_posts+total_comments+total_likes)  desc) as loyal_customer_rank
from total
group by user_id, username
order by total_activity desc;             

-- 2.For inactive users, what strategies would you recommend to re-engage them and encourage them to start posting or engaging again?

select  u.id, u.username, 
count(distinct l.photo_id) + count(distinct c.id) + count(distinct p.id) as engagement
from users u
left join likes l on u.id = l.user_id and l.created_at >= date_sub(now(), interval 30 day)
left join comments c on u.id = c.user_id and c.created_at >= date_sub(now(), interval 30 day)
left join photos p on u.id = p.user_id and p.created_dat >= date_sub(now(), interval 30 day)
group by u.id, u.username
having engagement = 0;

-- 3. Which hashtags or content topics have the highest engagement rates? How can this information guide content strategy and ad campaigns?

with tag_stats as (
    select 
        t.id as tag_id,
        t.tag_name,
        count(distinct l.photo_id) as num_likes,
        count(distinct cm.id) as num_comments,
        count(distinct p.id) as num_posts
    from tags t
    left join photo_tags pt on t.id = pt.tag_id
    left join likes l on pt.photo_id = l.photo_id
    left join comments cm on pt.photo_id = cm.photo_id
    left join photos p on pt.photo_id = p.id
    group by t.id, t.tag_name
)
select  tag_id, tag_name,
round((num_likes + num_comments) / nullif(num_posts, 0), 2) as engagement_rate,
dense_rank() over (order by (num_likes + num_comments) / nullif(num_posts, 0) desc) as ranking
from tag_stats
order by ranking;

  -- 4. Are there any patterns or trends in user engagement based on demographics (age, location, gender) or posting times? How can these insights inform targeted marketing campaigns?

select u.id, u.username,
l.likes_count,
c.comments_count,
f.follows_count,
p.first_post,
p.last_post
from users u
left join (
select user_id, count(distinct photo_id) as likes_count
from likes group by user_id
) l on u.id = l.user_id

left join (
select user_id, count(*) as comments_count
from comments group by user_id
) c on u.id = c.user_id

left join (
select follower_id, count(*) as follows_count
from follows group by follower_id
) f on u.id = f.follower_id

left join (
select user_id, min(created_dat) as first_post, max(created_dat) as last_post
from photos group by user_id
) p on u.id = p.user_id;

-- 5. Based on follower counts and engagement rates, which users would be ideal candidates for influencer marketing campaigns? How would you approach and collaborate with these influencers?

with user_followers as (
    select followee_id as id,
           count(followee_id) as no_of_followers
    from follows
    group by followee_id
),
user_likes as (
    select user_id,
           count(*) as num_likes
    from likes
    group by user_id
),
user_comments as (
    select user_id,
           count(id) as num_comments
    from comments
    group by user_id
),
user_photos as (
    select user_id,
           count(id) as num_photos
    from photos
    group by user_id
)
select u4.id,u4.username,
u1.no_of_followers,
u2.num_likes,
u3.num_comments,
round((u2.num_likes + u3.num_comments)/u5.num_photos,2) as engagement_rate,
 dense_rank() over(order by round((u2.num_likes + u3.num_comments)/u5.num_photos,2) desc) as ranking
from user_followers u1 
join user_likes u2 
on u1.id = u2.user_id
join user_comments u3 
on u1.id = u3.user_id
join users u4 
on u1.id = u4.id 
join user_photos u5 
on u1.id = u5.user_id;

-- 6. based on user behavior and engagement data, how would you segment the user base for targeted marketing campaigns or personalized recommendations?

select u.id, u.username,
coalesce(p.num_photos, 0) as num_photos,
coalesce(l.num_likes, 0)  as num_likes,
coalesce(c.num_comments, 0) as num_comments,
coalesce(f.follows_count, 0) as follows_count,
case
when coalesce(p.num_photos, 0) = 0 then 0
else round(
	(coalesce(l.num_likes, 0) + coalesce(c.num_comments, 0))
	/ coalesce(p.num_photos, 1),2
    )
  end as engagement_rate,
  case
    when coalesce(p.num_photos, 0) >= 50
	and (
	case when coalesce(p.num_photos,0)=0 then 0
	else (coalesce(l.num_likes,0)+coalesce(c.num_comments,0))/coalesce(p.num_photos,1)
	end
	) >= 50 then 'highly engaged'
    when coalesce(p.num_photos, 0) >= 20 then 'active user'
    when coalesce(p.num_photos, 0) < 5 then 'new or passive'
    else 'general user'
end as segment
from users u
left join (
select user_id, count(*) as num_photos
from photos
group by user_id
) p on u.id = p.user_id
left join (
select p.user_id as user_id, count(*) as num_likes
from likes l
join photos p on l.photo_id = p.id
group by p.user_id
) l on u.id = l.user_id
left join (
select p.user_id as user_id, count(*) as num_comments
from comments c
join photos p on c.photo_id = p.id
group by p.user_id
) c on u.id = c.user_id
left join (
select follower_id as user_id, count(*) as follows_count
from follows
group by follower_id
) f on u.id = f.user_id
order by engagement_rate desc;

-- 7. If data on ad campaigns (impressions, clicks, conversions) is available, how would you measure their effectiveness and optimize future campaigns? 

select ac.id,ac.name,
count(distinct i.id) as impressions,
count(distinct c.id) as clicks,
count(distinct cv.id) as conversions,
(count(distinct c.id) / count(distinct i.id)) * 100 as ctr, -- click-through rate
(count(distinct cv.id) / count(distinct c.id)) * 100 as cvr, -- conversion rate from clicks
(count(distinct cv.id) / count(distinct i.id)) * 100 as overall_conversion_rate
from ad_campaigns ac
left join impressions i on ac.id = i.ad_campaign_id
left join clicks c on i.id = c.impression_id
left join conversions cv on c.id = cv.click_id
group by ac.id, ac.name;

-- 8.  How can you use user activity data to identify potential brand ambassadors or advocates who could help promote Instagram's initiatives or events? 

with post_counts as (
  select user_id, count(*) as total_posts
  from photos
  group by user_id
),
comment_counts as (
select user_id, count(*) as total_comments
from comments
group by user_id
),
like_counts as (
select user_id, count(distinct photo_id) as total_likes
from likes
group by user_id
),
follower_counts as (
select followee_id as user_id, count(*) as total_followers
from follows
group by followee_id
),
tag_usage as (
select p.user_id, group_concat(distinct t.tag_name) as hashtags_used
from photos p
join photo_tags pt on p.id = pt.photo_id
join tags t on pt.tag_id = t.id
group by p.user_id
)
select u.id as user_id, u.username,
coalesce(pc.total_posts, 0) as total_posts,
coalesce(cc.total_comments, 0) as total_comments,
coalesce(lc.total_likes, 0) as total_likes,
coalesce(fc.total_followers, 0) as total_followers,
case
when coalesce(pc.total_posts, 0) = 0 then 0
else round((coalesce(lc.total_likes, 0) + coalesce(cc.total_comments, 0)) / pc.total_posts, 3)
end as engagement_rate, tu.hashtags_used,
case
when coalesce(pc.total_posts, 0) > 5
and (coalesce(lc.total_likes, 0) + coalesce(cc.total_comments, 0)) / nullif(pc.total_posts, 0) > 0.2
then 'high engagement user'
when coalesce(fc.total_followers, 0) > 50
and (coalesce(lc.total_likes, 0) + coalesce(cc.total_comments, 0)) / nullif(pc.total_posts, 0) > 0.1
then 'potential influencer'
when tu.hashtags_used like '%#instagram%'
or tu.hashtags_used like '%#event%'
then 'event advocate'
else 'other'
end as user_segment
from users u
left join post_counts pc on u.id = pc.user_id
left join comment_counts cc on u.id = cc.user_id
left join like_counts lc on u.id = lc.user_id
left join follower_counts fc on u.id = fc.user_id
left join tag_usage tu on u.id = tu.user_id
where coalesce(fc.total_followers, 0) > 50
and (
case
when coalesce(pc.total_posts, 0) = 0 then 0
else (coalesce(lc.total_likes, 0) + coalesce(cc.total_comments, 0)) / pc.total_posts
end
) > 0.1
order by total_followers desc, engagement_rate desc;


-- 10. Assuming there's a "User_Interactions" table tracking user engagements, how can you update the "Engagement_Type" column to change all instances of "Like" to "Heart" to align with Instagram's terminology?

update User_Interactions
set Engagement_Type = 'Heart'
where Engagement_Type = 'Like';


-- Addtitional
use ig_clone;
select count(id) as user_id
from users;

select count(id) as Postcreated
from photos;

select count(id) as totalcomments
from comments;

select count(user_id) as totallikes
from likes;

select count(id) as totaltags
from tags;

select u.id, count(p.id) as totalphotos,
case
when count(p.id) = 0 then 'zero photos'
when count(p.id) between 1 and 3 then 'low photos'
when count(p.id) between 4 and 7 then 'medium photos'
else 'high photos'
end as photos_segment 
from users u 
left join photos p 
on u.id = p.user_id 
group by u.id;


select u.id, count(c.id) as totalcomments,
case
	when count(c.id) = 0 then 'zero comments'
	when count(c.id) between 1 and 50 then 'low comments'
	when count(c.id) between 51 and 100 then 'medium comments'
	when count(c.id)> 100 then 'high comments'
	end as comment_segment
from users u 
left join comments c 
on u.id = c.user_id
group by u.id;


select u.id,count(l.user_id) as totallikes,
case
	when count(l.user_id) = 0 then 'zero likes'
	when count(l.user_id) between 1 and 50 then 'low likes'
	when count(l.user_id) between 51 and 100 then 'medium likes'
	when count(l.user_id) > 100 then 'high likes'
    end as like_segment
from users u 
left join likes l 
on u.id = l.user_id 
group by u.id;


select 
    dayname(u.created_at) as weekday,
    count(distinct p.id) as total_posts,
    count(distinct l.photo_id) as total_likes,
    count(distinct c.id) as total_comments,
	count(distinct l.photo_id) + count(distinct c.id) + count(distinct p.id) as engagement
from users u
left join photos p on u.id = p.user_id
left join comments c on u.id = c.user_id
left join likes l on u.id = l.user_id
group by weekday
order by engagement desc;



select 
 extract(hour from u.created_at) as hour_split,
	count(distinct l.photo_id) + count(distinct c.id) + count(distinct p.id) as engagement
from users u
left join photos p on u.id = p.user_id
left join comments c on u.id = c.user_id
left join likes l on u.id = l.user_id
group by hour_split
order by hour_split desc;

select 
    t.tag_name,
    count(distinct l.user_id) as total_likes,
    count(distinct c.id) as total_comments,
    round((count(distinct l.user_id) + count(distinct c.id)) / count(distinct p.id),0) AS avg_engagement_per_photo
from tags t
join photo_tags pt on t.id = pt.tag_id
join photos p on pt.photo_id = p.id
left join likes l on p.id = l.photo_id
left join comments c on p.id = c.photo_id
group by t.tag_name
order by  avg_engagement_per_photo desc;

with user_custom_engagement as (
    
    Select
        p.id AS photo_id,
        p.user_id,
        (Select count(*) FROM likes l where l.photo_id = p.id) as likes_count,
        (Select count(*) FROM comments c where c.photo_id = p.id) as comments_count
    from photos p
),
user_per_post_average AS (
    
    Select
        u.id as user_id,
        year(u.created_at) as joining_year,
        avg(uce.likes_count + uce.comments_count) as personal_avg_engagement
    from users u
    join user_custom_engagement uce on u.id = uce.user_id
    group BY u.id, year(u.created_at)
)

Select
    joining_year,
    round(avg(personal_avg_engagement), 2) as avg_engagement_per_post
from user_per_post_average
where joining_year in (2016, 2017)
group by  joining_year
order by  joining_year desc;
