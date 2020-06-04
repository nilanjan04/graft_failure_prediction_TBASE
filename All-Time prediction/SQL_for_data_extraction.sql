use tbase_import;

select  p.PatientID ,
		 t.TransplantationID 
		--Patient:
		, p.Geschlecht C_PatientGender_m
		, p.Blutgruppe as C_PatientBloodGroup
		, p.Koerpergroesse as N_PatientHeight
	    , grunderkr.C_Grunderkrankung_grouped
		, datediff(yyyy,p.Geburtsdatum,t.Datum) as N_PatientAge --Patient Age at date of transplantation
		, coalesce(case when datediff(yyyy,p.Datum_erste_Dialyse,t.Datum) < 0 then 0 else datediff(yyyy,p.Datum_erste_Dialyse,t.Datum) end, 0) as N_YearsBetweenTransplantationAndFirstDialysis -- changed NULLs into 0 because of preemtive transplants where patients have a donor readz and do not have to wait
		--Patient diagnoses:
		, coalesce(diag.PatientDiag_Harnweg,0) as O_PatientDiag_Harnweg
		, coalesce(diag.PatientDiag_Hypertonie ,0) as O_PatientDiag_Hypertonie 
		, coalesce(diag.PatientDiag_Infektionskrankheit ,0) as O_PatientDiag_Infektionskrankheit 
		, coalesce(diag.PatientDiag_Wegener,0) as O_PatientDiag_Wegener
		, coalesce(diag.PatientDiag_Anaemie,0) as O_PatientDiag_Anaemie
		, coalesce(diag.PatientDiag_Sepsis,0) as O_PatientDiag_Sepsis
		, coalesce(diag.PatientDiag_Immun,0) as O_PatientDiag_Immun
		, coalesce(diag.PatientDiag_Hyperkal,0) as O_PatientDiag_Hyperkal
		, coalesce(diag.PatientDiag_Hyperpara,0) as O_PatientDiag_Hyperpara
		, coalesce(diag.PatientDiag_DreiGefaessErkrankung,0) as O_PatientDiag_DreiGefaessErkrankung
		, coalesce(diag.PatientDiag_AnginaPectoris,0) as O_PatientDiag_AnginaPectoris
		, coalesce(diag.PatientDiag_Pneumo,0) as O_PatientDiag_Pneumo
		, coalesce(diag.PatientDiag_GastroEnteritis,0) as O_PatientDiag_GastroEnteritis
		, coalesce(diag.PatientDiag_Myokardinfarkt,0) as O_PatientDiag_Myokardinfarkt
		, coalesce(diag.PatientDiag_Mechanisch,0) as O_PatientDiag_Mechanisch
		, coalesce(diag.PatientDiag_Blutung,0) as O_PatientDiag_Blutung
		, coalesce(diag.PatientDiag_LupusErythematodes,0) as O_PatientDiag_LupusErythematodes
		, coalesce(diag.PatientDiag_GallenGangsVerschluss,0) as O_PatientDiag_GallenGangsVerschluss
		, coalesce(diag.PatientDiag_Diabetes,0) as O_PatientDiag_Diabetes
		, coalesce(diag.PatientDiag_Sphingolipidose,0) as O_PatientDiag_Sphingolipidose
		, coalesce(diag.PatientDiag_Hyperlipi,0) as O_PatientDiag_Hyperlipi
		, coalesce(diag.PatientDiag_Kolitis,0) as O_PatientDiag_Kolitis
		, coalesce(diag.PatientDiag_AortenStenose,0) as O_PatientDiag_AortenStenose
		, coalesce(diag.PatientDiag_Vorhoff,0) as O_PatientDiag_Vorhoff
		, coalesce(diag.PatientDiag_Hyperurik,0) as O_PatientDiag_Hyperurik
		, coalesce(diag.PatientDiag_Leberzirr,0) as O_PatientDiag_Leberzirr
		, coalesce(diag.PatientDiag_herzinsu,0) as O_PatientDiag_herzinsu
		, coalesce(diag.PatientDiag_Dyspn,0) as O_PatientDiag_Dyspn
		, coalesce(diag.PatientDiag_Mitralinsu,0) as O_PatientDiag_Mitralinsu
		, coalesce(diag.PatientDiag_Hyperchol,0) as O_PatientDiag_Hyperchol
		, coalesce(diag.PatientDiag_Volumenmangel,0) as O_PatientDiag_Volumenmangel
		, coalesce(diag.PatientDiag_Lupus,0) as O_PatientDiag_Lupus
		--Dialysetyp:
		, dial.TypeOfDialysis as C_PatientTypeOfDialysis
		--Transplant:
		--, year(t.Datum) as TransplantationYear -- Not needed
		, case when t.Ort like '%ircho%' then 'Virchow' else 'Mitte' end as C_PlaceOfTransplantation
		, case when t.Primaerfunktion like 'Ja' then 1 
	  			else 0
	  		 	end as O_primary_function_yes
	  	, case when t.Primaerfunktion like 'Nein' then 1 
	  	 		else 0
	  		 	end as O_primary_function_no
	  	, case when t.Empfaengerseite like '%rechts%' then 1 else 0 end as O_Receiver_side_rechts
	  	, case when t.Spenderorgan like '%rechts%' or t.Spenderorgan like '%beide%' then 1 else 0 end as O_Donor_side_rechts
	  	, case when t.Spenderorgan like '%links%' or t.Spenderorgan like '%beide%' then 1 else 0 end as O_Donor_side_links
	    , case when t.HbS_AG like '%pos%' or t.HbS_AG like '%+%' then 1 else 0 end as O_HbS_AG_pos
	    , case when t.HCV_AK like '%pos%' or t.HCV_AK like '%+%' then 1 else 0 end as O_HCV_AK_pos
	    , case when t.CMV_AK like '%pos%' or t.CMV_AK like '%+%' then 1 else 0 end as O_CMV_AK_pos
	    , t.PRA as N_PRA
	    , case when t.Dialyseart like '%CAPD%' then 1 else 0 end as O_Dialyseart_CAPD
	    , case when t.Dialyseart like '%HD%' then 1 else 0 end as O_Dialyseart_HD
	    , t.Ischaemie_kalt as N_Ischaemie_kalt
	    , t.MM_broad as N_MM_broad
	    , t.Anzahl as N_Number_of_prior_transplants
		--Donor:
		, case when s.Geschlecht like '%w%' or s.Geschlecht like '%u%' then 1 else 0 end as O_DonorGender_w
		, case when s.Geschlecht like '%m%' or s.Geschlecht like '%u%' then 1 else 0 end as O_DonorGender_m
		, s.Blutgruppe as C_DonorBloodGroup
		, SP_Alter as N_DonorAge --Donor Age at date of transplantation
		, case when len(trim(s.Todesursache)) < 2 then 1 else 0 end as O_Living_donor 
		, DCD.C_DonorCauseOfDeath_grouped 
	    , case when s.Spendergewicht > 150 or s.Spendergewicht < 40 then null else s.Spendergewicht end as N_DonorWeight 
	    , s.Spendergroesse as N_DonorHeight 
	    , case when len(trim(s.Spenderart))<2 or s.Spenderart is null then 'lebend(unbekannt)' else s.Spenderart end as C_Spenderart
	    --Donor_Laboratory:
	    , case when sl.hbsag like '%pos%' or sl.hbsag like '%+%' then 1 else 0 end as O_DonorHbsag_pos
	    , case when sl.cmvigg like '%pos%' or sl.cmvigg like '%+%' then 1 else 0 end  as O_DonorCmvigg_pos
	    , case when sl.hbcab like '%pos%' or sl.hbcab like '%+%' then 1 else 0 end  as O_DonorHbcab_pos
	    , case when sl.hcvak like '%pos%' or sl.hcvak like '%+%' then 1 else 0 end  as O_DonorHcvak_pos
	    , case when sl.hivak like '%pos%' or sl.hivak like '%+%' then 1 else 0 end  as O_DonorHivak_pos
	    , case when sl.hbcak like '%pos%' or sl.hbcak like '%+%' then 1 else 0 end  as O_DonorHbcak_pos
	    , case when sl.hcvab like '%pos%' or  sl.hcvab like '%+%' then 1 else 0 end as O_DonorHcvab_pos
	    , case when sl.hiv like '%pos%' or sl.hiv like '%+%' then 1 else 0 end  as O_DonorHiv_pos
	    , case when sl.antihcvetimport like '%pos%' or sl.antihcvetimport like '%+%' then 1 else 0 end  as O_DonorAntiHcvetImport_pos
	    , case when sl.hivabetimport like '%pos%' or sl.hivabetimport like '%+%' then 1 else 0 end  as O_DonorHivAbetImport_pos
	    , case when sl.acmviggse  like '%pos%' or sl.acmviggse  like '%+%' then 1 else 0 end as O_DonorAcmviggse_pos
	    , case when sl.luesetimport  like '%pos%' or sl.luesetimport  like '%+%' then 1 else 0 end as O_DonorLuesetImport_pos
	    , case when sl.hbsagetimport like '%pos%' or sl.hbsagetimport like '%+%' then 1 else 0 end  as O_DonorHbsagetImport_pos
	    , case when sl.antihcvse like '%pos%' or sl.antihcvse like '%+%' then 1 else 0 end  as O_DonorAntihcvse_pos
	    --TODO: Maybe more Donor Laboratory values?
	    --Dialysis required post transplantation
	    , COALESCE (d.dialyse_required_till_1_month, 0) as O_dialysis_req_post_transplant_1_month
	    , COALESCE (d.dialyse_required_till_2_months, 0) as O_dialysis_req_post_transplant_2_months
	    , COALESCE (d.dialyse_required_till_3_months, 0) as O_dialysis_req_post_transplant_3_months
	    , COALESCE (d.dialyse_required_till_4_months, 0) as O_dialysis_req_post_transplant_4_months
	    --, d.dialyse_required_till_5_months as dialysis_req_post_transplant_5_months
	    --, d.dialyse_required_till_6_months as dialysis_req_post_transplant_6_months
		--Lab values
		, Labvalue_Creatinine_mgdl_PostTransplant_1Months
		, Labvalue_Creatinine_mgdl_PostTransplant_2Months
		, Labvalue_Creatinine_mgdl_PostTransplant_3Months
		, Labvalue_Creatinine_mgdl_PostTransplant_4Months
		, Labvalue_Creatinine_mgdl_PostTransplant_5Months
		, Labvalue_Creatinine_mgdl_PostTransplant_6Months
		, Labvalue_Creatinine_mgdl_PostTransplant_AllTime
		, Labvalue_CRP_mgdl_PostTransplant_1Months
		, Labvalue_CRP_mgdl_PostTransplant_2Months
		, Labvalue_CRP_mgdl_PostTransplant_3Months
		, Labvalue_CRP_mgdl_PostTransplant_4Months
		, Labvalue_CRP_mgdl_PostTransplant_5Months
		, Labvalue_CRP_mgdl_PostTransplant_6Months
		, Labvalue_CRP_mgdl_PostTransplant_AllTime
		, Labvalue_Leuko_Blood_nl_PostTransplant_1Months
		, Labvalue_Leuko_Blood_nl_PostTransplant_2Months
		, Labvalue_Leuko_Blood_nl_PostTransplant_3Months
		, Labvalue_Leuko_Blood_nl_PostTransplant_4Months
		, Labvalue_Leuko_Blood_nl_PostTransplant_5Months
		, Labvalue_Leuko_Blood_nl_PostTransplant_6Months
		, Labvalue_Leuko_Blood_nl_PostTransplant_AllTime
		, Labvalue_Leuko_Urine_mgdl_PostTransplant_1Months
		, Labvalue_Leuko_Urine_mgdl_PostTransplant_2Months
		, Labvalue_Leuko_Urine_mgdl_PostTransplant_3Months
		, Labvalue_Leuko_Urine_mgdl_PostTransplant_4Months
		, Labvalue_Leuko_Urine_mgdl_PostTransplant_5Months
		, Labvalue_Leuko_Urine_mgdl_PostTransplant_6Months
		, Labvalue_Leuko_Urine_mgdl_PostTransplant_AllTime
		, Labvalue_Protein_Concentration_mgdl_PostTransplant_1Months
		, Labvalue_Protein_Concentration_mgdl_PostTransplant_2Months
		, Labvalue_Protein_Concentration_mgdl_PostTransplant_3Months
		, Labvalue_Protein_Concentration_mgdl_PostTransplant_4Months
		, Labvalue_Protein_Concentration_mgdl_PostTransplant_5Months
		, Labvalue_Protein_Concentration_mgdl_PostTransplant_6Months
		, Labvalue_Protein_Concentration_mgdl_PostTransplant_AllTime
		, Labvalue_Protein_DailyOutput_mgdl_PostTransplant_1Months
		, Labvalue_Protein_DailyOutput_mgdl_PostTransplant_2Months
		, Labvalue_Protein_DailyOutput_mgdl_PostTransplant_3Months
		, Labvalue_Protein_DailyOutput_mgdl_PostTransplant_4Months
		, Labvalue_Protein_DailyOutput_mgdl_PostTransplant_5Months
		, Labvalue_Protein_DailyOutput_mgdl_PostTransplant_6Months
		, Labvalue_Protein_DailyOutput_mgdl_PostTransplant_AllTime
		, Labvalue_Protein_Dipstick_mgdl_PostTransplant_1Months
		, Labvalue_Protein_Dipstick_mgdl_PostTransplant_2Months
		, Labvalue_Protein_Dipstick_mgdl_PostTransplant_3Months
		, Labvalue_Protein_Dipstick_mgdl_PostTransplant_4Months
		, Labvalue_Protein_Dipstick_mgdl_PostTransplant_5Months
		, Labvalue_Protein_Dipstick_mgdl_PostTransplant_6Months
		, Labvalue_Protein_Dipstick_mgdl_PostTransplant_AllTime
		--Proteine Turnover
		, case when protTUR.ProteinTUR_TransplantDate like '%pos%' or protTUR.ProteinTUR_TransplantDate like '%+%' then 1 else 0 end  as O_ProteinTUR_TransplantDate
		, case when protTUR.ProteinTUR_PostTransplant_1Month like '%pos%' or protTUR.ProteinTUR_PostTransplant_1Month like '%+%' then 1 else 0 end  as O_ProteinTUR_PostTransplant_1Month
		, case when protTUR.ProteinTUR_PostTransplant_2Months like '%pos%' or protTUR.ProteinTUR_PostTransplant_2Months like '%+%' then 1 else 0 end  as O_ProteinTUR_PostTransplant_2Months
		, case when protTUR.ProteinTUR_PostTransplant_3Months like '%pos%' or protTUR.ProteinTUR_PostTransplant_3Months like '%+%' then 1 else 0 end  as O_ProteinTUR_PostTransplant_3Months
		, case when protTUR.ProteinTUR_PostTransplant_4Months like '%pos%' or protTUR.ProteinTUR_PostTransplant_4Months like '%+%' then 1 else 0 end  as O_ProteinTUR_PostTransplant_4Months
		, case when protTUR.ProteinTUR_PostTransplant_5Months like '%pos%' or protTUR.ProteinTUR_PostTransplant_5Months like '%+%' then 1 else 0 end  as O_ProteinTUR_PostTransplant_5Months
		, case when protTUR.ProteinTUR_PostTransplant_6Months like '%pos%' or protTUR.ProteinTUR_PostTransplant_6Months like '%+%' then 1 else 0 end  as O_ProteinTUR_PostTransplant_6Months
		, case when protTUR.ProteinTUR_PostTransplant like '%pos%' or protTUR.ProteinTUR_PostTransplant like '%+%' then 1 else 0 end  as O_ProteinTUR_PostTransplant
		, case when protTUR.ProteinTUR_PreTransplant like '%pos%' or protTUR.ProteinTUR_PreTransplant like '%+%' then 1 else 0 end  as O_ProteinTUR_PreTransplant
		, case when protTUR.ProteinTUR_All_Time like '%pos%' or protTUR.ProteinTUR_All_Time like '%+%' then 1 else 0 end  as O_ProteinTUR_All_Time
		--Nitrit Turnover
		, case when nit.NitritTUR_TransplantDate like '%pos%' or nit.NitritTUR_TransplantDate like '%+%' then 1 else 0 end  as O_NitritTUR_TransplantDate
		, case when nit.NitritTUR_PostTransplant_1Month like '%pos%' or nit.NitritTUR_PostTransplant_1Month like '%+%' then 1 else 0 end  as O_NitritTUR_PostTransplant_1Month
		, case when nit.NitritTUR_PostTransplant_2Months like '%pos%' or nit.NitritTUR_PostTransplant_2Months like '%+%' then 1 else 0 end  as O_NitritTUR_PostTransplant_2Months
		, case when nit.NitritTUR_PostTransplant_3Months like '%pos%' or nit.NitritTUR_PostTransplant_3Months like '%+%' then 1 else 0 end  as O_NitritTUR_PostTransplant_3Months
		, case when nit.NitritTUR_PostTransplant_4Months like '%pos%' or nit.NitritTUR_PostTransplant_4Months like '%+%' then 1 else 0 end  as O_NitritTUR_PostTransplant_4Months
		, case when nit.NitritTUR_PostTransplant_5Months like '%pos%' or nit.NitritTUR_PostTransplant_5Months like '%+%' then 1 else 0 end  as O_NitritTUR_PostTransplant_5Months
		, case when nit.NitritTUR_PostTransplant_6Months like '%pos%' or nit.NitritTUR_PostTransplant_6Months like '%+%' then 1 else 0 end  as O_NitritTUR_PostTransplant_6Months
		, case when nit.NitritTUR_PostTransplant like '%pos%' or nit.NitritTUR_PostTransplant like '%+%' then 1 else 0 end  as O_NitritTUR_PostTransplant
		, case when nit.NitritTUR_PreTransplant like '%pos%' or nit.NitritTUR_PreTransplant like '%+%' then 1 else 0 end  as O_NitritTUR_PreTransplant
		, case when nit.NitritTUR_All_Time like '%pos%' or nit.NitritTUR_All_Time like '%+%' then 1 else 0 end  as O_NitritTUR_All_Time
		--Medications
		, case when med.Medik_A02B > 0 then Medik_A02B else 0 end as N_Medik_A02B
		, case when med.Medik_C03C > 0 then Medik_C03C else 0 end as N_Medik_C03C
		, case when med.Medik_C07A > 0 then Medik_C07A else 0 end as N_Medik_C07A
		, case when med.Medik_C08C > 0 then Medik_C08C else 0 end as N_Medik_C08C
		, case when med.Medik_H02AB > 0 then Medik_H02AB else 0 end as N_Medik_H02AB
		, case when med.Medik_L04AA > 0 then Medik_L04AA else 0 end as N_Medik_L04AA
		, case when med.Medik_L04AA02 > 0 then Medik_L04AA02 else 0 end as N_Medik_L04AA02
		, case when med.Medik_L04AA03 > 0 then Medik_L04AA03 else 0 end as N_Medik_L04AA03
		, case when med.Medik_L04AA04 > 0 then Medik_L04AA04 else 0 end as N_Medik_L04AA04
		, case when med.Medik_L04AA06 > 0 then Medik_L04AA06 else 0 end as N_Medik_L04AA06
		, case when med.Medik_L04AA08 > 0 then Medik_L04AA08 else 0 end as N_Medik_L04AA08
		, case when med.Medik_L04AA09 > 0 then Medik_L04AA09 else 0 end as N_Medik_L04AA09
		, case when med.Medik_L04AA10 > 0 then Medik_L04AA10 else 0 end as N_Medik_L04AA10
		, case when med.Medik_L04AA13 > 0 then Medik_L04AA13 else 0 end as N_Medik_L04AA13
		, case when med.Medik_L04AA18 > 0 then Medik_L04AA18 else 0 end as N_Medik_L04AA18
		, case when med.Medik_L04AD01 > 0 then Medik_L04AD01 else 0 end as N_Medik_L04AD01
		, case when med.Medik_L04AD02 > 0 then Medik_L04AD02 else 0 end as N_Medik_L04AD02
		, case when med.Medik_L04AA21 > 0 then Medik_L04AA21 else 0 end as N_Medik_L04AA21
		, case when med.Medik_L04AA23 > 0 then Medik_L04AA23 else 0 end as N_Medik_L04AA23
		, case when med.Medik_L04AA24 > 0 then Medik_L04AA24 else 0 end as N_Medik_L04AA24	
		--Verlauf
		, verlauf.Blutdruck_systolisch_post_6_months_avg as n_Blutdruck_systolisch_post_6_months_avg
		, verlauf.Blutdruck_diastolisch_post_6_months_avg as n_Blutdruck_diastolisch_post_6_months_avg
		, verlauf.Herzfrequenz_post_6_months_avg AS N_Herzfrequenz_post_6_months_avg
		, verlauf.Urinvolumen_post_6_months_avg as N_Urinvolumen_post_6_months_avg
		--Banff
		, Banff09_1  as O_Banff09_1
		, Banff09_2  as O_Banff09_2
		, Banff09_3  as O_Banff09_3
		, Banff09_4  as O_Banff09_4
		, Banff09_5  as O_Banff09_5
		, Banff09_6  as O_Banff09_6
		, Banff15_1  as O_Banff15_1
		, Banff15_2  as O_Banff15_2
		, Banff15_3  as O_Banff15_3
		, Banff15_4  as O_Banff15_4
		, Banff15_5  as O_Banff15_5
		, Banff15_6  as O_Banff15_6
		--Befundmerkmale
		, coalesce(befundm.C_Merkmal_Arteriosklerose, 'keine Angabe') as C_Merkmal_Arteriosklerose
		, coalesce(befundm.C_Merkmal_BKVNephropathy, 'nein') as C_Merkmal_BKVNephropathy
		, coalesce(befundm.C_Merkmal_C4d, 'not done') as C_Merkmal_C4d
		, coalesce(befundm.C_Merkmal_hyalineArteriopathie, 'keine Angabe') as C_Merkmal_hyalineArteriopathie
		, coalesce(befundm.C_Merkmal_ag,0) as C_Merkmal_ag
		, coalesce(befundm.C_Merkmal_ah,0) as C_Merkmal_ah
		, coalesce(befundm.C_Merkmal_ai,0) as C_Merkmal_ai
		, coalesce(befundm.C_Merkmal_at,0) as C_Merkmal_at
		, coalesce(befundm.C_Merkmal_ATI,0) as C_Merkmal_ATI
		, coalesce(befundm.C_Merkmal_av,0) as C_Merkmal_av
		, coalesce(befundm.C_Merkmal_cg,0) as C_Merkmal_cg
		, coalesce(befundm.C_Merkmal_ci,0) as C_Merkmal_ci
		, coalesce(befundm.C_Merkmal_ct,0) as C_Merkmal_ct
		, coalesce(befundm.C_Merkmal_cv,0) as C_Merkmal_cv
		, coalesce(befundm.C_Merkmal_mm,0) as C_Merkmal_mm
		, coalesce(befundm.C_Merkmal_ptc,0) as C_Merkmal_ptc
		, coalesce(befundm.C_Merkmal_rATI1,0) as C_Merkmal_rATI1
		, coalesce(befundm.C_Merkmal_rbTTI3,0) as C_Merkmal_rbTTI3
		, coalesce(befundm.C_Merkmal_rTTI1,0) as C_Merkmal_rTTI1
		, coalesce(befundm.C_Merkmal_TTI,0) as C_Merkmal_TTI
		 --Label: Short-term
		 --Deaths and transplant failure between 12 and 18 months after transplantation are considered as transplant failure; Everything else as success
		, case when datediff(dd,t.datum,t.TPV_Datum ) < 549 or datediff(dd,t.datum,p.Todesdatum ) < 549 then 1 else 0 end as Shortterm_TransplantOutcome -- 0: Success; 1: Transplant Failure  
		--Label: Long-term
		--Deaths and transplant failure between 12 and 72 months after transplantation are considered as transplant failure; Everything else as success
	    , case when datediff(dd,t.datum,t.TPV_Datum ) < (365*6) or datediff(dd,t.datum,p.Todesdatum ) < (365*6) then 1 else 0 end as Longterm_TransplantOutcome -- 0: Success; 1: Transplant Failure 	
from dbo.PATIENT_View p 
join dbo.Transplantation t
	on p.PatientID = t.PatientID
join dbo.Spender s
	on t.SpenderID = s.SpenderID 
left join ( 
			select spenderid
					, max(case when Bezeichnung = 'hbsag' then wert end) as hbsag
					, max(case when Bezeichnung = 'cmvigg' then wert end) as cmvigg
					, max(case when Bezeichnung = 'hbcab' then wert end) as hbcab
					, max(case when Bezeichnung = 'hcvak' then wert end) as hcvak
					, max(case when Bezeichnung = 'hivak' then wert end) as hivak
					, max(case when Bezeichnung = 'hbcak' then wert end) as hbcak
					, max(case when Bezeichnung = 'hcvab' then wert end) as hcvab
					, max(case when Bezeichnung = 'hiv' then wert end) as hiv
					, max(case when Bezeichnung = 'antihcvetimport' then wert end) as antihcvetimport
					, max(case when Bezeichnung = 'hivabetimport' then wert end) as hivabetimport
					, max(case when Bezeichnung = 'acmviggse' then wert end) as acmviggse
					, max(case when Bezeichnung = 'luesetimport' then wert end) as luesetimport 
					, max(case when Bezeichnung = 'hbsagetimport' then wert end) as hbsagetimport 
					, max(case when Bezeichnung = 'antihcvse' then wert end) as antihcvse
			from
			(
				select spenderid
						, replace(replace(replace(replace(replace(replace(trim(lower(Bezeichnung)), '-', ''), ' ', ''), ',', ''), '.', ''), '/', ''), '_', '') as Bezeichnung
						, case when replace(replace(replace(replace(replace(replace(replace(replace(wert, 'negativ', 'neg'), '.', ''), 'positiv', 'pos'), ' ', ''), '', ''), '', ''), '', ''), '', '') = '' then null else replace(replace(replace(replace(replace(replace(replace(replace(wert, 'negativ', 'neg'), '.', ''), 'positiv', 'pos'), ' ', ''), '', ''), '', ''), '', ''), '', '')  end as Wert 
				from dbo.Spender_Labor a 
			 ) a
			group by spenderid 
			) sl
			on s.SpenderID = sl.spenderid
left join (
			select TransplantationID 
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 0 and 0 then wert end) as ProteinTUR_TransplantDate
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 1 and 30 then wert end) as ProteinTUR_PostTransplant_1Month
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 31 and 60 then wert end) as ProteinTUR_PostTransplant_2Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 61 and 90 then wert end) as ProteinTUR_PostTransplant_3Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 91 and 120 then wert end) as ProteinTUR_PostTransplant_4Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 121 and 150 then wert end) as ProteinTUR_PostTransplant_5Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 151 and 180 then wert end) as ProteinTUR_PostTransplant_6Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) > 0 then wert end) as ProteinTUR_PostTransplant
					, max(case when datediff(dd,TransplantDatum,Labordatum) < 0 then wert end) as ProteinTUR_PreTransplant
					, max(wert) as ProteinTUR_All_Time
					--TODO: Later time slots!
			from (  select TransplantationID
							, a.Datum as LaborDatum
							, t.datum as TransplantDatum
							, case when wert like '%neg%' then 'neg'
								when wert like '%+-%' or wert like '%neut%' then 'neutral'
								when wert like '%+%' or wert like '%pos%' then 'pos'
							end as wert
					from dbo.Labor a
					join dbo.Laborwert b
						on a.LaborID = b.LaborID 
					join dbo.Transplantation t
						on a.PatientID = t.PatientID 
					where year(t.Datum) >= 2004
						and year(a.Datum) >= 2004
						and b.bezeichnung like '%ProteinTUR%'
						and datediff(dd,t.datum,a.datum) <= 365
					) a
			group by TransplantationID				
) protTUR
	on t.TransplantationID = protTUR.transplantationid	
left join (
			select TransplantationID 
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 0 and 0 then wert end) as NitritTUR_TransplantDate
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 1 and 30 then wert end) as NitritTUR_PostTransplant_1Month
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 31 and 60 then wert end) as NitritTUR_PostTransplant_2Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 61 and 90 then wert end) as NitritTUR_PostTransplant_3Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 91 and 120 then wert end) as NitritTUR_PostTransplant_4Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 121 and 150 then wert end) as NitritTUR_PostTransplant_5Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) between 151 and 180 then wert end) as NitritTUR_PostTransplant_6Months
					, max(case when datediff(dd,TransplantDatum,Labordatum) > 0 then wert end) as NitritTUR_PostTransplant
					, max(case when datediff(dd,TransplantDatum,Labordatum) < 0 then wert end) as NitritTUR_PreTransplant
					, max(wert) as NitritTUR_All_Time
					--TODO: Later time slots!
			from (  select TransplantationID
							, a.Datum as LaborDatum
							, t.datum as TransplantDatum
							, case when wert like '%neg%' then 'neg'
							when wert like '%+-%' or wert like '%neut%' then 'neutral'
							when wert like '%+%' or wert like '%pos%' then 'pos'
							end as wert
					from dbo.Labor a
					join dbo.Laborwert b
						on a.LaborID = b.LaborID 
					join dbo.Transplantation t
						on a.PatientID = t.PatientID 
					where year(t.Datum) >= 2004
						and year(a.Datum) >= 2004
						and lower(b.bezeichnung) like '%nitr%'
						and datediff(dd,t.datum,a.datum) <= 365
					) a
			group by TransplantationID				
) nit
	on t.TransplantationID = nit.transplantationid	
