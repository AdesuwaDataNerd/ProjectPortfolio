create database Covid;
use Covid;

show tables;
#i imported the table withe the table import wizard but i stopped it so i have to delete the rows
#to use the LOAD INFILE
Load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Covid_deaths.csv" into table covid_deaths
fields terminated by','
lines terminated by '\n'
ignore 1 lines
(iso_code,continent,location,dates,population,total_cases,new_cases,
new_cases_smoothed,total_deaths,new_deaths,new_deaths_smoothed,total_cases_per_million,
new_cases_per_million,new_cases_smoothed_per_million,total_deaths_per_million,
new_deaths_per_million,new_deaths_smoothed_per_million,reproduction_rate,icu_patients,
icu_patients_per_million,hosp_patients,hosp_patients_per_million,weekly_icu_admissions,weekly_icu_admissions_per_million,
weekly_hosp_admissions,weekly_hosp_admissions_per_million);
desc covid_deaths;
#i had issues with the importation so i wrote these queries to fix it
change total_cases int character set utf8mb4 collate utf8mb4_unicode_ci;
select @@sql_mode;
set SQL_MODE='';
alter table covid_deaths modify total_cases int;
set global interactive_timeout=6000;
show global variables like'read_only';

show global variables like 'local_infile';
show variables like 'secure_file_priv';
set global local_infile=true;
drop database covid;



create database covid;
use covid;
show tables;
select * from covid_deaths;


#i imported the table withe the table import wizard but i stopped it so i have to delete the rows
#ro use the LOAD INFILE
select * from covidvaccinations;
truncate table covidvaccinations;
#Loading my file from my pc
Load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CovidVaccinations.csv" into table covidvaccinations
fields terminated by','
lines terminated by '\n'
ignore 1 lines
(iso_code,continent,location,dates,new_tests,total_tests,total_tests_per_thousand,new_tests_per_thousand,new_tests_smoothed,
new_tests_smoothed_per_thousand,positive_rate,tests_per_case,tests_units,total_vaccinations,people_vaccinated,people_fully_vaccinated,
total_boosters,new_vaccinations,new_vaccinations_smoothed,total_vaccinations_per_hundred,people_vaccinated_per_hundred,people_fully_vaccinated_per_hundred,
total_boosters_per_hundred,new_vaccinations_smoothed_per_million,new_people_vaccinated_smoothed,new_people_vaccinated_smoothed_per_hundred,
stringency_index,population_density,median_age,aged_65_older,aged_70_older,gdp_per_capita,extreme_poverty,cardiovasc_death_rate,
diabetes_prevalence,female_smokers,male_smokers,handwashing_facilities,hospital_beds_per_thousand,life_expectancy,human_development_index,excess_mortality_cumulative_absolute,
excess_mortality_cumulative,excess_mortality,excess_mortality_cumulative_per_million);


use covid;
select * from covid_deaths order by 3,4;
select * from covidvaccinations order by 3,4;

#SELECTING Data that i'm going to be using
select location, dates, total_cases, new_cases, total_deaths, population
from covid_deaths;


#toal cases vs total death
#it shows the likely hood of dying if you contact covid
select location, dates, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from covid_deaths
where location='united states';

#total cases vs population
#shows percentage of population with covid
select location, dates, total_cases, population, (total_cases/population)*100 as covidpercentage 
from covid_deaths
where location='Nigeria';



select location,max(total_cases) as highest_infection,population,max((total_cases/population))*100 as percentageinfected
from covid_deaths
#where location='Nigeria'
group by location,population
order by percentageinfected desc;

select continent,max(cast(total_deaths as signed int)) as highest_death
from covid_deaths
where continent is not null
#where location='Nigeria'
group by continent
order by highest_death desc;



#global numbers
select  sum(new_cases) as total_cases,sum(cast(new_deaths as signed int)) as total_deaths,sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from covid_deaths
where continent is  not null
#group by dates
order by 1,2;


#total popululation vaccinated
#i'd also use CTE
with popsvac(continent,location,dates,population,new_vaccinations,peoplevaccinated) as
(select dea.continent,dea.location,dea.dates,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as signed int)) over (partition by dea.location order by dea.location,dea.dates) as
peoplevaccinated
#(peoplevaccinated/population)*100)
from covid_deaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.dates = vac.dates
where dea.continent is not null)
select *,(peoplevaccinated/population)*100 from popsvac;


#Temp Table
create table percentage_population_vaccinated
(continent nvarchar(255),
location nvarchar(255),
dates date,
population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
);
drop table percentage_population_vaccinated;
insert into percentage_population_vaccinated
select dea.continent,dea.location,dea.dates,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.dates) as
peoplevaccinated
#(peoplevaccinated/population)*100)
from covid_deaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.dates = vac.dates;

select *,(peoplevaccinated/population)*100 from popsvac;


#creating view to store data for later visualization
create view populationvaccinatedpercent  as
select dea.continent,dea.location,dea.dates,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.dates) as
peoplevaccinated
#(peoplevaccinated/population)*100)
from covid_deaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.dates = vac.dates;populationvaccinatedpercent

