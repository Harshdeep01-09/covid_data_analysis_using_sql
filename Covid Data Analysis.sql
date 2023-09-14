select *
from portfolioProject..CovidDeaths$
where continent is not null
order by 3,4 


--select *
--from portfolioProject..CovidVaccinations$
--order by 3,4 


select location, date , total_cases , new_cases, total_deaths, population
from portfolioProject..CovidDeaths$
where continent is not null
order by 1,2


-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract in the country
select location, date , total_cases , total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from portfolioProject..CovidDeaths$
where location like '%india%'
and continent is not null
order by 1,2


-- looking at the total cases vs population
--shows the population that got affected
select location, date , total_cases , population,(total_cases/population)*100 as infected_Percentage
from portfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
order by 1,2


-- looking at countries with highest infection rate compared to population
select location , MAX(total_cases) as highestInfectionCount , population,MAX((total_cases/population))*100 as affected_Percentage
from portfolioProject..CovidDeaths$
--where location like '%india%'
group by location, population
order by affected_Percentage desc




-- showing countries with the highest death count
select location , MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null 
group by location, population
order by totaldeathcount desc



-- breaking things by continent
 select location , MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioProject..CovidDeaths$
--where location like '%india%'
where continent is null 
group by location
order by totaldeathcount desc

--specifically continent
select continent , MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null 
group by continent
order by totaldeathcount desc

 

-- global numbers
select  date , SUM(new_cases)as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases) *100 as deathPercentage
from portfolioProject..CovidDeaths$
--where location like '%india%'
where  continent is not null
group by date
order by deathPercentage desc


select  location , SUM(new_cases)as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases) *100 as deathPercentage
from portfolioProject..CovidDeaths$
--where location like '%india%'
where  continent is not null
group by location
order by deathPercentage desc


select SUM(new_cases)as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases) *100 as deathPercentage
from portfolioProject..CovidDeaths$
--where location like '%india%'
where  continent is not null
--group by location
order by deathPercentage desc




-- looking at total population vs vaccination


select * 
from portfolioProject..CovidDeaths$ dea
join portfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date






-- Using CTE to perform Calculation on Partition By in previous query



with PopvsVac(continent, location, date , population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject..CovidDeaths$ dea
join portfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)
select * 
from PopvsVac 



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioProject..CovidDeaths$ dea
Join portfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

--Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioProject..CovidDeaths$ dea
Join portfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
