#looking at total cases v/s total deaths
#shows likelyhood of dying if you contract covid in your country
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentageDeath  from CovidDeaths
where location like '%state%' and  TRIM(continent) <> ''
 order by 1,2;
 
 # Shows what percentage of population got covid in the world 
 Select Location,date,total_cases,population,(total_cases/population)*100 as Percentage_Population_Infected  from CovidDeaths WHERE TRIM(continent) <> ''
#where location like '%state%'
 order by 1,2;
#Looking at countries with highest infection rate compared to population
select location,Population,max(total_cases) as highestInfectionCases, Max((total_cases/population)) as Population_Infected_Percentage from Coviddeaths
WHERE TRIM(continent) <> ''
group by location,population
order by Population_Infected_Percentage desc;

# showing countries with the highest death count
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotaldeathCount
FROM Coviddeaths
WHERE TRIM(continent) <> ''
GROUP BY location
ORDER BY TotalDeathCount DESC;
# showing highest death rate continent wise
SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS TotaldeathCount
FROM Coviddeaths
WHERE TRIM(continent) <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;
# showing highest death rate location wise
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotaldeathCount
FROM Coviddeaths
WHERE TRIM(continent) = ''
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- SELECT DISTINCT continent
-- FROM Coviddeaths
-- WHERE TRIM(continent) <> '';

# showing highest death rate continent wise
SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS TotaldeathCount
FROM Coviddeaths
WHERE TRIM(continent) = ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;

#Global Numbers
Select Sum(new_cases)as total_new_cases,sum(new_deaths) as total_new_deaths,Sum(new_deaths)/Sum(new_cases)*100 as deathpercase #total_cases,total_deaths,(total_deaths/total_cases)*100 
#as Percentage_Death
from CovidDeaths 
WHERE TRIM(continent) <> ''
#where location like '%state%'
#group by date
 order by 1,2;
 
 select * from coviddeaths dea join covid_vaccinations vac
 on dea.date=vac.date and dea.location=vac.location;
 #total Population v/s vaccinations
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
 from Coviddeaths dea 
 join covidvaccinations vac on dea.location = vac.location 
 and dea.date=vac.date WHERE TRIM(dea.continent) <> ''
order by 2,3;
 



#USE CTE
With popvsvac ( Continent,Location,Date,Population,new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from Coviddeaths dea 
 join covidvaccinations vac on dea.location = vac.location 
 and dea.date=vac.date WHERE TRIM(dea.continent) <> ''
order by 2,3
)
  select * ,(RollingPeopleVaccinated/Population)*100 from popvsvac;
  
  
  #temptable
  Drop table if exists PercentagePeopleVaccinated;
  CREATE TEMPORARY TABLE PercentagePeopleVaccinated (
  Continent Nvarchar(255),
  Location Nvarchar(255),
  Date DateTime,
  Population Numeric,
  New_Vaccinations Numeric,
  RollingPeopleVaccinated numeric
  );
  
  INSERT INTO PercentagePeopleVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  COALESCE(NULLIF(vac.new_vaccinations, ''), NULL), -- Replace empty strings with 0
  SUM(COALESCE(NULLIF(vac.new_vaccinations, ''), Null)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Coviddeaths dea
JOIN covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE TRIM(dea.continent) <> '';
  select * ,(RollingPeopleVaccinated/Population)*100 from PercentagePeopleVaccinated ;
  
  
  create View PercentagePopulationVaccinated as
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations , sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinations
 from Coviddeaths dea 
 join covidvaccinations vac on dea.location = vac.location 
 and dea.date=vac.date WHERE TRIM(dea.continent) <> ''
