CREATE DATABASE pivotedb;
USE pivotedb;

--Create temporary movies table

CREATE TABLE #Movies(
  MovieId INT PRIMARY KEY,
  Title VARCHAR(255),
  Gener VARCHAR(50),
  Director VARCHAR(50),
  ReleaseYear INT
); 

--Insert sample data into the #Movies table

INSERT INTO #Movies(MovieId, Title, Gener, Director, ReleaseYear) VALUES(1, 'The Matrix', 'Sci-Fi', 'Wachowski', 1999),
																		(2, 'The Shwashank Redemption', 'Drama', 'Frank Darabont', 1994),
																		(3, 'Pulp Fiction', 'Crime', 'Quentin Tarantino', 1994),
																		(4, 'Inception', 'Sci-Fi', 'Christopher Nolan', 2010),
																		(5, 'Forest Gump', 'Drama', 'Robert Zemeckis', 1994),
																		(6, 'The Dark Knight', 'Action', 'Christopher Nolan', 2008),
																		(7, 'Titanic', 'Romance', 'James Cameron', 1997),
																		(8, 'Avatar', 'Sci-Fi', 'James Cameron', 2009),
																		(9, 'Fight Club', 'Drama', 'David Fincher', 1999),
																		(10, 'Gladiator', 'Action', 'Ridley Scott', 2000);


SELECT * FROM #Movies;
-- How many movies in each genre were released per year?

SELECT * 
FROM (SELECT ReleaseYear , Gener FROM #Movies) AS Source
PIVOT (COUNT(Gener)
        FOR Gener IN ([Sci-Fi], Drama, Crime, Action, Romance)) AS PVT
ORDER BY ReleaseYear;


SELECT ReleaseYear 
      , Sum(CASE WHEN Gener = 'Sci-Fi' THEN 1 ELSE 0 END) AS [Sci-Fi]
	  , SUM(CASE WHEN Gener = 'Drama' THEN 1 ELSE 0 END) AS Drama
	  , SUM(CASE WHEN Gener = 'Crime' THEN 1 ELSE 0 END) AS Crime
	  , SUM(CASE WHEN Gener = 'Action' THEN 1 ELSE 0 END) AS Action
	  , SUM(CASE WHEN Gener = 'Romance' THEN 1 ELSE 0 END) AS Romance
FROM #Movies
GROUP BY ReleaseYear
ORDER BY ReleaseYear;

