select * from ..Covid_deaths
where continent is not null
order by 3,4

--select * from ..covid_vaccinations
--order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from ..Covid_deaths
order by 1,2



-- total cases of infections vs the total death recorded in nigeria 

select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPerentage
from ..Covid_deaths
where location like 'Nigeria%'
order by 1,2 desc


-- total cases compared with the total population recorded
-- percentage of nigerian that got infected over time 

select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as PopulationInfected
from ..Covid_deaths
where location like 'Nigeria%'
order by 1,2


-- country with highest number of cases 

select continent,max(total_cases) as HighestInfectionCount
from ..Covid_deaths
--where location like 'Nigeria%'
group by continent, population

-- Countries with Highest Death count per Popolation
select location, Max(cast (total_deaths as int)) as TotalNoDeath
from ..Covid_deaths
--where location like 'Nigeria%'
where continent is not null
group by location
order by TotalNoDeath desc


-- breakdown

select location, Max(cast (total_deaths as int)) as TotalNoDeath
from ..Covid_deaths
where continent is null
group by location
order by TotalNoDeath desc

-- xx

select continent, Max(cast (total_deaths as int)) as TotalNoDeath
from ..Covid_deaths
where continent is not null
group by continent
order by TotalNoDeath desc

-- GLOBAL CASES

select sum(new_cases) as total_cases,sum(new_deaths ) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from ..Covid_deaths
--where location like 'Nigeria%'
WHERE continent is not null
-- group by date
order by 1,2

-- Total population vs  vaccination count 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from ..Covid_deaths dea
join ..covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2 asc


-- xx
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as CurrentTotalVaccinated
from ..Covid_deaths dea
join ..covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2 asc


-- xx Cte 

with PoponVac (continent, location, date, population,new_vaccinations, CurrentTotalVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as CurrentTotalVaccinated
from ..Covid_deaths dea
join ..covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (CurrentTotalVaccinated/population)*100
from PoponVac


-- Temp Table 

drop table if exists #percPopVac

create table #percPopVac
(
continent nvarchar(255),
location nvarchar(255), date datetime, population bigint, new_vaccination float, CurrentTotalVaccinated float)



insert into
#percPopVac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as CurrentTotalVaccinated
from ..Covid_deaths dea
join ..covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null


select *, (CurrentTotalVaccinated/population)*100
from #percPopVac




-- View for later visuals

create view PercPopVac as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as CurrentTotalVaccinated
from ..Covid_deaths dea
join ..covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


-- xx

select * from PercPopVac