select *
from PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data to be used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 1,2

--total cases vs total deaths
--shows likelihood of death if contracted in Nigeria
select location, 
	date, 
	total_cases, 
	total_deaths,
	CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (total_deaths / total_cases)*100 
    END AS death_rate
from PortfolioProject..CovidDeaths
where location like '%nigeria%' and continent is not NULL
order by 1,2

--looking for total cases per population

select location, 
	date, 
	total_cases, 
	population,
	CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (total_cases / population)*100 
    END AS infection_rate
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not NULL
order by 1,2

--looking at countries with highest infection rates

select location, 
	MAX(total_cases) AS highest_infection_count, 
	population,
	MAX((total_cases / population))*100 AS infection_rate
from PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not NULL
GROUP BY location, population
order by 4 DESC


--Showing highest death by  continents
select continent, 
	MAX(total_deaths) AS total_death_count
from PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not NULL
GROUP BY continent
order by 2 DESC

--Showing countries with highest death count

select location, 
	MAX(total_deaths) AS total_death_count
from PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not NULL
GROUP BY location
order by 2 DESC

--Showing highest death by  continents
select continent, 
	MAX(total_deaths) AS total_death_count
from PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not NULL
GROUP BY continent
order by 2 DESC

--GOBAL DATA
select date, 
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (Sum(new_deaths) / SUM(new_cases))*100 
    END AS death_rate
from PortfolioProject..CovidDeaths
where continent is not NULL and new_cases !=0
group by date
order by 1,2


select  
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (Sum(new_deaths) / SUM(new_cases))*100 
    END AS death_rate
from PortfolioProject..CovidDeaths
where continent is not NULL and new_cases !=0
order by 1,2

--Using Vaccination Table
Select *
from PortfolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population Vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL--and vac.new_vaccinations is not NULL
Order by 2,3

--use CTE to get people vaccinated/population
With PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL--and vac.new_vaccinations is not NULL
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

--Using Temporary Table 
DROP TABLE IF EXISTS #PercentPopulationVaccinated  
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not NULL--and vac.new_vaccinations is not NULL
--Order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating a view
CREATE View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortFolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL--and vac.new_vaccinations is not NULL