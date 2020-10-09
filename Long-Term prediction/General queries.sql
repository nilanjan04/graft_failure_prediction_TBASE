--Number of patients and number of transplantions
select  count(distinct p.patientid), count(*)	
from dbo.PATIENT_View p 
join dbo.Transplantation t
	on p.PatientID = t.PatientID
where year(t.datum) >= 2004 
	and (Ort like '%Charité Urologische Klinik%' or Ort like '%Berlin Charité-Mitte%' or Ort like '%Virchow%')
	and trim(t.organ) = 'Niere'
	and datediff(yyyy,p.Geburtsdatum,t.Datum) >= 18
	
	
	
--Number of patients and number of transplantations per age group and gender
select (datediff(yyyy,p.Geburtsdatum,t.Datum)/10)*20 as "Age"
		, p.Geschlecht as "Gender"
		, count(distinct p.patientid) as "NumberOfPatients"
		, count(*)	as "NumberOfTransplantations"
from dbo.PATIENT_View p 
join dbo.Transplantation t
	on p.PatientID = t.PatientID
where year(t.datum) >= 2004 
	and (Ort like '%Charité Urologische Klinik%' or Ort like '%Berlin Charité-Mitte%' or Ort like '%Virchow%')
	and trim(t.organ) = 'Niere'
	and datediff(yyyy,p.Geburtsdatum,t.Datum) >= 18
group by (datediff(yyyy,p.Geburtsdatum,t.Datum)/20)*20
		, p.Geschlecht
