%let path=C:\Users\Xgao\Documents\GitHub\Performance\US\Data;  /*define path*/
libname Review "&path";

*year 2012 - 2014;
PROC IMPORT OUT= performance 
            DATAFILE= "&path\input_performance.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
data performance;
	set performance;
	if R_2014=. and R_2013=. and R_2012=. then delete;
run;
proc sort;
	by Payroll_Name;
run;

PROC IMPORT OUT= info 
            DATAFILE= "&path\input_info.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
proc sort;
	by Payroll_Name;
run;
data info;
	set info;
	if Employee_Status_Type='Active' then VSm=intck('month', Date_of_hire_rehire, '31DEC15'd);
	else VSm=intck('month', Date_of_hire_rehire, Last_Day_of_Employment);
	VS = round(VSm/12,0.01);
run;
PROC IMPORT OUT= edu 
            DATAFILE= "&path\input_edu.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
proc sort;
	by Payroll_Name;
run;
data info;
	merge info edu;
	by Payroll_Name;
	if Age = . then delete; /*delete edu from other country*/
run;
proc export data=info outfile="&path\info.csv" dbms = csv replace;
run;

data review.DataSetPerformance;
	merge info performance;
	by Payroll_Name;
	if R_2014=. and R_2013=. and R_2012=. then delete;
run;
proc export data=review.DataSetPerformance outfile="&path\DataSetPerformance.csv" dbms = csv replace;
run;

quit;


data review.DataSetPerformance1214;
	set review.DataSetPerformance(drop=J14 R14 C14 P14 I14 H14 S14 J13 R13 C13 P13 I13 H13 S13 J12 R12 C12 P12 I12 H12 S12);
	if R_2014=. and R_2013=. and R_2012^=. then Review=R_2012;
	if R_2014=. and R_2013^=. and R_2012=. then Review=R_2013;
	if R_2014^=. and R_2013=. and R_2012=. then Review=R_2014;
	if R_2014^=. and R_2013^=. and R_2012=. then
		if R_2014=R_2013 then Review=R_2014;
		else Review=.;
	if R_2014=. and R_2013^=. and R_2012^=. then
		if R_2013=R_2012 then Review=R_2013;
		else Review=.;
	if R_2014^=. and R_2013=. and R_2012^=. then
		if R_2014=R_2012 then Review=R_2012;
		else Review=.;
	if R_2014^=. and R_2013^=. and R_2012^=. then
		if R_2014=R_2013=R_2012 then Review=R_2012;
		else Review=.;
run;
data matched;
	set review.DataSetPerformance1214;
	if Review^=. then output;
run;
data unmatched;
	set review.DataSetPerformance1214;
	if Review=. then output;
	drop Review;
run;

proc export data=review.DataSetPerformance1214 outfile="&path\all.csv" dbms = csv replace;
run;
proc export data=matched outfile="&path\matched.csv" dbms = csv replace;
run;
proc export data=unmatched outfile="&path\unmatched.csv" dbms = csv replace;
run;

quit;


/* unmatched */
data reg12; *single reg12;
set review.DataSetPerformance1214(drop=VS VSm Review);
if R_2012=. then delete;
	*VS by year;
	if Employee_Status_Type='Active' then
		if Original_Date_of_hire <='31DEC12'd then VSm12=intck('month', Date_of_hire_rehire, '31DEC12'd);
	if Employee_Status_Type^='Active' then
		if Last_Day_of_Employment le '31DEC12'd then VSm12=intck('month', Date_of_hire_rehire, Last_Day_of_Employment);
		else VSm12=intck('month', Date_of_hire_rehire, '31DEC12'd);
drop R_2014 R_2013;
if VSm12=. or VSm12<0 then delete; *if Payroll_Name = 'Phillips, Brandon' then delete; *data input error, DOH > Review time;
run;
data reg13; *single reg13;
set review.DataSetPerformance1214(drop=VS VSm Review);
if R_2014^=. and R_2013=. and R_2012^=. then R_2013=R_2012;
if R_2013=. then delete;
	*VS by year;
	if Employee_Status_Type='Active' then
		if Date_of_hire_rehire <='31DEC13'd then VSm13=intck('month', Date_of_hire_rehire, '31DEC13'd);
	if Employee_Status_Type^='Active' then
		if Last_Day_of_Employment le '31DEC13'd then VSm13=intck('month', Date_of_hire_rehire, Last_Day_of_Employment);
		else VSm13=intck('month', Date_of_hire_rehire, '31DEC13'd);
