%let path=C:\Users\Xgao\Documents\GitHub\Performance\US\Data;  /*define path*/
libname Review "&path";

*pay;
PROC IMPORT OUT= pay 
            DATAFILE= "&path\pay.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
proc sort;
	by Payroll_Name;
run;
PROC IMPORT OUT= insurance 
            DATAFILE= "&path\insurance.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
proc sort;
	by Payroll_Name;
run;
data performance;
	set review.datasetperformance1215;
run;
proc sort;
	by Payroll_Name;
run;

data predict;
	merge performance pay insurance;
	by Payroll_Name;
	if VS=. then delete;
run;

data mydata (keep=Payroll_Name Age Children VS Gender Department M_Status Edu Pay R_2015 HSA);
	set predict;
	if R_2015=. then delete;
	if Gender='M' then Gender=1;
		else Gender=0;
	if Marital_Status='Married' then M_Status=1;
		else M_Status=0;
	if Education='PhD Level' then Edu=4;
		else if Education='Master Level' then Edu=3;
		else if Education='Bachelor Level' then Edu=2;
		else if Education='Associate Level' then Edu=1;
		else Edu=0;
	if Medical_plan_name='HSA' then HSA=1; *HSA no effect;
		else HSA=0;
	if Pay=. then delete;
run;

proc export data=mydata outfile="&path\mydata2015.csv" dbms=csv replace;
run;

quit;
