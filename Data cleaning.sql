-- 1. Show all candidate details
select * from layoffs;
-- 2.create a duplicate table
create table layoff_staging 
like layoffs;
-- 3 insert values from original table into duplicate table
insert into layoff_staging 
select * from layoffs;
-- 4 used a CTE and windows function to find duplicates
with duplicate_cte as (select *,row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,
funds_raised_millions) as row_num 
from layoff_staging)
select * from duplicate_cte where row_num > 1;
-- 5 created another dulicate table to make the window function into a column
CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
   `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- 5 insert values into the other duplicate table
insert into layoff_staging2 
select *,row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,
funds_raised_millions) as row_num 
from layoff_staging;
-- 6 deleted the duplicate rows
delete from layoff_staging2 where row_num > 1;
-- 7 comparing the data with inconsistency and the trimmed data
select company, trim(company) from layoff_staging2;
-- 8 removing spaces for data standardization 
update layoff_staging2
set company = trim(company); 
-- 9 updating industries of similar fields into one
update layoff_staging2 
set industry = "Crypto"
where industry like "Crypto%";
-- 10 trying to find inconsistency in country column
select distinct country from layoff_staging2
order by 1;
-- 11 updating inconsistency by trimming
update layoff_staging2 
set country = trim(trailing '.' from country)
where country like 'United States%';
-- 12 updating the date column into mm/dd/yyyy format
update layoff_staging2
set date = str_to_date(date,'%m/%d/%Y')
where `date` != 'null';
-- 13 changing data type from text to date
alter table layoff_staging2
modify column `date` Date;
-- 14 joining tables to find null or blank values to populate them
select *  from layoff_staging2 t1 join layoff_staging2 t2
on t1.company = t2.company 
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;
-- 15 populating null or blank values with the help of similar information present in the table
update layoff_staging2 t1 join layoff_staging2 t2
set t1.industry = t2.industry 
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;
-- 16 deleting rows with null values
delete from layoff_staging2
where total_laid_off is null and percentage_laid_off is null;
-- dropping the windows column "row_num"
alter table layoff_staging2
drop column row_num;
