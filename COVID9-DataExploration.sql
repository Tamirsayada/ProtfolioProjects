SELECT *
from CovidDeaths
order by 1,2

-- show which county had the most vacs per day 

SELECT location,max(cast(new_vaccinations as int)) as top_vac
from [project COVID9]..CovidVaccinations
where continent is not null
group by  location
order by 2 desc

-- show which county had the most vacs 

SELECT location,sum(cast(new_vaccinations as bigint)) as top_vac
from [project COVID9]..CovidVaccinations
where continent is not null
group by  location
order by 2 desc

-- show which county had the most vacs per population

select distinct dea.location, population,
sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location)/population as vacs_per_population
from [project COVID9]..CovidVaccinations as vac
join [project COVID9]..CovidDeaths as dea
on dea.location = vac.location
and dea.date = vac.date
order by 3 desc

--Show which county had the most vacs per CASES

select distinct dea.location,
sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location)/SUM(dea.new_cases) over(partition by dea.location) as vacs_per_CASES
from [project COVID9]..CovidVaccinations as vac
join [project COVID9]..CovidDeaths as dea
on dea.location = vac.location
and dea.date = vac.date
order by 2 desc

--MAX INFECTED IN ONE DAY GLOBALY

SELECT TOP 1 DATE,SUM(NEW_CASES) AS TOTAL_NEW_CASES
from [project COVID9]..CovidDeaths
GROUP BY date
ORDER BY TOTAL_NEW_CASES DESC

-- SHOW TOTAL AVG REPRODUTION PER COUNTRY

SELECT location,AVG(cast(reproduction_rate as numeric)) as AVG_REPRODUTION
from [project COVID9]..CovidDeaths
group by location
order by 2 desc

--shows your chance to die in your country if you had COVID9

SELECT location, date ,total_cases,total_deaths,
(total_deaths/total_cases)*100 as death_precent 
from CovidDeaths
where location like 'israel'
order by 1,2

-- show what percentage of population had COVID

SELECT location, date ,total_cases,population,
(total_cases/population)*100 as COVID_precent 
from CovidDeaths
where location like 'israel'
order by 1,2

-- show in which country the infection rate is the higher by order

SELECT  location, max(total_cases) as highet_infected ,population,
max((total_cases/population))*100 as COVID_precent_infected
from CovidDeaths
group by location,population
order by COVID_precent_infected desc

--showing which country had the highest death count per population

SELECT  location, max(cast(total_deaths as int)) as total_death_count 
from CovidDeaths
where continent is not null
group by location,population
order by total_death_count desc

--showing which continent had the highest death count per population

SELECT  continent, max(cast(total_deaths as int)) as total_death_count 
from CovidDeaths
where continent is not null
group by continent
order by total_death_count desc

--the global numbers per date

SELECT  date ,sum(new_cases) sum_cases,sum(cast(new_deaths as int)) sum_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_precentage
from CovidDeaths
where continent is not null
group by date
order by death_precentage desc

--the precrntage of people that got vaccinat

select sum(cast(new_vaccinations_smoothed as int))/population
from CovidDeaths as dea
join CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location
group by population

