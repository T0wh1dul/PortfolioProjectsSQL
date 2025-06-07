select * 
from Projects..CovidDeaths
where continent is not null 
order by 3,4

--select * 
--from Projects..CovidVaccinations
--order by 3,4

select location, date , total_cases, New_cases, total_deaths, population
from Projects..CovidDeaths
order by 1,2



-- Total cases,Total Deaths and Percentage of death
select location, date , total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Projects..CovidDeaths
where location like '%Bangladesh%'
order by 1,2 



-- total cases vs population 
--showing Percentage of population got infected 
select location, date , total_cases, population,(total_cases/population)*100 as InfectedPercentage
from Projects..CovidDeaths
where location like '%Bangladesh%'
order by 1,2 



--Countries with Highest Infection rate compare to Population 
select location, population,max(total_cases)as HighestInfectionCount,max(total_cases/population)*100 as InfectedPercentage
from Projects..CovidDeaths
--where location like '%Bangladesh%'
group by location,population
order by InfectedPercentage desc




--Showing The countries with highest death count per population 
select location, MAX(cast(total_deaths as int))as TotalDeathCount
from Projects..CovidDeaths
where continent is not null 
--where location like '%Bangladesh%'
group by location
order by TotalDeathCount desc




-- LET's BREAK THINGS DOWN BY CONTINENT 
--Means Total death count by Continent
select location, MAX(cast(total_deaths as int))as TotalDeathCount
from Projects..CovidDeaths
where continent is null 
--where location like '%Bangladesh%'
group by location
order by TotalDeathCount desc



--- Global Numbers DeathPercentage
select   sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Projects..CovidDeaths
--where location like '%Bangladesh%'
where continent is not null
--group by date
order by 1,2




-- Looking at WORLD population vs vaccination 

--  CTE
With PopvsVac (Continent, Location , date , population, new_vaccinations,RollingPeopleVaccinated)
as 
(
	Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
			sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
			dea.date) as RollingPeopleVaccinated

	from Projects..CovidDeaths dea
	join Projects..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		--where dea.location like '%Bangladesh%'
		where dea.continent is not null
		--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac





--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,

)


insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
			sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
			dea.date) as RollingPeopleVaccinated

	from Projects..CovidDeaths dea
	join Projects..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		--where dea.location like '%Bangladesh%'
		--where dea.continent is not null
		--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


---creating date to store for later Visualization
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
			sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
			dea.date) as RollingPeopleVaccinated

	from Projects..CovidDeaths dea
	join Projects..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		--where dea.location like '%Bangladesh%'
where dea.continent is not null
		--order by 2,3

select * from PercentPopulationVaccinated