# Major_League_Baseball
Advanced SQL querying techniques are used to track how player statistics have changed over time and across different teams in Major League Baseball (MLB). The dataset includes information such as schools attended, salaries, teams played for, height, weight, and more.

# Main objective

- What schools do MLB players attend?

- How much do teams spend on player salaries?

- What does each player’s career look like?

- How do player attributes compare?


## Data Dictionary

### Table: players

| Column Name   | Data Type     | Description                                                                 |
|---------------|---------------|------------|
| playerID      | VARCHAR(20)   | Unique identifier for each player (Primary Key).                            |
| birthYear     | INT           | Year the player was born.                                                  |
| birthMonth    | INT           | Month the player was born.                                                |
| birthDay      | INT           | Day the player was born.                                                  |
| birthCountry  | VARCHAR(50)   | Country where the player was born.                                        |
| birthState    | VARCHAR(50)   | State where the player was born.                                          |
| birthCity     | VARCHAR(50)   | City where the player was born.                                           |
| deathYear     | INT           | Year the player passed away (if applicable).                              |
| deathMonth    | INT           | Month the player passed away (if applicable).                             |
| deathDay      | INT           | Day the player passed away (if applicable).                               |
| deathCountry  | VARCHAR(50)   | Country where the player passed away (if applicable).                     |
| deathState    | VARCHAR(50)   | State where the player passed away (if applicable).                       |
| deathCity     | VARCHAR(50)   | City where the player passed away (if applicable).                        |
| nameFirst     | VARCHAR(50)   | First name of the player.                                                 |
| nameLast      | VARCHAR(50)   | Last name of the player.                                                  |
| nameGiven     | VARCHAR(100)  | Full given name of the player (first, middle, last).                      |
| weight        | INT           | Weight of the player in pounds.                                           |
| height        | INT           | Height of the player in inches.                                           |
| bats          | CHAR(1)       | Player's batting hand: 'R' = right, 'L' = left, 'B' = both.               |
| throws        | CHAR(1)       | Player's throwing hand: 'R' = right, 'L' = left.                          |
| debut         | DATE          | Date when the player made their major league debut.                       |
| finalGame     | DATE          | Date when the player played their last game.                              |
| retroID       | VARCHAR(20)   | Retroactive ID used by Baseball Reference.                                |
| bbrefID       | VARCHAR(20)   | Baseball Reference ID for the player.                                     |

---

### Table: salaries

| Column Name   | Data Type     | Description                                                                 |
|---------------|---------------|--------|
| yearID        | INT           | The year of the salary record (e.g., 1985).                                 |
| teamID        | VARCHAR(3)    | The three-letter team abbreviation (e.g., 'ATL' for Atlanta).              |
| lgID          | VARCHAR(2)    | The league identifier (e.g., 'NL' for National League, 'AL' for American League). |
| playerID      | VARCHAR(20)   | Unique identifier for the player (foreign key referencing `playerID` in the `players` table). |
| salary        | INT           | The salary of the player for the corresponding year, in dollars.           |

---

### Table: schools

| Column Name   | Data Type     | Description                                                                 |
|---------------|---------------|------|
| playerID      | VARCHAR(50)   | Unique identifier for each player (foreign key referencing `playerID` in the `players` table). |
| schoolID      | VARCHAR(50)   | Unique identifier for the school (foreign key referencing `schoolID` in the `school_details` table). |
| yearID        | INT           | The year the player attended the school (e.g., 2001).                      |

---

### Table: school_details

| Column Name   | Data Type     | Description                                                                 |
|---------------|---------------|----------------------------------------------|
| schoolID      | VARCHAR(50)   | Unique identifier for each school (Primary Key).                           |
| name_full     | VARCHAR(100)  | Full name of the school (e.g., 'Abilene Christian University').            |
| city          | VARCHAR(50)   | City where the school is located (e.g., 'Abilene').                        |
| state         | VARCHAR(2)    | Two-letter abbreviation of the state where the school is located (e.g., 'TX'). |
| country       | VARCHAR(50)   | Country where the school is located (e.g., 'USA').                         |

## Methodology and tools used
Tables

| Data Type     | Description                                                                 |
|---------------|---------------|
|First Exploratory Data Analysis & Joining Tables     | MS SQL Workbench |
|Data Cleaning, Advanced Exploratory Data Analysis & First Visualizations  |  |
|Advanced Data Visualizations & Dashboard    |     |

# Analysis 


### PART I: SCHOOL ANALYSIS

#### TASK 1: View the schools and school details tables
	SELECT * FROM schools;
	SELECT * FROM school_details;

Output:

![](https://i.imgur.com/89OIac7.png)

#### TASK 2: In each decade, how many schools were there that produced players? 
	SELECT 
		ROUND(yearID,-1) AS decade,
		COUNT(DISTINCT schoolID) AS num_schools
	FROM schools
	GROUP BY decade;

#### TASK 3: What are the names of the top 5 schools that produced the most players? [Joins]
	SELECT 
    	s.schoolID,
    	sd.name_full,
    	COUNT(DISTINCT s.playerID) AS num_players
	FROM schools s
	LEFT JOIN school_details sd  
    	ON s.schoolID = sd.schoolID
	GROUP BY s.schoolID
	ORDER BY num_players DESC
	LIMIT 5;

#### TASK 4: For each decade, what were the names of the top 3 schools that produced the most players? [Window Functions]
	WITH ds AS (
    	SELECT 
        		ROUND(s.yearID, -1) AS decade,
        		sd.name_full,
        		COUNT(DISTINCT s.playerID) AS num_players
    	FROM schools s
    	LEFT JOIN school_details sd  
        		ON s.schoolID = sd.schoolID
    	GROUP BY 
			ROUND(s.yearID, -1), 
			sd.name_full)

	SELECT decade, name_full, rank_number
	FROM(
    	SELECT *,
           	ROW_NUMBER() OVER (PARTITION BY decade ORDER BY num_players DESC) AS 	rank_number 
    	FROM ds
	) a
	WHERE rank_number < 4
	ORDER BY decade DESC, rank_number;

### PART II: SALARY ANALYSIS

#### TASK 1: View the salaries table
	SELECT * FROM salaries;

#### TASK 2: Return the top 20% of teams in terms of average annual spending 
	WITH ts AS (
		SELECT 
			teamID, 
			yearID, 
    		SUM(salary) AS total_spend
		FROM salaries
		GROUP BY teamID, yearID),
	sp AS(
		SELECT teamID, 
			AVG(total_spend) AS avg_spend,
        	NTILE(5) OVER (ORDER BY AVG(total_spend) DESC) AS spend_pct -- Divide teams into 5 groups based on avg spend: 1 = top 20% 
		FROM ts 
		GROUP BY teamID)

		SELECT	teamID, ROUND(avg_spend / 1000000, 1) AS avg_spend_millions
		FROM	sp
		WHERE	spend_pct = 1;

#### TASK 3: For each team, show the cumulative sum of spending over the years 
	WITH ts AS (
		SELECT 
			teamID, 
    		yearID, 
    		sum(salary) AS total_spend 
		FROM salaries
		GROUP BY teamID, yearID)

	SELECT 
		teamID, 
		yearID, 
		ROUND(SUM(total_spend) OVER (PARTITION BY teamID ORDER BY yearID) / 1000000, 1) AS cumulative_sum_millions
	FROM ts


#### TASK 4: Return the first year that each team's cumulative spending surpassed 1 billion [Min / Max Value Filtering]
	WITH ts AS(
		SELECT 
			teamID, 
    		yearID, 
    		sum(salary) AS total_spend 
		FROM salaries
		GROUP BY teamID, yearID),

	cs AS(
		SELECT 
			teamID, 
			yearID, 
			SUM(total_spend) OVER (PARTITION BY teamID ORDER BY yearID) AS cumulative_sum
		FROM ts),
	rn AS(
		SELECT 
			teamID, 
    		yearID, 
    		cumulative_sum, 
    		ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY cumulative_sum) as rn 
		FROM cs
		WHERE cumulative_sum > 1000000000)

	SELECT 
		teamID, 
    	yearID, 
    	ROUND(cumulative_sum / 1000000000,2) AS cumulative_sum_billions
	FROM rn 
	WHERE rn = 1;

