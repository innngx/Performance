%let path=C:\Users\Xgao\Documents\GitHub\Performance\CN\Data;  *define path;
libname Review "&path";

/*info;*/
PROC IMPORT OUT= info 
            DATAFILE= "&path\input.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  *set max length to avoid merge problem;
RUN;

data info;
	retain Name Gender DOB Age DOH VSm VS Job_Title Department Sub_Department Line_Manager Location Edu;
	set info;
	Age = intck('year', DOB, '1OCT16'd);
	VSm = intck('month', DOH, '1OCT16'd);
	VS = round(VSm/12,0.01);
run;

proc export data=info outfile="&path\info.csv" dbms = csv replace;
run;

quit;
