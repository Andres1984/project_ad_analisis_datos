** PROJECT: FINANCIAL ECONOMETRICS
** PROGRAM: seguros.do
** PROGRAM TASK: ARIMA
** AUTHOR: RODRIGO TABORDA
** AUTHOR: DANIELA CLAVIJO
** DATE CREATED: 14/11/2018

*********************************************************************;
*** #0 *** PROGRAM SETUP
*********************************************************************;

    pause on
    #delimit ;
    /*COMMAND LINES WILL ONLY END ONCE SEMICOLON IS FOUND*/;

*********************************************************************;
*** #1 *** IMPORT DATA;
*********************************************************************;

	import delimited
	http://rodrigotaborda.com/ad/data/seguros/seguros.csv
    ,
	delimiter(",")
    clear
	;

*********************************************************************;
*** #2 *** ORGANIZE DATA;
********************************************************************;

*** #2.1 *** ORGANIZE DATE VARIABLE;

	gen time= tm(2003m10) +_n - 1;
        /*DATA BEGINS OCTOBER 2003*/;
    format time %tm;

*** #2.2 *** DECLARE TIME SERIES FORMAT;

     tsset time, monthly;
	
*********************************************************************;
*** #3 *** SEGUROS VARIABLE TO NATURAL LOG;
*********************************************************************;
	
    rename seguros_observado seg_obs;
	gen seg_obs_ln = ln(seg_obs);

*********************************************************************;
*** #5 *** DATA AUTOCORRELATION AND PARCIAL AUTOCORRELATION GRAPH
*********************************************************************;

    tsline seg_obs_ln
        ,
        name(seguros, replace)
        ;

	ac seg_obs_ln
        ,
        name(seguros_ac, replace)
        ;
	
	pac seg_obs_ln
        ,
        name(seguros_pac, replace)
        ;

*********************************************************************;
*** #6 *** DICKEY-FULLER TEST
*********************************************************************;

*** #6.1 *** UNIT-ROOT TEST NO TREND - NO LAG;

    dfuller seg_obs_ln, regress ;
	
*** #6.2 *** UNIT-ROOT TEST TREND AND - 1 LAG;

	dfuller seg_obs_ln, trend regress lags(1);
    /*NOTE *** NULL HYPOTHESIS: variable generated by non stationary process*/;

*********************************************************************;
*** #7 *** DIFFERENCED ANALYSIS;
*********************************************************************;

*** #7.1 *** GRAPH;

	tsline d.seg_obs_ln
        ,
        name(seguros_d_pac, replace)
        ;

*** #7.2 *** AUTOCORRELATION AND PARCIAL AUTOCORRELATION GRAPH;

	ac d.seg_obs_ln
        ,
        name(seguros_d_ac, replace)
        ;
	
	pac d.seg_obs_ln
        ,
        name(seguros_d_pac, replace)
        ;
	
*** #7.4 *** UNIT-ROOT TEST NO TREND - NO LAG;

	dfuller d.seg_obs_ln, regress;
	
*********************************************************************;
*** #8 *** ARIMA;
*********************************************************************;

*** #8.1 *** ARIMA(1,1,1) MODEL ;

	arima seg_obs_ln, arima(1,1,1);
	estat ic;

*** #8.1.1 *** ADD 12 MONTHS ;

    tsappend, add(12);

*** #8.1.2 *** PREDICTED VALUES;

	predict seg_obs_ln_arima111, y dynamic(tm(2011m4));

*** #8.1.3 *** GRAPH OF OBSERVED AND PREDICTED VALUES;

	tsline seg_obs_ln seg_obs_ln_arima111
        ,
        name(arima111_ln, replace)
        ;

*** #8.1.4 *** PREDICTED VALUES LEVEL;

	gen seg_obs_arima111 = exp(seg_obs_ln_arima111);

*** #8.1.5 *** GRAPH OF OBSERVED AND PREDICTED VALUES;

	tsline seg_obs seg_obs_arima111
        ,
        name(arima111, replace)
        ;

*********************************************************************;
*** #9 *** ARIMA - SEASONAL;
*********************************************************************;

*** #9.1 *** ARIMA(1,1,1) SARIMA (1,1,0,6) MODEL ;

	arima seg_obs_ln, arima(1,1,1) sarima(1,1,0,6);
    estat ic;

*** #9.1.2 *** PREDICTED VALUES;
		
	predict seg_obs_ln_arima111s1106, y dynamic(tm(2011m4));

*** #9.1.3 *** PREDICTED VALUES LEVEL;

	gen seg_obs_arima111s1106 = exp(seg_obs_ln_arima111s1106);

*** #9.1.4 *** GRAPH OF OBSERVED AND PREDICTED VALUES;

	tsline seg_obs seg_obs_arima111s1106
        ,
        name(arima111s1106, replace)
        ;

*** #9.2 *** COMPARE ARIMA - SEASONAL;

*** #9.2.1 *** NEW VARIABLE DIFFERENCE;

    gen arima111_arima111s1106d = seg_obs_arima111 - seg_obs_arima111s1106
        if
        tin(,2011m4)
        ;

*** #9.2.2 *** GRAPH;

	tsline seg_obs_arima111 seg_obs_arima111s1106
        ,
        name(arima111_arima111s1106, replace)
        nodraw
        ;

	tsline arima111_arima111s1106d
        ,
        name(arima111_arima111s1106d, replace)
        nodraw
        ;

    graph combine
        arima111_arima111s1106
        arima111_arima111s1106d
        ,
        cols(1)
        ;
