select *
from PortfolioProject..['Covid Vaccinations$']
order by 3,4

select *
from PortfolioProject..['Covid Deaths$']
order by 3,4

select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject..['Covid Deaths$']
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
Where location like '%states%'
Order by 1,2


--Looking at Total Cases vs Population
--Shows the percentage of population got Covid

Select location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['Covid Deaths$']
Where location like '%states%'
Order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

Select location, MAX(total_cases) as HighestInfectionCount, population,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc




--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing Continents with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc;



--GLOBAL NUMBERS
--Group By date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
--Where location like '&states%'
Where continent is not null
Group By date
Order By 1,2


--Total Global Cases

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
--Where location like '&states%'
Where continent is not null
--Group By date
Order By 1,2



--Looking at Total Population vs Vaccination

Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.Location Order By Dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths$'] as dea
Join PortfolioProject..['Covid Vaccinations$'] as vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.Location Order By Dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] as dea
Join PortfolioProject..['Covid Vaccinations$'] as vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

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
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.Location Order By Dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] as dea
Join PortfolioProject..['Covid Vaccinations$'] as vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.Location Order By Dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] as dea
Join PortfolioProject..['Covid Vaccinations$'] as vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3


Select *
From PercentPopulationVaccinated