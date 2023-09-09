--Looking at Total Cases vs total Deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) 
from PortfolioProject..CovidDeaths
order by 1, 2

--Alter table PortfolioProject..CovidDeaths alter column total_cases float;
-- shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1, 2

-- looking at the total cases ve the population
-- shows what percentage of population got covid
select location, date, total_cases, population, total_cases,  (total_cases/population) * 100 as Percentagepopulationaffected
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highestinfection, max((total_cases/population))*100 as Percentagepopulationaffected
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
group by location, population
order by Percentagepopulationaffected desc

--showing the countries with the highest death count per population
select location, max(total_deaths) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
group by location
order by totaldeathcount desc

select location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by location
order by totaldeathcount desc

-- lets break this down by continents
-- gives incorrect figures
select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by continent
order by totaldeathcount desc

-- gives correct figures
select location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is null
group by location
order by totaldeathcount desc

-- showing the continenets with the highest death count per population

select continent, max(total_deaths) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers
select date, sum(new_cases) -- total_deaths, (total_deaths/total_cases) 
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

select date, sum(new_cases), sum(new_deaths) -- total_deaths, (total_deaths/total_cases) 
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

-- looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--alter table PortfolioProject..CovidDeaths alter column location nvarchar(50)
--alter table PortfolioProject..CovidVaccinations alter column new_vaccinations bigint or used sum(convert(int, vac.new_vaccinations))
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--alter table PortfolioProject..CovidDeaths alter column location nvarchar(50)
--alter table PortfolioProject..CovidVaccinations alter column new_vaccinations bigint or used sum(convert(int, vac.new_vaccinations))
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--USE CTE| common table expression

With PopvsVac (continent, Location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--alter table PortfolioProject..CovidDeaths alter column location nvarchar(50)
--alter table PortfolioProject..CovidVaccinations alter column new_vaccinations bigint or used sum(convert(int, vac.new_vaccinations))
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, convert(float, (rollingpeoplevaccinated/population)*100)
from PopvsVac

--temp table
Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from #percentpopulationvaccinated

-- creating view to store data for later vsiualisations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated
