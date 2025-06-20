**Overview**
COVID-19 Data Exploration
This repository contains SQL queries used for exploring and analyzing COVID-19 death and vaccination data. 
The queries are designed to extract meaningful insights, including infection rates, death percentages, and vaccination progress across different locations and continents.

**Data Sources**
The SQL queries in this project utilize two primary tables:
Projects..CovidDeaths: Contains data related to COVID-19 cases, new cases, total deaths, and population.
Projects..CovidVaccinations: Contains data related to COVID-19 vaccinations, including new vaccinations.
SQL Queries and Analysis

**Below is a breakdown of the key SQL queries used for analysis:**
1. Initial Data Overview
CovidDeaths Table: Selects all records from the CovidDeaths table where the continent is not null, providing an initial look at the death data.
SQL
select *
from Projects..CovidDeaths
where continent is not null
order by 3,4
Core Data Selection: Selects essential columns like location, date, total_cases, new_cases, total_deaths, and population for primary analysis.
SQL
select location, date , total_cases, New_cases, total_deaths, population
from Projects..CovidDeaths
order by 1,2


2.** Death Percentage Calculation**
Total Cases vs. Total Deaths: Calculates the percentage of deaths relative to total cases for a specific location (e.g., Bangladesh), showing the lethality of the virus.
SQL
select location, date , total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Projects..CovidDeaths
where location like '%Bangladesh%'
order by 1,2


3. Infection Rate Analysis
Total Cases vs. Population: Determines the percentage of the population that has been infected in a specific location (e.g., Bangladesh).
SQL
select location, date , total_cases, population,(total_cases/population)*100 as InfectedPercentage
from Projects..CovidDeaths
where location like '%Bangladesh%'
order by 1,2


**Countries with Highest Infection Rate: Identifies countries with the highest infection rates compared to their population,1 providing a comparative view of disease spread.
SQL**  
select location, population,max(total_cases)as HighestInfectionCount,max(total_cases/population)*100 as InfectedPercentage
from Projects..CovidDeaths
group by location,population
order by InfectedPercentage desc


4. Death Count Analysis
Highest Death Count per Population (Country Level): Shows the total death count for each country, excluding continental aggregates, to highlight countries most affected by fatalities.
SQL
select location, MAX(cast(total_deaths as int))as TotalDeathCount
from Projects..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


Total Death Count by Continent: Breaks down the total death count by continent (represented as location where continent is null in the dataset) to understand the global distribution of fatalities.
SQL
select location, MAX(cast(total_deaths as int))as TotalDeathCount
from Projects..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


5. Global Numbers
Overall Global Death Percentage: Calculates the global total cases, total deaths, and the overall death percentage across all countries where continent data is available.
SQL
select   sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Projects..CovidDeaths
where continent is not null
order by 1,2


6. Population vs. Vaccination Analysis
Rolling People Vaccinated (using CTE): Utilizes a Common Table Expression (CTE) to calculate the rolling sum of vaccinations, showing the progress of vaccination campaigns over time for each location.
SQL
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
        where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


Rolling People Vaccinated (using Temp Table): Demonstrates the same vaccination analysis using a temporary table, providing an alternative approach to managing intermediate results.
SQL
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
    Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
            sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
            dea.date) as RollingPeopleVaccinated
    from Projects..CovidDeaths dea
    join Projects..CovidVaccinations vac
        on dea.location = vac.location
        and dea.date = vac.date
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


7. View for Visualization
PercentPopulationVaccinated View: Creates a SQL view to store the results of the rolling vaccination analysis, making it easier to access and use this data for later visualization tools (e.g., Tableau, Power BI).
SQL
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
            sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
            dea.date) as RollingPeopleVaccinated
    from Projects..CovidDeaths dea
    join Projects..CovidVaccinations vac
        on dea.location = vac.location
        and dea.date = vac.date
where dea.continent is not null
You can query this view directly:
SQL
select * from PercentPopulationVaccinated
