%let path=C:\Users\Xgao\Documents\GitHub\Performance\US\Data\archived data;  /*define path*/
libname Review "&path";

PROC IMPORT OUT= performance 
            DATAFILE= "&path\test.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  *set max length to avoid merge problem;
RUN;

%macro transfer();
data performance;
	set performance;
%do var=12 %to 15;
	if R_20&var NOTIN (' ','1','2','3','4') then
	do;
		v1 = scan(R_20&var,1,'-');
		v2 = scan(R_20&var,2,'-');
		v3 = scan(R_20&var,3,'-');
		v4 = scan(R_20&var,4,'-');
	Review = 4*v1/sum(of v1-v4)+3*v2/sum(of v1-v4)-1*v3/sum(of v1-v4)-2*v4/sum(of v1-v4);
	if 2.5<=Review<3.1 then Review=Review-0.5;
	Review&var = round(Review,1);
	drop Review v1 v2 v3 v4;
	end;
	else Review&var=R_20&var;
%end;
run;
%mend;
%transfer;
quit;

data performance;
	retain Payroll_Name
		   R_2015 Review15 J15 R15 C15 P15 I15 H15 S15
		   R_2014 Review14 J14 R14 C14 P14 I14 H14 S14
		   R_2013 Review13 J13 R13 C13 P13 I13 H13 S13
		   R_2012 Review12 J12 R12 C12 P12 I12 H12 S12;
	set performance;
	rename R_2012-R_2015=bR_2012-bR_2015;
	rename Review12-Review15=R_2012-R_2015;
run;

proc export data=performance outfile="&path\input_test.csv" dbms = csv replace;
run;

quit;
