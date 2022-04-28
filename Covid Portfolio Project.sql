SELECT *
FROM PortofolioProjects..CovidDeaths$
ORDER BY 3,4;

-- SELECT *
-- FROM PortofolioProjects..CovidVaccinations$
-- ORDER BY 3,4;

-- SELECT data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProjects..CovidDeaths$
ORDER BY 1,2;

-- Looking at Total Cases VS Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProjects..CovidDeaths$
WHERE location LIKE '%Mex%'
ORDER BY 1,2;

-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortofolioProjects..CovidDeaths$
WHERE location LIKE '%Mex%'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortofolioProjects..CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Showing Countries With Hieghest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProjects..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let's Break Things Down by continent

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProjects..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Showing contintents whith higthest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProjects..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT  SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, 
(SUM(CAST(new_deaths AS INT))/SUM(New_cases))*100 AS DeathPercentage
FROM PortofolioProjects..CovidDeaths$
WHERE continent is not null
--GROUP BY date 
ORDER BY 1,2;


-- Looking at Total population VS vaccionations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (partition by dea.location ORDER BY dea.location) AS RollingPeopleVaccionated
FROM PortofolioProjects..CovidDeaths$ dea
JOIN  PortofolioProjects..CovidVaccinations$ vac
	ON dea.location = vac.location AND 
	dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortofolioProjects..CovidDeaths$ dea
Join PortofolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortofolioProjects..CovidDeaths$ dea
JOIN PortofolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProjects..CovidDeaths$ dea
Join PortofolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
