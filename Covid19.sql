
select *
from PortofolioProject_Covid1..coviddeaths
where continent is not null
order by 3,4



--select *
--from PortofolioProject_Covid1..covidvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject_Covid1..coviddeaths
order by 1,2

--total cases vs total deaths
-- shows likelihood of dying in indonesia
select location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)) *100 as DeathPercentage
from PortofolioProject_Covid1..coviddeaths
where location like '%indonesia%'
--where continent is not null
order by 1,2


--total cases vs population
-- shows percentage of population got covid
select location, date, population, total_cases, (CONVERT(DECIMAL(18, 2), total_cases) / CONVERT(DECIMAL(18, 2), population)) *100 as CasesPercentage
from PortofolioProject_Covid1..coviddeaths
where location like '%Yemen%'
--where continent is not null
order by 1,2


-- the highest infections rate country vs population
select location, population, MAX(CONVERT(DECIMAL(18, 2),total_cases)) as HighestInfectionCountry , MAX(CONVERT(DECIMAL(18, 2),total_cases/ CONVERT(DECIMAL(18, 2),population))) *100 as PercentPopulationInfected
from PortofolioProject_Covid1..coviddeaths
--where location like '%indonesia%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc



--countries with the highest death count per population
select location, MAX(cast(total_deaths as dec)) as TotalDeathCount
from PortofolioProject_Covid1..coviddeaths
--where location like '%indonesia%'
where continent is not null
group by location
order by TotalDeathCount desc


--break down the total deaths by continent

select continent, MAX(cast(total_deaths as dec)) as TotalDeathCount
from PortofolioProject_Covid1..coviddeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- continents with the highest death count per population

select continent, MAX(cast(total_deaths as dec)) as TotalDeathCount
from PortofolioProject_Covid1..coviddeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers

select date, sum(CONVERT(DECIMAL(18, 2),new_cases)) as newcases, sum(CONVERT(DECIMAL(18, 2),new_deaths)) as newdeaths, 
sum(CONVERT(DECIMAL(18, 2),new_deaths))/(sum(CONVERT(DECIMAL(18, 2),new_cases)))
from PortofolioProject_Covid1..coviddeaths
--where location like '%Yemen%'
where continent is not null
group by date
order by 1,2

SELECT date,
    SUM(CONVERT(DECIMAL(18, 2), new_cases)) AS newcases, 
    SUM(CONVERT(DECIMAL(18, 2), new_deaths)) AS newdeaths, 
    SUM(CONVERT(DECIMAL(18, 2), new_deaths)) / NULLIF(SUM(CONVERT(DECIMAL(18, 2), new_cases)), 0)*100 AS death_percentage
FROM 
    PortofolioProject_Covid1..coviddeaths
-- WHERE location LIKE '%Yemen%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 
    1,2;


--TOTAL POPULATION VS VACCINATIONS

with PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.location 
	order by DEA.LOCATION,dea.date)as RollingPeopleVaccinated
	--to see people who vaccinated in every country
	--(RollingPeopleVaccinated/population)*100
FROM PortofolioProject_Covid1..coviddeaths dea
JOIN PortofolioProject_Covid1..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMPORARY TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar (255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.location 
	order by DEA.LOCATION,dea.date)as RollingPeopleVaccinated
	--to see people who vaccinated in every country
	--(RollingPeopleVaccinated/population)*100
FROM PortofolioProject_Covid1..coviddeaths dea
JOIN PortofolioProject_Covid1..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated as
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.location 
	order by DEA.LOCATION,dea.date)as RollingPeopleVaccinated
	--to see people who vaccinated in every country
	--(RollingPeopleVaccinated/population)*100
FROM PortofolioProject_Covid1..coviddeaths dea
JOIN PortofolioProject_Covid1..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3