left join (
			select TransplantationID
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 30 and bezeichnung_grouped = 'CRP' then wert_mgdl end) as Labvalue_CRP_mgdl_PostTransplant_1Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 30 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end)/avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 90 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end) as Labvalue_Creatinine_mgdl_PostTransplant_1Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 30 and bezeichnung_grouped = 'Leuko_Blood' then wert_nl end) as Labvalue_Leuko_Blood_nl_PostTransplant_1Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 30 and bezeichnung_grouped = 'Leuko_Urine' then wert_nl end) as Labvalue_Leuko_Urine_mgdl_PostTransplant_1Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 30 and bezeichnung_grouped = 'Protein_Concentration' then wert_mgdl end) as Labvalue_Protein_Concentration_mgdl_PostTransplant_1Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 30 and bezeichnung_grouped = 'Protein_DailyOutput' then wert_mgdl end) as Labvalue_Protein_DailyOutput_mgdl_PostTransplant_1Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 30 and bezeichnung_grouped = 'Protein_Dipstick' then wert_mgdl end) as Labvalue_Protein_Dipstick_mgdl_PostTransplant_1Months
					--
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 30 and 60 and bezeichnung_grouped = 'CRP' then wert_mgdl end) as Labvalue_CRP_mgdl_PostTransplant_2Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 30 and 60 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end)/avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 90 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end) as Labvalue_Creatinine_mgdl_PostTransplant_2Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 30 and 60 and bezeichnung_grouped = 'Leuko_Blood' then wert_nl end) as Labvalue_Leuko_Blood_nl_PostTransplant_2Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 30 and 60 and bezeichnung_grouped = 'Leuko_Urine' then wert_nl end) as Labvalue_Leuko_Urine_mgdl_PostTransplant_2Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 30 and 60 and bezeichnung_grouped = 'Protein_Concentration' then wert_mgdl end) as Labvalue_Protein_Concentration_mgdl_PostTransplant_2Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 30 and 60 and bezeichnung_grouped = 'Protein_DailyOutput' then wert_mgdl end) as Labvalue_Protein_DailyOutput_mgdl_PostTransplant_2Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 30 and 60 and bezeichnung_grouped = 'Protein_Dipstick' then wert_mgdl end) as Labvalue_Protein_Dipstick_mgdl_PostTransplant_2Months
					--					
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 60 and 90 and bezeichnung_grouped = 'CRP' then wert_mgdl end) as Labvalue_CRP_mgdl_PostTransplant_3Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 60 and 90 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end)/avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 90 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end) as Labvalue_Creatinine_mgdl_PostTransplant_3Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 60 and 90 and bezeichnung_grouped = 'Leuko_Blood' then wert_nl end) as Labvalue_Leuko_Blood_nl_PostTransplant_3Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 60 and 90 and bezeichnung_grouped = 'Leuko_Urine' then wert_nl end) as Labvalue_Leuko_Urine_mgdl_PostTransplant_3Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 60 and 90 and bezeichnung_grouped = 'Protein_Concentration' then wert_mgdl end) as Labvalue_Protein_Concentration_mgdl_PostTransplant_3Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 60 and 90 and bezeichnung_grouped = 'Protein_DailyOutput' then wert_mgdl end) as Labvalue_Protein_DailyOutput_mgdl_PostTransplant_3Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 60 and 90 and bezeichnung_grouped = 'Protein_Dipstick' then wert_mgdl end) as Labvalue_Protein_Dipstick_mgdl_PostTransplant_3Months
					--
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 90 and 120 and bezeichnung_grouped = 'CRP' then wert_mgdl end) as Labvalue_CRP_mgdl_PostTransplant_4Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 90 and 120 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end)/avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 90 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end) as Labvalue_Creatinine_mgdl_PostTransplant_4Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 90 and 120 and bezeichnung_grouped = 'Leuko_Blood' then wert_nl end) as Labvalue_Leuko_Blood_nl_PostTransplant_4Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 90 and 120 and bezeichnung_grouped = 'Leuko_Urine' then wert_nl end) as Labvalue_Leuko_Urine_mgdl_PostTransplant_4Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 90 and 120 and bezeichnung_grouped = 'Protein_Concentration' then wert_mgdl end) as Labvalue_Protein_Concentration_mgdl_PostTransplant_4Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 90 and 120 and bezeichnung_grouped = 'Protein_DailyOutput' then wert_mgdl end) as Labvalue_Protein_DailyOutput_mgdl_PostTransplant_4Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 90 and 120 and bezeichnung_grouped = 'Protein_Dipstick' then wert_mgdl end) as Labvalue_Protein_Dipstick_mgdl_PostTransplant_4Months
					--
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 120 and 150 and bezeichnung_grouped = 'CRP' then wert_mgdl end) as Labvalue_CRP_mgdl_PostTransplant_5Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 120 and 150 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end)/avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 90 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end) as Labvalue_Creatinine_mgdl_PostTransplant_5Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 120 and 150 and bezeichnung_grouped = 'Leuko_Blood' then wert_nl end) as Labvalue_Leuko_Blood_nl_PostTransplant_5Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 120 and 150 and bezeichnung_grouped = 'Leuko_Urine' then wert_nl end) as Labvalue_Leuko_Urine_mgdl_PostTransplant_5Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 120 and 150 and bezeichnung_grouped = 'Protein_Concentration' then wert_mgdl end) as Labvalue_Protein_Concentration_mgdl_PostTransplant_5Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 120 and 150 and bezeichnung_grouped = 'Protein_DailyOutput' then wert_mgdl end) as Labvalue_Protein_DailyOutput_mgdl_PostTransplant_5Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 120 and 150 and bezeichnung_grouped = 'Protein_Dipstick' then wert_mgdl end) as Labvalue_Protein_Dipstick_mgdl_PostTransplant_5Months
					--
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 150 and 180 and bezeichnung_grouped = 'CRP' then wert_mgdl end) as Labvalue_CRP_mgdl_PostTransplant_6Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 150 and 180 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end)/avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 90 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end) as Labvalue_Creatinine_mgdl_PostTransplant_6Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 150 and 180 and bezeichnung_grouped = 'Leuko_Blood' then wert_nl end) as Labvalue_Leuko_Blood_nl_PostTransplant_6Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 150 and 180 and bezeichnung_grouped = 'Leuko_Urine' then wert_nl end) as Labvalue_Leuko_Urine_mgdl_PostTransplant_6Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 150 and 180 and bezeichnung_grouped = 'Protein_Concentration' then wert_mgdl end) as Labvalue_Protein_Concentration_mgdl_PostTransplant_6Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 150 and 180 and bezeichnung_grouped = 'Protein_DailyOutput' then wert_mgdl end) as Labvalue_Protein_DailyOutput_mgdl_PostTransplant_6Months
					, avg(case when datediff(dd, TransplantDatum, LaborDatum) between 150 and 180 and bezeichnung_grouped = 'Protein_Dipstick' then wert_mgdl end) as Labvalue_Protein_Dipstick_mgdl_PostTransplant_6Months
					--
					, avg(case when bezeichnung_grouped = 'CRP' then wert_mgdl end) as Labvalue_CRP_mgdl_PostTransplant_AllTime
					, avg(case when bezeichnung_grouped = 'Kreatinin' then wert_mgdl end)/avg(case when datediff(dd, TransplantDatum, LaborDatum) between 0 and 90 and bezeichnung_grouped = 'Kreatinin' then wert_mgdl end) as Labvalue_Creatinine_mgdl_PostTransplant_AllTime
					, avg(case when bezeichnung_grouped = 'Leuko_Blood' then wert_nl end) as Labvalue_Leuko_Blood_nl_PostTransplant_AllTime
					, avg(case when bezeichnung_grouped = 'Leuko_Urine' then wert_nl end) as Labvalue_Leuko_Urine_mgdl_PostTransplant_AllTime
					, avg(case when bezeichnung_grouped = 'Protein_Concentration' then wert_mgdl end) as Labvalue_Protein_Concentration_mgdl_PostTransplant_AllTime
					, avg(case when bezeichnung_grouped = 'Protein_DailyOutput' then wert_mgdl end) as Labvalue_Protein_DailyOutput_mgdl_PostTransplant_AllTime
					, avg(case when bezeichnung_grouped = 'Protein_Dipstick' then wert_mgdl end) as Labvalue_Protein_Dipstick_mgdl_PostTransplant_AllTime
			from 
			(  select t.TransplantationID 
					, bez.bezeichnung_grouped
					, t.datum as TransplantDatum
					, a.datum as LaborDatum
					, b.wert
					, b.Einheit
					, case  when trim(lower(b.einheit)) like 'mg/d%' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like 'g/l' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10))   * 100 
							when trim(lower(b.einheit)) like 'µmol/l' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) * 0.0113 
							when trim(lower(b.einheit)) like 'g/d' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like 'mg/g Crea.' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like 'ml/min' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like 'mmo/l' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like 'mmol/l' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) * 0.0113
							when trim(lower(b.einheit)) like 'nmol/l' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) * 0.0113
							when trim(lower(b.einheit)) like 'umol/l' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) * 0.0113
							when trim(lower(b.einheit)) like 'mg/24h' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like 'mg/die' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like 'mg/l' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) / 10
							when trim(lower(b.einheit)) like 'g/l' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) * 100
							end as wert_mgdl
					, case  when trim(lower(b.einheit)) like '/nl' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like '/pl' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like '/µl' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like '/ul' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like 'Tl./nl' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 
							when trim(lower(b.einheit)) like '/mcgl' and b.wert not LIKE '%[^0-9|\.]%' then cast(b.wert as decimal(20,10)) 				
							end as wert_nl
			from dbo.Labor a
			join dbo.Laborwert b
				on a.LaborID = b.LaborID 
			join dbo.Transplantation t
				on a.PatientID = t.PatientID 
			join (
					SELECT 'CRP' as Bezeichnung, 'CRP' as Bezeichnung_grouped UNION ALL
					SELECT 'CRP/P' as Bezeichnung, 'CRP' as Bezeichnung_grouped UNION ALL
					SELECT 'CRP-H' as Bezeichnung, 'CRP' as Bezeichnung_grouped UNION ALL
					SELECT 'CRPHP' as Bezeichnung, 'CRP' as Bezeichnung_grouped UNION ALL
					SELECT 'CRPLG' as Bezeichnung, 'CRP' as Bezeichnung_grouped UNION ALL
					SELECT 'CRPRocheH' as Bezeichnung, 'CRP' as Bezeichnung_grouped UNION ALL
					SELECT 'CRPRocheHP' as Bezeichnung, 'CRP' as Bezeichnung_grouped UNION ALL
					SELECT 'CRE' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'CREA' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'CREAJ-H' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'CREATININ ENZYMATIS ' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'KeratininHP' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'kr' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Kratinin' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Krea' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Krea/P' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Krea/S' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'KREASI' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Kreatenin' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Kreatenin i.S.' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Kreatiinin' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'KreatiininHP' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Kreatinin' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Kreatinin enz.      ' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Kreatinin HP' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'KreatininH' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'KreatininHP' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'KreatininSE' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'KREATINS' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'KreatitninHP' as Bezeichnung, 'Kreatinin' as Bezeichnung_grouped UNION ALL
					SELECT 'Leoukzyten' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leu Ur' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leuco' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leuko/B' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoE' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoEB' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leukos' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoZyten' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leuko im ustix' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoTU' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoTUR' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'Leukozyten (Stix)' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'LEUKOZYTEN STAT     ' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'Uleuko' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Leukozyten' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Leukozyten(stix)' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Leukozyten/Stix' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'Nitrit' as Bezeichnung, 'Nitrit' as Bezeichnung_grouped UNION ALL
					SELECT 'Nitrit im Urin' as Bezeichnung, 'Nitrit' as Bezeichnung_grouped UNION ALL
					SELECT 'NITRIT/U-TS' as Bezeichnung, 'Nitrit' as Bezeichnung_grouped UNION ALL
					SELECT 'NitritTU' as Bezeichnung, 'Nitrit' as Bezeichnung_grouped UNION ALL
					SELECT 'NitritTUR' as Bezeichnung, 'Nitrit' as Bezeichnung_grouped UNION ALL
					SELECT 'Unitr.' as Bezeichnung, 'Nitrit' as Bezeichnung_grouped UNION ALL
					SELECT 'Unitrit' as Bezeichnung, 'Nitrit' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Nitrit' as Bezeichnung, 'Nitrit' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Nitrit(stix)' as Bezeichnung, 'Nitrit' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiss i.U.        ' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiß i.U.         ' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiss, ges. i.U.' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiss, ges.i.SU.' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Ew-U.' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Prot/U' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinCS' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinCSU' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'EIWEISS PROTEIN 24  ' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'GEIW' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'ges. Protein SU/d' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'Prot/U/d' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinDS' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinDSU' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiss im ustix' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'Protein (Stix)' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'PROTEIN STAT        ' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinTU' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinTUR' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U eiweis' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U eiweiß' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'Ueiweiss' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Eiweiß' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Eiweiß(stix)' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Eiweiß/Stix' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-PROTT.' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-PROTTS' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped 
			) bez
			on trim(b.Bezeichnung) = trim(bez.bezeichnung)
			where year(t.datum) >= 2004 
				and (Ort like '%Charité Urologische Klinik%' or Ort like '%Berlin Charité-Mitte%' or Ort like '%Virchow%')
				and trim(t.organ) = 'Niere'
				and year(a.datum) >= 2004
				and isnumeric(wert) = 1
				and b.wert not LIKE '%[^0-9|\.]%'
				and datediff(dd,t.datum,a.datum) between -30 and 365
				--
				--
				UNION ALL
				--
				--
			select t.TransplantationID 
					, bez.bezeichnung_grouped
					, t.datum as TransplantDatum
					, a.datum as LaborDatum
					, b.wert
					, b.Einheit
					, case 	when bez.bezeichnung_grouped like '%Protein%' and b.wert like '%+++%'then 600 
							when bez.bezeichnung_grouped like '%Protein%' and b.wert like '%++%'then 300
							when bez.bezeichnung_grouped like '%Protein%' and (b.wert like '%pos%' or b.wert like '%+%') then 65
							when bez.bezeichnung_grouped like '%Protein%' and (b.wert like '%neg%' or b.wert like '%-%') then 15
					end as wert_mgdl
					, case 	when bez.bezeichnung_grouped like '%Leuko%' and b.wert like '%+++%'then 300 
							when bez.bezeichnung_grouped like '%Leuko%' and b.wert like '%++%'then 175
							when bez.bezeichnung_grouped like '%Leuko%' and (b.wert like '%trace%' or (b.wert like '%+%' and b.wert like '%-%')) then 30
							when bez.bezeichnung_grouped like '%Leuko%' and (b.wert like '%pos%' or b.wert like '%+%') then 75
							when bez.bezeichnung_grouped like '%Leuko%' and (b.wert like '%neg%' or b.wert like '%-%') then 7
					end as wert_nl 
			from dbo.Labor a
			join dbo.Laborwert b
				on a.LaborID = b.LaborID 
			join dbo.Transplantation t
				on a.PatientID = t.PatientID 
			join (
					SELECT 'Leoukzyten' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leu Ur' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leuco' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leuko/B' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoE' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoEB' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leukos' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoZyten' as Bezeichnung, 'Leuko_Blood' as Bezeichnung_grouped UNION ALL
					SELECT 'Leuko im ustix' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoTU' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'LeukoTUR' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'Leukozyten (Stix)' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'LEUKOZYTEN STAT     ' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'Uleuko' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Leukozyten' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Leukozyten(stix)' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Leukozyten/Stix' as Bezeichnung, 'Leuko_Urine' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiss i.U.        ' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiß i.U.         ' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiss, ges. i.U.' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiss, ges.i.SU.' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Ew-U.' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'Prot/U' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinCS' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinCSU' as Bezeichnung, 'Protein_Concentration' as Bezeichnung_grouped UNION ALL
					SELECT 'EIWEISS PROTEIN 24  ' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'GEIW' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'ges. Protein SU/d' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'Prot/U/d' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinDS' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinDSU' as Bezeichnung, 'Protein_DailyOutput' as Bezeichnung_grouped UNION ALL
					SELECT 'Eiweiss im ustix' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'Protein (Stix)' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'PROTEIN STAT        ' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinTU' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'ProteinTUR' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U eiweis' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U eiweiß' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'Ueiweiss' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Eiweiß' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Eiweiß(stix)' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-Eiweiß/Stix' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-PROTT.' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped UNION ALL
					SELECT 'U-PROTTS' as Bezeichnung, 'Protein_Dipstick' as Bezeichnung_grouped 
			) bez
			on trim(b.Bezeichnung) = trim(bez.bezeichnung)
			where year(t.datum) >= 2004 
				and (Ort like '%Charité Urologische Klinik%' or Ort like '%Berlin Charité-Mitte%' or Ort like '%Virchow%')
				and trim(t.organ) = 'Niere'
				and year(a.datum) >= 2004
				and datediff(dd,t.datum,a.datum) between -30 and 365
				and (b.wert like '%+%' or b.wert like '%-%' or b.wert like '%neg%' or b.wert like '%pos%'  )
			) a
			group by TransplantationID 		
	) lab
		on t.TransplantationID = lab.TransplantationID
left join (
			select TransplantationID
			 		,AVG (case when datediff(dd,a.Datum,b.datum) between 0 and 180 then Blutdruck_systolisch end) as Blutdruck_systolisch_post_6_months_avg
			 		,AVG (case when datediff(dd,a.Datum,b.datum) between 0 and 180 then Blutdruck_diastolisch end) as Blutdruck_diastolisch_post_6_months_avg
			 		,AVG (case when datediff(dd,a.Datum,b.datum) between 0 and 180 then Urinvolumen end) as Urinvolumen_post_6_months_avg
			 		,AVG (case when datediff(dd,a.Datum,b.datum) between 0 and 180 then Herzfrequenz end) as Herzfrequenz_post_6_months_avg
			from dbo.Verlauf  b
			join dbo.Transplantation a 
			 	on a.PatientID = b.PatientID 
			where year(a.Datum )>= 2004 
			group by TransplantationID
			) verlauf
			on t.TransplantationID = verlauf.TransplantationID
left join (
			SELECT --PatientID 
					TransplantationID 
					--, Datum  
					--, Dialyse_Enddatum, 
					--datediff(yy, Datum_erste_Dialyse , Datum ) as days_of_dialysis_prior_transplant , 
					--datediff(dd, Datum , Dialyse_Enddatum ) as datediff,
					--case when datediff(dd, Datum , Dialyse_Enddatum ) between -10000 and 0 then 0 else 1 end as dialyse_required_before_transplantation ,
					, case when datediff(dd, Datum , Dialyse_Enddatum ) > 1  then 1 else 0 end as dialyse_required_till_1_month ,
					case when datediff(dd, Datum , Dialyse_Enddatum ) > 30 then 1 else 0 end as dialyse_required_till_2_months ,
					case when datediff(dd, Datum , Dialyse_Enddatum ) > 60 then 1 else 0 end as dialyse_required_till_3_months ,
					case when datediff(dd, Datum , Dialyse_Enddatum ) > 90 then 1 else 0 end as dialyse_required_till_4_months 
					--case when datediff(dd, Datum , Dialyse_Enddatum ) > 120 then 1 else 0 end as dialyse_required_till_5_months ,
					--case when datediff(dd, Datum , Dialyse_Enddatum ) > 150 then 1 else 0 end as dialyse_required_till_6_months 
			from dbo.Transplantation 
			where year(Datum ) >= 2004
			and Datum is not null and Dialyse_Enddatum is not null
			and datediff(dd, Datum , Dialyse_Enddatum ) between 1 and 365
) d on t.TransplantationID = d.TransplantationID
left join ( 
			select distinct t.TransplantationID
					, max(case when d.Dialysetyp like '%Hämodial%' then 'Hämodialyse' else Dialysetyp end) as TypeOfDialysis
			from dbo.Dialyse d
			join dbo.Transplantation t
				on d.PatientID = t.PatientID 
			where d.Beginn < t.Datum-14 and d.ende >= t.Datum-14  
				and year(t.datum) >= 2004 
				and (Ort like '%Charité Urologische Klinik%' or Ort like '%Berlin Charité-Mitte%' or Ort like '%Virchow%')
				and datediff(dd, t.Datum , d.beginn ) <= 365
			group by t.TransplantationID 
		) dial
	on t.TransplantationID = dial.TransplantationID
left join (
			select t.TransplantationID 
					, max(case when Bezeichnung like '%Harnweg%' then 1 else 0 end) as PatientDiag_Harnweg
					, max(case when Bezeichnung like '%Hypertonie%' then 1 else 0 end) as PatientDiag_Hypertonie 
					, max(case when Bezeichnung like '%Infektionskrank%' then 1 else 0 end) as PatientDiag_Infektionskrankheit 
					, max(case when Bezeichnung like '%wegener%' then 1 else 0 end) as PatientDiag_Wegener
					, max(case when Bezeichnung like '%nämie%' then 1 else 0 end) as PatientDiag_Anaemie
					, max(case when Bezeichnung like '%sepsis%' then 1 else 0 end) as PatientDiag_Sepsis
					, max(case when Bezeichnung like '%immun%' then 1 else 0 end) as PatientDiag_Immun
					, max(case when Bezeichnung like '%hyperkal%' then 1 else 0 end) as PatientDiag_Hyperkal
					, max(case when Bezeichnung like '%hyperpara%' then 1 else 0 end) as PatientDiag_Hyperpara
					, max(case when Bezeichnung like '%gef%erk%' then 1 else 0 end) as PatientDiag_DreiGefaessErkrankung
					, max(case when Bezeichnung like '%angina%pec%' then 1 else 0 end) as PatientDiag_AnginaPectoris
					, max(case when Bezeichnung like '%pneumo%' then 1 else 0 end) as PatientDiag_Pneumo
					, max(case when Bezeichnung like '%Gastr%ente%' then 1 else 0 end) as PatientDiag_GastroEnteritis
					, max(case when Bezeichnung like '%Myokardinfarkt%' then 1 else 0 end) as PatientDiag_Myokardinfarkt
					, max(case when Bezeichnung like '%Mechanisch%' then 1 else 0 end) as PatientDiag_Mechanisch
					, max(case when Bezeichnung like '%blutung%' then 1 else 0 end) as PatientDiag_Blutung
					, max(case when Bezeichnung like '%up%erythe%' then 1 else 0 end) as PatientDiag_LupusErythematodes
					, max(case when Bezeichnung like '%Gastr%ente%' then 1 else 0 end) as PatientDiag_GallenGangsVerschluss
					, max(case when Bezeichnung like '%diabetes%' then 1 else 0 end) as PatientDiag_Diabetes					
					, max(case when Bezeichnung like '%Sphingolipidose%' then 1 else 0 end) as PatientDiag_Sphingolipidose
					, max(case when Bezeichnung like '%hyperlipi%' then 1 else 0 end) as PatientDiag_Hyperlipi
					, max(case when Bezeichnung like '%Kolitis%' then 1 else 0 end) as PatientDiag_Kolitis
					, max(case when Bezeichnung like '%Aort%tenose%' then 1 else 0 end) as PatientDiag_AortenStenose
					, max(case when Bezeichnung like '%vorhoff%' then 1 else 0 end) as PatientDiag_Vorhoff
					, max(case when Bezeichnung like '%Hyperurik%' then 1 else 0 end) as PatientDiag_Hyperurik
					, max(case when Bezeichnung like '%Leberzirr%' then 1 else 0 end) as PatientDiag_Leberzirr
					, max(case when Bezeichnung like '%herzinsu%' then 1 else 0 end) as PatientDiag_herzinsu
					, max(case when Bezeichnung like '%Dyspn%' then 1 else 0 end) as PatientDiag_Dyspn
					, max(case when Bezeichnung like '%Mitralinsu%' then 1 else 0 end) as PatientDiag_Mitralinsu
					, max(case when Bezeichnung like '%Hyperchol%' then 1 else 0 end) as PatientDiag_Hyperchol
					, max(case when Bezeichnung like '%olumenmange%' then 1 else 0 end) as PatientDiag_Volumenmangel
					, max(case when Bezeichnung like '%Lupus%' then 1 else 0 end) as PatientDiag_Lupus
					--TODO Mehr KomorbiditÃƒÂ¤ten
			from dbo.Diagnose d 
			join dbo.Transplantation t
				on d.PatientID = t.PatientID 
					and d.Anfangsdatum < t.Datum 
			where year(Anfangsdatum) >= 2004 
				and Bezeichnung not like '%niere%'
				and Bezeichnung not like '%dialyse%'
				and datediff(dd, t.Datum , d.Anfangsdatum ) <= 365
			group by TransplantationID 	
		) diag 
	on t.TransplantationID = diag.TransplantationID
left join (
			select TransplantationID 
					, max(case when merkmal like '%Banff 09 cat%' and wert like '%1%' then 1 else 0 end) as Banff09_1
					, max(case when merkmal like '%Banff 09 cat%' and wert like '%2%' then 1 else 0 end) as Banff09_2
					, max(case when merkmal like '%Banff 09 cat%' and wert like '%3%' then 1 else 0 end) as Banff09_3
					, max(case when merkmal like '%Banff 09 cat%' and wert like '%4%' then 1 else 0 end) as Banff09_4
					, max(case when merkmal like '%Banff 09 cat%' and wert like '%5%' then 1 else 0 end) as Banff09_5
					, max(case when merkmal like '%Banff 09 cat%' and wert like '%6%' then 1 else 0 end) as Banff09_6
					, max(case when merkmal like '%Banff 15 cat%' and wert like '%1%' then 1 else 0 end) as Banff15_1
					, max(case when merkmal like '%Banff 15 cat%' and wert like '%2%' then 1 else 0 end) as Banff15_2
					, max(case when merkmal like '%Banff 15 cat%' and wert like '%3%' then 1 else 0 end) as Banff15_3
					, max(case when merkmal like '%Banff 15 cat%' and wert like '%4%' then 1 else 0 end) as Banff15_4
					, max(case when merkmal like '%Banff 15 cat%' and wert like '%5%' then 1 else 0 end) as Banff15_5
					, max(case when merkmal like '%Banff 15 cat%' and wert like '%6%' then 1 else 0 end) as Banff15_6
					from untersuchung a 
			join dbo.Befundmerkmal b 
				on a.UntersuchungID = b.UntersuchungID 
			join dbo.Transplantation c 
				on a.PatientID = c.PatientID 
			where --(a.Art like 'Pathologie' or a.Art like 'PAB' or a.Art like 'Biopsie') 
				year(a.Datum) >= 2004 
				and b.Merkmal like '%banff%' 
				and datediff(mm, c.datum, a.Datum) between -30 and 365
				group by TransplantationID
) banff
	on t.TransplantationID = banff.TransplantationID
left join (
		select  transplantationid 
				, max(C_Merkmal_Arteriosklerose) as C_Merkmal_Arteriosklerose
				, max(C_Merkmal_BKVNephropathy) as C_Merkmal_BKVNephropathy
				, max(C_Merkmal_C4d) as C_Merkmal_C4d
				, max(C_Merkmal_hyalineArteriopathie) as C_Merkmal_hyalineArteriopathie
				, max(case when isnumeric(C_Merkmal_ag) = 1 and C_Merkmal_ag not LIKE '%[^0-9|\.]%' then C_Merkmal_ag end) as C_Merkmal_ag
				, max(case when isnumeric(C_Merkmal_ah) = 1 and C_Merkmal_ah not LIKE '%[^0-9|\.]%'  then C_Merkmal_ah end) as C_Merkmal_ah
				, max(case when isnumeric(C_Merkmal_ai) = 1 and C_Merkmal_ai not LIKE '%[^0-9|\.]%'  then C_Merkmal_ai end) as C_Merkmal_ai
				, max(case when isnumeric(C_Merkmal_at) = 1 and C_Merkmal_at not LIKE '%[^0-9|\.]%'  then C_Merkmal_at end) as C_Merkmal_at
				, max(case when isnumeric(C_Merkmal_ATI) = 1 and C_Merkmal_ATI not LIKE '%[^0-9|\.]%'  then C_Merkmal_ATI end) as C_Merkmal_ATI
				, max(case when isnumeric(C_Merkmal_av) = 1 and C_Merkmal_av not LIKE '%[^0-9|\.]%'  then C_Merkmal_av end) as C_Merkmal_av
				, max(case when isnumeric(C_Merkmal_cg) = 1 and C_Merkmal_cg not LIKE '%[^0-9|\.]%'  then C_Merkmal_cg end) as C_Merkmal_cg
				, max(case when isnumeric(C_Merkmal_ci) = 1 and C_Merkmal_ci not LIKE '%[^0-9|\.]%'  then C_Merkmal_ci end) as C_Merkmal_ci
				, max(case when isnumeric(C_Merkmal_ct) = 1 and C_Merkmal_ct not LIKE '%[^0-9|\.]%'  then C_Merkmal_ct end) as C_Merkmal_ct
				, max(case when isnumeric(C_Merkmal_cv) = 1 and C_Merkmal_cv not LIKE '%[^0-9|\.]%'  then C_Merkmal_cv end) as C_Merkmal_cv
				, max(case when isnumeric(C_Merkmal_mm) = 1 and C_Merkmal_mm not LIKE '%[^0-9|\.]%'  then C_Merkmal_mm end) as C_Merkmal_mm
				, max(case when isnumeric(C_Merkmal_ptc) = 1 and C_Merkmal_ptc not LIKE '%[^0-9|\.]%'  then C_Merkmal_ptc end) as C_Merkmal_ptc
				, max(case when isnumeric(C_Merkmal_rATI1) = 1 and C_Merkmal_rATI1 not LIKE '%[^0-9|\.]%'  then C_Merkmal_rATI1 end) as C_Merkmal_rATI1
				, max(case when isnumeric(C_Merkmal_rbTTI3) = 1 and C_Merkmal_rbTTI3 not LIKE '%[^0-9|\.]%'  then C_Merkmal_rbTTI3 end) as C_Merkmal_rbTTI3
				, max(case when isnumeric(C_Merkmal_rTTI1) = 1 and C_Merkmal_rTTI1 not LIKE '%[^0-9|\.]%'  then C_Merkmal_rTTI1 end) as C_Merkmal_rTTI1
				, max(case when isnumeric(C_Merkmal_TTI) = 1 and C_Merkmal_TTI not LIKE '%[^0-9|\.]%'  then C_Merkmal_TTI end) as C_Merkmal_TTI
		from (
			select transplantationid
			, t.datum as TransplantDate
			, b.Datum as UntersuchungDatum
			, case when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'ausgeprägt' then 'ausgeprägt'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'hochgradig' then 'ausgeprägt'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'stark' then 'ausgeprägt'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'ja' then 'ja'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'vorhanden' then 'ja'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'nein' then 'keine'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'keine Angabe' then 'keine Angabe'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'nicht erfasst' then 'keine Angabe'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'gering' then 'mäßig'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'mäßig' then 'mäßig'
				when trim(merkmal) = 'Arteriosklerose' and trim(wert) like 'mäßig stark' then 'mäßig'
				else 'keine'
				end as C_Merkmal_Arteriosklerose
			, case when trim(merkmal) = 'BKV Nephropathy' then wert end as C_Merkmal_BKVNephropathy
			, case when trim(wert) like '' then 'unknown'
				when trim(merkmal) = 'C4d' and trim(wert) like '+' then 'positive'
				when trim(merkmal) = 'C4d' and trim(wert) like 'aussstehend' then 'unknown'
				when trim(merkmal) = 'C4d' and trim(wert) like 'ausstehend' then 'unknown'
				when trim(merkmal) = 'C4d' and trim(wert) like 'glomerulär' then 'glomerular'
				when trim(merkmal) = 'C4d' and trim(wert) like 'glomerulär +' then 'glomerular'
				when trim(merkmal) = 'C4d' and trim(wert) like 'negativ' then 'negative'
				when trim(merkmal) = 'C4d' and trim(wert) like 'nein' then 'no'
				when trim(merkmal) = 'C4d' and trim(wert) like 'nicht bestimmt' then 'not done'
				when trim(merkmal) = 'C4d' and trim(wert) like 'nicht dokumentiert' then 'not done'
				when trim(merkmal) = 'C4d' and trim(wert) like 'nicht erfasst' then 'not done'
				when trim(merkmal) = 'C4d' and trim(wert) like 'periglomerulär' then 'periglomerular'
				when trim(merkmal) = 'C4d' and trim(wert) like 'positiv' then 'positive'
				else 'not done'
				end as C_Merkmal_C4d
			, case when trim(merkmal) = 'hyaline Arteriopathie' and trim(wert) like 'ausgeprägt' then 'ausgeprägt'
				when trim(merkmal) = 'hyaline Arteriopathie' and trim(wert) like 'gering' then 'gering'
				when trim(merkmal) = 'hyaline Arteriopathie' and trim(wert) like 'hochgradig' then 'ausgeprägt'
				when trim(merkmal) = 'hyaline Arteriopathie' and trim(wert) like 'mäßig' then 'gering'
				when trim(merkmal) = 'hyaline Arteriopathie' and trim(wert) like 'nein' then 'keine'
				when trim(merkmal) = 'hyaline Arteriopathie' and trim(wert) like 'nicht erfasst' then 'keine Angabe'
				when trim(merkmal) = 'hyaline Arteriopathie' and trim(wert) like 'stark' then 'ausgeprägt'
				when trim(merkmal) = 'hyaline Arteriopathie' and trim(wert) like 'vorhanden' then 'ja'
				else 'keine Angabe'
				end as C_Merkmal_hyalineArteriopathie
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%ag%' then substring(wert,charindex('ag',wert)+len('ag'),1)  end as C_Merkmal_ag
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%ah%' then substring(wert,charindex('ah',wert)+len('ah'),1)  end as C_Merkmal_ah
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%ai%' then substring(wert,charindex('ai',wert)+len('ai'),1)  end as C_Merkmal_ai
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%at%' then substring(wert,charindex('at',wert)+len('at'),1)  end as C_Merkmal_at
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%ATI%' then substring(wert,charindex('ATI',wert)+len('ATI'),1)  end as C_Merkmal_ATI
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%av%' then substring(wert,charindex('av',wert)+len('av'),1)  end as C_Merkmal_av
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%cg%' then substring(wert,charindex('cg',wert)+len('cg'),1)  end as C_Merkmal_cg
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%ci%' then substring(wert,charindex('ci',wert)+len('ci'),1)  end as C_Merkmal_ci
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%ct%' then substring(wert,charindex('ct',wert)+len('ct'),1)  end as C_Merkmal_ct
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%cv%' then substring(wert,charindex('cv',wert)+len('cv'),1)  end as C_Merkmal_cv
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%mm%' then substring(wert,charindex('mm',wert)+len('mm'),1)  end as C_Merkmal_mm
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%ptc%' then substring(wert,charindex('ptc',wert)+len('ptc'),1)  end as C_Merkmal_ptc
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%rATI1%' then 1  end as C_Merkmal_rATI1
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%rbTTI3%' then 1  end as C_Merkmal_rbTTI3
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%rTTI1%' then 1  end as C_Merkmal_rTTI1
			, case when(trim(merkmal) = 'Glomerular features' or trim(merkmal) = 'Tubular-interstitial features' or trim(merkmal) = 'Vascular features') and wert like '%TTI%' then substring(wert,charindex('TTI',wert)+len('TTI'),1)  end as C_Merkmal_TTI
		from dbo.Befundmerkmal a 
		join dbo.Untersuchung b
			on a.UntersuchungID = b.UntersuchungID 
		join dbo.Transplantation t
			on b.PatientID = t.PatientID 
		where year(t.datum) >= 2004 
			and (Ort like '%Charité Urologische Klinik%' or Ort like '%Berlin Charité-Mitte%' or Ort like '%Virchow%')
			and trim(t.organ) = 'Niere'
			and datediff(dd,t.datum,b.datum) between -30 and 180
			and (trim(merkmal) = 'Arteriosklerose'
						or trim(merkmal) = 'BKV Nephropathy'
						or trim(merkmal) = 'C4d'
						or trim(merkmal) = 'hyaline Arteriopathie'
						or trim(merkmal) = 'Glomerular features'
						or trim(merkmal) = 'Tubular-interstitial features'
						or trim(merkmal) = 'Vascular features')	
		) a
		group by transplantationid 
	) befundm 
	on t.TransplantationID = befundm.TransplantationID
