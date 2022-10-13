SELECT * FROM 
PortfolioProject2..CovidDeaths;
  
SELECT * FROM 
PortfolioProject2..CovidVaccinations
ORDER by 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject2..CovidDeaths
ORDER by 1,2;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_Cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE location like '%india'
order by  1,2;

--SHows what percentage of population got covid
SELECT location, date, total_Cases,total_deaths, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject2..CovidDeaths
WHERE location like '%india'
order by  1,2;




--Looking at Countries with Highest Infection Rate compared to Population

SELECT location,  Population, MAX(total_cases) as HighesInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject2..CovidDeaths

GROUP BY location, population

order by PercentagePopulationInfected DESC

--Showing countries with highest death count per population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE continent is not null
GROUP by location
order by TotalDeathCount desc;


--Showing continents with highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE continent is not null
GROUP by continent
order by TotalDeathCount desc;


--GLOBAL NUMBERS

SELECT  date, SUM(new_cases)as total_case, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
where continent is not null
Group by date
order by 1,2

--total deaths

SELECT   SUM(new_cases)as total_case, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
where continent is not null
order by 1,2;


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
,(
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
order by 2,3

--USE CTE

With PopvsVac(Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(255),
location varchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null 

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations
DROP VIEW PercentPopulationVaccinated

CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated

