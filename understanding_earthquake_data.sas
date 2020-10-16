libname dmas "/courses/dc36fc35ba27fe300/DMASAssessments";

*Setting 0 values as missing;
data earthquakes2;
	set dmas.earthquakes;
	if depth<=0 then depth=.;
	if md<=0 then md=.;
	if richter<=0 then richter=.;
	if mw<=0 then mw=.;
	if ms<=0 then ms=.;
	if mb<=0 then mb=.;
run;

data work.earthquakes3;
   set work.earthquakes2;
   array v md richter mw ms mb;
   xm = max(of v(*));
run;

data work.earthquakes4;
   set work.earthquakes3;
   where xm >= 3;
run;

data work.earthquakes5; 
set work.earthquakes4; 
if country in ('turkey','mediterranean','greece','aegean_sea','iran','georgia','russia') then country=country; 
else country = 'other'; 
run;


proc contents data = dmas.earthquakes;
run;



proc means data = dmas.earthquakes;
run;

proc sql;
title 'Value of 0s by numeric field';
select count(1) as records
,sum(case when depth = 0 then 1 else 0 end) as depth_0
,sum(case when md = 0 then 1 else 0 end) as md_0
,sum(case when richter = 0 then 1 else 0 end) as richter_0
,sum(case when mw = 0 then 1 else 0 end) as mw_0
,sum(case when ms = 0 then 1 else 0 end) as ms_0
,sum(case when mb = 0 then 1 else 0 end) as mb_0
from dmas.earthquakes;
quit;

proc freq data = dmas.earthquakes ORDER=freq;
table country / MISSING;
run;

proc freq data = dmas.earthquakes ORDER=freq;
table direction / MISSING;
run;

*Distribution of mw;
proc univariate data = dmas.earthquakes noprint;
	histogram mw;
run;


*Setting 0 values as missing;
data earthquakes2;
	set dmas.earthquakes;
	if depth<=0 then depth=.;
	if md<=0 then md=.;
	if richter<=0 then richter=.;
	if mw<=0 then mw=.;
	if ms<=0 then ms=.;
	if mb<=0 then mb=.;
run;

*Checking updated dist;

proc means data = work.earthquakes2;
run;

data earthquakesnum;
	set dmas.earthquakes;
	keep depth md richter mw ms mb;
run;


proc corr data=work.earthquakes2 plots(maxpoints=none)=matrix(histogram); 
	var depth md richter mw ms mb;
run;

data work.earthquakes3;
   set work.earthquakes2;
   array v md richter mw ms mb;
   xm = max(of v(*));
run;

data work.earthquakes4;
   set work.earthquakes3;
   where xm >= 3;
run;

proc univariate data = work.earthquakes4 noprint;
	histogram xm;
	*where country in ('greece','iran');
run;

PROC SGPLOT DATA=work.earthquakes4;
		title 'Boxplot of xm value by country (top 5 countries only)';
         VBOX xm / category = country;
         where country in ('greece','aegean_sea','iran','georgia','russia');
RUN;

PROC SGPLOT DATA=work.earthquakes4;
		title 'Boxplot of xm';
         VBOX xm;
RUN;

PROC SGPLOT DATA=work.earthquakes4;
		title 'Boxplot of xm value by direction';
         VBOX xm / category = direction;
RUN;

*Is average different to 4.1?;
proc ttest data = work.earthquakes4 H0 = 4.1;
var xm;
title 'One Sample T-test. Is the largest magnitude value mean different to 4.1?';
run;

proc ttest data = work.earthquakes4 H0 = 4.1 plots(shownull)= interval;
	var xm;
	title 'One Sample T-test. Is the population mean different to $135,000?';
run;

*Serious value;
data example_dsn1; set example_dsn1; if bmi < 18.5 then wt_status = 1; else wt_status = 2; run;
proc format; value $treatmentfmt 'Ctrl' = 'Control' 'Inte' = 'Intervention'; run;

*Grouping as 'Other';
data work.earthquakes5; 
set work.earthquakes4; 
if country in ('turkey','mediterranean','greece','aegean_sea','iran','georgia','russia') then country=country; 
else country = 'other'; 
run;

PROC SGPLOT DATA=work.earthquakes5;
		title 'Boxplot of xm value by country';
         VBOX xm / category = country;
RUN;


proc glm data=work.earthquakes5;
	class country;
	model mw=country;
	title "One-Way ANOVA with Country as Explanatory";
	output out=work.anova predicted = predict cookd = cook;
run;
quit;

proc glm data=work.earthquakes5 plots=DIAGNOSTICS;
class country;
model xm=country;
means country;
run;
quit;

proc glm data=work.earthquakes5 plots=diagnostics;
class direction;
model xm=direction;
means direction;
run;
quit;


*Includes Levene's test for equal variance;
proc glm data=STAT1.ameshousing3 plots=DIAGNOSTICS;
	class Heating_QC;
	model SalePrice=Heating_QC;
	means Heating_QC;
run;
quit;


proc glm data=work.earthquakes5;
class country;
model xm=country;
output out=work.test predicted = predict cookd = cook;
run;
quit;

ods graphics on;
proc glm data=work.earthquakes5 plots=diagnostics;
class country;
model xm=country;
means country / hovtest=levene;
run;
quit;
ods graphics off;


