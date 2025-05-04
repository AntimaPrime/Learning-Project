--Checking that tables were imported correctly

select *
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

select *
from [Portfolio Project]..CovidVacc
order by 3,4
 
 --Quick order by for relevant information

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
order by 1,2

-- Total cases vs. total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases*100) DeathRate
from [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2

-- Total cases vs. Population

select location, date, total_cases, population, (total_cases/population*100) CovidRates
from [Portfolio Project]..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2

-- Countries with highest infection rate

select location, population, max(total_cases) MaxCases, max((total_cases/population))*100 CovidRates
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location, population
order by CovidRates desc

-- Countries with highest death count per population

select location, max(cast(Total_Deaths as int)) TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Seperated by continent

select location, max(cast(Total_Deaths as int)) TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Global Numbers

-- By date

select date, sum(new_cases) tot_cases, sum(cast(new_deaths as int)) tot_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentages
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Overall

select sum(new_cases) tot_cases, sum(cast(new_deaths as int)) tot_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentages
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Note: Day 

-- Join tables coviddeaths and covidvacc

select *
from [Portfolio Project]..CovidDeaths death
join [Portfolio Project]..CovidVacc vac
	on death.location = vac.location
	and death.date = vac.date

--Total Population  vs Vaccinations

select death.continent, vac.location, death.date, death.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) Sum_of_Vaccinations
from [Portfolio Project]..CovidDeaths death
join [Portfolio Project]..CovidVacc vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by 2,3

-- Using CTE

with PopVsVac (Continent, location, date, population, new_vaccinations, sum_of_vaccinations)
as 
(
select death.continent, vac.location, death.date, death.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) Sum_of_Vaccinations
from [Portfolio Project]..CovidDeaths death
join [Portfolio Project]..CovidVacc vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
--order by 2,3
)

select *, sum_of_vaccinations/population*100 as VaccPercent
from PopVsVac

-- Using Temp Table

drop table if exists #VacPercent
create table #VacPercent
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Sum_of_Vaccinations numeric
)

Insert into #VacPercent
select death.continent, vac.location, death.date, death.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) Sum_of_Vaccinations
from [Portfolio Project]..CovidDeaths death
join [Portfolio Project]..CovidVacc vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by 2,3

select *, sum_of_vaccinations/population*100 as VaccPercent
from #VacPercent

-- Creating view for visualizations

create view VacPercent as
select death.continent, vac.location, death.date, death.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) Sum_of_Vaccinations
from [Portfolio Project]..CovidDeaths death
join [Portfolio Project]..CovidVacc vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null

select *
from VacPercent