left join ( 
		select TransplantationID
			, coalesce(avg(case when Untergruppe like 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' then case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end end), 0) as Medik_A02B
			, coalesce(avg(case when Untergruppe like 'A11C - Vitamin D, inkl. deren Kombinationen (0)' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_A11C
			, coalesce(avg(case when Untergruppe like 'B03X - Andere Antianämika (0)' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_B03X
			, coalesce(avg(case when Untergruppe like 'B03X - Andere Antianämika (0)' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_C03C
			, coalesce(avg(case when Untergruppe like 'C07A - Betablocker (0)' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_C07A
			, coalesce(avg(case when Untergruppe like 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_C08C
			, coalesce(avg(case when Untergruppe like 'H02AB*-Glucocorticoide' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_H02AB
			, coalesce(avg(case when Untergruppe like 'L04AA - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA
			, coalesce(avg(case when Untergruppe like 'L04AA02 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA02
			, coalesce(avg(case when Untergruppe like 'L04AA03 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA03
			, coalesce(avg(case when Untergruppe like 'L04AA04 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA04
			, coalesce(avg(case when Untergruppe like 'L04AA06 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA06
			, coalesce(avg(case when Untergruppe like 'L04AA08 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA08
			, coalesce(avg(case when Untergruppe like 'L04AA09 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA09
			, coalesce(avg(case when Untergruppe like 'L04AA10 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA10
			, coalesce(avg(case when Untergruppe like 'L04AA13 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA13
			, coalesce(avg(case when Untergruppe like 'L04AA18 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA18
			, coalesce(avg(case when Untergruppe like 'L04AA21 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA21
			, coalesce(avg(case when Untergruppe like 'L04AA23 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA23
			, coalesce(avg(case when Untergruppe like 'L04AA24 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AA24
			, coalesce(avg(case when Untergruppe like 'L04AD01 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AD01
			, coalesce(avg(case when Untergruppe like 'L04AD02 - Selektive Immunsuppressiva' then  case when einheit like '%mg%' then Tagesdosis else tagesdosis / 1000 end  end), 0) as Medik_L04AD02
			from dbo.Medikation a
			join  (SELECT 'A01AA51' as ATC, 'Natriumfluorid, Kombinationen' as BezKorrektur, 'A01A - Stomatologika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AB03' as ATC, 'Chlorhexidin' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AB04' as ATC, 'Amphotericin B' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AB18' as ATC, 'Clotrimazol' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AB22' as ATC, 'Doxycyclin' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AC01' as ATC, 'Triamcinolon' as BezKorrektur, 'A01AC Corticosteroide zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A02AA04' as ATC, 'Magnesiumhydroxid' as BezKorrektur, 'A02AA Magnesium-haltige Antacida' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AB02' as ATC, 'Algedrat' as BezKorrektur, 'A02AB Aluminium-haltige Antacida' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AB04' as ATC, 'Carbaldrate' as BezKorrektur, 'A02AB Aluminium-haltige Antacida' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AD01' as ATC, 'Co-Magaldrox' as BezKorrektur, 'A02AD Kombinationen und Komplexe von Aluminium-, Calcium- und' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AD02' as ATC, 'Magaldrat' as BezKorrektur, 'A02AD Kombinationen und Komplexe von Aluminium-, Calcium- und' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AD04' as ATC, 'Hydrotalcit' as BezKorrektur, 'A02AD Kombinationen und Komplexe von Aluminium-, Calcium- und' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AD05' as ATC, 'Almasilat' as BezKorrektur, 'A02AD Kombinationen und Komplexe von Aluminium-, Calcium- und' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AX02' as ATC, 'Mg-Al-hydroxid/Oxetacain' as BezKorrektur, 'A02AX Antacida, andere Kombinationen' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02BA01' as ATC, 'Cimetidin' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A02BA02' as ATC, 'Ranitidin' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A02BA03' as ATC, 'Famotidin' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A02BA06' as ATC, 'Roxatidin' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A02BB01' as ATC, 'Misoprostol' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A02BC01' as ATC, 'Omeprazol' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A02BC02' as ATC, 'Pantoprazol' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A02BC03' as ATC, 'Lansoprazol' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A02BC05' as ATC, 'Esomeprazol' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A02BX02' as ATC, 'Sucralfat' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A03AA04' as ATC, 'Mebeverin' as BezKorrektur, 'A03AA Synthetische Anticholinergika, Ester mit tertiären Aminogruppen' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03AD30' as ATC, 'Moxaverin' as BezKorrektur, 'A03AD Papaverin und Derivate' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03AX13' as ATC, 'Dimeticon' as BezKorrektur, 'A03A - Mittel bei funktionellen gastrointestinalen Störungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03BA01' as ATC, 'Atropin' as BezKorrektur, 'A03B - Belladonna und Derivate, rein (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03BB01' as ATC, 'Butylscopolaminiumbromid' as BezKorrektur, 'A03B - Belladonna und Derivate, rein (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03FA01' as ATC, 'Metoclopramid' as BezKorrektur, 'A03F - Prokinetika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03FA02' as ATC, 'Cisaprid' as BezKorrektur, 'A03F - Prokinetika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03FA03' as ATC, 'Domperidon' as BezKorrektur, 'A03F - Prokinetika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A04AB02' as ATC, 'Dimenhydrinat' as BezKorrektur, 'A04A - Antiemetika und Mittel gegen Übelkeit (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05AA01' as ATC, 'Chenodeoxycholsäure' as BezKorrektur, 'A05A - Gallentherapie (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05AA02' as ATC, 'Ursodeoxycholsäure' as BezKorrektur, 'A05A - Gallentherapie (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05AA05' as ATC, 'Ochsengalle' as BezKorrektur, 'A05A - Gallentherapie (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05AP03' as ATC, 'Cynara scolymus (Artischocke)' as BezKorrektur, 'A05A - Gallentherapie (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BA03' as ATC, 'Silymarin' as BezKorrektur, 'A05B - Lebertherapeutika, lipotrope Substanzen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BA17' as ATC, 'Ornithinaspartat' as BezKorrektur, 'A05B - Lebertherapeutika, lipotrope Substanzen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BA50' as ATC, 'Ornithin' as BezKorrektur, 'A05B - Lebertherapeutika, lipotrope Substanzen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BA60' as ATC, 'Cholin, Kombination' as BezKorrektur, 'A05B - Lebertherapeutika, lipotrope Substanzen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BP51' as ATC, 'Sylimarin/Curcumawurzelstockextrakt' as BezKorrektur, 'A05B - Lebertherapeutika, lipotrope Substanzen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AA01' as ATC, 'Paraffin' as BezKorrektur, 'A06A - Laxanzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AB02' as ATC, 'Bisacodyl' as BezKorrektur, 'A06A - Laxanzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AB08' as ATC, 'Natriumpicosulfat' as BezKorrektur, 'A06A - Laxanzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AC01' as ATC, 'Plantago ovata (Indische Flohsamen)' as BezKorrektur, 'A06A - Laxanzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AD11' as ATC, 'Lactulose' as BezKorrektur, 'A06A - Laxanzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AD15' as ATC, 'Macrogol' as BezKorrektur, 'A06A - Laxanzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AX99' as ATC, 'Manna/Feige' as BezKorrektur, 'A06A - Laxanzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07AA06' as ATC, 'Paromomycin' as BezKorrektur, 'A07A - Intestinale Antiinfektiva (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07AA09' as ATC, 'Vancomycin' as BezKorrektur, 'A07A - Intestinale Antiinfektiva (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07BC01' as ATC, 'Pektin' as BezKorrektur, 'A07B - Intestinale Adsorbenzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07BC51' as ATC, 'Apfelpulver' as BezKorrektur, 'A07B - Intestinale Adsorbenzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07DA02' as ATC, 'Opium' as BezKorrektur, 'A07D - Motilitätshemmer (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07DA03' as ATC, 'Loperamid' as BezKorrektur, 'A07D - Motilitätshemmer (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07EC02' as ATC, 'Mesalazin' as BezKorrektur, 'A07E - Intestinale Antiphlogistika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07FA01' as ATC, 'Lactobacillus gasseri' as BezKorrektur, 'A07F - Mikrobielle Antidiarrhoika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07FA02' as ATC, 'Saccharomyces boulardii' as BezKorrektur, 'A07F - Mikrobielle Antidiarrhoika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07FA06' as ATC, 'Escherichia coli' as BezKorrektur, 'A07F - Mikrobielle Antidiarrhoika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A09AA02' as ATC, 'Pankreatin' as BezKorrektur, 'A09A - Digestiva, incl. Enzyme (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10A' as ATC, 'Insulin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AB01' as ATC, 'Normalinsulin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AB01' as ATC, 'Alt-Insulin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AB04' as ATC, 'Insulin lispro' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AB04' as ATC, 'Insulin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AB05' as ATC, 'Insulin aspart' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AC01' as ATC, 'NPH-Insulin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AC01' as ATC, 'Verzögerungsinsulin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AC03' as ATC, 'Zink-Insulin (Schwein)' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AD01' as ATC, 'NPH-Mischinsulin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AD05' as ATC, 'Mischinsulin aspart' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AE04' as ATC, 'Insulin glargin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10BA02' as ATC, 'Metformin' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A10BB01' as ATC, 'Glibenclamid' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A10BB08' as ATC, 'Gliquidon' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A10BB12' as ATC, 'Glimepirid' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A10BF01' as ATC, 'Acarbose' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A10BF02' as ATC, 'Miglitol' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A10BG02' as ATC, 'Rosiglitazon' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A10BG03' as ATC, 'Pioglitazon' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A10BX02' as ATC, 'Repaglinid' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A10BX03' as ATC, 'Nateglinid' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'A11AB50' as ATC, 'Multivitaminkombination' as BezKorrektur, 'A11A - Multivitamine, Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11AB50' as ATC, 'Vitamine' as BezKorrektur, 'A11A - Multivitamine, Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11AH30' as ATC, 'Dexpanthenol' as BezKorrektur, 'A11A - Multivitamine, Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11CA01' as ATC, 'Retinol' as BezKorrektur, 'A11C - Vitamin A und D, inkl. deren Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11CC02' as ATC, 'Dihydrotachysterol' as BezKorrektur, 'A11C - Vitamin D, inkl. deren Kombinationen (0)' as Untergruppe, 'Vitamin D' as Dokumentation UNION ALL
					SELECT 'A11CC03' as ATC, 'Alfacalcidol' as BezKorrektur, 'A11C - Vitamin D, inkl. deren Kombinationen (0)' as Untergruppe, 'Vitamin D' as Dokumentation UNION ALL
					SELECT 'A11CC04' as ATC, 'Calcitriol' as BezKorrektur, 'A11C - Vitamin D, inkl. deren Kombinationen (0)' as Untergruppe, 'Vitamin D' as Dokumentation UNION ALL
					SELECT 'A11CC05' as ATC, 'Colecalciferol' as BezKorrektur, 'A11C - Vitamin D, inkl. deren Kombinationen (0)' as Untergruppe, 'Vitamin D' as Dokumentation UNION ALL
					SELECT 'A11DA01' as ATC, 'Thiamin' as BezKorrektur, 'A11D - Vitamin B1, rein und in Kombination mit Vitamin B6 und Vitamin B1<S (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11DA05' as ATC, 'Benfotiamin' as BezKorrektur, 'A11D - Vitamin B1, rein und in Kombination mit Vitamin B6 und Vitamin B1<S (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11DB01' as ATC, 'Thiamin/Pyridoxin' as BezKorrektur, 'A11D - Vitamin B1, rein und in Kombination mit Vitamin B6 und Vitamin B1<S (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11EA01' as ATC, 'Vitamin-B-Komplex, rein' as BezKorrektur, 'A11E - Vitamin-B-Komplex, inkl. Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11EB01' as ATC, 'Ascorbinsäure/Vitamin-B-Komplex' as BezKorrektur, 'A11E - Vitamin-B-Komplex, inkl. Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11GA01' as ATC, 'Ascorbinsäure' as BezKorrektur, 'A11G - Ascorbinsäure (Vitamin C), inkl. Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11HA02' as ATC, 'Pyridoxin' as BezKorrektur, 'A11H - Andere Vitamin-Präparate, rein (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11HA03' as ATC, 'Tocopherol' as BezKorrektur, 'A11H - Andere Vitamin-Präparate, rein (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11HA05' as ATC, 'Biotin' as BezKorrektur, 'A11H - Andere Vitamin-Präparate, rein (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11HA30' as ATC, 'Dexpanthenol' as BezKorrektur, 'A11H - Andere Vitamin-Präparate, rein (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11JC50' as ATC, 'Hirse/Calcium pantothenat/Cystin' as BezKorrektur, 'A11J - Andere Vitaminpräparate, Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12AA03' as ATC, 'Calciumgluconat' as BezKorrektur, 'A12A - Calcium (0)' as Untergruppe, 'Calcium' as Dokumentation UNION ALL
					SELECT 'A12AA04' as ATC, 'Calciumcarbonat' as BezKorrektur, 'A12A - Calcium (0)' as Untergruppe, 'Calciumcarbonat' as Dokumentation UNION ALL
					SELECT 'A12AA10' as ATC, 'Calciumglucoheptonat' as BezKorrektur, 'A12A - Calcium (0)' as Untergruppe, 'Calcium' as Dokumentation UNION ALL
					SELECT 'A12AA20' as ATC, 'Calciumgluconat/Calciumsaccharat' as BezKorrektur, 'A12A - Calcium (0)' as Untergruppe, 'Calcium' as Dokumentation UNION ALL
					SELECT 'A12AA20' as ATC, 'Calcium' as BezKorrektur, 'A12A - Calcium (0)' as Untergruppe, 'Calcium' as Dokumentation UNION ALL
					SELECT 'A11CC20' as ATC, 'Colecalciferol/Calciumcarbonat' as BezKorrektur, 'A11C - Vitamin D, inkl. deren Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA01' as ATC, 'Kaliumchlorid' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA02' as ATC, 'Kaliumcitrat' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA04' as ATC, 'Kaliumhydrogencarbonat' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA30' as ATC, 'Kalium/Magnesium' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA30' as ATC, 'Kaliumcitrat/Kaliumhydrogencarbonat' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA52' as ATC, 'Kaliumcitrat/Kaliumhydrogencarbonat' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CA01' as ATC, 'Natriumchlorid' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CB05' as ATC, 'Zinkhydrogenaspartat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CB06' as ATC, 'Zinkorotat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CB0X' as ATC, 'Zink' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC02' as ATC, 'Magnesiumsulfat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC04' as ATC, 'Magnesiumcitrat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC05' as ATC, 'Magnesiumaspartat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC09' as ATC, 'Magnesiumorotat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC10' as ATC, 'Magnesiumoxid' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC30' as ATC, 'Magnesium' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CD01' as ATC, 'Natriumfluorid' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CE02' as ATC, 'Natriumselenit' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CG04' as ATC, 'Calciumketoglutarat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CG0X' as ATC, 'Calciumacetat/Magnesiumcarbonat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CX50' as ATC, 'Mineralstoffkombination' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AA01' as ATC, 'Levocarnitin' as BezKorrektur, 'A16A - Andere Präparate des Alimentären Systems und des Stoffwechsels (1)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AA04' as ATC, 'Mecaptamin' as BezKorrektur, 'A16A - Andere Präparate des Alimentären Systems und des Stoffwechsels (1)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AC02' as ATC, 'Natriumhydrogencarbonat' as BezKorrektur, 'A16A - Andere Präparate des Alimentären Systems und des Stoffwechsels (1)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AC51' as ATC, 'Citronensäure/Kaliumhydrogencarbonat/Trinatriumcitrat' as BezKorrektur, 'A16A - Andere Präparate des Alimentären Systems und des Stoffwechsels (1)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AC51' as ATC, 'Natriumhydrogencarbonat/Calciumcarbonat/Citronensäure' as BezKorrektur, 'A16A - Andere Präparate des Alimentären Systems und des Stoffwechsels (1)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AX01' as ATC, 'Thioctsäure' as BezKorrektur, 'A16A - Andere Präparate des Alimentären Systems und des Stoffwechsels (1)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AA03' as ATC, 'Warfarin' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AA04' as ATC, 'Phenprocoumon' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AA09' as ATC, 'Clorindion' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB01' as ATC, 'Heparin' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB04' as ATC, 'Dalteparin' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB05' as ATC, 'Enoxaparin' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB06' as ATC, 'Nadroparin' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB08' as ATC, 'Reviparin' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB10' as ATC, 'Tinzaparin' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB13' as ATC, 'Certoparin' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC04' as ATC, 'Clopidogrel' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC05' as ATC, 'Ticlopidin' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC06' as ATC, 'Acetylsalicylsäure' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC07' as ATC, 'Dipyridamol' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC13' as ATC, 'Abciximab' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AX05' as ATC, 'Fondaparinux' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02BA01' as ATC, 'Phytomenadion' as BezKorrektur, 'B02A - Antifibrinolytika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03AA01' as ATC, 'Eisen(II)-glycin-sulfat' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA02' as ATC, 'Eisen(II)fumarat' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA03' as ATC, 'Eisen(II)-gluconat' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA05' as ATC, 'Eisen(II)chlorid' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA07' as ATC, 'Eisen(II)sulfat' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AC02' as ATC, 'Eisen(III)hydroxid-Saccharose-Komplex' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AC07' as ATC, 'Eisen(III)-Natrium-D-gluconat-Komplex' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AD05' as ATC, 'Eisen/Folsäure' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03BA01' as ATC, 'Cyanocobalamin' as BezKorrektur, 'B03B - Vitamin B12 und Folsäure (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03BA51' as ATC, 'Cyanocobalamin/Folsäure' as BezKorrektur, 'B03B - Vitamin B12 und Folsäure (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03BB01' as ATC, 'Folsäure' as BezKorrektur, 'B03B - Vitamin B12 und Folsäure (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03XA01' as ATC, 'Epoetin beta' as BezKorrektur, 'B03X - Andere Antianämika (0)' as Untergruppe, 'B.8 Erythropoetin' as Dokumentation UNION ALL
					SELECT 'B03XA01' as ATC, 'Epoetin alfa' as BezKorrektur, 'B03X - Andere Antianämika (0)' as Untergruppe, 'B.8 Erythropoetin' as Dokumentation UNION ALL
					SELECT 'B03XA02' as ATC, 'Darbepoetin alfa' as BezKorrektur, 'B03X - Andere Antianämika (0)' as Untergruppe, 'B.8 Erythropoetin' as Dokumentation UNION ALL
					SELECT 'B05AA01' as ATC, 'Albumin' as BezKorrektur, 'B05A - Blut und zugehörige Produkte (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BA01' as ATC, 'Aminosäuren' as BezKorrektur, 'B05B - Infusionslösungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BA10' as ATC, 'parenterale Ernährung' as BezKorrektur, 'B05B - Infusionslösungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BB01' as ATC, 'Elektrolytlösung' as BezKorrektur, 'B05B - Infusionslösungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BB01' as ATC, 'Vollelektrolyt-Lösung' as BezKorrektur, 'B05B - Infusionslösungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05CB01' as ATC, 'Natriumchlorid' as BezKorrektur, 'B05C - Spüllösungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05CX03' as ATC, 'Glycin' as BezKorrektur, 'B05C - Spüllösungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05CX04' as ATC, 'Mannitol' as BezKorrektur, 'B05C - Spüllösungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XA01' as ATC, 'Kaliumchlorid' as BezKorrektur, 'B05X - Elektrolytlösungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B06AA11' as ATC, 'Bromelaine' as BezKorrektur, 'B06A - Andere Hämatologika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01AA04' as ATC, 'Digitoxin' as BezKorrektur, 'C01A - Herzglykoside (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BA01' as ATC, 'Chinidin' as BezKorrektur, 'C01B - Antiarrhythmika, Klasse I und III (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BA33' as ATC, 'Detajmium' as BezKorrektur, 'C01B - Antiarrhythmika, Klasse I und III (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BC03' as ATC, 'Propafenon' as BezKorrektur, 'C01B - Antiarrhythmika, Klasse I und III (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BC04' as ATC, 'Flecainid' as BezKorrektur, 'C01B - Antiarrhythmika, Klasse I und III (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BD01' as ATC, 'Amiodaron' as BezKorrektur, 'C01B - Antiarrhythmika, Klasse I und III (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01CA01' as ATC, 'Etilefrin' as BezKorrektur, 'C01C - Kardiostimulanzien, exkl. Herzglykoside (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01CA04' as ATC, 'Dopamin' as BezKorrektur, 'C01C - Kardiostimulanzien, exkl. Herzglykoside (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01DA02' as ATC, 'Glyceroltrinitrat' as BezKorrektur, 'C01D - Koronar-Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01DA05' as ATC, 'Pentaerithrityltetranitrat' as BezKorrektur, 'C01D - Koronar-Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01DA08' as ATC, 'Isosorbiddinitrat' as BezKorrektur, 'C01D - Koronar-Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01DA14' as ATC, 'Isosorbidmononitrat' as BezKorrektur, 'C01D - Koronar-Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01DX11' as ATC, 'Trapidil' as BezKorrektur, 'C01D - Koronar-Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01DX12' as ATC, 'Molsidomin' as BezKorrektur, 'C01D - Koronar-Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EB03' as ATC, 'Indometacin' as BezKorrektur, 'C01E - Andere Herz-Kreislauf-Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EB09' as ATC, 'Ubidecarenon' as BezKorrektur, 'C01E - Andere Herz-Kreislauf-Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EP51' as ATC, 'Weißdorn/Magnesium/Vitamin E' as BezKorrektur, 'C01E - Andere Herz-Kreislauf-Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EX52' as ATC, 'Campher/Ätherische Öle/Flavonoide/Gerbstoff' as BezKorrektur, 'C01E - Andere Herz-Kreislauf-Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C02AB02' as ATC, 'Methyldopa' as BezKorrektur, 'C02A - Zentral wirksame Antiadrenergika (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C02AC01' as ATC, 'Clonidin' as BezKorrektur, 'C02A - Zentral wirksame Antiadrenergika (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C02AC05' as ATC, 'Moxonidin' as BezKorrektur, 'C02A - Zentral wirksame Antiadrenergika (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C02CA01' as ATC, 'Prazosin' as BezKorrektur, 'C02C - Antiadrenergika, peripher wirksam (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C02CA04' as ATC, 'Doxazosin' as BezKorrektur, 'C02C - Antiadrenergika, peripher wirksam (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C02CA06' as ATC, 'Urapidil' as BezKorrektur, 'C02C - Antiadrenergika, peripher wirksam (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C02CA07' as ATC, 'Bunazosin' as BezKorrektur, 'C02C - Antiadrenergika, peripher wirksam (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C02DB01' as ATC, 'Dihydralazin' as BezKorrektur, 'C02D - Vasodilatatoren mit Wirkung auf die glatte Muskulatur (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C02DC01' as ATC, 'Minoxidil' as BezKorrektur, 'C02D - Vasodilatatoren mit Wirkung auf die glatte Muskulatur (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C02KX01' as ATC, 'Bosentan' as BezKorrektur, 'C02K - Andere Antihypertonika (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C03AA03' as ATC, 'Hydrochlorothiazid' as BezKorrektur, 'C03A - Low-ceiling-Diuretika, Thiazide (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03BA08' as ATC, 'Metolazon' as BezKorrektur, 'C03B - Low-ceiling-Diuretika, excl. Thiazide (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03BA10' as ATC, 'Xipamid' as BezKorrektur, 'C03B - Low-ceiling-Diuretika, excl. Thiazide (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03BX03' as ATC, 'Cicletanin' as BezKorrektur, 'C03B - Low-ceiling-Diuretika, excl. Thiazide (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03CA01' as ATC, 'Furosemid' as BezKorrektur, 'C03C - High-ceiling-Diuretika (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03EB01' as ATC, 'Furosemid/Spironolacton' as BezKorrektur, 'C03E - Diuretika und kaliumsparende Mittel, kombiniert (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03CA03' as ATC, 'Piretanid' as BezKorrektur, 'C03C - High-ceiling-Diuretika (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03CA04' as ATC, 'Torasemid' as BezKorrektur, 'C03C - High-ceiling-Diuretika (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03CC01' as ATC, 'Etacrynsäure' as BezKorrektur, 'C03C - High-ceiling-Diuretika (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03DA01' as ATC, 'Spironolacton' as BezKorrektur, 'C03D - Kaliumsparende Diuretika (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03EA41' as ATC, 'Amilorid/Hydrochlorothiazid' as BezKorrektur, 'C03E - Diuretika und kaliumsparende Mittel, kombiniert (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C03EA21' as ATC, 'Triamteren/Hydrochlorothiazid' as BezKorrektur, 'C03E - Diuretika und kaliumsparende Mittel, kombiniert (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'C04AD02' as ATC, 'Xantinolnicotinat' as BezKorrektur, 'C04A - Periphere Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AD03' as ATC, 'Pentoxifyllin' as BezKorrektur, 'C04A - Periphere Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AF01' as ATC, 'Kallidinogenase' as BezKorrektur, 'C04A - Periphere Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AX02' as ATC, 'Phenoxybenzamin' as BezKorrektur, 'C04A - Periphere Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AX21' as ATC, 'Naftidrofuryl' as BezKorrektur, 'C04A - Periphere Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AX37' as ATC, 'Diisopropylamin' as BezKorrektur, 'C04A - Periphere Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05AA11' as ATC, 'Fluocinonid' as BezKorrektur, 'C05A - Hämorrhoidenmittel, topisch (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05AD03' as ATC, 'Benzocain' as BezKorrektur, 'C05A - Hämorrhoidenmittel, topisch (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05AD04' as ATC, 'Cinchocain' as BezKorrektur, 'C05A - Hämorrhoidenmittel, topisch (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05BX01' as ATC, 'Calciumdobesilat' as BezKorrektur, 'C05B - Antivarikosa (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CA04' as ATC, 'Troxerutin' as BezKorrektur, 'C05C - Kapillarstabilisatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CP01' as ATC, 'Aesculus hippocastaneum (Rosskastanie)' as BezKorrektur, 'C05C - Kapillarstabilisatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AA05' as ATC, 'Propranolol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AA05/C02DB01' as ATC, 'Propranolol/Dihydralazin' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AA06' as ATC, 'Timolol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AA07' as ATC, 'Sotalol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AB02' as ATC, 'Metoprolol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AB03' as ATC, 'Atenolol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AB05' as ATC, 'Betaxolol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AB07' as ATC, 'Bisoprolol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AB08' as ATC, 'Celiprolol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AB12' as ATC, 'Nebivolol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AB13' as ATC, 'Talinolol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07AG02' as ATC, 'Carvedilol' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C07BB02' as ATC, 'Metoprolol/Hydrochlorothiazid' as BezKorrektur, 'C07B - Betablocker und Thiazide (0)' as Untergruppe, 'B.3 Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C08CA01' as ATC, 'Amlodipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08CA02' as ATC, 'Felodipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08CA03' as ATC, 'Isradipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08CA04' as ATC, 'Nicardipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08CA05' as ATC, 'Nifedipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08CA07' as ATC, 'Nisoldipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08CA08' as ATC, 'Nitrendipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08CA09' as ATC, 'Lacidipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08CA13' as ATC, 'Lercanidipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08CX01' as ATC, 'Mibefradil' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08DA01' as ATC, 'Verapamil' as BezKorrektur, 'C08D - Selektive Calciumkanalblocker mit vorwiegender Herzwirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C08DB01' as ATC, 'Diltiazem' as BezKorrektur, 'C08D - Selektive Calciumkanalblocker mit vorwiegender Herzwirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA01' as ATC, 'Captopril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA02' as ATC, 'Enalapril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA03' as ATC, 'Lisinopril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA04' as ATC, 'Perindopril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA05' as ATC, 'Ramipril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA07' as ATC, 'Benazepril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA08' as ATC, 'Cilazapril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA09' as ATC, 'Fosinopril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA10' as ATC, 'Trandolapril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA11' as ATC, 'Spirapril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09AA16' as ATC, 'Imidapril' as BezKorrektur, 'C09A - ACE-Hemmer, rein (0)' as Untergruppe, 'B.1 ACE-Hemmer/ Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09BA05' as ATC, 'Ramipiril/Hydrochlorothiazid' as BezKorrektur, 'C09B - ACE-Hemmer, Kombinationen (0)' as Untergruppe, 'B.1 ACE-Hemmer-Komb./ Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C09BA07' as ATC, 'Benazepril/Hydrochlorothiazid' as BezKorrektur, 'C09B - ACE-Hemmer, Kombinationen (0)' as Untergruppe, 'B.1 ACE-Hemmer-Komb./ Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C09BA09' as ATC, 'Fosinopril/Hydrochlorothiazid' as BezKorrektur, 'C09B - ACE-Hemmer, Kombinationen (0)' as Untergruppe, 'B.1 ACE-Hemmer-Komb./ Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C09BB05' as ATC, 'Ramipril/Felodipin' as BezKorrektur, 'C09B - ACE-Hemmer, Kombinationen (0)' as Untergruppe, 'B.1 ACE-Hemmer-Komb./ Antihypertensivum+Antihypert' as Dokumentation UNION ALL
					SELECT 'C09CA01' as ATC, 'Losartan' as BezKorrektur, 'C09C - Angiotensin-II-Antagonisten, rein (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09CA02' as ATC, 'Eprosartan' as BezKorrektur, 'C09C - Angiotensin-II-Antagonisten, rein (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09CA03' as ATC, 'Valsartan' as BezKorrektur, 'C09C - Angiotensin-II-Antagonisten, rein (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09CA04' as ATC, 'Irbesartan' as BezKorrektur, 'C09C - Angiotensin-II-Antagonisten, rein (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09CA06' as ATC, 'Candesartan' as BezKorrektur, 'C09C - Angiotensin-II-Antagonisten, rein (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09CA07' as ATC, 'Telmisartan' as BezKorrektur, 'C09C - Angiotensin-II-Antagonisten, rein (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09CA08' as ATC, 'Olmesartan' as BezKorrektur, 'C09C - Angiotensin-II-Antagonisten, rein (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09DA01' as ATC, 'Losartan/Hydrochlorothiazid' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C09DA03' as ATC, 'Valsartan/Hydrochlorothiazid' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C09DA04' as ATC, 'Irbesartan/Hydrochlorothiazid' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C09DA06' as ATC, 'Candesartan/Hydrochlorothiazid' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C10AA01' as ATC, 'Simvastatin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, 'B.7 Statine' as Dokumentation UNION ALL
					SELECT 'C10AA02' as ATC, 'Lovastatin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, 'B.7 Statine' as Dokumentation UNION ALL
					SELECT 'C10AA03' as ATC, 'Pravastatin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, 'B.7 Statine' as Dokumentation UNION ALL
					SELECT 'C10AA04' as ATC, 'Fluvastatin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, 'B.7 Statine' as Dokumentation UNION ALL
					SELECT 'C10AA04' as ATC, 'Fluvastatin (pc)' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, 'B.7 Statine' as Dokumentation UNION ALL
					SELECT 'C10AA05' as ATC, 'Atorvastatin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, 'B.7 Statine' as Dokumentation UNION ALL
					SELECT 'C10AA06' as ATC, 'Cerivastatin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, 'B.7 Statine' as Dokumentation UNION ALL
					SELECT 'C10AB01' as ATC, 'Clofibrat' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AB02' as ATC, 'Bezafibrat' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AB04' as ATC, 'Gemfibrozil' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AB05' as ATC, 'Fenofibrat' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AC01' as ATC, 'Colestyramin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AC02' as ATC, 'Colestipol' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AP02' as ATC, 'Sojabohnenphospholipide' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AX06' as ATC, 'Omega-3-Triglyceride' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AX09' as ATC, 'Ezetimib' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AA01' as ATC, 'Nystatin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AC08' as ATC, 'Ketoconazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AE14' as ATC, 'Ciclopirox' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01BA02' as ATC, 'Terbinafin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D04AA34' as ATC, 'Chlorphenoxamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D05AX02' as ATC, 'Calcipotriol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D05BB02' as ATC, 'Acitretin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06AA04' as ATC, 'Tetracyclin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06AX01' as ATC, 'Fusidinsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06BB10' as ATC, 'Imiquimod' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AG02' as ATC, 'Povidon-Iod' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AH03' as ATC, 'Oxychinolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D09AA10' as ATC, 'Clioquinol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AE01' as ATC, 'Benzoylperoxid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AF02' as ATC, 'Erythromycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AC30' as ATC, 'Steinkohlenteer' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02AB01' as ATC, 'Methylergometrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02CE05' as ATC, 'Traubensilberkerzewurzelsockextrakt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA05' as ATC, 'Norethisteronacetat/Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA07' as ATC, 'Levonorgestrel/Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA09' as ATC, 'Desogestrel/Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA12' as ATC, 'Drospirenon/Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA17' as ATC, 'Dienogest/Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03BA03' as ATC, 'Testosteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03BB01' as ATC, 'Mesterolon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03CA03' as ATC, 'Estradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03CA10' as ATC, 'Mestranol/Chlormadinacetat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03CA57' as ATC, 'Konjugierte Estrogene' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03DB03' as ATC, 'Medrogeston' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03DB06' as ATC, 'Chlormadinon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03DC02' as ATC, 'Norethisteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03FA01' as ATC, 'Estradiol/Norethisteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03FB01' as ATC, 'Norgestrel/Estradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03FB05' as ATC, 'Norethisteron/Estradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03FB08' as ATC, 'Dydrogesteron/Estradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03FB09' as ATC, 'Levonorgestrel/Estradiol/Estriol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03HB01' as ATC, 'Cyproteron/Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03XC01' as ATC, 'Raloxifen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BC01' as ATC, 'Kalium-Natrium-Hydrogencitrat' as BezKorrektur, 'G04BC-Harnkonkrement lösende Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BC50' as ATC, 'Kaliumdihydrogenphosphat/Natriummonohydrogenphosphat' as BezKorrektur, 'G04BC-Harnkonkrement lösende Mittel' as Untergruppe, 'Phosphatsupplementation' as Dokumentation UNION ALL
					SELECT 'G04BC50' as ATC, 'Natriumdihydrogenphosphat/Kaliumhydrogencarbonat' as BezKorrektur, 'G04BC-Harnkonkrement lösende Mittel' as Untergruppe, 'Phosphatsupplementation' as Dokumentation UNION ALL
					SELECT 'G04BD04' as ATC, 'Oxybutynin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BD06' as ATC, 'Propiverin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BD07' as ATC, 'Tolterodin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BD09' as ATC, 'Trospium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BE01' as ATC, 'Alprostadil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BE03' as ATC, 'Sildenafil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BE08' as ATC, 'Tadalafil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CA01' as ATC, 'Alfuzosin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CA02' as ATC, 'Tamsulosin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CB01' as ATC, 'Finasterid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CP01' as ATC, 'Beta-Sitosterin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CP02' as ATC, 'Brennnesselwurzeltrockenextrakt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CP03' as ATC, 'Gräserpollenextrakt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CX02' as ATC, 'Serenoa repens' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H02AA02' as ATC, 'Fludrocortison' as BezKorrektur, 'H02AA-Mineralocorticoide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H02AB02' as ATC, 'Dexamethason' as BezKorrektur, 'H02AB*-Glucocorticoide' as Untergruppe, 'A.6 Steroide' as Dokumentation UNION ALL
					SELECT 'H02AB04' as ATC, 'Methylprednisolon' as BezKorrektur, 'H02AB*-Glucocorticoide' as Untergruppe, 'A.6 Steroide' as Dokumentation UNION ALL
					SELECT 'H02AB06' as ATC, 'Prednisolon' as BezKorrektur, 'H02AB*-Glucocorticoide' as Untergruppe, 'A.6 Steroide' as Dokumentation UNION ALL
					SELECT 'H02AB09' as ATC, 'Hydrocortison' as BezKorrektur, 'H02AB*-Glucocorticoide' as Untergruppe, 'A.6 Steroide' as Dokumentation UNION ALL
					SELECT 'H02AB13' as ATC, 'Deflazacort' as BezKorrektur, 'H02AB*-Glucocorticoide' as Untergruppe, 'A.6 Steroide' as Dokumentation UNION ALL
					SELECT 'H03AA01' as ATC, 'Levothyroxin' as BezKorrektur, 'H03A-Schilddrüsenhormone' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03AA02' as ATC, 'Liothyronin' as BezKorrektur, 'H03A-Schilddrüsenhormone' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03AA03' as ATC, 'Liothyronin/Levothyroxin' as BezKorrektur, 'H03A-Schilddrüsenhormone' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03BB02' as ATC, 'Thiamazol' as BezKorrektur, 'H03B-Thyreostatika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03CA01' as ATC, 'Kaliumiodid' as BezKorrektur, 'H03C-Iodtherapeutika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H05BA01' as ATC, 'Calcitonin' as BezKorrektur, 'H05B-Nebenschilddrüsenhormonantagonisten' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01AA02/R05CB06' as ATC, 'Doxycyclin/Ambroxol' as BezKorrektur, 'J01A - Tetracycline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01AA08' as ATC, 'Minocyclin' as BezKorrektur, 'J01A - Tetracycline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CA01' as ATC, 'Ampicillin' as BezKorrektur, 'J01CA - Breitspektrum-Penicilline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CA04' as ATC, 'Amoxicillin' as BezKorrektur, 'J01CA - Breitspektrum-Penicilline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CA12' as ATC, 'Piperacillin' as BezKorrektur, 'J01CA - Breitspektrum-Penicilline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CE02' as ATC, 'Phenoxymethylpenicillin' as BezKorrektur, 'J01CE - Beta-Lactamase-sensitive Penicilline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CE04' as ATC, 'Azidocillin' as BezKorrektur, 'J01CE - Beta-Lactamase-sensitive Penicilline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CF04' as ATC, 'Oxacillin' as BezKorrektur, 'JJ01CF - Beta-Lactamase-resistente Penicilline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CF05' as ATC, 'Flucloxacillin' as BezKorrektur, 'JJ01CF - Beta-Lactamase-resistente Penicilline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CG01' as ATC, 'Sulbactam' as BezKorrektur, 'J01CG - Beta-Lactamase-Inhibitoren' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CR01' as ATC, 'Ampicillin/Sulbactam' as BezKorrektur, 'J01CR - Kombinationen von Penicillinen, inkl. Betalactamase-Inhibitoren' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CR02' as ATC, 'Amoxicillin/Clavulansäure' as BezKorrektur, 'J01CR - Kombinationen von Penicillinen, inkl. Betalactamase-Inhibitoren' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CR04' as ATC, 'Sultamicillin' as BezKorrektur, 'J01CR - Kombinationen von Penicillinen, inkl. Betalactamase-Inhibitoren' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CR05' as ATC, 'Piperacillin/Tazobactam' as BezKorrektur, 'J01CR - Kombinationen von Penicillinen, inkl. Betalactamase-Inhibitoren' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DB01' as ATC, 'Cefalexin' as BezKorrektur, 'J01DB - Cephalosporine der 1. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DC02' as ATC, 'Cefuroxim' as BezKorrektur, 'J01DC - Cephalosporine der 2. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DC04' as ATC, 'Cefaclor' as BezKorrektur, 'J01DC - Cephalosporine der 2. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DB05' as ATC, 'Cefadroxil' as BezKorrektur, 'J01DB - Cephalosporine der 1. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DD02' as ATC, 'Ceftazidim' as BezKorrektur, 'J01DD - Cephalosporine der 3. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DD04' as ATC, 'Ceftriaxon' as BezKorrektur, 'J01DD - Cephalosporine der 3. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DD08' as ATC, 'Cefixim' as BezKorrektur, 'J01DD - Cephalosporine der 3. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DD14' as ATC, 'Ceftibuten' as BezKorrektur, 'J01DD - Cephalosporine der 3. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DH02' as ATC, 'Meropenem' as BezKorrektur, 'J01DH - Carbapeneme' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DH51' as ATC, 'Imipenem und Enzym-Inhibitor' as BezKorrektur, 'J01DH - Carbapeneme' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01EA01' as ATC, 'Trimethoprim' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Cotrimoxazol' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE09' as ATC, 'Trimethoprim/Sulfamerazin' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01FA06' as ATC, 'Roxithromycin' as BezKorrektur, 'J01FA - Makrolide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01FA09' as ATC, 'Clarithromycin' as BezKorrektur, 'J01FA - Makrolide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01FA10' as ATC, 'Azithromycin' as BezKorrektur, 'J01FA - Makrolide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01FF01' as ATC, 'Clindamycin' as BezKorrektur, 'J01FA - Makrolide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01GB03' as ATC, 'Gentamicin' as BezKorrektur, 'J01G Aminoglycoside' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01MA01' as ATC, 'Ofloxacin' as BezKorrektur, 'J01MA - Fluorchinolone' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01MA02' as ATC, 'Ciprofloxacin' as BezKorrektur, 'J01MA - Fluorchinolone' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01MA06' as ATC, 'Norfloxacin' as BezKorrektur, 'J01MA - Fluorchinolone' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01MA12' as ATC, 'Levofloxacin' as BezKorrektur, 'J01MA - Fluorchinolone' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01MA14' as ATC, 'Moxifloxacin' as BezKorrektur, 'J01MA - Fluorchinolone' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XA02' as ATC, 'Teicoplanin' as BezKorrektur, 'J01XA - Glykopeptid-Antibiotika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XD01' as ATC, 'Metronidazol' as BezKorrektur, 'J01XD - Imidazol-Derivate, parenteral' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XE01' as ATC, 'Nitrofurantoin' as BezKorrektur, 'J01XE - Nitrofuran-Derivate' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XX08' as ATC, 'Linezolid' as BezKorrektur, 'J01XX - Andere Antibiotika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J02AC01' as ATC, 'Fluconazol' as BezKorrektur, 'J02AC - Triazol-Derivate' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J02AC02' as ATC, 'Itraconazol' as BezKorrektur, 'J02AC - Triazol-Derivate' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AB02' as ATC, 'Rifampicin' as BezKorrektur, 'J04A - Mittel zur Behandlung der Tuberkulose' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AC01' as ATC, 'Isoniazid' as BezKorrektur, 'J04A - Mittel zur Behandlung der Tuberkulose' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AC51' as ATC, 'Isoniazid/Pyridoxin' as BezKorrektur, 'J04A - Mittel zur Behandlung der Tuberkulose' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AK02' as ATC, 'Ethambutol' as BezKorrektur, 'J04A - Mittel zur Behandlung der Tuberkulose' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AB01' as ATC, 'Aciclovir' as BezKorrektur, 'J05AB - Nucleoside und Nucleotide, exkl. Reverse-Transcriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AB04' as ATC, 'Ribavirin' as BezKorrektur, 'J05AB - Nucleoside und Nucleotide, exkl. Reverse-Transcriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AB06' as ATC, 'Ganciclovir' as BezKorrektur, 'J05AB - Nucleoside und Nucleotide, exkl. Reverse-Transcriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AB09' as ATC, 'Famciclovir' as BezKorrektur, 'J05AB - Nucleoside und Nucleotide, exkl. Reverse-Transcriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AB11' as ATC, 'Valaciclovir' as BezKorrektur, 'J05AB - Nucleoside und Nucleotide, exkl. Reverse-Transcriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AB14' as ATC, 'Valganciclovir' as BezKorrektur, 'J05AB - Nucleoside und Nucleotide, exkl. Reverse-Transcriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AB15' as ATC, 'Brivudin' as BezKorrektur, 'J05AB - Nucleoside und Nucleotide, exkl. Reverse-Transcriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF08' as ATC, 'Adefovir' as BezKorrektur, 'J05AF - Nucleosidale und nucleotidale Reverse-Transkriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF05' as ATC, 'Lamivudin' as BezKorrektur, 'J05AF - Nucleosidale und nucleotidale Reverse-Transkriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BA02' as ATC, 'Immunglobulin G' as BezKorrektur, 'J06BA - Immunglobuline, human, unspezifisch' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB09' as ATC, 'Cytomegalievirus-Immunglobulin' as BezKorrektur, 'J06BB - Spezifische Immunglobuline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AA01' as ATC, 'Cyclophosphamid' as BezKorrektur, 'L01AA - Stickstofflost-Analoga' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BA01' as ATC, 'Methotrexat' as BezKorrektur, 'L01BA - Folsäure-Analoga' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BB02' as ATC, 'Mercaptopurin' as BezKorrektur, 'L01BB - Purin-Analoga' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01DC01' as ATC, 'Bleomycin' as BezKorrektur, 'L01DC - Andere zytotoxische Antibiotika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX14' as ATC, 'Tretinoin' as BezKorrektur, 'L01XX - Andere antineoplastische Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02BA01' as ATC, 'Tamoxifen' as BezKorrektur, 'L02BA - Antiestrogene' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02BB01' as ATC, 'Flutamid' as BezKorrektur, 'L02BB - Antiandrogene' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02BB03' as ATC, 'Bicalutamid' as BezKorrektur, 'L02BB - Antiandrogene' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AA02' as ATC, 'Filgrastim' as BezKorrektur, 'L03AA - Koloniestimulierende Faktoren' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AB07' as ATC, 'Interferon beta' as BezKorrektur, 'L03AB - Interferone' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AD01' as ATC, 'Ciclosporin' as BezKorrektur, 'L04AD01 - Selektive Immunsuppressiva' as Untergruppe, 'CNI CsA' as Dokumentation UNION ALL
					SELECT 'L04AA02' as ATC, 'Muromonab-CD3' as BezKorrektur, 'L04AA02 - Selektive Immunsuppressiva' as Untergruppe, 'OKT3' as Dokumentation UNION ALL
					SELECT 'L04AA03' as ATC, 'Antilymphozytäres Immunglobulin' as BezKorrektur, 'L04AA03 - Selektive Immunsuppressiva' as Untergruppe, 'ALG' as Dokumentation UNION ALL
					SELECT 'L04AA04' as ATC, 'Antithymozytäres Immunglobulin' as BezKorrektur, 'L04AA04 - Selektive Immunsuppressiva' as Untergruppe, 'ATG' as Dokumentation UNION ALL
					SELECT 'L04AD02' as ATC, 'Tacrolimus' as BezKorrektur, 'L04AD02 - Selektive Immunsuppressiva' as Untergruppe, 'CNI Tac' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolat' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolatmofetil' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolatnatrium' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA08' as ATC, 'Daclizumab' as BezKorrektur, 'L04AA08 - Selektive Immunsuppressiva' as Untergruppe, 'Ind Zenapax' as Dokumentation UNION ALL
					SELECT 'L04AA09' as ATC, 'Basiliximab' as BezKorrektur, 'L04AA09 - Selektive Immunsuppressiva' as Untergruppe, 'Ind Simulect' as Dokumentation UNION ALL
					SELECT 'L04AA10' as ATC, 'Sirolimus' as BezKorrektur, 'L04AA10 - Selektive Immunsuppressiva' as Untergruppe, 'mTOR Sirolimus' as Dokumentation UNION ALL
					SELECT 'L04AA13' as ATC, 'Leflunomid' as BezKorrektur, 'L04AA13 - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L04AA18' as ATC, 'Everolimus (pc)' as BezKorrektur, 'L04AA18 - Selektive Immunsuppressiva' as Untergruppe, 'mTOR Everolimus' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolatmofetil (pc)' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA18' as ATC, 'Everolimus' as BezKorrektur, 'L04AA18 - Selektive Immunsuppressiva' as Untergruppe, 'mTOR Everolimus' as Dokumentation UNION ALL
					SELECT 'L04AX' as ATC, 'Anti-CD4-AK' as BezKorrektur, 'L04AX - Andere Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L04AX01' as ATC, 'Azathioprin' as BezKorrektur, 'L04AX - Andere Immunsuppressiva' as Untergruppe, 'Aza' as Dokumentation UNION ALL
					SELECT 'M01AA01' as ATC, 'Phenylbutazon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AA06' as ATC, 'Kebuzon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AB05' as ATC, 'Diclofenac' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AB55' as ATC, 'Diclofenac/Misoprostol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AE01' as ATC, 'Ibuprofen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AH01' as ATC, 'Celecoxib' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AH02' as ATC, 'Rofecoxib' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AX05' as ATC, 'Glucosaminsulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AA09' as ATC, 'Bufexamac' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AD01' as ATC, 'Propylnicotinat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03BX01' as ATC, 'Baclofen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03BX02' as ATC, 'Tizanidin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03BX04' as ATC, 'Tolperison' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03BX07' as ATC, 'Tetrazepam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M04AA01' as ATC, 'Allopurinol' as BezKorrektur, 'M04A-Gichtmittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M04AB03' as ATC, 'Benzbromaron' as BezKorrektur, 'M04A-Gichtmittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M04AC01' as ATC, 'Colchizin' as BezKorrektur, 'M04A-Gichtmittel' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'M05BA02' as ATC, 'Clodronsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA04' as ATC, 'Alendronsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA06' as ATC, 'Ibandronsäure' as BezKorrektur, 'M05BA-Bisphosphonate' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA07' as ATC, 'Risedronsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BX02' as ATC, 'Aluminiumhydroxychlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AA02' as ATC, 'Chinin/Aminophyllin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AB52' as ATC, 'Bromelain/Trypsin/Rutosid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AP03' as ATC, 'Teufelskrallenwurzelextrakt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AP04' as ATC, 'Brennnesselblätterextrakt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AX09' as ATC, 'Escherichia coli' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07XB54' as ATC, 'Uridinphosphatkombination' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AA01' as ATC, 'Morphin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AA55' as ATC, 'Oxycodon/Naloxon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AB03' as ATC, 'Fentanyl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AC03' as ATC, 'Piritramid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AE01' as ATC, 'Buprenorphin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AX01' as ATC, 'Tilidin' as BezKorrektur, 'N02AX-Andere Opioide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AX02' as ATC, 'Tramadol' as BezKorrektur, 'N02AX-Andere Opioide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AX51' as ATC, 'Tilidin/Naloxon' as BezKorrektur, 'N02AX-Andere Opioide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02BB02' as ATC, 'Metamizol' as BezKorrektur, 'N02B-andere Analgetika und Antipyretika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02BE01' as ATC, 'Paracetamol' as BezKorrektur, 'N02B-andere Analgetika und Antipyretika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02BG07' as ATC, 'Flupirtin' as BezKorrektur, 'N02B-andere Analgetika und Antipyretika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CA01' as ATC, 'Dihydroergotamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CC01' as ATC, 'Sumatriptan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CP01' as ATC, 'Pestwurzelextrakt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CX01' as ATC, 'Pizotifen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AB02' as ATC, 'Phenytoin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AE01' as ATC, 'Clonazepam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AF01' as ATC, 'Carbamazepin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AG01' as ATC, 'Valproinsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX12' as ATC, 'Gabapentin' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX14' as ATC, 'Levetiracetam' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX16' as ATC, 'Pregabalin' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BA01' as ATC, 'Levodopa' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BA02' as ATC, 'Levodopa/Carbidopa' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BA11' as ATC, 'Levodopa/Benserazid' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BA10' as ATC, 'Levodopa/Carbidopa' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BC01' as ATC, 'Bromocriptin' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AB02' as ATC, 'Fluphenazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AB10' as ATC, 'Perazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AC02' as ATC, 'Thioridazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AD01' as ATC, 'Haloperidol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AF03' as ATC, 'Chlorprothixen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AH03' as ATC, 'Olanzapin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AL01' as ATC, 'Sulpirid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BA01' as ATC, 'Diazepam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BA03' as ATC, 'Medazepam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BA06' as ATC, 'Lorazepam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BA08' as ATC, 'Bromazepam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BA09' as ATC, 'Clobazam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BA12' as ATC, 'Alprazolam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BB01' as ATC, 'Hydroxyzin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BE01' as ATC, 'Buspironhydrochlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BP02' as ATC, 'Kava Kava (Rauschpfeffer)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CD02' as ATC, 'Nitrazepam' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CD03' as ATC, 'Flunitrazepam' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CD06' as ATC, 'Lormetazepam' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CD08' as ATC, 'Midazolam' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CF01' as ATC, 'Zopiclon' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CF02' as ATC, 'Zolpidem' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CM09' as ATC, 'Baldrian' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CM21' as ATC, 'Doxylamin' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CP50' as ATC, 'Baldrian/Hopfen/Passionsblume' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CP51' as ATC, 'Avena sativa/Ignatia/Valeriana/Selenium/Gelsemium' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AA02' as ATC, 'Imipramin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AA05' as ATC, 'Opipramol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AA06' as ATC, 'Trimipramin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AA09' as ATC, 'Amitriptylin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AA10' as ATC, 'Nortriptylin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AA12' as ATC, 'Doxepin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AA21' as ATC, 'Maprotilin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AB03' as ATC, 'Fluoxetin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AB04' as ATC, 'Citalopram' as BezKorrektur, 'N06AB-Selektive Serotonin-Wiederaufnahmehemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AB06' as ATC, 'Sertralin' as BezKorrektur, 'N06AB-Selektive Serotonin-Wiederaufnahmehemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AG02' as ATC, 'Moclobemid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AP01' as ATC, 'Hypericum perforatum (Johanniskraut)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AX11' as ATC, 'Mirtazapin' as BezKorrektur, 'N06AX-Andere Antidepressiva' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06BX01' as ATC, 'Meclofenoxat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06BX03' as ATC, 'Piracetam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DX02' as ATC, 'Ginkgo biloba' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07AA03' as ATC, 'Distigmin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07BA01' as ATC, 'Nicotin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07BC02' as ATC, 'Levomethadon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07CA01' as ATC, 'Betahistin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07CA03' as ATC, 'Flunarizin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07XH20' as ATC, 'Cocculus/Conium/Ambra/Petroleum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P01BA01' as ATC, 'Chloroquin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P01BC02' as ATC, 'Mefloquin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P01PD51' as ATC, 'Sulfadoxin/Pyrimethamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AA05' as ATC, 'Oxymetazolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AA07' as ATC, 'Xylometazolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AX06' as ATC, 'Mupirocin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AX10' as ATC, 'Natriumchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AC02' as ATC, 'Salbutamol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AC04' as ATC, 'Fenoterol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AC12' as ATC, 'Salmeterol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AC13' as ATC, 'Formoterol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AK03' as ATC, 'Ipratropiumbromid/Fenoterol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AK06' as ATC, 'Salmeterol/Fluticason' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AK07' as ATC, 'Budesonid/Formoterol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03BA02' as ATC, 'Budesonid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03BA05' as ATC, 'Fluticason' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03BB01' as ATC, 'Ipratropiumbromid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03BB02' as ATC, 'Oxitropiumbromid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03BB04' as ATC, 'Tiotropiumbromid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03DA04' as ATC, 'Theophyllin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03DA05' as ATC, 'Aminophyllin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CA10' as ATC, 'Pflanzenextraktkombination' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CA19' as ATC, 'Myrtol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CA22' as ATC, 'Emser Salz' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CB01' as ATC, 'Acetylcystein' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CB02' as ATC, 'Bromhexin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CB06' as ATC, 'Ambroxol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05DA04' as ATC, 'Codein' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05DB03' as ATC, 'Clobutinol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05DB05' as ATC, 'Pentoxyverin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AA02' as ATC, 'Diphenhydramin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AA04' as ATC, 'Clemastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AB03' as ATC, 'Dimetinden' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AE07' as ATC, 'Cetirizin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AE09' as ATC, 'Levocetirizin' as BezKorrektur, 'R06A-Antihistaminika systemisch' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AX11' as ATC, 'Astemizol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AX13' as ATC, 'Loratadin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AX25' as ATC, 'Mizolastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06HX26' as ATC, 'Fexofenadin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01EA03' as ATC, 'Apraclonidin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01EB01' as ATC, 'Pilocarpin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01EC03' as ATC, 'Dorzolamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01ED01' as ATC, 'Timolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01ED04' as ATC, 'Metipranolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01ED51' as ATC, 'Dorzolamid/Timolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01ED51' as ATC, 'Latanoprost/Timolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01EE04' as ATC, 'Travoprost' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01EX03' as ATC, 'Latanoprost' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA20' as ATC, 'Hypromellose' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XC02' as ATC, 'Povidon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S02DC02' as ATC, 'Docusat-Natrium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S03CA01' as ATC, 'Polymyxin B sulfate/neomycin sulfate/gramicidin.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB15' as ATC, 'Naloxon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB26' as ATC, 'Methionin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AE01' as ATC, 'Polystyrolsulfonat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AE02' as ATC, 'Sevelamer' as BezKorrektur, '' as Untergruppe, 'PB-Sevelamer' as Dokumentation UNION ALL
					SELECT 'V03AF01' as ATC, 'Mesna' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AF03' as ATC, 'Calciumfolinat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V06DB50' as ATC, 'Trinknahrung' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V06DX' as ATC, 'Selen/Antioxydantien' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V06DX50' as ATC, 'Mineralsalzkombination' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04PP00' as ATC, 'Placebo' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'FK 778 Studienmedikation' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'FTY 720 Studienmedikation' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'X00XX00' as ATC, 'Ethyllinolat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'X00XX00' as ATC, 'test4' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'X00XX00' as ATC, 'TAK' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'X00XX00' as ATC, 'test2' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05AD04' as ATC, 'Policresulen/Cinchocain' as BezKorrektur, 'C05A - Hämorrhoidenmittel, topisch (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12AA20' as ATC, 'Calciumgluconat/Calciumlactat' as BezKorrektur, 'A12A - Calcium (0)' as Untergruppe, 'Calcium' as Dokumentation UNION ALL
					SELECT 'C09BA05' as ATC, 'Ramipril/HCT' as BezKorrektur, 'C09B - ACE-Hemmer, Kombinationen (0)' as Untergruppe, 'B.1 ACE-Hemmer-Komb./ Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C09BB10' as ATC, 'Verapamil/Trandolapril' as BezKorrektur, 'C09B - ACE-Hemmer, Kombinationen (0)' as Untergruppe, 'B.1 ACE-Hemmer-Komb./ Antihypertensivum+Antihypert' as Dokumentation UNION ALL
					SELECT 'C09DA04' as ATC, 'Irbesartan/HCT' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'L04AD01' as ATC, 'Ciclosporin A' as BezKorrektur, 'L04AD01 - Selektive Immunsuppressiva' as Untergruppe, 'CNI CsA' as Dokumentation UNION ALL
					SELECT 'L04AD01' as ATC, 'CyA' as BezKorrektur, 'L04AD01 - Selektive Immunsuppressiva' as Untergruppe, 'CNI CsA' as Dokumentation UNION ALL
					SELECT 'L04AD01' as ATC, 'Cyclosporin A' as BezKorrektur, 'L04AD01 - Selektive Immunsuppressiva' as Untergruppe, 'CNI CsA' as Dokumentation UNION ALL
					SELECT 'L04AD01' as ATC, 'Cyclosporin' as BezKorrektur, 'L04AD01 - Selektive Immunsuppressiva' as Untergruppe, 'CNI CsA' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'SFZ/TMP' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Cotrim forte' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Co-trimoxazo' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Co-trimoxazol 960 mg' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'cotrimoxazol+trimethoprim' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Sulfamethoxazol' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Sulfamethoxazol/trimethoprim' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'TMP SMZ' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'TPM/SMZ' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Trimethoprim/SMZ' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Trimethoprim/Sulfamethoxa' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Co-trimoxazol 960 mg' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'TPM/SMZ' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Co-trimoxazol' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Co-trimoxazol 960 mg' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'L04AD02' as ATC, 'Tacrolismus' as BezKorrektur, 'L04AD02 - Selektive Immunsuppressiva' as Untergruppe, 'CNI Tac' as Dokumentation UNION ALL
					SELECT 'J01EE01' as ATC, 'Sulfamethoxazol/Trimethop' as BezKorrektur, 'J01E Trimethoprim/Sulfonamide' as Untergruppe, 'Beeinflussung Nierenfunktion' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolat Natrium' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolant-Sodium' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolat 360' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Myfortic' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolsäure' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'mycophenolsäure' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'MPA' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolat mofetil' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'C07AB02' as ATC, 'Metoprololsuccinat' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'B03XA01' as ATC, 'beta-Epoetin' as BezKorrektur, 'B03X - Andere Antianämika (0)' as Untergruppe, 'B.8 Erythropoetin' as Dokumentation UNION ALL
					SELECT 'B01AA07' as ATC, 'Acenocoumarol' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'AEB071' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'J05AX99' as ATC, 'AIC-Studienmedikation' as BezKorrektur, 'J05AX - Sonstige Antivirenmittel' as Untergruppe, 'Phase II/III' as Dokumentation UNION ALL
					SELECT 'C09XA02' as ATC, 'Aliskiren' as BezKorrektur, 'C09 Reninhemmer' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'M05BA04' as ATC, 'Alendronat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C08CA01' as ATC, 'Amlodipinmesilat' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'C09DB01' as ATC, 'Amlodipin/Valsartan' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'A01AB04' as ATC, 'Amphotericin' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03AC04' as ATC, 'Atracuriumbesilat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10AC01' as ATC, 'Basal-Insulin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'R03BA01' as ATC, 'Beclometason' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V06DB' as ATC, 'enterale Zusatznahrung' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CC07' as ATC, 'Frovatriptan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'FTY Studienmedikation' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'D05BX51' as ATC, 'Fumarat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03XA03' as ATC, 'mPEG Epoetin beta' as BezKorrektur, 'B03X - Andere Antianämika (0)' as Untergruppe, 'B.8 Erythropoetin' as Dokumentation UNION ALL
					SELECT 'N04BC06' as ATC, 'Cabergolin' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AX' as ATC, 'Campher/Ätherische Öle/Flavonoide/Gerbstoffe' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01ED51' as ATC, 'Brimonidin/Timolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GX01' as ATC, 'Cromoglicinsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AK05' as ATC, 'Cromoglicinsäure/Reproterol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03HA01' as ATC, 'Cyproteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D07AC01' as ATC, 'Betamethasonvalerat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'Belatacept' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'S01EC04' as ATC, 'Brinzolamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AX20' as ATC, 'Buflomedil' as BezKorrektur, 'C04A - Periphere Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA20' as ATC, 'Carbomer' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DC02' as ATC, 'Cefuroximaxetil' as BezKorrektur, 'J01DC - Cephalosporine der 2. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DD13' as ATC, 'Cefpodoxim' as BezKorrektur, 'J01DD - Cephalosporine der 3. Generation' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H05BX01' as ATC, 'Cinacalcet' as BezKorrektur, 'H05B-Nebenschilddrüsenhormonantagonisten' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AK07' as ATC, 'Beclometason/Formeterol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03GA01' as ATC, 'Choriongonadotrophin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC30' as ATC, 'Acetylsalicylsäure/Dipyridamol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA04' as ATC, 'Antithymozytenglobulin' as BezKorrektur, 'L04AA04 - Selektive Immunsuppressiva' as Untergruppe, 'ATG' as Dokumentation UNION ALL
					SELECT 'B03AD05' as ATC, 'Ammoniumeisen(II)sulfat/Folsäure' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B01AB04' as ATC, 'Dalteparin-Na' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB04' as ATC, 'Dalteparin-Natrium' as BezKorrektur, 'B01A - Antithrombotische Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AX99' as ATC, 'dän. Hagebutte' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BD10' as ATC, 'Darifenacin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AX26' as ATC, 'Desloratadin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AC09' as ATC, 'Desogestrel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AA20' as ATC, 'Dexamethason/Gentamicin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AB99' as ATC, 'Dexpanthenol/Amphotericin' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05DA05' as ATC, 'Dihydrocodein' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AB03' as ATC, 'Dimentindenmaleat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07AA03' as ATC, 'Distigminbromid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A04AD10' as ATC, 'Dronabinol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AX21' as ATC, 'Duloxetin' as BezKorrektur, 'N06AX-Andere Antidepressiva' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CB02' as ATC, 'Dutasterid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AX22' as ATC, 'Ebastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03AA05' as ATC, 'Eisen(II)-succinat' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AC07' as ATC, 'Eisen(III)-natrium-gluconatkomplex' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AE01' as ATC, 'Eisensulfat/Fols/B12' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'A12AX02' as ATC, 'Ergocalciferol/Calciumgluconat/Calciumlactat' as BezKorrektur, 'A12A - Calcium (0)' as Untergruppe, 'inakt.Vitamin D und Calcium-Kombi' as Dokumentation UNION ALL
					SELECT 'W00XX00' as ATC, 'Proteine enteral' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XA30' as ATC, 'Elektrolytlösung parenteral' as BezKorrektur, 'B05X - Elektrolytlösungen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF10' as ATC, 'Entecavir' as BezKorrektur, 'J05AF - Nucleosidale und nucleotidale Reverse-Transkriptase-Hemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AB04' as ATC, 'Algasidase beta' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C03DA04' as ATC, 'Eplerenon' as BezKorrektur, 'C03D - Kaliumsparende Diuretika (0)' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'B03XA01' as ATC, 'Epoetin delta' as BezKorrektur, 'B03X - Andere Antianämika (0)' as Untergruppe, 'B.8 Erythropoetin' as Dokumentation UNION ALL
					SELECT 'S01AA30' as ATC, 'Erythromycin/Colistin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AB10' as ATC, 'Escitalopram' as BezKorrektur, 'N06AB-Selektive Serotonin-Wiederaufnahmehemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AP01' as ATC, 'Hypericum perforatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA06' as ATC, 'Ibandronat' as BezKorrektur, 'M05BA-Bisphosphonate' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03AE10' as ATC, 'Eisen(II)sulfat/Ascorbinsäure' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AC07' as ATC, 'Eisen(III)-natrium-glukonatkomplex' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AD03' as ATC, 'Eisen(II)sulfat/Folsäure' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'A10AB06' as ATC, 'Insulin glulisin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AC03' as ATC, 'Insulin-Aminoquinurid (Schwein)' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AC03' as ATC, 'Intermediärinsulin (Schwein)' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AE04' as ATC, 'Insulin-Glargin' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'A10AE05' as ATC, 'Insulin detemir' as BezKorrektur, 'A10A - Insuline und Analoga (0)' as Untergruppe, 'B.6 Insulin' as Dokumentation UNION ALL
					SELECT 'C07AB02' as ATC, 'Metoprolol-Succinat' as BezKorrektur, 'C07A - Betablocker (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolat-Natrium' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolat-Na' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'N02BB02' as ATC, 'Novaminsulfon' as BezKorrektur, 'N02B-andere Analgetika und Antipyretika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07AF51' as ATC, 'antidiarrh. Mikroorganismen' as BezKorrektur, 'Antidiarrheal microorganisms' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA07' as ATC, 'Risedronat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02AA02' as ATC, 'Tranexamsäure' as BezKorrektur, 'B02A - Antifibrinolytika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA03' as ATC, 'Pamidronsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AD02' as ATC, 'Promethazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC06' as ATC, 'Magnesium-L-hydrogenaspartat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA16' as ATC, 'Chlormadinonacetat/Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03BA03' as ATC, 'Hyoscyamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AC02' as ATC, 'Natriumbicarbonat' as BezKorrektur, 'A16A - Andere Präparate des Alimentären Systems und des Stoffwechsels (1)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA18' as ATC, 'RAD 201 Tabletten' as BezKorrektur, 'L04AA18 - Selektive Immunsuppressiva' as Untergruppe, 'mTOR Everolimus' as Dokumentation UNION ALL
					SELECT 'N05CH01' as ATC, 'Melatonin' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'CP-690,550-10' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'C01EP01' as ATC, 'Weißdornextrakt' as BezKorrektur, 'C01E - Andere Herz-Kreislauf-Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AA07' as ATC, 'Rosuvastatin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, 'B.7 Statine' as Dokumentation UNION ALL
					SELECT 'J06BB09' as ATC, 'Anti-CMV-Immunglobulin' as BezKorrektur, 'J06BB - Spezifische Immunglobuline' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H02AB07' as ATC, 'Prednison' as BezKorrektur, 'H02AB*-Glucocorticoide' as Untergruppe, 'A.6 Steroide' as Dokumentation UNION ALL
					SELECT 'N05AD05' as ATC, 'Pipamperon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03BX04' as ATC, 'Mephenesin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AX07' as ATC, 'Prothipendyl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11EB01' as ATC, 'Vitamin B und C' as BezKorrektur, 'A11E - Vitamin-B-Komplex, inkl. Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C08CA10' as ATC, 'Nilvadipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'L01XX11' as ATC, 'Estramustin' as BezKorrektur, 'L01XX - Andere antineoplastische Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AD03' as ATC, 'Melperon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03BB51' as ATC, 'Folsäure/Vitamine' as BezKorrektur, 'B03B - Vitamin B12 und Folsäure (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02CX99' as ATC, 'Mönchspfeffer' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D04AA13' as ATC, 'Dimetindenmaleat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'FK 778 Study Med' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'A06AD15' as ATC, 'Macrogol 4000' as BezKorrektur, 'A06A - Laxanzien (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AD01' as ATC, 'Foscarnet' as BezKorrektur, 'J05AD - Phosphonsäurederivate' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AE03' as ATC, 'Lanthancarbonat' as BezKorrektur, '' as Untergruppe, 'PB-Lanthan' as Dokumentation UNION ALL
					SELECT 'B01AB06' as ATC, 'Nadroparin-Calcium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03AP30' as ATC, 'Kräuterextrakt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10BA02' as ATC, 'Simvastatin/Ezetimib' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03BC02' as ATC, 'Natriumperchlorat' as BezKorrektur, 'H03B-Thyreostatika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10BH01' as ATC, 'Sitagliptin' as BezKorrektur, 'A10B - Orale Antidiabetika (0)' as Untergruppe, 'B.5 orale Antidiabetika' as Dokumentation UNION ALL
					SELECT 'N02AA03' as ATC, 'Hydromorphon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA30' as ATC, 'Kaliumadipat/Magnesiumadipat' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DA07' as ATC, 'Telmisartan/Hydrochlorothiazid' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'G03FA15' as ATC, 'Dienogest/Estradiolvalerat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX09' as ATC, 'Lamotrigin' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01AA01' as ATC, 'Metildigoxin' as BezKorrektur, 'C01A - Herzglykoside (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03AA51' as ATC, 'Levothyroxin/Kaliumjodid' as BezKorrektur, 'H03A-Schilddrüsenhormone' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XC02' as ATC, 'Rituximab' as BezKorrektur, '' as Untergruppe, 'Rituxi' as Dokumentation UNION ALL
					SELECT 'C08CA11' as ATC, 'Manidipin' as BezKorrektur, 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)' as Untergruppe, 'B.3 Antihypertensivum' as Dokumentation UNION ALL
					SELECT 'B03BB51' as ATC, 'Folsäure/VitB6/VitB12' as BezKorrektur, 'B03B - Vitamin B12 und Folsäure (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AC06' as ATC, 'Meloxicam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R07AR99' as ATC, 'Ambroxol/Salbutamol-Rezeptur' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AX21' as ATC, 'Naftidrofuryloxalat' as BezKorrektur, 'C04A - Periphere Vasodilatatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AD09' as ATC, 'Mometason' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XE05' as ATC, 'Sorafenib' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AD02' as ATC, 'Nicotinsäure' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XE51' as ATC, 'Nitrofurantoin/Pyridoxin' as BezKorrektur, 'J01XE - Nitrofuran-Derivate' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AX06' as ATC, 'Omega-3-Fettsäuren' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03BA03' as ATC, 'Methocarbamol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AX59' as ATC, 'Calciumacetat/Magnesiumcarbonat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AF02' as ATC, 'Oxcarbazepin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S02DH20' as ATC, 'Homöopath Mischtropfen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AA03' as ATC, 'Hydromorphonhydrochlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D03AX03' as ATC, 'Dexpanthenol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A02BC03' as ATC, 'Rabeprazol' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'N06AB0' as ATC, 'Paroxetin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07FA02' as ATC, 'Saccharomyces cerevisiae' as BezKorrektur, 'A07F - Mikrobielle Antidiarrhoika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AE07' as ATC, 'Calciumacetat' as BezKorrektur, '' as Untergruppe, 'PB-Calciumacetat' as Dokumentation UNION ALL
					SELECT 'C09BA02' as ATC, 'Enalapril/Hydrochlorothiazid' as BezKorrektur, 'C09B - ACE-Hemmer, Kombinationen (0)' as Untergruppe, 'B.1 ACE-Hemmer-Komb./ Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'S01GA01' as ATC, 'Naphazolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BC04' as ATC, 'Ropinirol' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AD11' as ATC, 'Triamcinolonacetonid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07XX02' as ATC, 'Riluzol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AX08' as ATC, 'Risperidon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AH04' as ATC, 'Quetiapin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BC05' as ATC, 'Pramipexol' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BP01' as ATC, 'Silybum marianum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03DC03' as ATC, 'Montelukast' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CF03' as ATC, 'Zaleplon' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02CX99' as ATC, 'Soja-Isoflavone' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03BD09' as ATC, 'Trospiumchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AA05' as ATC, 'Oxycodon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CA03' as ATC, 'Terazosin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AX02' as ATC, 'Thalidomid' as BezKorrektur, 'L04AX - Andere Immunsuppressiva' as Untergruppe, 'other' as Dokumentation UNION ALL
					SELECT 'N07AX16' as ATC, 'Venlafaxin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CD51' as ATC, 'Fluorid/Calcium' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CM09' as ATC, 'Valeriana officinalis' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J02AC03' as ATC, 'Voriconazol' as BezKorrektur, 'J02AC - Triazol-Derivate' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BE03' as ATC, 'Sildenafilcitrat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DA08' as ATC, 'Olmesartan/Hydrochlorothiazid' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'A01AB02' as ATC, 'Wasserstoffperoxid' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V06XX99' as ATC, 'Wasser' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11CC07' as ATC, 'Paricalcitol' as BezKorrektur, 'A11C - Vitamin D, inkl. deren Kombinationen (0)' as Untergruppe, 'Vitamin D' as Dokumentation UNION ALL
					SELECT 'J01DH51' as ATC, 'Imipenem/Cilastatin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CB02' as ATC, 'Zinkgluconat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A04AA01' as ATC, 'Ondansetron' as BezKorrektur, 'A04A - Antiemetika und Mittel gegen Übelkeit (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02AE03' as ATC, 'Goserelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA08' as ATC, 'Zoledronsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CP01' as ATC, 'Triterpenglykoside, ber als Aescin' as BezKorrektur, 'C05C - Kapillarstabilisatoren (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BA11' as ATC, 'L-Dopa/Benserazid' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H02AB06' as ATC, 'STOPP-Absetzmedikation' as BezKorrektur, 'H02AB*-Glucocorticoide' as Untergruppe, 'A.6 Steroide' as Dokumentation UNION ALL
					SELECT 'H02AB06' as ATC, 'STOPP-Dauermedikation' as BezKorrektur, 'H02AB*-Glucocorticoide' as Untergruppe, 'A.6 Steroide' as Dokumentation UNION ALL
					SELECT 'D11AA01' as ATC, 'Salvia officinalis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01BB02' as ATC, 'Lidocain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03BA01' as ATC, 'Vitamin B 12' as BezKorrektur, 'B03B - Vitamin B12 und Folsäure (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J000000' as ATC, 'Tenofovir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09BB02' as ATC, 'Lercanidipin/Enalapril' as BezKorrektur, 'C09B - ACE-Hemmer, Kombinationen (0)' as Untergruppe, 'B.1 ACE-Hemmer-Komb./ Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'G03AA07' as ATC, 'Levonorgestrel/Ethinylest' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DA08' as ATC, 'Olmesartan/HCT' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'Sotrastaurin' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'Sotrastaurin (pc-gelb)' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'Sotrastaurin (pc-pink)' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'Studienmedikation' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L01XX32' as ATC, 'Bortezomib' as BezKorrektur, 'L01XX - Andere antineoplastische Mittel' as Untergruppe, 'Borte' as Dokumentation UNION ALL
					SELECT 'N03AF04' as ATC, 'Eslicarbazepinacetat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M04AA03' as ATC, 'Febuxostat' as BezKorrektur, 'M04A-Gichtmittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BB02' as ATC, 'H1N1-Impfstoff' as BezKorrektur, 'J07BB - Influenzaimpfstoffe' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX18' as ATC, 'Lacosamid' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07AB02' as ATC, 'Bethanechol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DB02' as ATC, 'Olmesartan/Amlodipin' as BezKorrektur, 'C09D - Angiotensin-II-Antagonisten, Kombinationen (0)' as Untergruppe, 'B.2 AR-Blocker/Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'V03AE02' as ATC, 'Sevelamercarbonat' as BezKorrektur, '' as Untergruppe, 'PB-Sevelamer' as Dokumentation UNION ALL
					SELECT 'C03XA01' as ATC, 'Tolvaptan' as BezKorrektur, 'C03XA - Vasopressin-Antagonisten' as Untergruppe, 'B.4 Diuretikum' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'Flasche 1' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'Flasche 2' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L04AA99' as ATC, 'Flasche 3' as BezKorrektur, 'L04AA - Selektive Immunsuppressiva' as Untergruppe, 'Phase I/II/III' as Dokumentation UNION ALL
					SELECT 'L04AA06' as ATC, 'Mycophenolatnatrium (pc)' as BezKorrektur, 'L04AA06 - Selektive Immunsuppressiva' as Untergruppe, 'MPA' as Dokumentation UNION ALL
					SELECT 'N02AA59' as ATC, 'Paracetamol; Codeinphosphat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AB09' as ATC, 'Miconazol' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AB10' as ATC, 'Natamycin' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AB12' as ATC, 'Hexetidin' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AB27' as ATC, 'Ethacridin' as BezKorrektur, 'A01AB - Antiinfektiva und Antiseptika zur oralen Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AE05' as ATC, 'Polidocanol' as BezKorrektur, 'A01AE Lokalanästhetika für die orale Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A01AE51' as ATC, 'Lidocain-HCl; Kamillenblüten' as BezKorrektur, 'A01AE Lokalanästhetika für die orale Lokalbehandlung' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A02AA02' as ATC, 'Magnesium-Ion' as BezKorrektur, 'A02AA Magnesium-haltige Antacida' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A02AB01' as ATC, 'Aluminiumhydroxid' as BezKorrektur, 'A02AB Aluminium-haltige Antacida' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AB03' as ATC, 'Aluminiumphosphat' as BezKorrektur, 'A02AB Aluminium-haltige Antacida' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AB04' as ATC, 'Carbaldrat' as BezKorrektur, 'A02AB Aluminium-haltige Antacida' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AD02' as ATC, 'Magaldrat; Simeticon' as BezKorrektur, 'A02AD Kombinationen und Komplexe von Aluminium-, Calcium- und' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AX02' as ATC, 'Oxetacain; Aluminiumhydroxid; Magnesiumhydroxid' as BezKorrektur, 'A02AX Antacida, andere Kombinationen' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02AX02' as ATC, 'Oxetacain; Aluminiumhydroxid; Magnesiumcarbonat' as BezKorrektur, 'A02AX Antacida, andere Kombinationen' as Untergruppe, 'Antacidic drugs' as Dokumentation UNION ALL
					SELECT 'A02BA04' as ATC, 'Nizatidin' as BezKorrektur, 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)' as Untergruppe, 'Peptic dp' as Dokumentation UNION ALL
					SELECT 'A03AB02' as ATC, 'Glycopyrroniumbromid' as BezKorrektur, 'A03AB Synthetische Anticholinergika, quartäre Ammonium-' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03AB07' as ATC, 'Methantheliniumbromid' as BezKorrektur, 'A03AB Synthetische Anticholinergika, quartäre Ammonium-' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03AB14' as ATC, 'Pipenzolatbromid' as BezKorrektur, 'A03AB Synthetische Anticholinergika, quartäre Ammonium-' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03AP02' as ATC, 'Kamillenblütenöl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03AX13' as ATC, 'Simeticon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03BA04' as ATC, 'Gesamtalkaloide, ber. als Hyoscyamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03BB01' as ATC, 'Butylscopolaminium-Kation' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03FA01' as ATC, 'Metoclopramid-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03FA05' as ATC, 'Alizaprid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A03PP02' as ATC, 'Chelidonin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A04AA02' as ATC, 'Granisetron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A04AA03' as ATC, 'Tropisetron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A04AA04' as ATC, 'Dolasetron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A04AA05' as ATC, 'Palonosetron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A04AD01' as ATC, 'Scopolamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A04AD12' as ATC, 'Aprepitant' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05AH' as ATC, 'Cynara scolymus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05AX02' as ATC, 'Hymecromon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05AX07' as ATC, 'Fenipentol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05AX09' as ATC, 'Febuprol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BA03' as ATC, 'Silibinin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BA03' as ATC, 'Silymarin, ber. als Silibinin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BA10' as ATC, 'Cholin-Kation' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A05BA22' as ATC, 'Tiopronin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AA01' as ATC, 'Dickfl. Paraffin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AB06' as ATC, 'Sennosid B' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AB07' as ATC, 'Hydroxyanthracen-Glykoside, ber. als Cascarosid A' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AB07' as ATC, 'Hydroxyanthracenderivate, ber. als Cascarosid A' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AB13' as ATC, 'Aloin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AC01' as ATC, 'Flohsamenschalen, indische' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AD65' as ATC, 'Macrogolkombination' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AG07' as ATC, 'Sorbitol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A06AX01' as ATC, 'Glycerol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07AA10' as ATC, 'Colistin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07AX03' as ATC, 'Nifuroxazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07BA01' as ATC, 'Kohle, medizinische' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07DA03' as ATC, 'Loperamid-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07EA04' as ATC, 'Betamethason' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07EC01' as ATC, 'Sulfasalazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07EC03' as ATC, 'Olsalazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07FA01' as ATC, 'Lactobacillus acidophilus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07FA02' as ATC, 'Saccharomyces cerevisiae Hansen CBS 5926' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07FA05' as ATC, 'Bacillus IP 5832' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07XA01' as ATC, 'Tanninalbuminat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07XA04' as ATC, 'Racecadotril' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07XP05' as ATC, 'Apfelpulver, getrocknet' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A07XP06' as ATC, 'Ethanol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A08AB01' as ATC, 'Orlistat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A08AH' as ATC, 'Fucus vesiculosus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A08AH' as ATC, 'Calotropis gigantea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A09AA02' as ATC, 'Pankreas-Pulver (Schwein)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A09AA04' as ATC, 'Tilactase (Aspergillus oryzae)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A09AP01' as ATC, 'Chrysophansäurederivate' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10AB01' as ATC, 'Insulin, normal (human)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10AC01' as ATC, 'Verzögerungsinsulin (human)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10AD01' as ATC, 'Insulin, normal; Insulin-Isophan (human)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10AD01' as ATC, 'Kombinationsinsulin (human)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10AD04' as ATC, 'Insulin lispro; Insulin lispro-Isophan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10AD05' as ATC, 'Insulin aspart (Kombinationsinsulin)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10BA02' as ATC, 'Metformin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10BB03' as ATC, 'Tolbutamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10BB04' as ATC, 'Glibornurid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10BB09' as ATC, 'Gliclazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10BH01' as ATC, 'Sitagliptinphosphat 1H£2O' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A10BH02' as ATC, 'Vildagliptin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11AB' as ATC, 'Multivitaminpräparat iv' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11CB' as ATC, 'Lebertran' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11DB01' as ATC, 'Thiamin-HCl; Pyridoxin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11EB' as ATC, 'Vitamin-B-Komplex und Vitamin C' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11HA01' as ATC, 'Nicotinamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11HA03' as ATC, 'all-rac-Alpha-Tocopherol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11HA03' as ATC, 'RRR-Alpha-Tocopherol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A11HA04' as ATC, 'Riboflavin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12AA' as ATC, 'Putamen ovi' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12AA' as ATC, 'Calcium-Ion' as BezKorrektur, '' as Untergruppe, 'Calcium' as Dokumentation UNION ALL
					SELECT 'A12AA20' as ATC, 'Calciumgluconat; Calciumdilactat' as BezKorrektur, '' as Untergruppe, 'Calcium' as Dokumentation UNION ALL
					SELECT 'A12AX01' as ATC, 'Calciumcarbonat; Colecalciferol' as BezKorrektur, '' as Untergruppe, 'inakt.Vitamin D und Calcium-Kombi' as Dokumentation UNION ALL
					SELECT 'A12AX02' as ATC, 'Calciumsalze und Ergocalciferol' as BezKorrektur, '' as Untergruppe, 'inakt.Vitamin D und Calcium-Kombi' as Dokumentation UNION ALL
					SELECT 'A12BA01' as ATC, 'Kalium-Ion' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA02' as ATC, 'Kalium' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA02' as ATC, 'Kaliumcitrat; Kaliumhydrogencarbonat' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA04' as ATC, 'Kalium-Ion' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12BA30' as ATC, 'Kaliumhydrogenaspartat; Magnesiumhydrogenaspartat' as BezKorrektur, 'A12B - Kalium (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CB01' as ATC, 'Zink-Ion' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CB02' as ATC, 'Zink-Ion' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CB02' as ATC, 'Zink-D-gluconat' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CB05' as ATC, 'Zink-Ion' as BezKorrektur, 'A12C - Andere Mineralstoffe (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC05' as ATC, 'Magnesium-Ion' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC05' as ATC, 'Magnesium-L-hydrogenaspartat 2H£2O' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC09' as ATC, 'Magnesium-Ion' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC10' as ATC, 'Magnesium-Ion' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CC30' as ATC, 'Magnesiumsalzkombination' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CD02' as ATC, 'Dinatriumfluorophosphat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CE02' as ATC, 'Selen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A12CE02' as ATC, 'Selen-Ion' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A13AA02' as ATC, 'Lebertran' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A13AH' as ATC, 'Selenium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A13AH' as ATC, 'Avena sativa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A13AP01' as ATC, 'Ethanol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A13AP02' as ATC, 'Ginsenosid Rg1' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AA02' as ATC, 'Ademetionin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AA04' as ATC, 'Mercaptamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AA05' as ATC, 'Carglumsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AA06' as ATC, 'Betain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AA50' as ATC, 'Ketosäurenkombination' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AB02' as ATC, 'Imiglucerase(CHO-Zellen)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AB03' as ATC, 'Agalsidase alfa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AB04' as ATC, 'Agalsidase beta' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AB05' as ATC, 'Laronidase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AB07' as ATC, 'Alglucosidase alfa (CHO-Zellen)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AB08' as ATC, 'Galsulfase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AB09' as ATC, 'Idursulfase (HDC-Zellen)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16ACY1' as ATC, 'Calcium-natrium-hydrogen-citrat (6:6:3:7)' as BezKorrektur, 'A16A - Andere Präparate des Alimentären Systems und des Stoffwechsels (1)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AX03' as ATC, 'Natriumphenylbutyrat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AX04' as ATC, 'Nitisinon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AX05' as ATC, 'Zink-Ion' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'A16AX06' as ATC, 'Miglustat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AA03' as ATC, 'Warfarin-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB01' as ATC, 'Heparin-Ca' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB01' as ATC, 'Heparin-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB02' as ATC, 'Antithrombin III' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB05' as ATC, 'Enoxaparin-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB09' as ATC, 'Danaparoid-Natrium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB10' as ATC, 'Anti-Xa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB10' as ATC, 'Tinzaparin-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AB13' as ATC, 'Certoparin-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC06' as ATC, 'Acetylsalicylsäure (Ph.Eur.)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC11' as ATC, 'Iloprost' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC16' as ATC, 'Eptifibatid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC17' as ATC, 'Tirofiban' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC21' as ATC, 'Treprostinil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC22' as ATC, 'Cilostazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AC30' as ATC, 'Dipyridamol; Acetylsalicylsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AD01' as ATC, 'Streptokinase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AD02' as ATC, 'Alteplase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AD03' as ATC, 'Anistreplase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AD04' as ATC, 'Urokinase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AD11' as ATC, 'Tenecteplase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AD12' as ATC, 'Protein C v. Menschen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AE01' as ATC, 'Desirudin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AE02' as ATC, 'Lepirudin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AE03' as ATC, 'Argatroban' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AE06' as ATC, 'Bivalirudin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AX05' as ATC, 'Fondaparinux-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B01AX06' as ATC, 'Natriumpentosanpolysulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02AA03' as ATC, '4-Aminomethylbenzoesäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02AB03' as ATC, 'C1-Esterase-Inhibitor, human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02BB01' as ATC, 'Plasmaprotein, human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02BD02' as ATC, 'Von Willebrand-Faktor' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02BD02' as ATC, 'Plasmaprotein, human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02BD03' as ATC, 'Plasmaprotein, human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02BD04' as ATC, 'Gesamtprotein' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B02BD06' as ATC, 'Blutgerinnungsfaktor VIII human; Von Willebrand-Faktor' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03AA01' as ATC, 'Eisen(II)-Ion' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA02' as ATC, 'Eisen' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA02' as ATC, 'Eisen(II)-Ion' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA03' as ATC, 'Eisen' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA03' as ATC, 'Eisen(II)-Ion' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA06' as ATC, 'Eisen(III)-Ion' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA07' as ATC, 'Eisen' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA07' as ATC, 'Eisen(II)-Ion' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AA07' as ATC, 'Eisen(III)-Ion' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AB05' as ATC, 'Eisen' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AC02' as ATC, 'Eisen' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AC06' as ATC, 'Eisen(III)-Ion' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AC07' as ATC, 'Eisen(III)-Ion' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03AE01' as ATC, 'Eisen(II)-glycin-sulfat; Folsäure; Cyanocobalamin' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'B03BA03' as ATC, 'Hydroxocobalamin' as BezKorrektur, 'B03B - Vitamin B12 und Folsäure (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03BA51' as ATC, 'Pyridoxin-HCl; Folsäure; Cyanocobalamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03BB02' as ATC, 'Folinsäure' as BezKorrektur, 'B03B - Vitamin B12 und Folsäure (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03XA03' as ATC, 'Methoxy-Polyethylenglycol-Epoetin beta' as BezKorrektur, 'B03X - Andere Antianämika (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05AA01' as ATC, 'Plasmaprotein, human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05AA02' as ATC, 'Plasmaprotein, human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05AA06' as ATC, 'Gelatinepolysuccinat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05AA07' as ATC, 'Hydroxyethylstärke; Natriumchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05AA07' as ATC, 'Hydroxyethylstärke' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05AA10' as ATC, 'Polygelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05AA57' as ATC, 'Hydroxyethylstärke' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BA02' as ATC, 'Fischkörperöl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BA02' as ATC, 'Glyceroltri(alkanoat, alkenoat) (C£8-C£1£8)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BA02' as ATC, '(3-sn-Phosphatidyl)cholin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BA02' as ATC, 'Fett' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BA03' as ATC, 'Glucose, wasserfrei z. par. Anw.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BA03' as ATC, 'Glucose' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BA03' as ATC, 'Xylitol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BB01' as ATC, 'Chlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BB03' as ATC, 'Trometamol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05BC' as ATC, 'Sorbitol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05CX01' as ATC, 'Glucose, wasserfrei z. par. Anw.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05CX01' as ATC, 'Glucose' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XA' as ATC, 'Kalium L-malat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XA03' as ATC, 'Chlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XA14' as ATC, 'Glycerol-1(2)-dihydrogenphosphat-Gemisch, Dinatrium-5-Wasser' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XA15' as ATC, 'Kalium (RS)-lactat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XA30' as ATC, 'Spurenelemente iv' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XB02' as ATC, 'N(2)-L-Alanyl-L-Glutamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XX02' as ATC, 'Trometamol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B05XX04' as ATC, 'Ethanol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B06AA03' as ATC, 'Hyaluronidase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B06AA11' as ATC, 'Bromelain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B06AA12' as ATC, 'Serrapeptase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B06AB' as ATC, 'Hemin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01AA02' as ATC, 'Beta-Acetyldigoxin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01AA05' as ATC, 'Digoxin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01AB01' as ATC, 'Proscillaridin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01AC05' as ATC, 'Oleum Strophanti' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01AH20' as ATC, 'Convallaria' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BA03' as ATC, 'Disopyramid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BA05' as ATC, 'Ajmalin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BA33' as ATC, 'Detajmiumbitartrat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BB02' as ATC, 'Mexiletin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01BD01' as ATC, 'Amiodaron-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01CA03' as ATC, 'Norepinephrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01CA07' as ATC, 'Dobutamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01CA17' as ATC, 'Midodrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01CA24' as ATC, 'Epinephrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01CA28' as ATC, 'Ameziniummetilsulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01CB02' as ATC, 'Oxilofrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01CE03' as ATC, 'Enoximon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01DA05' as ATC, 'Pentaerythrityltetranitrat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EB02' as ATC, 'Campher' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EB02' as ATC, 'Camphora' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EB04' as ATC, 'Procyanidine' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EB04' as ATC, 'Hyperosid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EB04' as ATC, 'Procyanidine, ber. als Epicatechin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EB10' as ATC, 'Adenosin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EB17' as ATC, 'Ivabradin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EH' as ATC, 'Strophanthus gratus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EH' as ATC, 'Crataegus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C01EH20' as ATC, 'Cor suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C02AC01' as ATC, 'Clonidin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C02CA02' as ATC, 'Indoramin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C02DB01' as ATC, 'Dihydralazinsulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C02KX03' as ATC, 'Sitaxentan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C02LA01' as ATC, 'Clopamid; Reserpin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C03BA04' as ATC, 'Chlortalidon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C03BA11' as ATC, 'Indapamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C03CA02' as ATC, 'Bumetanid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C03EA21' as ATC, 'Triamteren; Hydrochlorothiazid' as BezKorrektur, 'C03E - Diuretika und kaliumsparende Mittel, kombiniert (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C03EA41' as ATC, 'Amilorid; Hydrochlorothiazid' as BezKorrektur, 'C03E - Diuretika und kaliumsparende Mittel, kombiniert (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C03EB01' as ATC, 'Spironolacton; Furosemid' as BezKorrektur, 'C03E - Diuretika und kaliumsparende Mittel, kombiniert (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AC03' as ATC, 'Inositolnicotinat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AE02' as ATC, 'Nicergolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AX01' as ATC, 'Cyclandelat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C04AX13' as ATC, 'Piribedil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05AD04' as ATC, 'Policresulen; Cinchocain-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05BA01' as ATC, 'Chondroitinpolysulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05BA03' as ATC, 'Heparin-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05BA04' as ATC, 'Natriumpentosanpolysulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05BB02' as ATC, 'Polidocanol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05BZ09' as ATC, 'Aescin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CA01' as ATC, 'Rutosid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CA03' as ATC, 'Diosmin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CA07' as ATC, 'Aescin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CA54' as ATC, 'Oxerutine' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CP01' as ATC, 'Triterpenglykoside, ber. als wasserfr. Aescin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CP01' as ATC, 'Aescin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C05CP05' as ATC, 'Cumarin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AA02' as ATC, 'Oxprenolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AA03' as ATC, 'Pindolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AA05' as ATC, 'Propranolol-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AA07' as ATC, 'Sotalol-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AB02' as ATC, 'Metoprololtartrat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AB04' as ATC, 'Acebutolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AB05' as ATC, 'Betaxolol-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AB07' as ATC, 'Bisoprololfumarat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AB08' as ATC, 'Celiprolol-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07AB09' as ATC, 'Esmolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07BB02' as ATC, 'Metoprololsuccinat; Hydrochlorothiazid' as BezKorrektur, 'C07B - Betablocker und Thiazide (0)' as Untergruppe, 'B.3 Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C07BB07' as ATC, 'Bisoprololfumarat; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07CB02' as ATC, 'Metoprololtartrat; Chlortalidon' as BezKorrektur, 'C07B - Betablocker und Thiazide (0)' as Untergruppe, 'B.3 Antihypertensivum+Diuretikum' as Dokumentation UNION ALL
					SELECT 'C07FB02' as ATC, 'Felodipin; Metoprololsuccinat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07FB03' as ATC, 'Atenolol; Nifedipin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C08CA06' as ATC, 'Nimodipin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C08DA02' as ATC, 'Gallopamil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C08DB01' as ATC, 'Diltiazem-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C08EA01' as ATC, 'Fendilin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09AA02' as ATC, 'Enalaprilat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09AA02' as ATC, 'Enalaprilmaleat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09AA06' as ATC, 'Quinapril' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09AA07' as ATC, 'Benazepril-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09AA09' as ATC, 'Fosinopril-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09BA02' as ATC, 'Enalaprilmaleat; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09BA03' as ATC, 'Lisinopril; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09BA05' as ATC, 'Ramipril; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09BA07' as ATC, 'Benazepril-HCl; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09BB02' as ATC, 'Lercanidipin; Enalapril' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09CA01' as ATC, 'Losartan-Kalium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09CA06' as ATC, 'Candesartancilexetil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09CA08' as ATC, 'Olmesartanmedoxomil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DA01' as ATC, 'Losartan-Kalium; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DA03' as ATC, 'Valsartan; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DA04' as ATC, 'Irbesartan; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DA06' as ATC, 'Candesartan; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DA07' as ATC, 'Telmisartan; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DA08' as ATC, 'Olmesartanmedoxomil; Hydrochlorothiazid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C09DB01' as ATC, 'Amlodipinbesilat; Valsartan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AA03' as ATC, 'Pravastatin-Na' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AB09' as ATC, 'Etofibrat' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AD02' as ATC, 'Nikotinsäure' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AD06' as ATC, 'Acipimox' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AP02' as ATC, '(3-sn-Phosphatidyl)cholin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AP03' as ATC, 'Allicin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AX06' as ATC, 'Omega-3-Säurenethylester 90' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AX06' as ATC, 'Fischkörperöl' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10AX07' as ATC, 'Magnesium-pyridoxal-5-phosphat-glutamat' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C10BA02' as ATC, 'Ezetimib; Simvastatin' as BezKorrektur, 'C10A - Cholesterin- und Triglycerid senkende Mittel (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AC02' as ATC, 'Miconazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AC03' as ATC, 'Econazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AC07' as ATC, 'Tioconazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AC10' as ATC, 'Bifonazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AC11' as ATC, 'Oxiconazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AE13' as ATC, 'Selendisulfid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AE16' as ATC, 'Amorolfin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01AE18' as ATC, 'Tolnaftat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D01BA01' as ATC, 'Griseofulvin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D02AB' as ATC, 'Zinkoxid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D02AC' as ATC, 'Olivenöl, natives' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D02AC' as ATC, 'Ethyl[(Z/Z)-octadeca-9,12-dienoat]' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D02AC' as ATC, 'Fettsäuren (C18:2) unges.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D02AE01' as ATC, 'Harnstoff' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D02AF' as ATC, 'Salicylsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D02AX' as ATC, 'Fettsäuren (C18:2) unges.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D03AHY3' as ATC, 'Echinacea angustifolia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D03AP04' as ATC, 'Kamillenblütenöl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D03AP04' as ATC, 'Levomenol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D03AX14' as ATC, 'Blut-Dialysat (Kalb), deproteinisiert' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D03AX32' as ATC, 'Lucilia sericata' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D04AB11' as ATC, 'Polidocanol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D04AX01' as ATC, 'Gerbstoff, synthetisch' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D04AX02' as ATC, 'Crotamiton' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D04AX06' as ATC, 'Calciumhydroxid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D05AC01' as ATC, 'Dithranol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D05AD02' as ATC, 'Methoxsalen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D05AX' as ATC, 'Salicylsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D05AX02' as ATC, 'Calcipotriol 1H£2O' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D05AX04' as ATC, 'Tacalcitol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D05AX05' as ATC, 'Tazaroten' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D05BA02' as ATC, 'Methoxsalen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06AA02' as ATC, 'Chlortetracyclin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06AA03' as ATC, 'Oxytetracyclin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06AA05' as ATC, 'Meclocyclin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06AX08' as ATC, 'Tyrothricin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06BA01' as ATC, 'Sulfadiazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06BB01' as ATC, 'Idoxuridin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06BB04' as ATC, 'Podophyllotoxin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06BB06' as ATC, 'Penciclovir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D07AC01' as ATC, 'Betamethason' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D07AC03' as ATC, 'Desoximetason' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D07AC05' as ATC, 'Fluocortolon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D07AC06' as ATC, 'Diflucortolon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D07AC11' as ATC, 'Amcinonid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D07AC18' as ATC, 'Prednicarbat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D07AD01' as ATC, 'Clobetasol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D07XB03' as ATC, 'Flupredniden-21-acetat; Estradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AA01' as ATC, 'Ethacridin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AC05' as ATC, 'Polihexanid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AE02' as ATC, 'Policresulen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AF01' as ATC, 'Nitrofural' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AG02' as ATC, 'Povidon-Jod' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AH01' as ATC, 'Dequalinium Kation' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AL02' as ATC, 'Methenamin-Silbernitrat (1:2)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AX06' as ATC, 'Kaliumpermanganat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AX07' as ATC, 'Natriumhypochlorit' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AX08' as ATC, 'Ethanol, vergällt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AX09' as ATC, 'Oxoferin-(Oxovasin)Reaktionsprodukt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D08AX10' as ATC, 'Ammoniumbituminosulfonat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D09AA09' as ATC, 'Povidon-Jod' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AB02' as ATC, 'Schwefel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AD03' as ATC, 'Adapalen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AD04' as ATC, 'Isotretinoin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AF06' as ATC, 'Nadifloxacin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AX03' as ATC, 'Azelainsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AX05' as ATC, 'Ammoniumbituminosulfonat, hell' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AX05' as ATC, 'Ammoniumbituminosulfonat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AX05' as ATC, 'Natriumbituminosulfonat, hell' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10AX11' as ATC, 'Salicylsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10BA01' as ATC, 'Deferipron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10BA01' as ATC, 'Isotretinoin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D10BX01' as ATC, 'Natriumbituminosulfonat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AA01' as ATC, 'Salbeiöl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AA01' as ATC, 'Salbei-Extr.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AA03' as ATC, 'Methenamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AB05' as ATC, 'Sojabohnenöl, raffiniertes' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AC03' as ATC, 'Selendisulfid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AF01' as ATC, 'Salicylsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AF07' as ATC, 'Monochloressigsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AH' as ATC, 'Sulfur' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AH' as ATC, 'Conium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AH20' as ATC, 'Cutis fet.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AH20' as ATC, 'Cutis suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AX15' as ATC, 'Pimecrolimus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AX16' as ATC, 'Eflornithin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D11AX22' as ATC, 'Kalium-4-aminobenzoat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G01AF05' as ATC, 'Econazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G01AF17' as ATC, 'Oxiconazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G01AX03' as ATC, 'Policresulen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G01AX05' as ATC, 'Nifuratel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G01AX11' as ATC, 'Povidon-Jod' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G01AX14' as ATC, 'Lactobacillus-gasseri-Kulturlyophilisat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G01AX14' as ATC, 'Lactobacillus-Stämme, inaktiviert' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G01AX22' as ATC, 'Hexetidin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02BA03' as ATC, 'Levonorgestrel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02CB02' as ATC, 'Lisurid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02CB04' as ATC, 'Quinagolid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02CB05' as ATC, 'Metergolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02CH' as ATC, 'Ovarium suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G02CH' as ATC, 'Lachesis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA07' as ATC, 'Levonorgestrel; Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA11' as ATC, 'Norgestimat; Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA12' as ATC, 'Ethinylestradiol-Betadex-Klathrat; Drospirenon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AA17' as ATC, 'Ethinylestradiol; Dienogest' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AB03' as ATC, 'Levonorgestrel; Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AC03' as ATC, 'Levonorgestrel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AC06' as ATC, 'Medroxyprogesteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03AC08' as ATC, 'Etonogestrel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03CA01' as ATC, 'Ethinylestradiol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03CA04' as ATC, 'Estriol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03CX01' as ATC, 'Tibolon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03DA02' as ATC, 'Medroxyprogesteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03DA03' as ATC, 'Hydroxyprogesteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03DA04' as ATC, 'Progesteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03DB01' as ATC, 'Dydrogesteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03DC03' as ATC, 'Lynestrenol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03FA01' as ATC, 'Estradiolvalerat; Norethisteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03FA15' as ATC, 'Dienogest; Estradiolvalerat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03FB05' as ATC, 'Estradiolvalerat; Norethisteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03GA01' as ATC, 'Choriongonadotropin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03GA02' as ATC, 'Menotropin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03GA04' as ATC, 'Urofollitropin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03GA05' as ATC, 'Follitropin alfa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03GA06' as ATC, 'Follitropin beta' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G03GB02' as ATC, 'Clomifen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BA01' as ATC, 'Ammoniumchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BC51' as ATC, 'Citronensäure; Kaliumhydrogencarbonat; Natriumcitrat' as BezKorrektur, 'G04BC-Harnkonkrement lösende Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BC50' as ATC, 'Kaliumdihydrogenphosphat; Natriummonohydrogenphosphat' as BezKorrektur, 'G04BC-Harnkonkrement lösende Mittel' as Untergruppe, 'Phosphatsupplementation' as Dokumentation UNION ALL
					SELECT 'G04BD06' as ATC, 'Propiverin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BD08' as ATC, 'Solifenacin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BE09' as ATC, 'Vardenafil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BH' as ATC, 'Populus tremuloides' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BH20' as ATC, 'Vesica urinaria suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BH20' as ATC, 'Ren suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BP01' as ATC, 'Arbutin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04BP01' as ATC, 'Hydrochinonderivate, ber. als Arbutin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CA02' as ATC, 'Tamsulosin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CP01' as ATC, 'Phytosterol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CP06' as ATC, 'Sägepalmenfrüchte-Extr.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'G04CP56' as ATC, 'Sägepalmenfrüchte; Brennnesselwurzel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01AA02' as ATC, 'Tetracosactidhexaacetat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01AC01' as ATC, 'Somatropin (E. coli)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01AC03' as ATC, 'Mecasermin (E. coli)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01BA02' as ATC, 'Desmopressin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01BA04' as ATC, 'Terlipressin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01BB02' as ATC, 'Oxytocin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01BB03' as ATC, 'Carbetocin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01CA01' as ATC, 'Gonadorelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01CA02' as ATC, 'Nafarelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01CB01' as ATC, 'Somatostatin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01CB02' as ATC, 'Octreotid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01CB03' as ATC, 'Lanreotid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01CC01' as ATC, 'Ganirelix' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H01CC02' as ATC, 'Cetrorelix' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H02AB01' as ATC, 'Betamethason' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H02AB02' as ATC, 'Dexamethason-21-dihydrogenphosphat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H02AB03' as ATC, 'Fluocortolon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H02AB12' as ATC, 'Rimexolon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H02AB14' as ATC, 'Cloprednol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03AA01' as ATC, 'Levothyroxin-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03AA51' as ATC, 'Levothyroxin-Na; Kaliumjodid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03BA02' as ATC, 'Propylthiouracil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03BB01' as ATC, 'Carbimazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03BX01' as ATC, 'Diiodtyrosin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H03CA01' as ATC, 'Kaliumjodid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H05AA01' as ATC, 'Glandula parathyreoidea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H05AA02' as ATC, 'Teriparatid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'H05AA03' as ATC, 'Parathyroidhormon (human)(rDNA)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01AA12' as ATC, 'Tigecyclin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01BA01' as ATC, 'Chloramphenicol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CA10' as ATC, 'Mezlocillin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CE01' as ATC, 'Benzylpenicillin-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CE08' as ATC, 'Benzylpenicillin-Benzathin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CF01' as ATC, 'Dicloxacillin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CR02' as ATC, 'Amoxicillin; Kaliumclavulanat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01CR05' as ATC, 'Piperacillin-Na; Tazobactam-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DB04' as ATC, 'Cefazolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DC01' as ATC, 'Cefoxitin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DC07' as ATC, 'Cefotiam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DC08' as ATC, 'Loracarbef' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DD01' as ATC, 'Cefotaxim' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DE01' as ATC, 'Cefepim' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DF01' as ATC, 'Aztreonam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DH03' as ATC, 'Ertapenem' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01DH51' as ATC, 'Imipenem; Cilastatin-Natrium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01EC02' as ATC, 'Sulfadiazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01FA02' as ATC, 'Spiramycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01FA15' as ATC, 'Telithromycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01FF02' as ATC, 'Lincomycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01GA01' as ATC, 'Streptomycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01GB01' as ATC, 'Tobramycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01GB06' as ATC, 'Amikacin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01GB07' as ATC, 'Netilmicin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01MA04' as ATC, 'Enoxacin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01MB04' as ATC, 'Pipemidsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XA01' as ATC, 'Vancomycin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XX01' as ATC, 'Fosfomycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XX04' as ATC, 'Spectinomycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XX07' as ATC, 'Nitroxolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J01XX09' as ATC, 'Daptomycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J02AA01' as ATC, 'Amphotericin B, liposomal' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J02AC04' as ATC, 'Posaconazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J02AX01' as ATC, 'Flucytosin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J02AX04' as ATC, 'Caspofungin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J02AX06' as ATC, 'Anidulafungin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AA02' as ATC, '4-Aminosalicylsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AB04' as ATC, 'Rifabutin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AC51' as ATC, 'Isoniazid; Pyridoxin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AD01' as ATC, 'Protionamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AK01' as ATC, 'Pyrazinamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04AK03' as ATC, 'Terizidon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J04BA02' as ATC, 'Dapson' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AB12' as ATC, 'Cidofovir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AD01' as ATC, 'Foscarnet-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AE' as ATC, 'Tipranavir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AE01' as ATC, 'Saquinavir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AE02' as ATC, 'Indinavir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AE03' as ATC, 'Ritonavir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AE05' as ATC, 'Amprenavir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AE07' as ATC, 'Fosamprenavir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AE08' as ATC, 'Atazanavir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF01' as ATC, 'Zidovudin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF02' as ATC, 'Didanosin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF03' as ATC, 'Zalcitabin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF04' as ATC, 'Stavudin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF06' as ATC, 'Abacavir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF09' as ATC, 'Emtricitabin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AF11' as ATC, 'Telbivudin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AG01' as ATC, 'Nevirapin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AG03' as ATC, 'Efavirenz' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AH02' as ATC, 'Oseltamivir' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AX07' as ATC, 'Enfuvirtid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J05AX09' as ATC, 'Maraviroc' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06AA04' as ATC, 'Botulismus Antitoxine (Pferd)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BA01' as ATC, 'Hepatitis-A-Immunglobulin vom Menschen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BA01' as ATC, 'Immunglobulin human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BA02' as ATC, 'Immunglobulin human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB01' as ATC, 'Anti-D-Immunglobulin human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB02' as ATC, 'Tetanus-Immunglobulin vom Menschen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB03' as ATC, 'Varizellen-Immunglobulin v. Menschen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB03' as ATC, 'Varizellen-Lebendimpfstoff (Stamm: Oka/Merck)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB04' as ATC, 'Hepatitis-B-Immunglobulin vom Menschen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB05' as ATC, 'Tollwut-Immunglobulin v. Menschen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB09' as ATC, 'Plasmaprotein, human' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB09' as ATC, 'Cytomegalie-Immunglobulin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J06BB16' as ATC, 'Palivizumab' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07AE01' as ATC, 'Vibrio comma' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07AH07' as ATC, 'Meningokokken-C-Saccharid-CRM-Konjugat-Impfstoff' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07AM01' as ATC, 'Tetanus-Adsorbat-Impfstoff' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07AP03' as ATC, 'Typhus-Polysaccharid-Impfstoff' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BB02' as ATC, 'Hämagglutinine' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BC02' as ATC, 'Aluminium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BC02' as ATC, 'Hepatitis-A-Virus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BD01' as ATC, 'Masernvirus, abgeschwächt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BF03' as ATC, 'Poliomyelitis-Impfstoff, inaktiviert, trivalent (Verozellen)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BG01' as ATC, 'Tollwut-Virus, inaktiviert' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BH01' as ATC, 'Rotavirus, human, lebend attenuiert (Stamm RIX4414)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BK01' as ATC, 'Varizellenviren, lebend abgeschwächt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BK01' as ATC, 'Varizellen-Lebendimpfstoff (Stamm: Oka/Merck)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'J07BM01' as ATC, 'Papillomvirus (human)-Impfstoff, rekombiniert, tetravalent' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AA02' as ATC, 'Chlorambucil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AA03' as ATC, 'Melphalan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AA06' as ATC, 'Ifosfamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AA07' as ATC, 'Trofosfamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AB01' as ATC, 'Busulfan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AB02' as ATC, 'Treosulfan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AC01' as ATC, 'Thiotepa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AD01' as ATC, 'Carmustin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AD02' as ATC, 'Lomustin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AX03' as ATC, 'Temozolomid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01AX04' as ATC, 'Dacarbazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BA04' as ATC, 'Pemetrexed' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BB03' as ATC, 'Tioguanin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BB04' as ATC, 'Cladribin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BB05' as ATC, 'Fludarabin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BB07' as ATC, 'Nelarabin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BC01' as ATC, 'Cytarabin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BC02' as ATC, 'Fluorouracil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BC05' as ATC, 'Gemcitabin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01BC06' as ATC, 'Capecitabin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01CA01' as ATC, 'Vinblastinsulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01CA02' as ATC, 'Vincristin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01CA03' as ATC, 'Vindesin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01CA04' as ATC, 'Vinorelbin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01CB01' as ATC, 'Etoposid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01CD01' as ATC, 'Paclitaxel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01CD02' as ATC, 'Docetaxel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01CP01' as ATC, 'Mistellektin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01DA01' as ATC, 'Dactinomycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01DB01' as ATC, 'Doxorubicin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01DB01' as ATC, 'Doxorubicin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01DB02' as ATC, 'Daunorubicin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01DB03' as ATC, 'Epirubicin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01DB06' as ATC, 'Idarubicin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01DB07' as ATC, 'Mitoxantron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01DC03' as ATC, 'Mitomycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01X' as ATC, 'Oligopeptide aus Schweinemilz' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XA01' as ATC, 'Cisplatin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XA02' as ATC, 'Carboplatin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XA03' as ATC, 'Oxaliplatin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XB01' as ATC, 'Procarbazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XC03' as ATC, 'Trastuzumab' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XC04' as ATC, 'Alemtuzumab' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XC06' as ATC, 'Cetuximab (Mauszellen)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XC07' as ATC, 'Bevacizumab' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XD01' as ATC, 'Porfimernatrium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XD03' as ATC, 'Methyl (5-amino-4-oxopentanoat)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XD05' as ATC, 'Temoporfin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XE03' as ATC, 'Erlotinib' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XE04' as ATC, 'Sunitinib' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XE06' as ATC, 'Dasatinib' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX02' as ATC, 'Asparaginase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX02' as ATC, 'Asparaginase (Erwinia chrysanthemi)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX05' as ATC, 'Hydroxycarbamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX08' as ATC, 'Pentostatin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX09' as ATC, 'Miltefosin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX11' as ATC, 'Estramustin-17Beta-dihydrogenphosphat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX17' as ATC, 'Topotecan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX19' as ATC, 'Irinotecan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX22' as ATC, 'Alitretinoin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX23' as ATC, 'Mitotan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX24' as ATC, 'Pegaspargase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX25' as ATC, 'Bexaroten' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L01XX35' as ATC, 'Anagrelid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02AB01' as ATC, 'Megestrol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02AB02' as ATC, 'Medroxyprogesteron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02AE01' as ATC, 'Buserelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02AE02' as ATC, 'Leuprorelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02AE04' as ATC, 'Triptorelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02BA02' as ATC, 'Toremifen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02BG01' as ATC, 'Aminoglutethimid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02BG03' as ATC, 'Anastrozol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02BG04' as ATC, 'Letrozol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L02BG06' as ATC, 'Exemestan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AA10' as ATC, 'Lenograstim' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AA13' as ATC, 'Pegfilgrastim' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AB03' as ATC, 'Interferon gamma-1b' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AB07' as ATC, 'Interferon beta-1a' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AB11' as ATC, 'Peginterferon alfa-2a' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AC01' as ATC, 'Aldesleukin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AG01' as ATC, 'Enterococcus faecalis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AG02' as ATC, 'Bacillus subtilis M.U.345' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AG03' as ATC, 'Mycobacterium phlei' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AG50' as ATC, 'Bakterien-Autolysat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AH01' as ATC, 'Echinacea purpurea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AH02' as ATC, 'Echinacea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AX03' as ATC, 'Bacillus Calmette-Guérin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AX13' as ATC, 'Glatiramer' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AX17' as ATC, 'Thymostimulin (Kalb)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L03AX19' as ATC, 'Leukozytenultrafiltrat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA03' as ATC, 'Anti-Humanlymphozyten-Immunglobulin vom Pferd' as BezKorrektur, 'L04AA03 - Selektive Immunsuppressiva' as Untergruppe, 'ALG' as Dokumentation UNION ALL
					SELECT 'L04AA04' as ATC, 'Anti-Human-T-Lymphozyten-Immunglobuline von Kaninchen' as BezKorrektur, 'L04AA04 - Selektive Immunsuppressiva' as Untergruppe, 'ATG' as Dokumentation UNION ALL
					SELECT 'L04AA21' as ATC, 'Efalizumab' as BezKorrektur, 'L04AA21 - Selektive Immunsuppressiva' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA23' as ATC, 'Natalizumab' as BezKorrektur, 'L04AA23 - Selektive Immunsuppressiva' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AA24' as ATC, 'Abatacept' as BezKorrektur, 'L04AA24 - Selektive Immunsuppressiva' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AB01' as ATC, 'Etanercept' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AB02' as ATC, 'Infliximab' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AB04' as ATC, 'Adalimumab' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AC03' as ATC, 'Anakinra' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'L04AX04' as ATC, 'Lenalidomid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AA02' as ATC, 'Mofebutazon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AB05' as ATC, 'Diclofenac-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AB09' as ATC, 'Lonazolac' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AB11' as ATC, 'Acemetacin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AB16' as ATC, 'Aceclofenac' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AC01' as ATC, 'Piroxicam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AC05' as ATC, 'Lornoxicam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AE02' as ATC, 'Naproxen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AE03' as ATC, 'Ketoprofen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AE11' as ATC, 'Tiaprofensäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AE14' as ATC, 'Dexibuprofen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AE17' as ATC, 'Dexketoprofen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AG06' as ATC, 'Etofenamat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AH04' as ATC, 'Parecoxib' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AH05' as ATC, 'Etoricoxib' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AX01' as ATC, 'Nabumeton' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AX05' as ATC, 'Glucosamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01AX24' as ATC, 'Oxaceprol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01CB01' as ATC, 'Natriumaurothiomalat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01CB03' as ATC, 'Auranofin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01CC01' as ATC, 'Penicillamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M01CX02' as ATC, 'Sulfasalazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AA06' as ATC, 'Etofenamat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AA07' as ATC, 'Piroxicam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AA08' as ATC, 'Felbinac' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AA10' as ATC, 'Ketoprofen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AA25' as ATC, 'Flufenaminsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AB03' as ATC, 'Nonivamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AC01' as ATC, 'Hydroxyethylsalicylat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AC02' as ATC, 'Methylsalicylat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AD02' as ATC, 'Benzylnicotinat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AH' as ATC, 'Ledum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AP07' as ATC, 'Capsaicin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AP07' as ATC, 'Capsaicinoide' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AP07' as ATC, 'Capsaicinoide, ber. als Capsaicin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AX04' as ATC, 'Campher' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02AX10' as ATC, 'Aluminiumacetat-tartrat-Lösung' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M02BA04' as ATC, 'Benzylnicotinat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03AA01' as ATC, 'Alcuroniumchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03AB01' as ATC, 'Suxamethoniumchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03AC03' as ATC, 'Vecuroniumbromid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03AC09' as ATC, 'Rocuroniumbromid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03AC10' as ATC, 'Mivacurium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03AC11' as ATC, 'Cisatracurium besilat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03BC01' as ATC, 'Orphenadrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03BX04' as ATC, 'Tolperison-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M03CA01' as ATC, 'Dantrolen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M04AB01' as ATC, 'Probenecid' as BezKorrektur, 'M04A-Gichtmittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M04AC01' as ATC, 'Colchicin' as BezKorrektur, 'M04A-Gichtmittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA01' as ATC, 'Etidronsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA02' as ATC, 'Clodronsäure, Dinatriumsalz' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BA05' as ATC, 'Tiludronsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M05BB04' as ATC, 'Risedronsäure; Calciumcarbonat; Colecalciferol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AA02' as ATC, 'Chinin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AA02' as ATC, 'Chininsulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AH' as ATC, 'Viscum album' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AH' as ATC, 'Toxicodendron quercifolium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AH20' as ATC, 'Acidum sarcolacticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AH20' as ATC, 'Cartilago suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AH20' as ATC, 'Discus intervertebralis suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AH20' as ATC, 'Fraxinus excelsior Ø' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AH20' as ATC, 'Columna vertebral. fet.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'M09AP05' as ATC, 'Salicin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AB06' as ATC, 'Isofluran' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AB07' as ATC, 'Desfluran' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AF03' as ATC, 'Thiopental' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AH02' as ATC, 'Alfentanil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AH03' as ATC, 'Sufentanil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AH06' as ATC, 'Remifentanil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AX03' as ATC, 'Ketamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AX07' as ATC, 'Etomidat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AX10' as ATC, 'Propofol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01AX14' as ATC, 'Esketamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01BA02' as ATC, 'Procain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01BA03' as ATC, 'Tetracain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01BB01' as ATC, 'Bupivacain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01BB03' as ATC, 'Mepivacain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01BB08' as ATC, 'Articain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01BB09' as ATC, 'Ropivacain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N01BB10' as ATC, 'Levobupivacain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AA01' as ATC, 'Morphinsulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AA01' as ATC, 'Morphin-HCl 3H2O' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AA05' as ATC, 'Oxycodon-HCl; Naloxon-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AB02' as ATC, 'Pethidin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AD01' as ATC, 'Pentazocin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AX01' as ATC, 'Tilidin-HCl; Naloxon-HCl' as BezKorrektur, 'N02AX-Andere Opioide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AX01' as ATC, 'Tilidinphosphat; Naloxon-HCl' as BezKorrektur, 'N02AX-Andere Opioide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AX02' as ATC, 'Tramadol-HCl' as BezKorrektur, 'N02AX-Andere Opioide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02AX04' as ATC, 'Meptazinol' as BezKorrektur, 'N02AX-Andere Opioide' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02BA01' as ATC, 'Acetylsalicylsäure (Ph.Eur.)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02BB01' as ATC, 'Phenazon' as BezKorrektur, 'N02B-andere Analgetika und Antipyretika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02BB02' as ATC, 'Metamizol-Na' as BezKorrektur, 'N02B-andere Analgetika und Antipyretika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02BB04' as ATC, 'Propyphenazon' as BezKorrektur, 'N02B-andere Analgetika und Antipyretika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02BG07' as ATC, 'Flupirtinmaleat' as BezKorrektur, 'N02B-andere Analgetika und Antipyretika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CC02' as ATC, 'Naratriptan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CC03' as ATC, 'Zolmitriptan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CC04' as ATC, 'Rizatriptan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CC05' as ATC, 'Almotriptan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CC06' as ATC, 'Eletriptan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N02CX12' as ATC, 'Topiramat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AA02' as ATC, 'Phenobarbital' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AA03' as ATC, 'Primidon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AD01' as ATC, 'Ethosuximid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AD03' as ATC, 'Mesuximid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AF03' as ATC, 'Rufinamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AG01' as ATC, 'Natriumvalproat; Valproinsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AG01' as ATC, 'Natriumvalproat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AG04' as ATC, 'Vigabatrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AG06' as ATC, 'Tiagabin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX03' as ATC, 'Sultiam' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX10' as ATC, 'Felbamat' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX11' as ATC, 'Topiramat' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX15' as ATC, 'Zonisamid' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N03AX21' as ATC, 'Kaliumbromid' as BezKorrektur, 'N03AX-Andere Antiepileptika' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04AA02' as ATC, 'Biperiden' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04AA03' as ATC, 'Metixen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04AA11' as ATC, 'Bornaprin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BA10' as ATC, 'Levodopa; Carbidopa' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BA11' as ATC, 'Levodopa; Benserazid-HCl' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BB01' as ATC, 'Amantadin' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BC02' as ATC, 'Pergolid' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BC03' as ATC, 'Alpha-Dihydroergocryptinmesilat' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BC07' as ATC, 'Apomorphin' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BC08' as ATC, 'Piribedil' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BC09' as ATC, 'Rotigotin' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BD01' as ATC, 'Selegilin' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BX01' as ATC, 'Tolcapon' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BX02' as ATC, 'Entacapon' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N04BX03' as ATC, 'Budipin' as BezKorrektur, 'N04B-Dopaminerge Mittel' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AA01' as ATC, 'Chlorpromazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AA02' as ATC, 'Levomepromazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AB03' as ATC, 'Perphenazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AD06' as ATC, 'Bromperidol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AD07' as ATC, 'Benperidol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AE03' as ATC, 'Sertindol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AE04' as ATC, 'Ziprasidon-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AF01' as ATC, 'Flupentixol-2HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AF01' as ATC, 'Flupentixol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AF05' as ATC, 'Zuclopenthixol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AG01' as ATC, 'Fluspirilen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AG02' as ATC, 'Pimozid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AH02' as ATC, 'Clozapin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AL03' as ATC, 'Tiaprid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AL05' as ATC, 'Amisulprid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AN01' as ATC, 'Lithiumcarbonat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AN01' as ATC, 'Lithium-Ion' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AX11' as ATC, 'Zotepin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AX12' as ATC, 'Aripiprazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05AX13' as ATC, 'Paliperidon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BA02' as ATC, 'Chlordiazepoxid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BA04' as ATC, 'Oxazepam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BA11' as ATC, 'Prazepam' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05BE01' as ATC, 'Buspiron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CC01' as ATC, 'Chloralhydrat (Ph.Eur.)' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CD01' as ATC, 'Flurazepam' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CD05' as ATC, 'Triazolam' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CD07' as ATC, 'Temazepam' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CD09' as ATC, 'Brotizolam' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CF02' as ATC, 'Zolpidemtartrat' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CH' as ATC, 'Kava-Kava' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CH' as ATC, 'Passiflora incarnata' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N05CM02' as ATC, 'Clomethiazol' as BezKorrektur, 'N05C-Hypnotika und Sedativa' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AA04' as ATC, 'Clomipramin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AA05' as ATC, 'Opipramol-2HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AB08' as ATC, 'Fluvoxamin' as BezKorrektur, 'N06AB-Selektive Serotonin-Wiederaufnahmehemmer' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AF04' as ATC, 'Tranylcypromin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AP01' as ATC, 'Johanniskraut-Trockenextr.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AX' as ATC, 'Bupropion' as BezKorrektur, 'N06AX-Andere Antidepressiva' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AX02' as ATC, 'Tryptophan' as BezKorrektur, 'N06AX-Andere Antidepressiva' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06AX18' as ATC, 'Reboxetin' as BezKorrektur, 'N06AX-Andere Antidepressiva' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06BA04' as ATC, 'Methylphenidat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06BA05' as ATC, 'Pemolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06BA07' as ATC, 'Modafinil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06BA09' as ATC, 'Atomoxetin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06BC01' as ATC, 'Coffein' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06BX04' as ATC, 'Deanol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DA02' as ATC, 'Donepezil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DA03' as ATC, 'Rivastigmin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DA04' as ATC, 'Galantamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DX01' as ATC, 'Memantin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DX02' as ATC, 'Flavonglykoside' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DX02' as ATC, 'Ginkgoflavonglykoside' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DX02' as ATC, 'Flavonoide' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DX02' as ATC, 'Terpenlactone' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N06DX10' as ATC, 'Blut-Dialysat (Kalb), deproteinisiert' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07AA01' as ATC, 'Neostigmin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07AB02' as ATC, 'Bethanecholchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07BB01' as ATC, 'Disulfiram' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07BB04' as ATC, 'Naltrexon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07BC02' as ATC, 'Methadon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07CA52' as ATC, 'Cinnarizin; Dimenhydrinat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07XB01' as ATC, 'DL-Alpha-Liponsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07XH' as ATC, 'Zincum metallicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07XH' as ATC, 'Hypophysis suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07XH20' as ATC, 'Anamirta; Conium; Ambra grisea ; Petroleum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07XX' as ATC, 'Levodopa; Benserazid-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'N07XX06' as ATC, 'Tetrabenazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P01AX06' as ATC, 'Atovaquon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P01BA02' as ATC, 'Hydroxychloroquin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P01BB01' as ATC, 'Proguanil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P01BD01' as ATC, 'Pyrimethamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P01CX01' as ATC, 'Pentamidindiisethionat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P02BA01' as ATC, 'Praziquantel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P02CA01' as ATC, 'Mebendazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P02CA03' as ATC, 'Albendazol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P02CC01' as ATC, 'Pyrantel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P02CX01' as ATC, 'Pyrvinium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P02DA01' as ATC, 'Niclosamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P03AB02' as ATC, 'Lindan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P03AC04' as ATC, 'Permethrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'P03AX01' as ATC, 'Benzylbenzoat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AA05' as ATC, 'Oxymetazolin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AA07' as ATC, 'Xylometazolin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AA09' as ATC, 'Tramazolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AC02' as ATC, 'Levocabastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AC03' as ATC, 'Azelastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AC07' as ATC, 'Nedocromil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AD04' as ATC, 'Flunisolid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AH01' as ATC, 'Luffa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01AX15' as ATC, 'Silbereiweiß-Acetyltannat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01BH' as ATC, 'Luffa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01BH20' as ATC, 'Sinusitis-Nosode' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R01BP30' as ATC, 'Enzian; Primel; Sauerampfer; Holunder; Eisenkraut' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R02AA02' as ATC, 'Dequalinium Kation' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R02AA20' as ATC, 'Aluminiumchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R02AA20' as ATC, 'Cetylpyridiniumchlorid ; Benzocain' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R02AB03' as ATC, 'Fusafungin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R02AX02' as ATC, 'Flurbiprofen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AA01' as ATC, 'Epinephrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AC02' as ATC, 'Salbutamolsulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AC03' as ATC, 'Terbutalin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AC04' as ATC, 'Fenoterolhydrobromid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AC13' as ATC, 'Formoterolhemifumarat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AK03' as ATC, 'Ipratropiumbromid; Fenoterolhydrobromid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AK06' as ATC, 'Salmeterolxinafoat; Fluticason-17-propionat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AK07' as ATC, 'Beclometasondipropionat; Formoterolhemifumarat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03AK07' as ATC, 'Budesonid; Formoterolhemifumarat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03BA08' as ATC, 'Ciclesonid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03BB04' as ATC, 'Tiotropium-Ion' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03BC03' as ATC, 'Nedocromil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03CC03' as ATC, 'Terbutalin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03CC12' as ATC, 'Bambuterol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03DA05' as ATC, 'Aminophyllin 2H£2O' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R03DX05' as ATC, 'Omalizumab' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R04AX04' as ATC, 'Cineol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CA03' as ATC, 'Guaifenesin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CA25' as ATC, 'Cineol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CB03' as ATC, 'Carbocistein' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CB06' as ATC, 'Sorbitol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CB06' as ATC, 'Ambroxol-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CB06' as ATC, 'Phenylalanin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CB13' as ATC, 'Dornase alfa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CH20' as ATC, 'Bronchus suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CH20' as ATC, 'Pulmo suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CP01' as ATC, 'Thymol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CP01' as ATC, 'Thymus vulgaris' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CP01' as ATC, 'Thymianöl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CP02' as ATC, 'Ethanol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05DA07' as ATC, 'Noscapin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05DA09' as ATC, 'Dextromethorphan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05DB02' as ATC, 'Benproperin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05DB19' as ATC, 'Dropropizin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05DB27' as ATC, 'Levodropropizin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05FH20' as ATC, 'Cuprum aceticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05X' as ATC, 'Kapuzinerkressenkraut; Meerrettichwurzel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05XH20' as ATC, 'Grippe-Nosode' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AA07' as ATC, 'Diphenylpyralin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AB04' as ATC, 'Chlorphenamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AD02' as ATC, 'Promethazin-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AD02' as ATC, 'Rivastigmin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AD07' as ATC, 'Mequitazin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AE05' as ATC, 'Meclozin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AE06' as ATC, 'Oxatomid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AE07' as ATC, 'Cetirizin 2HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AE09' as ATC, 'Levocetirizin 2HCl' as BezKorrektur, 'R06A-Antihistaminika systemisch' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AX12' as ATC, 'Terfenadin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AX17' as ATC, 'Ketotifen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R06AX19' as ATC, 'Azelastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AA01' as ATC, 'Chloramphenicol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AA02' as ATC, 'Chlortetracyclin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AA10' as ATC, 'Natamycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AA12' as ATC, 'Tobramycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AA24' as ATC, 'Kanamycin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AA25' as ATC, 'Azidamfenicol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AD02' as ATC, 'Trifluridin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AX02' as ATC, 'Silbereiweiß-Acetyltannat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AX05' as ATC, 'Bibrocathol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01AX17' as ATC, 'Lomefloxacin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01BA07' as ATC, 'Fluorometholon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01BA13' as ATC, 'Rimexolon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01BC04' as ATC, 'Flurbiprofen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01BC05' as ATC, 'Ketorolac' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01BC08' as ATC, 'Salicylsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01CA01' as ATC, 'Dexamethason; Neomycinsulfat; Polymyxin-B-sulfat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01EA05' as ATC, 'Brimonidin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01EB02' as ATC, 'Carbachol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01EC01' as ATC, 'Acetazolamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01ED03' as ATC, 'Levobunolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01ED07' as ATC, 'Pindolol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01ED51' as ATC, 'Bimatoprost; Timololmaleat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01EE03' as ATC, 'Bimatoprost' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01FA06' as ATC, 'Tropicamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GA05' as ATC, 'Phenylephrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GA10' as ATC, 'Tramazolin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GX02' as ATC, 'Levocabastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GX04' as ATC, 'Nedocromil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GX05' as ATC, 'Lodoxamid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GX06' as ATC, 'Emedastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GX07' as ATC, 'Azelastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GX08' as ATC, 'Ketotifen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01GX10' as ATC, 'Epinastin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01LA01' as ATC, 'Verteporfin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01LA04' as ATC, 'Ranibizumab' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA02' as ATC, 'Retinolpalmitat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA20' as ATC, 'Polyvinylalkohol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA20' as ATC, 'Polyacrylsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA20' as ATC, 'Blut-Dialysat (Kalb), deproteinisiert' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA20' as ATC, 'Dexpanthenol; Polyvinylalkohol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA20' as ATC, 'Digitalin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA20' as ATC, 'Hyetellose' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XA85' as ATC, 'Heidelbeer-Anthocyanoside' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XH' as ATC, 'Calendula officinalis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XH' as ATC, 'Ledum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XH01' as ATC, 'Euphrasia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XH20' as ATC, 'Oculus totalis suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XH20' as ATC, 'Retina suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XH20' as ATC, 'Augapfel-fetal-Lysat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'S01XH20' as ATC, 'Organpräparate' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA' as ATC, 'Allergenextrakt aus Pollen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA' as ATC, 'Allergenextrakt aus Wiesenlieschgraspollen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA' as ATC, 'Allergenextrakte' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA02' as ATC, 'Allergenextrakte' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA02' as ATC, 'Allergenextrakt aus Gräserpollen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA02' as ATC, 'Allergenextrakt aus Pollen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA04' as ATC, 'Allergenextrakt aus Schimmelpilzen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA05' as ATC, 'Allergenextrakte' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA05' as ATC, 'Allergenextrakt aus Birkenpollen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA05' as ATC, 'Allergenextrakt aus Baumpollen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA07' as ATC, 'Allergenextrakt aus Wespengift' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA07' as ATC, 'Allergenextrakt aus Bienengift' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA07' as ATC, 'Allergenextrakte' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA10' as ATC, 'Allergenextrakte' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA10' as ATC, 'Allergenextrakt aus Pollen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA11' as ATC, 'Allergenextrakt aus Katzenepithel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA11' as ATC, 'Allergenextrakt aus Epithelien' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA20' as ATC, 'Allergenextrakt aus Milben' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA20' as ATC, 'Allergenextrakt aus Pollen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA20' as ATC, 'Allergenextrakte' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA20' as ATC, 'Allergenextrakt aus Hausstaubmilben' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V01AA20' as ATC, 'Allergenextrakt aus Kräuterpollen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB' as ATC, 'Toloniumchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB03' as ATC, 'Edetinsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB13' as ATC, 'Obidoximchlorid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB15' as ATC, 'Naloxon-HCl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB19' as ATC, 'Physostigminsalicylat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB21' as ATC, 'Kaliumjodid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB25' as ATC, 'Flumazenil' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB27' as ATC, '4-Dimethylaminophenol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB31' as ATC, 'Eisen(III)-hexacyanoferrat(II)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB34' as ATC, 'Fomepizol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AB43' as ATC, '2,3-Dimercapto-1-propansulfonsäure, Natriumsalz' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AC01' as ATC, 'Deferoxamin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AC02' as ATC, 'Deferipron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AC03' as ATC, 'Deferasirox' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AE01' as ATC, 'Polystyrolsulfonat-Ca' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AE01' as ATC, 'Polystyrolsulfonat-Na' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AE03' as ATC, 'Lanthan' as BezKorrektur, '' as Untergruppe, 'PB-Lanthan' as Dokumentation UNION ALL
					SELECT 'V03AE04' as ATC, 'Aluminium-chlorid-hydroxid' as BezKorrektur, '' as Untergruppe, 'PB-Aluminium' as Dokumentation UNION ALL
					SELECT 'V03AE05' as ATC, 'Aluminiumhydroxid-Gel' as BezKorrektur, '' as Untergruppe, 'PB-Aluminium' as Dokumentation UNION ALL
					SELECT 'V03AE05' as ATC, 'Aluminiumoxid' as BezKorrektur, '' as Untergruppe, 'PB-Aluminium' as Dokumentation UNION ALL
					SELECT 'V03AF02' as ATC, 'Dexrazoxan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AF03' as ATC, 'Folinsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AF05' as ATC, 'Amifostin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AF06' as ATC, 'Folinsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AF07' as ATC, 'Rasburicase' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AF08' as ATC, 'Palifermin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AH01' as ATC, 'Diazoxid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AX' as ATC, 'Leber-Milz-Extrakt' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AX' as ATC, 'Spongiosa-Knochen lösungsmittelkonserviert, gamma-strahlensterilisiert (human)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AX' as ATC, 'Gelbkörper maternal-Lysat' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V03AX' as ATC, 'Lactose' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CA02' as ATC, 'Glucose' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CC04' as ATC, 'Ceruletid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CD04' as ATC, 'Corticorelin-vom-Mensch' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CD05' as ATC, 'Somatorelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CF01' as ATC, 'Tuberkulin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CJ01' as ATC, 'Thyrotropin alfa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CJ02' as ATC, 'Protirelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CK' as ATC, 'Fluorescein' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CK01' as ATC, 'Secretin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CM01' as ATC, 'Gonadorelin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CX' as ATC, 'Indocyaningrün, Mononatriumsalz' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CX11' as ATC, 'Methacholin-Kation' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V04CX13' as ATC, 'Harnstoff, C£1£3 markiert' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V07AB' as ATC, 'Tetrachlorethylen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V07AB' as ATC, 'Wasser f. Inj.-Zwecke' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V07AB' as ATC, 'Wasser, dest.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V07AM' as ATC, 'Human-Oberschenkelfaszie, dehydratisiert' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V07AM' as ATC, 'Spongiosa-Knochen lösungsmittelkonserviert, gamma-strahlensterilisiert (human)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V07KA' as ATC, 'Dexpanthenol; Polyvinylalkohol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AA01' as ATC, 'Jod' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AA04' as ATC, 'Iotalaminsäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AA04' as ATC, 'Jod' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AB02' as ATC, 'Iohexol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AB04' as ATC, 'Iopamidol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AB05' as ATC, 'Iopromid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AB06' as ATC, 'Iotrolan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AB07' as ATC, 'Ioversol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AB13' as ATC, 'Iosarcol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08AC02' as ATC, 'Jod' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08CA01' as ATC, 'Gadolinium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08CA02' as ATC, 'Gadotersäure' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08CB03' as ATC, 'Eisenoxide (E172)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V08DA02' as ATC, 'Galactose' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V10XX02' as ATC, 'Ibritumomab-Tiuxetan' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum acetylosalicylicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum benzoicum e resina' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum cis-aconiticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum DL-malicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum hydrochloricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum lacticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum oxalicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Adonis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aesculus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Allium cepa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Allium sativum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ammonium carbonicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Amnion lysat. bovis fetal extr. lyophyl. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Anamirta' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Apatit' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Apocynum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arisaema' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Artemisia absinthium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria basilaris bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria cerebri media bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria femoralis bovis-Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria renalis bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulatio sacroiliaca bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulationes intervertebrales lumbales bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Asparagus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Asthma-Nosode' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Atlas bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aurum chloratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aurum sulfuratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Balsamum copaivae' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Berberis vulgaris' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Calcium fluoratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Calotropis gigantea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Camphora' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Castanea sativa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Causticum Hahnemanni' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Chlorophyllum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cinchona' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Conium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cornea lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Crataegus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cuprum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cuprum arsenicosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cyclamen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Daucus carota' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Dioscorea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Drosera' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Echinacea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Equisetum arvense' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Fraxinus americana' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Fucus vesiculosus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula lymphatica suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula parathyreoidea lysat. suis juvenil extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula parathyreoidea suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula thymi lysat. suis juvenil extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula thymi suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Graphites' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Guaiacum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Helleborus niger' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hepar lysat. bovis fetal. et juvenil (1:1) extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Herpes simplex' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Herpes zoster' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hydrargyrum stibiato-sulfuratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hypericum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Illicium verum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Iris versicolor' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Kalium jodatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Kalium phosphoricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Kreosotum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lachesis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lithium chloratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lobelia inflata' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lophophytum leandri' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Mahonia aquifolium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Mercurius vivus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Nadidum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Natrium bicarbonicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Natrium oxalaceticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Natrium tetrachloroauratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Nitroglycerinum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Origanum vulgare' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Panax quinquefolius' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Prunella vulgaris' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Pyrogenium-Nosode' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Rhododendron' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ribes nigrum P.P.H Ø' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Secale cornutum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Smilax' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Solanum dulcamara' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Spongilla' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Streptococcus haemolyticus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Sulfur jodatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Taraxacum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Tetraethylblei' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Toxicodendron quercifolium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Tumor herb art. diverser genesis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ubichinon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Vaccinium myrtillus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Veratrum album' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Vincetoxicum hirundinaria' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Zincum valerianicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum asparagicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum citricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum formicum e formica rufa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum fumaricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum nitrohydrochloricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum picrinicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum salicylicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum sulfuricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aconitum napellus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aloe' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aluminium oxydatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ammi visnaga' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Antimonit' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Antimonium arsenicosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aorta bovis tota Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Apis cum Levistico' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Apis mellifica' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Apomorphinum hydrochloricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Araneus diadematus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Artemisia abrotanum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria brachialis bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria poplitea bovis-Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteriae bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulatio cubiti bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulatio radiocarpea bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulatio talocrualis bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulationes intervertebrales cervicales bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Asa foetida' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Astragalus excapus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aurum metallicum praeparatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Bacterium coli-Nosode' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Bambusa arundinacea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Barium jodatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Betula pendula' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Boswellia serrata' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Bryonia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Buxus chinensis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Calcium sulfuricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Capsicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Carbo vegetabilis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cerebellum suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cerebrum suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Chamomilla' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cinnamomum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Clematis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Colon suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Convallaria' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cor lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Corpus vitreum lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cortisonum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Crocus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cynara scolymus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Eleutherococcus senticosus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Epinephrin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Epiphysis lysat. suis juvenil extr. lyophyl. aquosum (HAB, V, 5b)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Euphrasia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Euspongia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ferrum phosphoricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Gentiana acaulis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Gentiana lutea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula thymi lysat. bovis fetal extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula thyreoidea suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hamamelis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hekla lava' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hydrargyrum cyanatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hyoscyamus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ignatia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Kalium arsenicosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Kalium bromatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ledum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lien lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lingua lysat. bovis maternal extr. lyophil. aqu.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lithium benzoicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lobaria pulmonaria' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Magnesium fluoratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Mamma lactans lysat. bovis maternal extr. lyophil. aqu.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Melissa officinalis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Mucosa intestinalis crassi lysat. bovis fetal extr. lyophyl. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Musculus suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Natrium selenosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Pallasit' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Panax pseudoginseng' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Paris quadrifolia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Phyllostachys e nodo ferm 35c' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Picrasma excelsa, Quassia amara' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Piper methysticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Polyketon' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Prostata lysat. bovis juvenil. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Pulmo lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Pyrit' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Quassia amara' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Quercus cortice cum Calcio carbonico' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ranunculus bulbosus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Salmonella typhi' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Sambucus nigra' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Scrophularia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Sepia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Splen suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Stannum metallicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Stibium sulfuratum aurantiacum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Thryallis glauca' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Thuja occidentalis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Viscum album' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Achat aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum alpha-ketoglutaricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum hydrocyanicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum phosphoricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Adeps suillus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aesculin' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aethusa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Agaricus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aletris' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Allium ursinum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Alumen' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aluminium metallicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aluminium-kalium-sulfuricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Amethyst' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ammonium jodatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Anthrachinonum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Appendix vermiformis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arctostaphylos uva-ursi' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Argentum metallicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Argentum nitricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aristolochia clematitis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arnica montana' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arsenicum jodatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria ophthalmica bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria vertebralis bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulatio coxae bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Asclepias tuberosa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Atropa belladonna' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aurum metallicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Avena sativa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Baptisia tinctoria' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Barium citricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Berberis ; Colchicum; etc (7) Komplexmittel' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Calendula officinalis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'cAMP' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Capsicum frutescens' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Centaurea jacea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Centaurea montana' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Chelidonium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Chininum sulfuricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cholesterinum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Citrullus colocynthis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Colchicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Columna vertebralis lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Conjunctiva lysat. bovis maternal extr. lyophil. aqu.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Corpus pineale suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Coxsackie-Virus A£9' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'D100 Homöpathische Tropfen (Ethanol)' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Delphinium staphisagria' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Galipea officinalis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula suprarenalis lysat. suis juvenil extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula thymi bovis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Glandula thyreoidea bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Helianthus tuberosus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hepar lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hepar sulfuris' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hyancinthoides non-scripta' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hypophysinum (gland. pituit.) lysat. suis juvenil extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ipecacuanha' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Kalium bichromicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Levisticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lophophora williamsii' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lycopodium clavatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Manganum sulfuricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Medicago sativa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Methylguanidinum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Momordica balsamina' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Momordica charantia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Mucosa ventriculi lysat. bovis fetal extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Musculi lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'para-Benzochinonum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Periosteum lysat. bovis fetal. extr. lyophil. aqu.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Plumbum metallicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Polyporus squamosus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Pulpa dentis suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Quarz' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Sabadilla' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Salvia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Stannum silicas' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Staphylococcus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Stibium sulfuratum nigrum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Tarantula' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Trichinoyl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Vena suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Vesica fellea lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Zincum gluconicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum aceticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum arsenicosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum formicicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum hydrofluoricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum nitricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum sarcolacticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum silicicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum succinicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Acidum uricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Adhatoda' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ailanthus altissima' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Alpinia officinarum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Amanita muscaria' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ambra grisea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ambrosia artemisiifolia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ammonium bromatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ammonium causticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Ammonium chloratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Anagallis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Anus bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aquilegia vulgaris' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aralia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Argentum metallicum praeparatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria carotis communis et sinus caroticus bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria coronaria bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arteria pulmonalis bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulatio genus bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulatio humeri bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulatio subtalaris bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulatio temporomandibularis bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Articulationes intercarpeae bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Arundo donax' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Asarum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aurum colloidale' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Aurum jodatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Balsamum peruvianum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Barium carbonicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Barium chloratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Bellis perennis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Biotinum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Calcium carbonicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Calcium jodatum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Calcium phosphoricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Candida albicans' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cardiospermum halicacabum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Caulophyllum thalictroides' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cerebrum lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cholin citricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Commiphora mukul' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Coxsackie-Virus-B£4' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cutis lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Cytisus scoparius' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Daphne mezereum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Datura stramonium' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Eichhornia crassipes' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Fagopyrum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Funiculus umbilicalis suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Galega officinalis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Gelsemium sempervirens' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hamamelis virginiana' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Histaminum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hydrastis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Hypothalamus suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Interferon beta-1b' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Jodum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Juglans regia' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Kalium carbonicum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Kalium sulfuricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Lytta vesicatoria' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Madar' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Magnesium oroticum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Magnesium sulfuricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Marrubium vulgare' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Medulla ossis suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Membrana sinus frontalis bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Mercurius solubilis Hahnemanni' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Mucosa vesica urinaria lysat. bovis fetal. extr. lyophil. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Mucuna' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Natrium sulfuricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Oenanthe crocata' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Opuntia vulgaris' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Passiflora incarnata' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Petasites hybridus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Petroleum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Phosphorus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Phytolacca americana' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Pollis graminis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Portulaca oleracea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Prostata suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Pulsatilla pratensis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Quercus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Resina piceae' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Rhodiola rosea' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Sanguinaria' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Schisandra chinensis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Semecarpus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Stachys officinalis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Strychninum nitricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Strychnos ignatii' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Strychnos nux vomica' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Sulfur' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Symphytum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Testes lysat. bovis juvenil extr. lyophyl. aquosum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Testes suis' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Trigonella foenum-graecum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Urtica' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Vakzine 12 Lyme-Borreliose' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Viburnum opulus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Viola tricolor' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Vitex agnus castus' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Yucca filamentosa' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60A' as ATC, 'Zincum chloratum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60B' as ATC, 'Corpus luteum bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60B' as ATC, 'Kalium chromosulfuricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60B' as ATC, 'Siliciumdioxid' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60B' as ATC, 'Keimzumpenblätter-Extr.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60B' as ATC, 'Quarz' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60B' as ATC, 'Ferrum phosphoricum' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'V60B' as ATC, 'Arteriae bovis Gl' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D06BB03' as ATC, 'Aciclovir-extern' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'D03AX03' as ATC, 'Dexpanthenol-ext.' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'R05CA' as ATC, 'Tyloxapol; Glycerol' as BezKorrektur, '' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'B03AA01' as ATC, 'Eisen(II)glycinsulfat' as BezKorrektur, 'B03A - Eisen-haltige Zubereitungen (0)' as Untergruppe, 'Eisenpräparate' as Dokumentation UNION ALL
					SELECT 'A11JB01' as ATC, 'Vitamine mit Mineralstoffen' as BezKorrektur, 'A11J - Andere Vitaminpräparate, Kombinationen (0)' as Untergruppe, '' as Dokumentation UNION ALL
					SELECT 'C07BB02' as ATC, 'Metoprololtatrat/Hydrochlorothiazid' as BezKorrektur, 'C07B - Betablocker und Thiazide (0)' as Untergruppe, 'B.3 Antihypertensivum+Diuretikum' as Dokumentation
			) b
				on a.bezeichnung = b.BezKorrektur
			join dbo.Transplantation t
				on a.PatientID = t.PatientID 
			where len(trim(untergruppe)) > 1
				and year(datum) >= 2004
				and (Untergruppe like 'A02B - Mittel bei peptischem Ulkus und gastroösophagealer Refluxkrankheit (0)'
					or Untergruppe like 'A11C - Vitamin D, inkl. deren Kombinationen (0)' or Untergruppe like 'B03X - Andere Antianämika (0)' 
					or Untergruppe like 'B03X - Andere Antianämika (0)' 
					or Untergruppe like 'C07A - Betablocker (0)' 
					or Untergruppe like 'C08C - Selektive Calciumkanalblocker mit vorwiegend vaskulärer Wirkung (0)'
					or Untergruppe like 'H02AB*-Glucocorticoide' 
					or Untergruppe like 'L04AA - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA02 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA03 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA04 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA08 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA09 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA10 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA13 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA18 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA21 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA23 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AA24 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AD01 - Selektive Immunsuppressiva'
					or Untergruppe like 'L04AD02 - Selektive Immunsuppressiva'
					and datediff(dd, t.Datum ,a.Anfangsdatum ) between -1 and  365
				) and einheit in ('mg', 'µg')
			group by TransplantationID 
		) med
		on t.TransplantationID = med.TransplantationID
		left join (				
					SELECT 'IgA Nephropathie' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis chronisch onA' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'diab. Nephropathie Typ I' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zystennieren' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zystennieren,bds.' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrosklerose' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetische Nephropathie' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mellitus Typ I' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'hypertensive Nephropathie' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfnieren bds.' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'IgA-Nephropathie' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'IgA- Nephropathie' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'ADPKD' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfnieren' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrosklerose onA' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'interstitielle Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mell., Typ II' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'fokal segmentale Glomerulosklerose' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Alport-Syndrom' as Grunderkrankung_orig, 'Alport' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'terminale Niereninsuffizienz' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'FSGS' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'diab. Nephropathie Typ II' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Pyelonephritis' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyzystische Nierenerkrankung' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Reflux-Nephropathie' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zystenniere Erwachsener' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'diabet. Nephropathie Typ 1' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Morbus Wegener' as Grunderkrankung_orig, 'Morbus Wegener' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'HUS' as Grunderkrankung_orig, 'HUS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Pyelonephritis chronisch' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfniere onA' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephropathie onA' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mellitus Typ 1' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'diabetische Nephropathie Typ I' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephropathie bei Diabetes Typ I' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephritis interstitiell onA' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'hypertensive Nephropahie' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'membranöse Glomerulonephritis' as Grunderkrankung_orig, 'membranöse GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mellitus Typ II' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chron. Glomerulonephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chronische Glomerulonephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zysten-Niere kongenital' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'unbekannt' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'unklar' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polycyst. Nierendegeneration (Potter III)' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyzyst. Nierendegeneration' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Analgetika-Nephropathie' as Grunderkrankung_orig, 'Analgetikanephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis rapid progressiv' as Grunderkrankung_orig, 'RPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Goodpasture-Syndrom' as Grunderkrankung_orig, 'Streptokokken-GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Lupus erythematodes' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hydronephrose' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Refluxnephropathie' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Term. Niereninsuff.' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrotisches Syndrom onA' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'CyA-Schaden' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chronische Niereninsuffizienz onA' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierendysplasie bds.' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephronophthise' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zystenniere onA' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfniere' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Pyelonephritis, chron.' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'polyzystische Nierendegeneration' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrosklerose maligne' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'hämolytisch urämisches Syndrom' as Grunderkrankung_orig, 'HUS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hypoplastische Nieren bds.' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Akutes Nierenversagen' as Grunderkrankung_orig, 'ANV' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulosklerose, fokal- segment.' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis, chron.' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulosklerose' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mellitus 1' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Analgetikanephropathie' as Grunderkrankung_orig, 'Analgetikanephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chron. Pyelonephritis' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'hypertensive Nephrosklerose' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrokalzinose' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'mesangioproliferative Glomerulonephritis' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyzystische Niere Erwachsenentyp' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'mesangioproleferative Glomerulonephritis' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'dysplastische Nieren' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis membrano-proliferativ' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'glomerulonephritis mesangio' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Good-Pasture-Syndrom' as Grunderkrankung_orig, 'Streptokokken-GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chronische Niereninsuffizienz' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'CNI Toxizität nach LTx' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Lupus-Nephritis' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'membrano proliferative Glomerulonephritis' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'glomeruläre Nierenerkrankung' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrolithiasis' as Grunderkrankung_orig, 'Nephrolithiasis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polycystische Nierendegenration' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenzell-Ca.' as Grunderkrankung_orig, 'Nierenzellkarzinom' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polycystische Nierendegeneration' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zysten-Nieren kongential' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Unspecified' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zystennieren Potter III' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nieren-Krankheit onA' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierendysplasie' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hypertonie mit Nephrosklerose' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'IgA-Nephritis' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Lupus erythematodes visceralis' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'CNI Tox.' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chron. Niereninsuffizienz' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Analgetika Nephropathie' as Grunderkrankung_orig, 'Analgetikanephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Analgetika- Nephropathie' as Grunderkrankung_orig, 'Analgetikanephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mellitus II' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'diabetische Nephropathie Typ IIb' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'fokal sklerosierende Glomerulosklerose' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulosklerose diabetisch' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Gichtnephropathie' as Grunderkrankung_orig, 'Gichtnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis mesangioproliferativ' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis mesangioproliferativ onA' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Alport- Syndrom' as Grunderkrankung_orig, 'Alport' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Alport' as Grunderkrankung_orig, 'Alport' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chronische  Glomerulonephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'CNI-Toxizität' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diab. Typ 1' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Interstitial Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'mesangioproliferative GN' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Mikroskopische Polyangiitis' as Grunderkrankung_orig, 'Morbus Wegener' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Morbus Fabry' as Grunderkrankung_orig, 'Morbus Fabry' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hämolytisch-urämisches Syndrom' as Grunderkrankung_orig, 'HUS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrotisches Syndrom fokale und segmentale' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephronophthiese' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrocalcinose' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'MPGN' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zystische Nierenkrankheit onA' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Tubulo-interstitial nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'terminale Niereninsuffizienz unklarer Genes' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuffizienz' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuffizienz onA' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Pyleonephrititis' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'rapid progressive Glomerulonephritis' as Grunderkrankung_orig, 'RPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Pyelonephritis chron.' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Pyelonephritis und Pyonephrose onA' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schoenlein-Henoch-Nephritis' as Grunderkrankung_orig, 'HUS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Purpura Schoenlein-Henoch' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyzystische Nieren' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'proliferativ sklerosierende Glomerulonephri' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Tubolo- interstitielle Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'SLE' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Steinleiden' as Grunderkrankung_orig, 'Nephrolithiasis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Streptokokken-GN' as Grunderkrankung_orig, 'Streptokokken-GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Wilms-Tumor bds' as Grunderkrankung_orig, 'Nierenzellkarzinom' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephropathie bei Diabetes Typ II' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephropathie hypertensiv' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niere hypoplastisch' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nieren-Insuffizienz terminal' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Lupus eryth. visceralis' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'membranoproliferative Glomerulonephritis' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Membranoproliferative GN' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Megaureter angeboren' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Lupusnephritis' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabet. Nephropathie' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'CNI Toxizität nach HTx' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Amyloidose m. Nieren-Beteiligung' as Grunderkrankung_orig, 'Amyloidose' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Amyloidose onA' as Grunderkrankung_orig, 'Amyloidose' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis membrano-proliferativ ch' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis fokal sklerosierend' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis fokal-segmental sklerosi' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis, messangiosklerose' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Goodpasture Syndrom' as Grunderkrankung_orig, 'Streptokokken-GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Fokal-segmentale Glomerulosklerose' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Einzelniere' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mellitus' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mell' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Dabetes mellitus Typ I' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetis Typ 2' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'fokal-segmentale membranöse GN' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'GN unklarer Genese' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis proliferativ' as Grunderkrankung_orig, 'RPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis extrakapillaer' as Grunderkrankung_orig, 'RPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'FSGS, familiär' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'CAKUT' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chr. Nierenins. unbek. Genese' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Amyloid - Nephrose' as Grunderkrankung_orig, 'Amyloidose' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'ADKD' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Amyloidose bei fam. Mittelmeerfieber' as Grunderkrankung_orig, 'Amyloidose' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Cystennieren' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chronische GN' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chronische PN' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chron.Glomerulonephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chronic Glomerulonephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chron. intersitielle Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Markschwammniere' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Markschwammnieren' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Laurence-Moon-Biedl-Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Lupus Erythematosis' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Membranöse GN' as Grunderkrankung_orig, 'membranöse GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'mesangio proliferative Glomerulonephritis' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Membrano-proliferative GN' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Mesangioprol. GN' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'IgA-NP' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hemolytic Uremic Syndrome' as Grunderkrankung_orig, 'HUS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hypertensive Genese' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Harnstauungs-Niere onA' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Harnstauungsnieren bds' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nieren-Insuffizienz terminal dialysepflicht' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nieren-Degeneration polyzystisch' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenagenesie einseitig' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuff., chron. OnA' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenerkrankung' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenhypoplasie onA' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuff. ,terminal' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephropathie medikamentös-toxisch' as Grunderkrankung_orig, 'Analgetikanephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephropathie durch Ciclosporin' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'nephritis interstitiell' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephangiosklerose' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephritis, chron.' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephritis, interstitiell' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephritisches Syndrom onA sonstige morpholo' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'MPGN Typ I' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'multifaktoriell' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zystinose' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Vasculitis' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'vaskuläre Nephropathie' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Vaskulitis' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'VD : GN ? diab.Nephropathie?' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'unklare Genese' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Urethralklappen' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Strahlennephritis' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfnieren bds.  unklarer Genese' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Sklerodermie' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Terminale Nierenisuffizienz unklarer Genese' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyzystische Nierendegen.' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'pyelonephritische Schrumpfnieren bds.' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpf-Niere pyelonephritisch' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuffizienz chron.' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Other' as Grunderkrankung_orig, 'other' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyzystische Leber u. Niere' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierentransplantatversagen' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'polyzystische Nierendegeneration PotterIII' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyzystische Nierendegenration' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'polyzystische Nierendysplasie' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyzystische Nierenierkrankung' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'polyzystsische Nierendegeneration' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Präterminale Niereninsuffizienz' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenversagen akut, vermutlich toxisch' as Grunderkrankung_orig, 'ANV' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenzell-Ca' as Grunderkrankung_orig, 'Nierenzellkarzinom' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'polycystische Nierendegeneraiton' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyzystische Leber- und Nierendegeneration' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'p.op.Nierenversagen' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'pANCA-positive mikroskopische Polyangitis' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'polizystische Nierenerkrankung' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenzell-Karzinom' as Grunderkrankung_orig, 'Nierenzellkarzinom' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenzellenkarzinom' as Grunderkrankung_orig, 'Nierenzellkarzinom' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenzellkarzinom' as Grunderkrankung_orig, 'Nierenzellkarzinom' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenzellkarzinom bds.' as Grunderkrankung_orig, 'Nierenzellkarzinom' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierinsuff., terminal' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Obstruktive Nephropathie' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuffizienz dialysepfl.' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuffizienz dialysepflichtig' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuffizienz präterminal' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuffizienz/Schrumpfniere' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenrindennekrosen bds. bei  Schock' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfniere / Agnesie li' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfniere Niereninsuffizienz' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfniere re. + obstr. NP li.' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfniere re., Zystinurie-Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfniere, pyeloneph.' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'RPGN im Rahmen IgA Nephropathie' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Sarkoidose' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schaden durch Cyclosporin' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schoenlein-Henoch- Nephritis' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schönlein Henoch Nephritis' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'rezid. PN bei Einzelniere' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'rapid progressive Gomerulonephritis' as Grunderkrankung_orig, 'RPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Pyelonephritis mit Nierensteinen' as Grunderkrankung_orig, 'Nephrolithiasis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Pyelonephritis akut' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Proteinurie unklarer Genese' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Prune-Belly-Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'PSH + M. Bechterew + Colitis  ulc.' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Thin basement membrane GN' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Toxische Nephropathie sonst nicht klassifiz' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'toxischer Nierenschaden' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Tuberöse Sklerose' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Tubolo- interstitial Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Tubuläre Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Tubulointerstitielle Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'tubulointerstitieller Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'tubulointestitielle Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Sklerose, messangial' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'sklerosierende Glomerulonephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'sklerosierende GN' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfnieren mit unklaren Genesen' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schrumpfnieren, unklar' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Senior-Loken-Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Simpson-Golabi-Behmel Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Sonstige näher bez. Krankheit Niere und Ur' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'systemischer Lupus erytematodes' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'teilweise Nephrektomie und NSKL' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'term IN unklarer Genese' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Term. NI' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Urethralklappen, Zystennieren, Nephrektomie' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'V.a. chronische GN' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'V.a. GN' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'V.a.Calzineurininhibitortoxizität' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'V.a.Nephrosclerose' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'ungeklärt' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Vd. hypertensive Nephropathie' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Wegener-Granulomatose' as Grunderkrankung_orig, 'Morbus Wegener' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Wegner&#39sche Granulomatose' as Grunderkrankung_orig, 'Morbus Wegener' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Wegner`sche Granulomatose' as Grunderkrankung_orig, 'Morbus Wegener' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Wegnersche Granulomatose' as Grunderkrankung_orig, 'Morbus Wegener' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zystennieren, Erwachsenenform' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Z.n. Multiorganversagen+Sepsis' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Z.n. typischem HUS' as Grunderkrankung_orig, 'HUS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Ureterreflux bds.' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Zystenleber+Zystennieren' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'N05.9' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'nach Chemotherapie' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Mesangioproliferative Glomerulonnephritis' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Morbus Wegner' as Grunderkrankung_orig, 'Morbus Wegener' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Moschcowitz-Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephroblastom' as Grunderkrankung_orig, 'Nierenzellkarzinom' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrangiosklerose' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrektomie bds' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'MPGN Typ 1' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephritis mit pathologischer Nieren-Veränd' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephronophthise hereditär idiopathisch' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephropathie b. Diabetes mell Typ II' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephropathie b. Diabetes mell. Typ II' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrolitiasis' as Grunderkrankung_orig, 'Nephrolithiasis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephropathie, diabetisch' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuff. onA' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Niereninsuff., term.' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierendysplasie links' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenagenesie li u. Steinschrumpfniere re' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenagenesie rechts' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenaplasie' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierenarterien-Stenose' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nierendegeneration,multizyst.' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nieren-Ruptur' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nieren-Insuffizienz chronisch präterminal' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nieren-Arterien-Stenose' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'neurogene Blase bei Meningomyelozele' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'NI unklarer Genese' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrosklerose onA DD FSGS' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrosklerose und ANV nach Sepsis' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrotisches Syndrom bei FSGS' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Harnstauungsnieren bds.' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hydronephrose bds.' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hydronephrose kongenital' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'hepatorenales Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'HIV-Nephropathie' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'HL-Problem li. + Schrumpfniere re.' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'HTN + DM II + NSAR' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'hämolytisches urämisches Syndrom' as Grunderkrankung_orig, 'HUS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'hämorrhagischer Schock' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Harnblasen-Entleerungsstörung neurogen' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Harnblasenhals-Stenose kongenital' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'IgA-Vaskulitis (Purpura Schönlein-Henoch)' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Immunkomplex-GN' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'IgA-Nephropathie, rheumatoide Arthritis' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hypertonus' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hypoplasie einseitig + HTN' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'hypertensives NV bei Einzelniere ?' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Morbus Ormond' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Mesangio-Proliferative Glomerulonephritis' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Membranoproliferative GN Typ I' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'membranoproliterative GN' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'intestitielle Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Kongenitale dysplast. Niere li., Reflux bds' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'kongenitaler Dysplasie' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Megauretheren' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Membrano-Proliferative Glomerulonephritis' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chron. interstitielle Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chron. Niereninsuff.' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chronisch interstitielle Nephritis' as Grunderkrankung_orig, 'interstitielle Nephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chronische Pyelonephritis' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'chronische Pyelonnephritis' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chronisches Nierenversagen' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chronische IgA-Nephropathie' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Cystinose' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Crush-Niere' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chronische Niereninsuffizienzz' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Chronische obstruktive Pyelonephritis' as Grunderkrankung_orig, 'Pyelonephritis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'CYA-Toxizität' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Cyclosporin-Schaden nach HTx' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Cyclosporin-toxizität nach HTx' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Amyloidose' as Grunderkrankung_orig, 'Amyloidose' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Alport-Syndrom (X-chrom.)' as Grunderkrankung_orig, 'Alport' as C_Grunderkrankung_grouped UNION ALL
					SELECT '' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'acute Nierenversagen' as Grunderkrankung_orig, 'ANV' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Agenesie li.' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Agenesie re.' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'aHUS' as Grunderkrankung_orig, 'HUS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Analgegetika-Nephropatie' as Grunderkrankung_orig, 'Analgetikanephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'ANCA Assoziierte Vaskulitis' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Antiphospholipidsyndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'ARPKD' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'atypisches HUS' as Grunderkrankung_orig, 'HUS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Balkannephropathie' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Bartter-Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Gichtnephritis' as Grunderkrankung_orig, 'Gichtnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'FSGS bei Lupus' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis mesangioproliferativ chr' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Goldenhar-Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'goltz- Gorlin- Syndrom' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glumerulonephritis chronisch' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'GPA' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis; histologisch gesichert' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis sklerosierend' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'fokale segmentale Glomerusklerose' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'fokal sklerosierende GN' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Einzelniere rechts, unklare Genese' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Fabri-Erkrankung' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'familiäre Nephritis' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetische Nephropatie' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diffus noduläre Glomerulosklerose' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'diffuse segmentale proliferative GN' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'DM + HTN' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'durch CyA ausgelöst' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'durch Cyclosporin A' as Grunderkrankung_orig, 'Ciclosporin A' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mellitus, HTN' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes Typ II' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetis mellitus I' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes + Adipositas' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mell. Typ I' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes mellitus + HTN' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polycystic' as Grunderkrankung_orig, 'Zystennieren' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'IgA Nephropathy' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes - Juvenile type' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulonephritis, other' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes - Adult type' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Diabetes' as Grunderkrankung_orig, 'Diabetes mellitus' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hypertensive Nephropathy' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrosclerosis' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Foc.scleros. GN (F.Sclerosis)' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Alport Syndrome' as Grunderkrankung_orig, 'Alport Syndrome' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Reflux Nephropathy' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Mesangio-Proliferative' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Lupus, S.L.E., LED' as Grunderkrankung_orig, 'SLE' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Wegeners' as Grunderkrankung_orig, 'Morbus Wegener' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Analgesic Nephropathy' as Grunderkrankung_orig, 'Analgetikanephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Focal-segmental-mesangiale GN' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Membrano-Proliferative' as Grunderkrankung_orig, 'MPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Proliferative GN' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Goodpasture' as Grunderkrankung_orig, 'Streptokokken-GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Dysplasia' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Glomerulosclerosis' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Amyloidosis' as Grunderkrankung_orig, 'Amyloidose' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Cirrhosis of the kidney' as Grunderkrankung_orig, 'unbekannt' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephronophtise' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hypoplasia' as Grunderkrankung_orig, 'Einzelniere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Cystinosis' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Tumor' as Grunderkrankung_orig, 'Nierenzellkarzinom' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrocalcinosis' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hydronephrosis' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrotic Syndrome' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schoenlein Henoch' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Vascular' as Grunderkrankung_orig, 'Hypertension' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Mesangiale GN' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Membranous GN' as Grunderkrankung_orig, 'membranöse GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Oxalosis' as Grunderkrankung_orig, 'Nephrolithiasis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Fabry&#39 s Disease' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Obstructive Uropathy' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Focal Glomerulonephritis' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Scleroderma' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Gout' as Grunderkrankung_orig, 'Gichtnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Urethral valves' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Rapidly Progressive GN' as Grunderkrankung_orig, 'RPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Megacystis-Megaureter-Syn' as Grunderkrankung_orig, 'Refluxnephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Post Streptococcal GN' as Grunderkrankung_orig, 'Streptokokken-GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Hereditary Nephritis' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Medullary sponge' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Immun Complex Nephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Minimal change' as Grunderkrankung_orig, 'FSGS' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Congenital Nephrosis' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Polyarteritis, P.A.N.' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrektomie' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Acute Glomerulonephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Traumatic renal' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Segmental Glomerulonephritis' as Grunderkrankung_orig, 'GN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Sarcoidois' as Grunderkrankung_orig, 'Vaskulitis' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Other (genetisch)' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Anti GBM-Nephropathy' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Berger' as Grunderkrankung_orig, 'IgA Nephropathie' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'RPGN' as Grunderkrankung_orig, 'RPGN' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Medullary Cystic' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Schistosomiasis Nephropathy' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped UNION ALL
					SELECT 'Nephrophtisis' as Grunderkrankung_orig, 'andere' as C_Grunderkrankung_grouped
			) grunderkr
				on coalesce(p.Grunderkrankung, p.ET_Grunderkrankung) = grunderkr.Grunderkrankung_orig
		left join (
					SELECT 'Lebendspende' as DonorCauseOfDeath_orig, 'Lebendspende' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Subarachnoidalblutung' as DonorCauseOfDeath_orig, 'SAB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'intracerebrale Blutung' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT '' as DonorCauseOfDeath_orig, 'unbekannt' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Schädel-Hirn-Trauma' as DonorCauseOfDeath_orig, 'SHT' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'hypoxämischer Hirnschaden' as DonorCauseOfDeath_orig, 'hypoxämischer Hirnschaden' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirninfarkt' as DonorCauseOfDeath_orig, 'Apoplex' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'intracranielle Blutung' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'SAB (Subarachnoidalblutung)' as DonorCauseOfDeath_orig, 'SAB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirnödem' as DonorCauseOfDeath_orig, 'Hirnödem' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'cerebrale Ischämie' as DonorCauseOfDeath_orig, 'Apoplex' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'subdurales Hämatom' as DonorCauseOfDeath_orig, 'SDH' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'andere' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'ICB (intrazerebrale Blutung)' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'intrakranielle Blutung' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'intercerebrale Blutung' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Schädeltrauma' as DonorCauseOfDeath_orig, 'SHT' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'CBL: Intrazerebrale Blutung' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Media-Infarkt onA' as DonorCauseOfDeath_orig, 'Apoplex' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirnmassenblutung' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Subarochnoidalblutung' as DonorCauseOfDeath_orig, 'SAB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'SAB: Subarachnoidalblutung' as DonorCauseOfDeath_orig, 'SAB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hypoxie zerebral nach Reanimat' as DonorCauseOfDeath_orig, 'hypoxämischer Hirnschaden' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Kopfschuß' as DonorCauseOfDeath_orig, 'Trauma' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirn-Aneurysma' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'unbekannt' as DonorCauseOfDeath_orig, 'unbekannt' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Blutung zerebral' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'T_CAPI: Trauma: Schädel' as DonorCauseOfDeath_orig, 'SHT' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Polytrauma' as DonorCauseOfDeath_orig, 'Trauma' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Carotis-Thrombose' as DonorCauseOfDeath_orig, 'kardiovasculär' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Blutung intrakraniell onA nich' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Herzinfarkt (NHB)' as DonorCauseOfDeath_orig, 'kardiovasculär' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'epidurales Hämatom' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Aneurysma Lokalisation onA' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirn-Blutung onA' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Aneurysma Arteria cerebri' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Lungenembolie' as DonorCauseOfDeath_orig, 'kardiovasculär' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirnschaden hypoxisch' as DonorCauseOfDeath_orig, 'hypoxämischer Hirnschaden' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hypoxämie' as DonorCauseOfDeath_orig, 'hypoxämischer Hirnschaden' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'CID: Ischämischer Insult' as DonorCauseOfDeath_orig, 'Apoplex' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirnembolie' as DonorCauseOfDeath_orig, 'Apoplex' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'RESP: Atmung  nicht anderweitig klassifizierbar' as DonorCauseOfDeath_orig, 'kardiovasculär' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Subduralhaematom traumatisch' as DonorCauseOfDeath_orig, 'Trauma' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Anoxie zerebral' as DonorCauseOfDeath_orig, 'hypoxämischer Hirnschaden' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Schädel-Fraktur onA' as DonorCauseOfDeath_orig, 'SHT' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Herzversagen akut' as DonorCauseOfDeath_orig, 'kardiovasculär' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Kleinhirn-Blutung' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Blutung zerebellar onA' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Contusio cerebri' as DonorCauseOfDeath_orig, 'SHT' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Apoplexie onA' as DonorCauseOfDeath_orig, 'Apoplex' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Aortenaneurysma onA' as DonorCauseOfDeath_orig, 'kardiovasculär' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hydrozephalus onA' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Schaedel-Hirn-Trauma onA' as DonorCauseOfDeath_orig, 'SHT' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirnaneurysma' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Sturz' as DonorCauseOfDeath_orig, 'Trauma' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'BRBE: Hirntumor, gutartig' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Ertrinken und nichttödliches U' as DonorCauseOfDeath_orig, 'Trauma' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirnstammblutung' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Erstickung durch Erhängen' as DonorCauseOfDeath_orig, 'Trauma' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Intrazerebrale Blutung onA' as DonorCauseOfDeath_orig, 'ICB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Schaedel-Hirn-Trauma Grad III' as DonorCauseOfDeath_orig, 'SHT' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'CVA: Zerebrovaskuläres Ereignis a.n. klassifizierbar' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Hirntumor' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Herzstillstand onA' as DonorCauseOfDeath_orig, 'kardiovasculär' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Status asthmaticus' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'CVA: Zerebrovaskuläres Ereignis,a.n. klassifizierbar' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Sonstige Epilepsie' as DonorCauseOfDeath_orig, 'andere' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'SAB' as DonorCauseOfDeath_orig, 'SAB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'Subarachnoidalblutung onA' as DonorCauseOfDeath_orig, 'SAB' as C_DonorCauseOfDeath_grouped UNION ALL 
					SELECT 'NAO: Nicht traumatische Todesursache,a.n. klassifizierbar' as DonorCauseOfDeath_orig, 'non traumatic' as C_DonorCauseOfDeath_grouped 
		) DCD 
		on s.Todesursache = DCD.DonorCauseOfDeath_orig
where year(t.datum) >= 2004 
	and (Ort like '%Charité Urologische Klinik%' or Ort like '%Berlin Charité-Mitte%' or Ort like '%Virchow%')
	and trim(t.organ) = 'Niere'
	--Transplants that fail or where patients die within 12 months after transplantation are ignored
	and (t.TPV_Datum is null or datediff(dd,t.datum, t.TPV_Datum) > 365)
	and (p.todesdatum is null or datediff(dd,t.datum, p.todesdatum) > 365)
	and datediff(yyyy,p.Geburtsdatum,t.Datum) >= 18