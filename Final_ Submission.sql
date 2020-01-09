-- Final Complete


SELECT u1.id FROM user AS u1, user AS u2  -- Calling same column again using aliasing and 
WHERE u1.password = u2.password -- matching for exact match
AND u1.id != u2.id; -- to ensure that we don't get the same id

-- 2nd method
-- selecting the passwords which are used twice (use of count function) 

SELECT id FROM user WHERE password in (
		SELECT password FROM user
		GROUP BY password 
        HAVING count(*) > 1
);





-- use of max function to get the max date out of group by results so that 
-- if one person visited twice we will use the latest date of his visit
-- and compare it with "2000-01-31" this will give us the correct result 

SELECT email FROM 
		(SELECT u.email, max(v.visit_date) AS max_date 
		FROM user u JOIN visit v ON u.id = v.id 
        GROUP BY email) AS Main
WHERE max_date < '2000-01-31';



-- QUESTION 3 SLUTION WITHOUT CTE

SELECT   email, average_visit_date from
    (SELECT * , date_dif/2 as average_visit_date -- AVERAGE OF DATES
       FROM
		(SELECT * , 
			(AVG(nth_second_most_date - nth_first_most_date) -- calculates the difference of dates with regards to the user_id
				Over(PARTITION BY user_id) ) AS date_dif
					FROM
					(SELECT *, 
						NTH_VALUE(visit_date, 2) 
							OVER(PARTITION BY user_id ORDER BY user_id, days
								RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS nth_second_most_date ,
						NTH_VALUE(visit_date, 1)  -- The Nth_Value function get's the first two visit date
							OVER(PARTITION BY user_id ORDER BY user_id,days
								RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS nth_first_most_date
                                FROM
									(SELECT * ,
										COUNT(user_id)
											OVER(PARTITION BY user_id) AS count_
		FROM 
			(SELECT user.* , user_id, visit_date, RIGHT(visit_date,2) AS days
				  FROM user JOIN visit_ ON user.id = visit_.id) as Q1
                  )  AS FINAL ) as final_) as final_f) as final_ff WHERE count_ >= 2 AND email LIKE '%@gmail.com%'
		 Group by user_id, date_dif;
         -- avoids duplication ( similarly we could have used distinct email)
        -- or use Right((email,10) to get @gmail.com assumig good data quality 
        
        
        

-- QUESTION 3 SLUTION WITH CTE



WITH CTE_main_ AS (SELECT user.* , user_id, visit_date, RIGHT(visit_date,2) AS days
				  FROM user JOIN visit_ ON user.id = visit_.id)
SELECT  email, average_visit_date
	FROM
    (SELECT * , date_dif/2 as average_visit_date
       FROM
		(SELECT * , 
			(AVG(nth_second_most_ - nth_first_most_)
				Over(PARTITION BY user_id) ) AS date_dif
					FROM
					(SELECT *, 
						NTH_VALUE(visit_date, 2) 
							OVER(PARTITION BY user_id ORDER BY user_id, days
								RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS nth_second_most_ ,
						NTH_VALUE(visit_date, 1) 
							OVER(PARTITION BY user_id ORDER BY user_id,days
								RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS nth_first_most_
                                FROM
									(SELECT * ,
										COUNT(user_id)
											OVER(PARTITION BY user_id) AS count_
									
		FROM CTE_main_ )  AS Q1 ) as Q2 ) AS Q3) AS Q4 WHERE count_ >= 2 AND email LIKE '%@gmail.com%'
          Group by user_id, date_dif
        -- or use Right((email,10) to get @gmail.com assumig good data quality 





















