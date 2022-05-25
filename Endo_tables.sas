
%macro univ(data=all, var=, classvar=, ndec=1,stat=mean std, order=);
*check distributions;
proc univariate data=&data;
histogram/normal;
var &var follow_up_&var change_in_&var;
run;

*For Table 1;
ods output table=t1_&var.;
proc tabulate data=&data missing;
var &var ;
table &var , (&stat)/nocellmerge;
run;

*For Table 2;
ods output table=t2_&var.;
proc tabulate data=&data missing;
class &classvar;
var &var follow_up_&var. change_in_&var.;
table &var follow_up_&var. change_in_&var., &classvar.*(&stat)/nocellmerge;
run;


%if &stat=median p25 p75 %then %do;
*Table 1;
data t1_&var.;
length clean $20;
set t1_&var.;
order=&order;
clean=strip(put(&var._median,8.&ndec))||" ("||strip(put(&var._p25,8.&ndec))||", "||strip(put(&var._p75, 8.&ndec))||")";
variable="&var";
run;

*Table 2;
data t2_&var.;
length clean clean_fu clean_change $20;
set t2_&var.;
order=&order;
clean=strip(put(&var._median,8.&ndec))||" ("||strip(put(&var._p25,8.&ndec))||", "||strip(put(&var._p75, 8.&ndec))||")";
clean_fu=strip(put(follow_up_&var._median,8.&ndec))||" ("||strip(put(follow_up_&var._p25,8.&ndec))||", "||strip(put(follow_up_&var._p75, 8.&ndec))||")";
clean_change=strip(put(change_in_&var._median,8.&ndec))||" ("||strip(put(change_in_&var._p25,8.&ndec))||", "||strip(put(change_in_&var._p75, 8.&ndec))||")";
variable="&var";
run;

ods output  WilcoxonTest=p_&var;
proc npar1way data=&data wilcoxon;
class &classvar;
var change_in_&var.;
run;
%end;

%else %do;
*Table 1;
data t1_&var.;
length clean $20;
set t1_&var.;
order=&order;
clean=strip(put(&var._mean,8.&ndec))||" ("||strip(put(&var._std, 8.&ndec))||")";
variable="&var";
run;

*Table 2;
data t2_&var.;
length clean clean_fu clean_change $20;
set t2_&var.;
order=&order;
clean=strip(put(&var._mean,8.&ndec))||" ("||strip(put(&var._std, 8.&ndec))||")";
clean_FU=strip(put(follow_up_&var._mean,8.&ndec))||" ("||strip(put(follow_up_&var._std, 8.&ndec))||")";
clean_change=strip(put(change_in_&var._mean,8.&ndec))||" ("||strip(put(change_in_&var._std, 8.&ndec))||")";
variable="&var";
run;

ods output  TTests=p_&var.(where=(variances="Unequal"));
proc ttest data=&data;
class &classvar;
var change_in_&var.;
run;
%end;
%mend;


