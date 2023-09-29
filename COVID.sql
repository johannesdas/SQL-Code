-- Calculate a 'Death Percentage' of those who are infected. Order by location (country) and date.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Calculate a 'Infection Percentage' of total population by location (country). Order by location (country) and date.

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Calculate highest rates of infection by country. Order by highest to lowest Infection Rate.

SELECT location, population, MAX(total_cases) AS TotalCases, MAX(total_cases/population)*100 AS HighestInfectionRate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Calculate percentage of population which has died from COVID. Order by highest to lowest Death Rate.

SELECT location, population, MAX(total_deaths) AS TotalDeaths, MAX(total_deaths/population)*100 AS HighestDeathRate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Same as above but view is by Continent and/or Income Class rather than by Country.

SELECT location, MAX(total_deaths) AS TotalDeaths, MAX(total_deaths/population)*100 AS HighestDeathRate
FROM CovidProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 3 DESC

-- Total deaths and Death Rate across the entire world.

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL AND (new_cases != 0)
ORDER BY 1

-- Calculate a rolling total for vaccinated population. Displays both rolling total and rolling percentage of population.

DROP TABLE IF EXISTS #PopulationVaccinated
CREATE TABLE #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationTotal numeric
)

INSERT INTO #PopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
	SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingVaccinationTotal	
FROM CovidProject..CovidDeaths AS DEA
JOIN CovidProject..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (RollingVaccinationTotal/Population)*100 AS RollingVaccinationPercentage
FROM #PopulationVaccinated

-- CREATION OF A VIEW
CREATE VIEW PopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
	SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingVaccinationTotal	
FROM CovidProject..CovidDeaths AS DEA
JOIN CovidProject..CovidVaccinations AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *
FROM PopulationVaccinated

SELECT location, date, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, date, population
ORDER BY 5 DESC