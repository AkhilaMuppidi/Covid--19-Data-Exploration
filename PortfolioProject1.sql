/*
COVID 19 Data Exploration

Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting data types

*/

--Looking at tables in dataset

SELECT *
FROM PortfolioProject1..[Covid deaths]
ORDER BY 3,4

SELECT *
FROM PortfolioProject1.dbo.[Covid Vaccinations]
ORDER BY 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..[Covid deaths]
Where continent is not null 
order by 1,2


--Total Cases vs Total Deaths
--Tells us the probability of dying, if we contract COVID in your country

SELECT Location, Date,total_cases,total_deaths,(CONVERT(float, total_deaths) / CONVERT(float, total_cases))*100 as DeathPercentage
FROM PortfolioProject1..[Covid deaths]
WHERE Location = 'India'
ORDER BY 1,2

--Total Cases vs Population
--Tells us the percentage of people contracted with covid 

SELECT Location, Date, total_cases, population, (CONVERT(float, total_cases) / population)*100 as InfectedPercentage
FROM PortfolioProject1..[Covid deaths]
WHERE Location LIKE '%Ind%'
ORDER BY 1,2

--Determining countries with highest infection rates against population

SELECT Location, population, Max(convert(float, total_cases)) As Max_cases_country, (Max(CONVERT(int,total_cases)) / population)*100 as HighestInfectionRate
FROM PortfolioProject1..[Covid deaths]
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestInfectionRate DESC

--Countries with highest death count against population

SELECT Location, max(Convert(float, total_deaths)) As Max_deaths_country
FROM PortfolioProject1..[Covid deaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Max_deaths_country DESC


--Showing continents with the highest death count 

SELECT continent, Max(Convert(int, total_deaths)) As Total_death_counts
FROM PortfolioProject1..[Covid deaths]
WHERE continent is not null
GROUP BY continent
ORDER By Total_death_counts DESC

--Showing GLOBAL numbers of new cases and new deaths per day

SELECT Date, Sum(new_deaths) As TotalNewdeaths, Sum(new_cases) As TotalNewCases
FROM PortfolioProject1..[Covid deaths]
WHERE continent is not null
GROUP BY Date
ORDER BY TotalNewCases DESC

--Death percentage of new cases per day globally

SELECT Date,  Sum(new_deaths) As TotalNewDeaths, Sum(new_cases) As TotalNewCases,
(sum(new_deaths) / CASE WHEN sum(new_cases) = 0 Then 1 Else sum(new_cases) END)*100 As DeathPercentage 
FROM PortfolioProject1..[Covid deaths]
Where continent is not null
GROUP BY Date
ORDER BY DeathPercentage


--GLOBAL death percentage

SELECT Sum(new_deaths) As TotalNewDeaths, Sum(new_cases) As TotalNewCases,
(sum(new_deaths) / CASE WHEN sum(new_cases) = 0 Then 1 Else sum(new_cases) END)*100 As DeathPercentage 
FROM PortfolioProject1..[Covid deaths]
Where continent is not null 
ORDER BY DeathPercentage DESC

--Total populations vs vaccinations
--Shows vaccination count including multipe doses and booster doses

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_Vaccinations As float))
Over (partition by dea.Location Order by dea.date) As RollingVaccinations
FROM PortfolioProject1..[Covid deaths] dea
     JOIN PortfolioProject1..[Covid Vaccinations] Vac
ON dea.location = Vac.location and
dea.date = vac.date
WHERE dea.continent is not null

--Using CTE to perform Calculation on Partition By in previous query

With CTERollingVaccinations As(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_Vaccinations As float))
Over (partition by dea.Location Order by dea.date) As RollingVaccinations
FROM PortfolioProject1..[Covid deaths] dea
     JOIN PortfolioProject1..[Covid Vaccinations] Vac
ON dea.location = Vac.location and
dea.date = vac.date
WHERE dea.continent is not null
)

SELECT location,population, Max(RollingVaccinations) As MaxVaccinations
FROM CTERollingVaccinations
Group by location,population
ORDER BY MaxVaccinations DESC

--Using Temp Table to perform Calculation on Partition by in previous query

DROP TABLE if exists #TotVacPerDay
CREATE TABLE #TotVacPerDay(
Continent nvarchar(150),
Location nvarchar(150),
Date DateTime,
Population float,
Vaccinations float,
Rolling_Vaccinations float
)

INSERT INTO #TotVacPerDay 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_Vaccinations As float))
Over (partition by dea.Location Order by dea.date) As RollingVaccinations
FROM PortfolioProject1..[Covid deaths] dea
     JOIN PortfolioProject1..[Covid Vaccinations] Vac
ON dea.location = Vac.location and
dea.date = vac.date
WHERE dea.continent is not null

SELECT date, SUM(Rolling_Vaccinations) As TotVacPerDay
FROM #TotVacPerDay
GROUP BY date
Order by 1

--Creating view to save data for later visualizations

CREATE VIEW TotalDeathCount As
SELECT continent, Max(Convert(int, total_deaths)) As Total_death_counts
FROM PortfolioProject1..[Covid deaths]
WHERE continent is not null
GROUP BY continent

CREATE VIEW TotalVacsbyDay As
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_Vaccinations As float))
Over (partition by dea.Location Order by dea.date) As RollingVaccinations
FROM PortfolioProject1..[Covid deaths] dea
     JOIN PortfolioProject1..[Covid Vaccinations] Vac
ON dea.location = Vac.location and
dea.date = vac.date
WHERE dea.continent is not null

CREATE VIEW DeathPercentage As
SELECT Location, Date,total_cases,total_deaths,(CONVERT(float, total_deaths) / CONVERT(float, total_cases))*100 as DeathPercentage
FROM PortfolioProject1..[Covid deaths]
WHERE Location = 'India'











 


