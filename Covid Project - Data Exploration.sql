
Select *
 From PortfolioProject..CovidDeaths
 where continent is not null
  order by 3,4


--********************************************************************************
-- Global Numbers 
 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
		SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 --Where location like '%Angola%'
 Where continent is not null
 --Group by date
 order by 1,2

 Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 -- Where location like '%Angola%'
 where continent is null
 and location not in ('World', 'European Union', 'International')
 Group by location
 order by TotalDeathCount desc

 -- Countries with Highest Infection Rate Compared to Population
 Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 -- Where location like '%Angola%'
 Group by location, population
 order by PercentPopulationInfected desc

  Select Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 -- Where location like '%Angola%'
 Group by location, population, date
 order by PercentPopulationInfected desc
--********************************************************************************
Select Location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths
 where continent is not null
 order by 1,2

 -- Total Cases vs Total Deaths
 Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 Where location like '%Angola%'
 and continent is not null
 order by 1,2

 -- Total Cases vs Population
 Select Location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
 From PortfolioProject..CovidDeaths
 Where location like '%Angola%'
 and continent is not null
 order by 1,2

 -- Countries with Highest Death Count Compared to Population
 Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 -- Where location like '%Angola%'
 where continent is not null
 Group by location
 order by TotalDeathCount desc

 -- Continent with Highest Death Count per population
 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 where continent is not null
 Group by continent
 order by TotalDeathCount desc

-- Total Population vs Vaccinations
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
		--(RollingPeopleVaccinated/Population)*100
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccination vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

-- CTE
 With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated) 
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
				dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccination vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
From PopvsVac

-- Temp Table

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
		--(RollingPeopleVaccinated/Population)*100
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccination vac
		On dea.location = vac.location
		and dea.date = vac.date
--Where dea.continent is not null

Select *, 
(RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated



-- View to store data for data visualization

Create View PercentagePopulationVaccinated as 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
		--(RollingPeopleVaccinated/Population)*100
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccination vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null


IF EXISTS (SELECT 1 FROM SYS.objects WHERE NAME = 'HighestDeathCount' AND TYPE = 'V')
	BEGIN 
		DROP VIEW HighestDeathCount
	END 
GO

CREATE VIEW TotalDeathvsTotalcases as
	 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 Where continent is not null
 and total_deaths is not null


CREATE VIEW HighestInfectionRate as
 Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 -- Where location like '%Angola%'
   Where continent is not null
 Group by location, population


CREATE VIEW HighestDeathCount as
 Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 -- Where location like '%Angola%'
 where continent is not null
 Group by location