*Trying again;
ods graphics;
proc glm data=work.earthquakes5 plots=diagnostics;
	class country;
	model xm=country;
	means country / hovtest=levene;
run;
quit;

ods graphics;
proc glm data=work.earthquakes5 PLOTS(UNPACK)=DIAGNOSTICS;
	class country;
	model richter=country;
	means country / hovtest=levene;
run;
quit;

proc glm data=work.earthquakes5 PLOTS(maxpoints=none)=diagnostics;
	class country;
	model mw=country;
	means country / hovtest=levene;
run;
quit;

proc glm data=work.earthquakes5 PLOTS(maxpoints=none)=diagnostics;
	class country;
	model mw=country;
	title "Welch's variance-weighted one-way ANOVA with Country as Explanatory";
	means country / welch;
run;
quit;


proc glm data=work.earthquakes5 plots(only)=(diffplot(center));
	class country;
	model mw=country;
	title "One-Way ANOVA with Country as Explanatory";
lsmeans country / pdiff=all adjust = tukey;
run;
quit;



proc glmselect data=work.earthquakes5;
class country direction;
model richter=country direction lat long dist depth md mw ms mb /selection = backward select=AIC showpvalues;
run;

proc glmselect data=work.earthquakes5;
class country direction;
model richter=country direction lat long dist depth md mw ms mb /selection = backward select=AIC showpvalues;
run;

/*
• the errors are independent (check study design).
• the errors are Normally distributed.
• the errors have mean zero.
• the errors have constant variance.
• there is a linear relationship between the expected value of the response and the explanatory variables (linearity
with respect to the parameters).
*/

proc glm data=work.earthquakes5 plots(only)=diagnostic;
class country direction;
model richter=country direction lat long dist depth md mw ms mb/solution clparm;
run;
quit;

data richter;
   set work.earthquakes5;
   where richter ne .;
   drop id xm;
run;

proc means data = work.richter;
run;

*Imputing values;

/* Mean imputation: Use PROC STDIZE to replace missing values with mean */
proc stdize data=work.earthquakes5 out=richter_impute 
      oprefix=Orig_         /* prefix for original variables */
      reponly               /* only replace; do not standardize */
      method=MEDIAN;          /* or MEDIAN, MINIMUM, MIDRANGE, etc. */
   var Height;              /* you can list multiple variables to impute */
run;

proc sql;
title 'How many values are populated for candidate variables?';
select count(lat) as lat_populated
,count(long) as long_populated
,count(dist) as dist_populated
,count(depth) as depth_populated
,count(md) as md_populated
,count(mw) as mw_populated
,count(ms) as ms_populated
,count(mb) as mb_populated
,count(country) as country_populated
,count(direction) as direction_populated
from work.richter;
quit;

proc glm data=work.richter plots(maxpoints=none)=diagnostic;
class country;
model richter = country lat long depth /solution clparm;
run;
quit;

proc reg data=work.richter;
model SalePrice=Lot_Area/clb;
run;
quit;

*Partitioning data;

data serious;
   set work.earthquakes5;
   where richter ne . and depth ne .;
   if richter >= 5 then serious=1; 
	else serious = 0; 
   keep lat long depth country serious xm;
run;

proc sort data=work.serious out=work.serious_sort;
by serious;
run;

proc surveyselect noprint data=work.serious_sort samprate=.7
outall out=work.serious_sampling;
strata serious;
run;

data work.train(drop=selected SelectionProb SamplingWeight)
work.test(drop=selected SelectionProb SamplingWeight);
set work.serious_sampling;
if selected then output work.train;
else output work.test;
run;

*Training a logistic model;
proc logistic data=work.train plots(only)=(effect oddsratio);
class country;
model serious(event='1')=lat long depth country/ clodds=pl;
run;

proc glmselect data=STAT1.ameshousing3;
class Lot_Shape_2;
model SalePrice=Age_Sold Lot_Shape_2/selection = forward select=AIC showpvalues;
run;

proc logistic data=work.train plots(only)=(effect oddsratio);
	class country;
	model serious(event='1')=lat long depth country/selection = backward;
run;

*Potentially grouping variables;
proc means data=work.train noprint nway;
	class country;
	var serious;
	output out=seriousgroup mean=prop;
run;

ods output clusterhistory=work.serious_cluster;

proc cluster data=seriousgroup method=ward plots=(dendrogram(vertical height=rsq));
	freq _freq_;
	var prop;
	id country;
run;

*xm model;
proc logistic data=work.train plots(only)=(effect oddsratio);
model serious(event='1')=xm/ clodds=pl;
run;

*ROC curve;
proc logistic data=work.train;
class country;
model serious(event='1')=lat depth country;
score data=work.test
out=work.testAssess
outroc=work.roc;
run;


proc logistic data=work.train;
class country;
model serious(event='1')=lat depth country;
score data=work.test out=testAssess(rename=(p_1=p_selected_model))
outroc=work.roc;
run;

proc logistic data=work.train;
model serious(event='1')=xm;
score data=work.testAssess out=testAssess(rename=(p_1=p_xm_model))
outroc=work.roc;
run;

proc logistic data=work.testAssess;
model serious(event='1')=p_selected_model p_xm_model/nofit;
roc "Selected Model" p_selected_model;
roc "XM Model" p_xm_model;
roccontrast "Comparing Models";
run;
