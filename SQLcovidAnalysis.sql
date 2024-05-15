select*
from PortfolioProject..CovidDeaths
order by 3,4

--select*
--from PortfolioProject..CovidVacc
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

 --Check total cases vs total deaths
 --Shows likelihood of dying if you contract covid in Australia in 1st year
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'australia'
order by 1,2

-- Check total cases vs population
-- Shows what percentage of population got covid in Australian in 1st year
select location, date, population,total_cases,(total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where location like 'australia'
order by 1,2

-- Check countries with highest infection rate compared to population
select location, population, max(total_cases)as HighestInfectionCount,max((total_cases/population))*100 as CasesPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by  CasesPercentage desc

-- Check countries with highest death rate compared to population 
select location, population, max(cast(total_deaths as int))as HighestDeathCount,max((cast(total_deaths as int)/population))*100 as HighestDeathRate
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by HighestDeathRate desc

--Check which continent has the highest death number
select continent, max(cast(total_deaths as int)) as MaxTotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by  MaxTotalDeathCount desc

--Global numbers of death percentage

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by total_cases

--Check total population vs Covid-vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

-- CTE

With PopvsVac (continent, location,date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
	on dea.location= vac.location
	and dea.date= vac.date
--where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated


--Create view to store data for later visualizaitons
create view NewPercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null







