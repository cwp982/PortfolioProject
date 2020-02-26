
/*****************************************************************************/
/* Accessibility and quality of care, 2016
/*
/* Children with dental care
/*
/* Example SAS code to replicate number and percentage of children with dental
/*  care, by poverty status
*/

*Assign Filename;
filename h192  "/folders/myshortcuts/MEPS/h192.ssp"; 

 *Convert SAS Transport Files to regular SAS data sets;
proc xcopy in=h192 out=WORK import;                                                           
run; 

data WORK.meps;
  	set h192;

 /* Children receiving dental care */
	child_2to17 = (1 < AGELAST & AGELAST < 18)*1;
	child_dental = ((DVTOT16 > 0) & (child_2to17 = 1))*1;

/*Keep only records of Children*/
	where (1 < AGELAST & AGELAST < 18)*1;
run;

proc format;
  value child_dental
	  1 = "One or more dental visits"
	  0 = "No dental visits in past year";

  value POVCAT
	  1 = "Negative or poor"
	  2 = "Near-poor"
	  3 = "Low income"
	  4 = "Middle income"
	  5 = "High income";
/*Added code to categorize lower income childern (1-3) and Higher Income Children (4-5)*/
  value POVCAT_A
      1 - 3 = 'Lower Income Children'
	  4 - 5 = 'Higher Income Children';
run;

/* Calculate estimates using survey procedures *******************************/
ods output CrossTabs = out;
proc surveyfreq data = MEPS missing;
	FORMAT child_dental child_dental. POVCAT16 POVCAT.;
	STRATA VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT16F;
	TABLES child_2to17*POVCAT16*child_dental / row;
run;

proc print data = out noobs label;
	where child_2to17 = 1 and child_dental ne . and POVCAT16 ne .;
	var child_dental POVCAT16 WgtFreq StdDev RowPercent RowStdErr;
run;

/*graphs to show relationships of the childrens dental care and their income status*/
title 'Dental Visits by Income status';
proc sgplot data=MEPS;
  vbar child_dental / response = POVCAT16 group=POVCAT16 groupdisplay=cluster;
  xaxis display=(nolabel);
  yaxis display = (nolabel);
  format child_dental child_dental. POVCAT16 POVCAT.;
run;

/*Two sample T Test*/
/*  Null hypothesis: Lower poverty children have equal or more dental visits than higher income children. 
    Alternate hypothesis: Lower poverty children have fewer dental visits than higher income children.  */
proc ttest data=meps alpha = 0.05 sides=L;
  class POVCAT16;
  format POVCAT16 POVCAT_A.;
  var DVTOT16;
run;
 

