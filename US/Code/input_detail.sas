%let path=C:\Users\Xgao\Documents\GitHub\Performance\US\Data;  /*define path*/
libname Review "&path";

%macro DetailLoop(varlist);
%let i=1;
	%do %while (%scan(&varlist, &i, |) ^=%str());
		%let var=%scan(&varlist, &i, |); 
		%put &var;

*code for detail.csv output;
data DataSetPerformance1214_&var;
	set review.DataSetPerformance(keep=Payroll_Name Gender Date_of_Birth Age Marital_Status Children Job_title EEO_Category Date_of_hire_rehire Years_Of_Service Company_Code Original_Date_of_hire Business_Unit Home_Department Employee_Status_Type Employee_Status_Classification Last_Day_of_Employment VSm VS Education
									   &var.12 &var.13 &var.14);
	if &var.14=. and &var.13=. and &var.12=. then delete;	/*not all detail review exist*/
	if &var.14=. and &var.13=. and &var.12^=. then Review=&var.12;
	if &var.14=. and &var.13^=. and &var.12=. then Review=&var.13;
	if &var.14^=. and &var.13=. and &var.12=. then Review=&var.14;
	if &var.14^=. and &var.13^=. and &var.12=. then
		if &var.14=&var.13 then Review=&var.14;
		else Review=.;
	if &var.14=. and &var.13^=. and &var.12^=. then
		if &var.13=&var.12 then Review=&var.13;
		else Review=.;
	if &var.14^=. and &var.13=. and &var.12^=. then
		if &var.14=&var.12 then Review=&var.12;
		else Review=.;
	if &var.14^=. and &var.13^=. and &var.12^=. then
		if &var.14=&var.13=&var.12 then Review=&var.12;
		else Review=.;
	Review = round(Review,1);	/*round up all review*/
run;
data matched_&var;
	set DataSetPerformance1214_&var;
	if Review^=. then output;
run;
data unmatched_&var;
	set DataSetPerformance1214_&var;
	if Review=. then output;
	drop Review;
run;
proc export data=matched_&var outfile="&path\matched_&var..csv" dbms = csv replace;
run;
proc export data=unmatched_&var outfile="&path\unmatched_&var..csv" dbms = csv replace;
run;
*code end;

*Increment counter;
%let i=%eval(&i+1);
%end;
%mend;

%DetailLoop(J|R|C|P|I|H|S);


data ReviewRegDetail(keep=Payroll_Name J R C P I H Review);
	merge review.DataSetPerformance1214
		  DataSetPerformance1214_J(rename=(Review=J))
		  DataSetPerformance1214_R(rename=(Review=R))
		  DataSetPerformance1214_C(rename=(Review=C))
		  DataSetPerformance1214_P(rename=(Review=P))
		  DataSetPerformance1214_I(rename=(Review=I))
		  DataSetPerformance1214_H(rename=(Review=H));
	by Payroll_Name;
	if Review=. or J=. or R=. or C=. or P=. or I=. or H=. then delete;
run;

proc export data=ReviewRegDetail outfile="&path\ReviewRegDetail.csv" dbms = csv replace;
run;

data ReviewRegDetailS(keep=Payroll_Name J R C P I H S Review);
	merge review.DataSetPerformance1214
		  DataSetPerformance1214_J(rename=(Review=J))
		  DataSetPerformance1214_R(rename=(Review=R))
		  DataSetPerformance1214_C(rename=(Review=C))
		  DataSetPerformance1214_P(rename=(Review=P))
		  DataSetPerformance1214_I(rename=(Review=I))
		  DataSetPerformance1214_H(rename=(Review=H))
		  DataSetPerformance1214_S(rename=(Review=S));
	by Payroll_Name;
	if Review=. or J=. or R=. or C=. or P=. or I=. or H=. or S=. then delete;
run;

proc export data=ReviewRegDetailS outfile="&path\ReviewRegDetailS.csv" dbms = csv replace;
run;

quit;
