-- 1 show all the information 
select * from layoff_staging2;
-- 2 company wise highest laid off, percentage laid off
select company,max(total_laid_off),max(percentage_laid_off) from layoff_staging2
group by company;
-- 3 companies that went completely under sorted by funds raised
select * from layoff_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;
-- 4 sum of total laid off by each company
select company,sum(total_laid_off) from layoff_staging2
group by company
order by sum(total_laid_off) desc;
-- 5 layoff period
select min(`date`),max(`date`) from layoff_staging2;
-- 6 sum of layoffs in each industry
select industry,sum(total_laid_off) from layoff_staging2
group by industry;
-- 7 sum of layoff by countries
select country,sum(total_laid_off) from layoff_staging2
group by country
order by 2 desc;
-- 8 sum of layoffs in each year
select year(`date`),sum(total_laid_off) from layoff_staging2
group by year(`date`)
order by 1 desc;
-- 9 rolling sum of total laid of based on months
with rolling_total as (select substring(`date`,1,7) as `month`,sum(total_laid_off) as total_off from layoff_staging2
where substring(`date`,1,7) 
group by `month`
order by 1 asc
)
select `month`,total_off,sum(total_off) over(order by `month` asc) as rolling_total
 from rolling_total;
-- 10 su of total laid off by companies and years
select company,year(`date`),sum(total_laid_off) from layoff_staging2
group by company,year(`date`)
order by 3 desc;
-- 11 top 5 companies with the highest layoffs in each year
with company_year as (select company,year(`date`) as years,sum(total_laid_off) as total_laid_off 
from layoff_staging2 group by company,year(`date`)),company_year_rank as (select *,dense_rank() over (partition by years order by total_laid_off desc)
as rank_num from company_year where years is not null)
select * from company_year_rank 
where rank_num <= 5;













