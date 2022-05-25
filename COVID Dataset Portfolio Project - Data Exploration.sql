/* 
Covid 19 Data exploration
The 2 tables are CovidDeaths and CovidVaccinations
Skills used Joins, CTE's, Temp tables, Windows functions, Aggregate funtions, Creting views, Coverting Data types
*/

SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidVaccinations

SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_percen
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Singapore'
ORDER BY 5 DESC

-- Total cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 5 DESC

--showing countries with highest death counts per population

SELECT location, MAX(cast (total_deaths as int)) AS TotalDeathCounts
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

-- View continents with the highest death counts per population

SELECT continent, MAX(cast (total_deaths as int)) AS TotalDeathCounts
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

-- Total cases vs population

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2

-- Countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--View contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--View Total population vs vaccinations

SELECT SUM(CAST(vac.people_vaccinated as float))/SUM(CAST(dea.population as float))* 100
FROM PortfolioProject..CovidVaccinations AS vac
INNER JOIN PortfolioProject..CovidDeaths AS dea
ON dea.location = vac.location and vac.date = dea.date
WHERE dea.population is not null and vac.people_vaccinated is not null

--View percentage of population that has recived at least one covid vaccination.

SELECT dea.continent, dea.location, dea.date, dea.population, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations AS vac
INNER JOIN PortfolioProject..CovidDeaths AS dea
	ON dea.location = vac.location 
	and vac.date = dea.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- Creating a CTE
With Popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations AS vac
INNER JOIN PortfolioProject..CovidDeaths AS dea
	ON dea.location = vac.location 
	and vac.date = dea.date
WHERE dea.continent is not null 

)

SELECT *, (RollingPeopleVaccinated/population) * 100 
FROM Popvsvac

--Using Temp Table to perform calculations on Partition by in previous query

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations AS vac
INNER JOIN PortfolioProject..CovidDeaths AS dea
	ON dea.location = vac.location 
	and vac.date = dea.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated

--Creating view to store data 

CREATE VIEW PercentPopulationVaccinate AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations AS vac
INNER JOIN PortfolioProject..CovidDeaths AS dea
	ON dea.location = vac.location 
	and vac.date = dea.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinate
