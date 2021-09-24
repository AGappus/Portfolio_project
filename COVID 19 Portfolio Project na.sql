select *
from CV19death
where continent is null


-------------
-- Looking at total cases vs total death 
-- Show likelihood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from CV19death
where location like 'Viet%'
order by 1,2

-- Looking at total cases vs population 
-- Show what percentage of population got covid 
select location, date, total_cases, total_deaths, (total_cases/population)*100 as deathpercentage
from CV19death
where location like 'Viet%'
order by 1,2

-- Looking at countries with hightest infection rate compared to population
select location, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as percentpopulationinfected
from CV19death
group by location
order by percentpopulationinfected desc

--Showing countries with highest death count per population 
select location, max(cast(total_deaths as int)) as totaldeathcount 
from CV19death
where continent is not null
group by location
order by totaldeathcount desc

--Let's break things down by continent 
select continent, max(cast(total_deaths as int)) as totaldeathcount
from CV19death
where continent is not null 
group by continent 
order by totaldeathcount desc


---Showing continents with the hightest death count per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from CV19death
where continent is not null 
group by continent 
order by totaldeathcount desc

---- Global numbers over the time
select date, sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
-- total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from CV19death
where continent is not null
group by date
order by 1,2

----death_percentage overall across the world
select sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
-- total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from CV19death
where continent is not null
order by 1,2

--LET'S EXPLORE COVID-VACCINE

--Looking a total population vs vaccinations
select DE.continent, DE.location, DE.date, DE.population, VA.new_vaccinations,
sum(cast(VA.new_vaccinations as int)) over (partition by DE.location order by DE.location, DE.date ) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
from CV19death as DE
join vaccination as VA
on DE.location = VA.location 
and DE.date = VA.date 
where DE.continent is not null
order by 2,3

--USE CTE
with PopvsVac  (continent, location, date, population, new_vaccinations, RollingpeopleVaccinated)
as 
(
select DE.continent, DE.location, DE.date, DE.population, VA.new_vaccinations,
sum(cast(VA.new_vaccinations as int)) over (partition by DE.location order by DE.location, DE.date ) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
from CV19death as DE
join vaccination as VA
on DE.location = VA.location 
and DE.date = VA.date 
where DE.continent is not null
)
select *, (RollingpeopleVaccinated/Population)*100 as PercentPopulationVac
from PopvsVac

-- TEMP TABLE 
DROP table if exists #PercentPopulationVac
create table #PercentPopulationVac
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric)

Insert into #PercentPopulationVac

select DE.continent, DE.location, DE.date, DE.population, VA.new_vaccinations,
sum(cast(VA.new_vaccinations as int)) over (partition by DE.location order by DE.location, DE.date ) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
from CV19death as DE
join vaccination as VA
on DE.location = VA.location 
and DE.date = VA.date 
select *, (RollingpeopleVaccinated/Population)*100 as PercentPopulationVac
from #PercentPopulationVac

--Creating view to store data for later visualizations 

Create view PercentPopulationVac as
select DE.continent, DE.location, DE.date, DE.population, VA.new_vaccinations,
sum(cast(VA.new_vaccinations as int)) over (partition by DE.location order by DE.location, DE.date ) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
from CV19death as DE
join vaccination as VA
on DE.location = VA.location 
and DE.date = VA.date 
where DE.continent is not null
--end
select *
from PercentPopulationVac