drop R_2014 R_2012;
if VSm13=. or VSm13<0 then delete;
run;
data reg14; *single reg14;
set review.DataSetPerformance1214(drop=VS VSm Review);
if R_2014=. then delete;
	*VS by year;
	if Employee_Status_Type='Active' then
		if Date_of_hire_rehire <='31DEC14'd then VSm14=intck('month', Date_of_hire_rehire, '31DEC14'd);
	if Employee_Status_Type^='Active' then
		if Last_Day_of_Employment le '31DEC14'd then VSm14=intck('month', Date_of_hire_rehire, Last_Day_of_Employment);
		else VSm14=intck('month', Date_of_hire_rehire, '31DEC14'd);
drop R_2013 R_2012;
if VSm14=. or VSm14<0 then delete;
run;

/*only unmatched*/
data reg1213;
	merge reg13 reg12;
	by Payroll_Name;
	if R_2012=. or R_2013=. then delete;
	if R_2012=R_2013 then delete;
run;
data r13;
	set reg1213;
	Year = 2013;
	Review = R_2013;
	VSm = VSm13;
	drop R_2013 VSm13 R_2012 VSm12;
run;
data r12;
	set reg1213;
	Year = 2012;
	Review = R_2012;
	VSm = VSm12;
	drop R_2013 VSm13 R_2012 VSm12;
run;
data reg1213 (keep=Payroll_Name Year Review VS); *reg1213;
	retain Payroll_Name Year Review Age VS;
	set r12 r13;
	by Payroll_Name;
	VS = round(VSm/12,0.01);
run;

data reg1314;
	merge reg14 reg13;
	by Payroll_Name;
	if R_2014=. or R_2013=. then delete;
	if R_2014=R_2013 then delete;
run;
data r14;
	set reg1314;
	Year = 2014;
	Review = R_2014;
	VSm = VSm14;
	drop R_2014 VSm14 R_2013 VSm13;
run;
data r13;
	set reg1314;
	Year = 2013;
	Review = R_2013;
	VSm = VSm13;
	drop R_2014 VSm14 R_2013 VSm13;
run;
data reg1314 (keep=Payroll_Name Year Review VS); *reg1314;
	retain Payroll_Name Year Review VS;
	set r13 r14;
	by Payroll_Name;
	VS = round(VSm/12,0.01);
run;

data reg1214;
	merge reg14 reg13 reg12;
	by Payroll_Name;
	if R_2014=. or R_2012=. or R_2013=. then delete;
	if R_2014=R_2013=R_2012 then delete;
run;
data r14;
	set reg1214;
	Year = 2014;
	Review = R_2014;
	VSm = VSm14;
	drop R_2014 VSm14 R_2013 VSm13 R_2012 VSm12;
run;
data r13;
	set reg1214;
	Year = 2013;
	Review = R_2013;
	VSm = VSm13;
	drop R_2014 VSm14 R_2013 VSm13 R_2012 VSm12;
run;
data r12;
	set reg1214;
	Year = 2012;
	Review = R_2012;
	VSm = VSm12;
	drop R_2014 VSm14 R_2013 VSm13 R_2012 VSm12;
run;
data reg1214 (keep=Payroll_Name Year Review VS); *reg1214;
	retain Payroll_Name Year Review VS;
	set r12 r13 r14;
	by Payroll_Name;
	VS = round(VSm/12,0.01);
run;

/*all reg*/
data reg12all;
	set reg12;
	Year=2012;
	VSm=VSm12;
	Review=R_2012;
	output;
	drop R_2012 VSm12;
run;
data reg13all;
	set reg13;
	Year=2013;
	VSm=VSm13;
	Review=R_2013;
	output;
	drop R_2013 VSm13;
run;
data reg14all;
	set reg14;
	Year=2014;
	VSm=VSm14;
	Review=R_2014;
	output;
	drop R_2014 VSm14;
run;
data reg;
 	set reg14all reg13all reg12all;
  	by Payroll_Name;
run;

proc export data=reg outfile="&path\reg.csv" dbms = csv replace;
run;
proc export data=reg1213 outfile="&path\reg1213.csv" dbms = csv replace;
run;
proc export data=reg1314 outfile="&path\reg1314.csv" dbms = csv replace;
run;
proc export data=reg1214 outfile="&path\reg1214.csv" dbms = csv replace;
run;

quit;
