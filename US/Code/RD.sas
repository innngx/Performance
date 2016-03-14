%let path=C:\Users\Xgao\Documents\GitHub\Performance\US\Data;  /*define path*/
libname Review "&path";

PROC IMPORT OUT= performance 
            DATAFILE= "&path\input_PerformanceRD.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
proc sort;
	by Payroll_Name;
run;

PROC IMPORT OUT= info 
            DATAFILE= "&path\info.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
proc sort;
	by Payroll_Name;
run;

data review.performanceRD;
	merge info performance;
	by Payroll_Name;
	if Sub_Department=' ' then delete;
run;

proc export data=review.performanceRD outfile="&path\PerformanceRD.csv" dbms = csv replace;
run;

quit;
