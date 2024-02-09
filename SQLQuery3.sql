Select *
From SQLProject..CovidDeaths
Order by 3,4



-- Looking at Total Cases Vs Total Deaths
Select Location, date, total_cases, total_deaths,  (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 as DeathPercentage
From SQLProject..CovidDeaths
Where Location like '%Bangladesh%'
Order by 1,2

-- Looking at Total Cases Vs Population
Select Location, date, total_cases, population,  (CONVERT(float, total_cases) / population) * 100 as CasePercentage
From SQLProject..CovidDeaths
Where Location like '%Bangladesh%'
Order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / population)) * 100 as
PercentPopulationInfected
From SQLProject..CovidDeaths
Group by Location, population
Order by PercentPopulationInfected desc

-- Looking into countries with highest death count per population

Select Location, population, Max(total_deaths) as HighestDeathCount, MAX((CONVERT(float, total_deaths) / population)) * 100 as
PercentPopulationDeath
From SQLProject..CovidDeaths
Where continent is not null
Group by Location, population
Order by PercentPopulationDeath desc

--showing location with the highest death count per population

Select location, Max(total_deaths) as HighestDeathCount
From SQLProject..CovidDeaths
Where continent is not null
Group by location
Order by HighestDeathCount desc

--showing continents with the highest death count per population

Select continent, MAX(total_deaths) as HighestDeathCount
From SQLProject..CovidDeaths
Where continent is not null
Group by continent
Order by HighestDeathCount desc

Select *
From SQLProject..CovidVaccinations
Order by 4 desc

--Looking at total population vs vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,SUM(CONVERT(float, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date)
as RollingPeopleVaccinated
From SQLProject..CovidDeaths cd
Join SQLProject..CovidVaccinations cv
On cd.location = cv.location
and cd.date = cv.date 
Where cd.continent is not null
Order by 2,3

--With CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,SUM(CONVERT(float, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date)
as RollingPeopleVaccinated
From SQLProject..CovidDeaths cd
Join SQLProject..CovidVaccinations cv
On cd.location = cv.location
and cd.date = cv.date 
Where cd.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 percentage
From PopvsVac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
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
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,SUM(CONVERT(float, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date)
as RollingPeopleVaccinated
From SQLProject..CovidDeaths cd
Join SQLProject..CovidVaccinations cv
On cd.location = cv.location
and cd.date = cv.date 
Where cd.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 percentage
From #PercentPopulationVaccinated

--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,SUM(CONVERT(float, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date)
as RollingPeopleVaccinated
From SQLProject..CovidDeaths cd
Join SQLProject..CovidVaccinations cv
On cd.location = cv.location
and cd.date = cv.date 
Where cd.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated
