
select location, date, total_cases, new_cases,total_deaths,population
from coviddeaths
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying of covid
 select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as total_death_rate
 from coviddeaths
 where location = "Singapore"
 order by 1,2;

-- Total Cases vs Population
-- Shows the percentage of population getting covid
 select location, date, total_cases,(total_cases/population)*100 as total_cases_rate
 from coviddeaths
 where location = "Singapore"
 order by 1,2;
 
 -- Countries with highest infection rate
 select location,population, MAX(total_cases) as Highestinfectioncount,MAX((total_cases/population)*100) as Infection_rate
 from coviddeaths
 group by location,population
 order by Infection_rate desc;

 -- Top 10 countries with highest infection rate per population
 select location,population, MAX(total_cases) as Highestinfectioncount,MAX((total_cases/population)*100) as Infection_rate
 from coviddeaths
 group by location,population
 order by Infection_rate desc
 limit 10;
 
 -- Check data type of total_death columns
  SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'coviddeaths' and column_name='total_deaths';
  
  
  -- Countries with highest death count
 select location,MAX(cast(total_deaths as signed)) as Totaldeathcount
 from coviddeaths
 where continent <> ''
 group by location
 order by 2 desc;
  
  
  
  
 -- Countries with highest death rate per population
 -- Convert total_deaths into Integer
 
 select location,population,MAX(cast(total_deaths as signed)) as Totaldeathcount, MAX((total_deaths/population)*100) as Death_rate
 from coviddeaths
 where continent <> ''
 group by location,population
 order by 4 desc;
 
 
 
 -- Break down global numbers
 select date, sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as Deathpercentage
 from coviddeaths
 where continent <> ''
 group by date
 order by 1 desc; 
 
 -- Join
 select *
 from coviddeaths dea
 join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3;
 
 
 -- Join onto Vaccinations table
 -- Total Population vs Total Vaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 from coviddeaths dea
 join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3;
 
 -- Running Total
 -- Partition by location so that the count starts at a new location every time
 -- Order by location and date which separates out
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) 
 OVER (partition by dea.location order by dea.location, dea.date) as running_vaccinated_total
 from coviddeaths dea
 join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3;


-- Vaccination rate
-- Running_vaccinated_total/population
-- temp table

create temporary table vaccination
select
*
from(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) 
 OVER (partition by dea.location order by dea.location, dea.date) as running_vaccinated_total
 from coviddeaths dea
 join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3) as withrunningtotal;
 
 select *,(running_vaccinated_total/population)*100 as vaccination_rate
 from vaccination;
 