
--Select *
--From CovidProject..CovidDeaths$
--order by 3,4

--Select *
--From CovidProject..CovidVaccinations$
--order by 3,4

-- Change Column Data Types in CovidDeaths Table
--Alter Table [dbo].[CovidDeaths$]
--Alter column total_cases float
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column total_deaths float
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column total_cases_per_million float
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column total_deaths_per_million float
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column reproduction_rate float
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column icu_patients BIGINT
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column icu_patients_per_million float
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column hosp_patients BIGINT
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column hosp_patients_per_million float
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column weekly_icu_admissions BIGINT
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column weekly_icu_admissions_per_million float
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column weekly_hosp_admissions BIGINT
--GO
--Alter Table [dbo].[CovidDeaths$]
--Alter column weekly_hosp_admissions_per_million float
--GO


-- Select Data That we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths$
Where location like '%United%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
Where location like '%United%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
Group by Location, Population
-- Where location like '%states%'
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as TotalDeathCount
From CovidProject..CovidDeaths$
WHERE continent is NOT NULL
Group by Location
order by TotalDeathCount desc

-- Broken down by Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
Where continent is null
group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidProject..CovidDeaths$
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Looking at Total Population vs Vaccinations
-- Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
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
, SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PerecntPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *
From PerecntPopulationVaccinated