### PART III: PLAYER CAREER ANALYSIS

#### TASK 1: View the players table and find the number of players in the table
	SELECT * FROM players;
	SELECT COUNT(*) FROM players;

#### TASK 2: For each player, calculate their age at their first (debut) game, their last game, and their career length (all in years). Sort from longest career to shortest career. 

	SELECT 
		nameGiven, 
		CAST(CONCAT (birthYear, '-', birthMonth, '-', birthDay) AS DATE) AS birthdate,
		TIMESTAMPDIFF(YEAR, CAST(CONCAT (birthYear, '-', birthMonth, '-', birthDay) AS DATE), debut) as starting_age,
    	TIMESTAMPDIFF(YEAR, CAST(CONCAT (birthYear, '-', birthMonth, '-', birthDay) AS DATE), finalGame) as end_age,
    	TIMESTAMPDIFF(YEAR, debut, finalGame) AS career_length
	FROM players;


#### TASK 3: What team did each player play on for their starting and ending years? 

	SELECT 
		p.nameGiven,
		s.yearID AS starting_year, s.teamID AS starting_team,
    	e.yearID AS ending_year, e.teamID AS ending_team
	FROM players p
	INNER JOIN salaries s
		ON p.playerID = s.playerID
    	AND year(p.debut) = s.yearID
	INNER JOIN salaries e
		ON p.playerID = e.playerID
    	AND year(p.finalGame) = e.yearID


#### TASK 4: How many players started and ended on the same team and also played for over a decade? 

	SELECT 
		p.nameGiven,
		s.yearID AS starting_year, s.teamID AS starting_team,
    	e.yearID AS ending_year, e.teamID AS ending_team
	FROM players p
	INNER JOIN salaries s
		ON p.playerID = s.playerID
    	AND year(p.debut) = s.yearID
	INNER JOIN salaries e
		ON p.playerID = e.playerID
    	AND year(p.finalGame) = e.yearID
	WHERE s.teamID = e.teamID and e.yearID - s.yearID >10;

Output:
![](https://i.imgur.com/89OIac7.png)

### PART IV: PLAYER COMPARISON ANALYSIS

#### TASK 1: View the players table
	SELECT * FROM players;

Output:

![](https://i.imgur.com/89OIac7.png)

#### TASK 2: Which players have the same birthday? Hint: Look into GROUP_CONCAT / LISTAGG / STRING_AGG [String Functions]

	WITH bn AS(
		SELECT 
			CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE) AS birthdate,
			nameGiven
		FROM players)
	SELECT 
		birthdate, 
		GROUP_CONCAT(nameGiven SEPARATOR ', ') AS players
	FROM bn 
	WHERE YEAR(birthdate) BETWEEN 1980 AND 1990
	GROUP BY birthdate
	ORDER BY birthdate

Output:

![](https://i.imgur.com/89OIac7.png)

#### TASK 3: Create a summary table that shows for each team, what percent of players bat right, left and both 

	SELECT	
		s.teamID,
		ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_right,
        ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_left,
        ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_both
	FROM	salaries s 
	LEFT JOIN players p
		ON s.playerID = p.playerID
	GROUP BY s.teamID;

Output:

![](https://i.imgur.com/89OIac7.png)

#### TASK 4: How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference? 

	WITH hw AS(
		SELECT
    		ROUND(YEAR(debut), -1) AS decade, 
    		AVG(height) AS avg_height,
    		AVG(weight) AS avg_weight
		FROM players
		GROUP BY decade )

	SELECT 
		decade, 
		avg_height - LAG(avg_height) OVER(ORDER BY decade) AS height_diff,
		avg_weight - LAG(avg_weight) OVER(ORDER BY decade) AS weight_diff
	FROM hw
	WHERE decade IS NOT NULL;

Output:

![](https://i.imgur.com/89OIac7.png)



