 -- Details covered in SQL
-- Finding total no of approved loans 

select 
count(claim_status)  as approved_claims
from insurance_data.tax_account
where CLAIM_STATUS = 'approved'   ;

-- Finding total no of loan denied

Select
 count(claim_status)  as denied_claims
from insurance_data.tax_account
where CLAIM_STATUS = 'denied'   ;

-- Total claims made and claims approved per month
SELECT 
    EXTRACT(MONTH FROM TXN_DATE_TIME) AS month,
    COUNT(CASE WHEN CLAIM_STATUS = 'approved' THEN 1 END) AS total_approved_claims,
    COUNT(CASE WHEN CLAIM_STATUS IS NOT NULL THEN 1 END) AS total_claims
FROM 
    insurance_data.tax_account
GROUP BY 
     EXTRACT(MONTH FROM TXN_DATE_TIME)
ORDER BY   month;

-- Percentage of loan approved
Select
  round((a.approved_claims/10000)*100,2) as  percentage_approved
from (
select
 count(claim_status)  as approved_claims
from
 insurance_data.tax_account
where CLAIM_STATUS = 'approved' ) as a ;

-- Percentage of loan denied
select 
 round((a.approved_claims/10000)*100,2) as  percentage_denied
from (
select 
count(claim_status)  as approved_claims
from 
insurance_data.tax_account
where CLAIM_STATUS = 'denied' ) as a ;

-- People applied for loan more than once and are approved
 Select
 CUSTOMER_NAME, count(claim_status) as claims
From
 insurance_data.tax_account
group by CUSTOMER_NAME
having count(claim_status) >1 ;


-- All details related to the loan approved
Select 
 txn_date_time,claim_status, customer_name
 acct_number,INCIDENT_CITY, incident_severity,
 authority_contacted, any_injury, incident_time,
 agent_id,vendor_id
from
 insurance_data.tax_account
where CLAIM_STATUS= 'approved';

-- No of insurance claims per city
select tax_account.incident_city  ,count(tax_account.TXN_DATE_TIME) as repetettive_claims
from insurance_data.tax_account 
group by INCIDENT_CITY;

--All details related to customer
Select
  c.TXN_DATE_TIME,c.customer_name, c.city, c .age, c.MARITAL_STATUS, c.TENURE,
c. RISK_SEGMENTATION, c.NO_OF_FAMILY_MEMBERS,c.HOUSE_TYPE, c.any_injury, c.incident_severity, c.claim_status,c.agent_id, c.vendor_id,d. premium_amount, d.claim_amount
from(
select a.TXN_DATE_TIME,a.customer_name, a.city, a.age, a.MARITAL_STATUS, a.TENURE,
a. RISK_SEGMENTATION, a.NO_OF_FAMILY_MEMBERS,a.HOUSE_TYPE, b.any_injury, b.incident_severity,
 b.claim_status,b.agent_id, b.vendor_id
from insurance_data.customer_detail as a
inner join insurance_data.tax_account as b
on a.TXN_DATE_TIME = b.txn_date_time) as c
inner join insurance_data.insurance_info as d
on c.TXN_DATE_TIME = d.TAX_DATE;
-- Time taken for claim approval
SELECT  tax_date,
    DATEDIFF(  STR_TO_DATE(report_date, '%d-%m-%Y')  ,STR_TO_DATE(loss_date, '%d-%m-%Y')) as claim_days
FROM 
    insurance_data.insurance_info ;

--Nunber of agents associated  with each vendor
SELECT b. VENDOR_ID, COUNT(a.AGENT_ID) AS Total_Agents
FROM     insurance_data.employee_data as a
    inner join insurance_data.vendor_data as b
    on a.POSTAL_CODE= b.POSTAL_CODE
WHERE 
    AGENT_ID is not null
GROUP BY VENDOR_ID;
--  Claims approved and denied per city and date
     SELECT
        tax_account.TXN_DATE_TIME AS dates,
        tax_account.incident_city AS city,
		COUNT(tax_account.claim_status) AS claim_made,
        SUM(CASE WHEN tax_account.claim_status = 'approved' THEN 1 ELSE 0 END) AS claim_approved, 
        SUM(CASE WHEN tax_account.claim_status = 'denied' THEN 1 ELSE 0 END) AS claim_denied  
    FROM
        insurance_data.tax_account
    GROUP BY
        tax_account.TXN_DATE_TIME, 
        tax_account.incident_city;

-- Agent  ids associated with each vendor
SELECT b. VENDOR_ID, COUNT(a.AGENT_ID) AS Total_Agents
FROM 
    insurance_data.employee_data as a
    inner join insurance_data.vendor_data as b
    on a.POSTAL_CODE= b.POSTAL_CODE
WHERE 
    AGENT_ID is not null
GROUP BY VENDOR_ID;

-- Claims approved and denied with each agent id
    SELECT    agent_id, 
    COUNT(CASE WHEN CLAIM_STATUS = 'approved' THEN 1 END) AS approved_count,
    COUNT(CASE WHEN CLAIM_STATUS = 'denied' THEN 1 END) AS denied_count
FROM     insurance_data.tax_account
GROUP BY   agent_id
ORDER BY     agent_id desc;
-- Claim amount and claim days as per insurance type 
SELECT 
    INSURANCE_TYPE, 
    SUM(CLAIM_AMOUNT) AS Total_Claim_Amount, 
    AVG(DATEDIFF(STR_TO_DATE(report_date, '%d-%m-%Y'), STR_TO_DATE(loss_date, '%d-%m-%Y'))) AS Avg_Claim_Days
FROM 
    insurance_data.insurance_info
GROUP BY 
    INSURANCE_TYPE
ORDER BY 
    Total_Claim_Amount DESC;

--Top 10 agents with highest claimed amount

SELECT   c.agent_id, 
   COUNT(DISTINCT c.customer_name) AS customer_count,
    SUM(c.claim_amount) AS total_claim_amount
FROM (
    SELECT   a.TXN_DATE_TIME,    a.customer_name,   b.agent_id,    b.claim_status,      d.claim_amount
    FROM 
        insurance_data.customer_detail AS a
    INNER JOIN 
        insurance_data.tax_account AS b
    ON 
        a.TXN_DATE_TIME = b.txn_date_time
    INNER JOIN 
        insurance_data.insurance_info AS d
    ON 
        b.txn_date_time = d.tax_date
) AS c
WHERE   
c.claim_status = 'Approved'
GROUP BY 
  c.agent_id
ORDER BY 
  total_claim_amount DESC;


--Top  10 vendors with highest claim given

select  VENDOR_NAME, sum(claim_amount) as Amt_claimed
from insurance_data.vendor_data as a
inner join insurance_data.insurance_info as b
on a.TAX_DATE= b.TAX_DATE
group by VENDOR_NAME;


--   Finding anomalities in approved loans

select a.INCIDENT_CITY, (a.AUTHORITY_CONTACTED) ,a.VENDOR_ID
from (
select txn_date_time,claim_status, customer_name
 acct_number,INCIDENT_CITY, incident_severity,
 authority_contacted, any_injury, incident_time,
 agent_id,vendor_id
from insurance_data.tax_account
where CLAIM_STATUS= 'approved')as a
where INCIDENT_CITY = " "
or AUTHORITY_CONTACTED = "none"
or vendor_id = "NA";









