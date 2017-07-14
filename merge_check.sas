%let pgm=merge_check;

SAS Forum: Must matching variable attributes be identical when using proc sql to create tables?

the code and message is at
https://www.dropbox.com/s/qkylzvc49hef3hz/merge_check.sas?dl=0

Can I Join two tables on Name and Age?

   WORKING CODE   ( merge keys can be different )
   =============

        %*utl_merge(
              uin1=work
             ,uin2=work
             ,uinmem11=classx
             ,uinmem21=classy
             ,ujoin1  =name age
             ,ujoin2  =name age
             ,uproces =DETAIL
            );

     Utility macros on end


see
https://goo.gl/H2SF9t
https://communities.sas.com/t5/General-SAS-Programming/Must-matching-variable-attributes-be-identical-when-using-proc/m-p/375786


HAVE ( TWO DATASETS)
=====================

WORK.CLASSX  (TRANSACTION)

Up to 40 obs from classx total obs=20

Obs    NEWNAME    AGE    SEX    SEQ

  1    Alfred      14     .       1
  2    Alfred      14     1       1
  3                13     0       2
  4    Barbara     13     0       3

WORK.CLASSY (MASTER)

Up to 40 obs from CLASSY total obs=19

Obs    OLDNAME    AGE    SEX    HEIGHT    WEIGHT    SEQ

  1    Alfred      14     M      69.0      112.5      1
  2    Alfred      14     M      69.0      112.5      1
  3    Alice       13     F      56.5       84.0      2
  4    Barbara     13            65.3       98.0      .
  5    Carol       14     F      62.8      102.5      1

Comparison of attributes

      -------- CLASSX --------   --- CLASSY -----

      Variable    Type    Len     Type    Len

Keys  NAME        Char     32     Char      8  ( different lengths)
      AGE         Num       4     Num       8  (defferent lengths can be an issue for floats)

      SEX         Num       8     Char     10  ( different types  )

      HEIGHT      Num       8
      WEIGHT      Num       8                  (not in classy)

      SEQ         Num       8     Num       8



WANT  Detail analysis
======================

This is complicated

 1. Union - all variable
 2. Master variables
 3. Transation variables (note HEIGHT, WEIGHT and OLDNAME are missing)
 4. Transaction only ( variables with non matching type or length are considered Trans only.
    Note type and length differences
 5. Like 4 but WEIGHT and HEIGHT added because they only exist in Master
 6. Only SEQ has the same type and lenght an is in both datasets


     1            2                3              4                5                6
-----------------------------------------------------------------------------------------------
|           ____MASTER____   ____TRANS_____   __TRAN ONLY___   _MASTER ONLY__   _MASTER TRANS_|
|UNION      NAME     T LEN   NAME     T LEN   NAME     T LEN   NAME     T LEN   NAME     T LEN|
|---------------------------------------------------------------------------------------------|
|AGE     |*|AGE     |n|  8|*|AGE     |n|  4|*|AGE     |n|  4|*|AGE     |n|  8|*|        | |   |
|--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|
|HEIGHT  |*|HEIGHT  |n|  8|*|        | |   |*|        | |   |*|HEIGHT  |n|  8|*|        | |   |
|--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|
|NEWNAME |*|        | |   |*|NEWNAME |c| 32|*|NEWNAME |c| 32|*|        | |   |*|        | |   |
|--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|
|OLDNAME |*|OLDNAME |c|  8|*|        | |   |*|        | |   |*|OLDNAME |c|  8|*|        | |   |
|--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|
|SEQ     |*|SEQ     |n|  8|*|SEQ     |n|  8|*|        | |   |*|        | |   |*|SEQ     |n|  8|
|--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|
|SEX     |*|SEX     |c| 10|*|SEX     |n|  8|*|SEX     |n|  8|*|SEX     |c| 10|*|        | |   |
|--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|
|WEIGHT  |*|WEIGHT  |n|  8|*|        | |   |*|        | |   |*|WEIGHT  |n|  8|*|        | |   |
-----------------------------------------------------------------------------------------------

LOG MESSAGES

/===================================================
!
! --------------------------------------------------
! CORRESPONDING KEY VARIABLES HAVE DIFFERENT LENGTHS
! --------------------------------------------------
!
!
! THE LENGTH OF newname AND oldname ARE NOT EQUAL
!
!  Transaction Dataset -- DATABASE work
!
!    VARIABLE LABEL -> Transact name
!    TABLE classx VARIABLE  newname LENGTH 32 TYPE C
!
!  Master Dataset -- DATABASE work
!
!    VARIABLE LABEL -> Master name
!    TABLE classy VARIABLE  oldname LENGTH 8  TYPE C
!
!
\===================================================

/===================================================
!
! --------------------------------------------------
! CORRESPONDING KEY VARIABLES HAVE DIFFERENT LENGTHS
! --------------------------------------------------
!
!
! THE LENGTH OF age AND age ARE NOT EQUAL
!
!  Transaction Dataset -- DATABASE work
!
!    VARIABLE LABEL -> Transact Age
!    TABLE classx VARIABLE  age LENGTH 4 TYPE N
!
!  Master Dataset -- DATABASE work
!
!    VARIABLE LABEL -> Master Age
!    TABLE classy VARIABLE  age LENGTH 8  TYPE N
!
!
\===================================================

/=================================================
!
! ---------------------------------------
! VARIABLE LENGTH INCONSISTENT
!
! VARIABLE AGE  HAS LENGTH 8  ON classx
! AND LENGTH 4  ON classy
! ---------------------------------------
!
\=================================================

/=================================================
!
! ---------------------------------------
! VARIABLE TYPE INCONSISTENT
!
! VARIABLE SEX  IS char  ON classx
! AND num  ON classy
! ---------------------------------------
!
\=================================================

/=================================================
!
! ---------------------------------------
! VARIABLE LENGTH INCONSISTENT
!
! VARIABLE SEX  HAS LENGTH 10  ON classx
! AND LENGTH 8  ON classy
! ---------------------------------------
!
\=================================================

/=====================================================
!
! ----------------------------------------------------
! MANY TO MANY MERGE MAY NOT BE SUITABLE FOR SAS MERGE
! CONSIDER PROC SQL CARTESIAN PRODUCT
!
! TRANSACTION AND MASTER DATASET HAVE DUPLICATE KEYS
! ----------------------------------------------------
!
\=====================================================

/==============================================================
!
!   TABLE classx  -- Transaction Dataset  (MASTER)
!---------------------------------------------------------------
!
!   NUMERIC VARIABLE SEX  HAS 1 NULL/MISSING VALUES
!
!
!---------------------------------------------------------------
!
!   CHARACTER VARIABLE NEWNAME  HAS 1 NULL/MISSING VALUES
!
!   THIS VARIABLE IS  PART OF A PRIMARY KEY
!   CONSIDER RECODING TO A NON NULL VALUE
!
!
\==============================================================

/==============================================================
!
! TABLE classy -- Master Dataset TRANSACTION
!---------------------------------------------------------------
!
!   NUMERIC VARIABLE SEQ  HAS 1 NULL/MISSING VALUES
!   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER
!   CONSIDER MODIFY WITH NO MISSING UPATE OPTION
!
!   THIS VARIABLE IS IN BOTH TABLES AND THE
!   TRANSACTION COPY WILL OVERWRITE THE MASTER COPY
!
!-----------------------------------------------------------------
!
!   CHARACTER VARIABLE SEX  HAS 1 NULL/MISSING VALUES
!   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER
!   CONSIDER MODIFY WITH NO MISSING UPATE OPTION
!
!
!
\=================================================================


*  _           _     _
  (_)_   _ ___| |_  (_)_ __     ___ __ _ ___  ___
  | | | | / __| __| | | '_ \   / __/ _` / __|/ _ \
  | | |_| \__ \ |_  | | | | | | (_| (_| \__ \  __/
 _/ |\__,_|___/\__| |_|_| |_|  \___\__,_|___/\___|
|__/
;


%utlnopts;
%*utlopts; *(for debugging only );

* only needed if you rerun;
proc datasets lib=work kill;
run;quit;

* only needed if you have submitted section of macro in global environmen
  or some of these are already global (note the all begin with U;

%symdel U1BY UVARNM12 UVARLN22 UFDUP2 UOBS1 UVARNM11
UVARLN21 UVARLB12 UOBTRAN UOBS2 UVARS2 UVARLB11 UINMEM21
U2BY1 UNUMS U2BY3 UVARTP22 U2BY2 UBIX UVARTP21 UCHRS U1BY1
UVARLN12 U1BY3 UOBMSTR UPROCES U1BY2 UVARLN11 UFDUP1 UOT1
UVARNM22 UBI UINBOTH UQJ1 UVARS1 UVARNM21 UPOS UJ UVARTP12
UVARLB22 UOTMEM11 ULBL1 UVARTP11 UVARLB21 UINMEM11 U2BY

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data classx (drop=height weight
           rename=name=newname label="Transaction Dataset");
 label
    name =  "Transact name"
    age  =  "Transact Age"
    sex  =  "Transact Gender"
 ;
 retain name sex age;
 length name $32 age 4 ;
 set sashelp.class(rename=sex=chrsex);;
 seq+1;
 if _n_=1 then output;
 if _n_=2 then name='';
 sex=(chrsex='M');
 drop chrsex;
 output;
run;

data classy(label="Master Dataset"
        rename=name=oldname);
 label
    name    =  "Master name"
    age     =  "Master Age"
    sex     =  "Master Gender"
    height  =  "Master Height"
    weight  =  "Master Weight"
 ;
 retain name sex age;
 length sex $10;
 set sashelp.class;
 seq+1;
 if _n_=1 then output;
 if _n_=3 then do;sex='';seq=.;end;
 if _n_ ne 18;
 output;
run;

%utl_merge(
          uin1=work
         ,uin2=work
         ,uinmem11=classx
         ,uinmem21=classy
         ,ujoin1  =newname age
         ,ujoin2  =oldname age
         ,uproces =DETAIL
        );
*/

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%MACRO UTL_MERGE
     (
      UIN1=work,
      UIN2=work,
      uproces =DETAIL,
      UINMEM11=MASTER,       /* RREQUIRES UTL_MARY/UTL_NOPTS/UTL_OPTS */
      UINMEM21=TRANSACT,     /* TABLE ON THE RIGHT */
      UJOIN1  =SSN TAXID,      /* JOIN KEY  FIRST TABLE */
      UJOIN2  =SSN_TAXID       /* JOIN KEY  SECOND TABLE TRANSACTION TABLE */
                             /* DO NOT HAVE TO BE THE SAME VARIABLES  */
                             /* DO HAVE TO BE ONE TO ONE              */
      )
      / DES = "DIAGNOSTIC CHECKUP TWO TABLE JOIN";

 %put %sysfunc(ifc(%sysevalf(%superq(UINMEM11)=,boolean),  **** Need a Master dataset ************,));
 %put %sysfunc(ifc(%sysevalf(%superq(UINMEM21)=,boolean),  **** Need a transation datasets *******,));
 %put %sysfunc(ifc(%sysevalf(%superq(UJOIN1)=,boolean), **** Need join key for master *********,));
 %put %sysfunc(ifc(%sysevalf(%superq(UJOIN2)=,boolean), **** Need join key for master *********,));

 %if %eval(
    %sysfunc(ifc(%sysevalf(%superq(UINMEM11)=,boolean),1,0)) +
    %sysfunc(ifc(%sysevalf(%superq(UINMEM21)=,boolean),1,0)) +
    %sysfunc(ifc(%sysevalf(%superq(UJOIN1)=,boolean),1,0)) +
    %sysfunc(ifc(%sysevalf(%superq(UJOIN2)=,boolean),1,0))
    ) eq 0 %then %do;

      %let uprocess=QUICK;

        /*----------------------------------------------*\
        |  BETA CODE LOOK FOR UPDATES                    |
        |  Code by Roger DeAngelis                       |
        \*----------------------------------------------*/

    %goto utlmrck0;

    =====================================================
    INPUTS                                              !
    =====================================================
      MASTER TABLE -- LEFT TABLE IN DATASTEP MERGE
      UIN1  -- UINMEM11

      TRANSACTION TABLE -- RIGHT TABLE IN DATASTEP MERGE
      UIN2  -- UINMEM21

      JOIN VARS FOR MASTER
      JOIN VARS FOR TRANSACTION

    =====================================================
    PROCESS                                             !
    =====================================================

    SUPPOSE YOU WANT TO JOIN TWO TABLES

    OPTION QUICK -- ANALYZE THE MERGE WITHOUT READING THE DATA
                    ANALYSIS USING ONLY METADATA

    OPTION DETAIL-- EXAMINE MISSING VALUES AND OVERWRITE ORDER

    MASTER TABLE
    ============================================================
    OBS    SSN     TAXID    SEQ    DUM1    DUM2    DUM3    DUM

      1                       1      1               3      .
      2       2    0002       2      1               3      .
      3       2    0002       3      1               3      .
      4       4    0004       4      1               3      .
      5       5    0005       5      1               3      .
      6       6    0006       6      1               3      .
      7       7    0007       7      1               3      .
      8       8    0008       8      1               3      .
      9       9    0009       9      1               3      .
     10      10    0010      10      1               3      .
     11      10    0010      10      1               3      .


    TRANSACTION TABLE
    ===================================================================
    OBS    SOC_NUM      TAXID      SEQ1    DUM    DUM1    DUM2    DUM3

      1    00000001    00000001      1      .       .               .
      2    00000002    00000002      2      .       .               .
      3    00000002    00000002      3      .       .               .
      4    00000004    00000004      4      .       .               .
      5    00000005    00000005      5      .       .               .
      6    00000006    00000006      6      .       .               .
      7    00000007    00000007      7      .       .               .
      8    00000008    00000008      8      .       .               .
      9    00000009    00000009      9      .       .               .
     10    00000010    00000010     10      .       .               .
     11    00000010    00000010     10      .       .               .

    Using either proc sql or datastep merge

    ie   data update;
              merge
                     master ( in=master )
                     transact(in=transact rename=soc_num=ssn);
              by ssn taxid;
          run;
    ================================================================
    OUTPUT   SASLOG
    ================================================================
    All output appears in the log
    other data used for demonstration of all options

    /===================================================
    ! --------------------------------------------------
    ! CORRESPONDING KEY VARIABLES HAVE DIFFERENT LENGTHS
    ! --------------------------------------------------
    !
    ! THE LENGTH OF SSN AND SOC_NUM ARE NOT EQUAL
    !
    !  MASTER TABLE AJAX COMPANY -- DATABASE e:\obj\#TD78061
    !
    !    VARIABLE LABEL -> MASTER SOCIAL SECURITY NUMBER
    !    TABLE MASTER VARIABLE  SSN LENGTH 4 TYPE C
    !                           -------------------
    !
    !  TRANSACTION TABLE AJAX COMPANY -- DATABASE e:\obj\#TD78061
    !
    !    VARIABLE LABEL -> TRANSACTION SOCIAL SECURITY NUMBER
    !    TABLE TRANSACT VARIABLE  SOC_NUM LENGTH 8  TYPE C
    !                             ------------------------
    \===================================================

    /===================================================
    ! --------------------------------------------------
    ! CORRESPONDING KEY VARIABLES HAVE DIFFERENT LENGTHS
    ! --------------------------------------------------
    !
    ! THE LENGTH OF TAXID AND TAXID ARE NOT EQUAL
    !
    !  MASTER TABLE AJAX COMPANY -- DATABASE e:\obj\#TD78061
    !
    !    VARIABLE LABEL -> MASTER TAX IDENTIFICATION NUMBER
    !    TABLE MASTER VARIABLE  TAXID LENGTH 4 TYPE C
    !                           ---------------------
    !
    !  TRANSACTION TABLE AJAX COMPANY -- DATABASE e:\obj\#TD78061
    !
    !    VARIABLE LABEL -> TRANSACTION TAX IDENTIFICATION NUMBER
    !    TABLE TRANSACT VARIABLE  TAXID LENGTH 8  TYPE C
    !                             ----------------------
    \===================================================


       EVEN THOUGH TAXID IS IN MASTER AND TRANSACTION DATASET,THE  LAST
       SET OF COLUMNS '_MASTER TRANS_'(INTERSECTION) DOES NOT SHOW TAXID. THIS IS DUE
       TO INCORRECT TYPING AND/OR LENGTHS.

       UNION                                                                           INTERSECTIOM
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?           ____MASTER____   ____TRANS_____   __TRAN ONLY___   _MASTER ONLY__   _MASTER TRANS_?
      ?UNION      NAME     T LEN   NAME     T LEN   NAME     T LEN   NAME     T LEN   NAME     T LEN?
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?DUM     ???DUM     ?n?  8???DUM     ?n?  8???        ? ?   ???        ? ?   ???DUM     ?n?  8?
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?DUM1    ???DUM1    ?n?  8???DUM1    ?n?  8???        ? ?   ???        ? ?   ???DUM1    ?n?  8?
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?DUM2    ???DUM2    ?c?  3???DUM2    ?c?  3???        ? ?   ???        ? ?   ???DUM2    ?c?  3?
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?DUM3    ???DUM3    ?n?  8???DUM3    ?n?  8???        ? ?   ???        ? ?   ???DUM3    ?n?  8?
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?SEQ     ???        ? ?   ???SEQ     ?n?  8???SEQ     ?n?  8???        ? ?   ???        ? ?   ?
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?SEQ1    ???SEQ1    ?n?  8???        ? ?   ???        ? ?   ???SEQ1    ?n?  8???        ? ?   ?
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?SOC_NUM ???SOC_NUM ?c?  8???        ? ?   ???        ? ?   ???SOC_NUM ?c?  8???        ? ?   ?
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?SSN     ???        ? ?   ???SSN     ?c?  4???SSN     ?c?  4???        ? ?   ???        ? ?   ?
      ???????????????????????????????????????????????????????????????????????????????????????????????
      ?TAXID   ???TAXID   ?c?  8???TAXID   ?c?  4???TAXID   ?c?  4???TAXID   ?c?  8???        ? ?   ?
      ???????????????????????????????????????????????????????????????????????????????????????????????

    SOMEWHAT REDUNDANT

    /=================================================
    ! ---------------------------------------
    ! VARIABLE LENGTH INCONSISTENT
    !
    ! VARIABLE TAXID  HAS LENGTH 8  ON MASTER
    ! AND LENGTH 4  ON TRANSACT
    ! ---------------------------------------
    \=================================================

     SAS MERGE CANNOT merge two datasets with multiple
     occurrances of join variables in each table.
     SQL cartesion product is often a better choice
     or see SUGI 15 page 910

    /=====================================================
    ! ----------------------------------------------------
    ! MANY TO MANY MERGE MAY NOT BE SUITABLE FOR SAS MERGE
    ! CONSIDER PROC SQL CARTESIAN PRODUCT
    !
    ! TRANSACTION AND MASTER DATASET HAVE DUPLICATE KEYS
    ! ----------------------------------------------------


     It is not a good practice to have nulls in a primary key
     or common transacion variables.

     Also dangerous to allow many overwrites.

    /==============================================================
    !
    !   TABLE MASTER  -- MASTER TABLE AJAX COMPANY  (MASTER)
    !---------------------------------------------------------------
    !   NUMERIC VARIABLE DUM  HAS 10 NULL/MISSING VALUES
    !---------------------------------------------------------------
    !   CHARACTER VARIABLE SSN  HAS 1 NULL/MISSING VALUES
    !
    !   THIS VARIABLE IS  PART OF A PRIMARY KEY
    !   CONSIDER RECODING TO A NON NULL VALUE
    !---------------------------------------------------------------
    !   CHARACTER VARIABLE TAXID  HAS 1 NULL/MISSING VALUES
    !
    !   THIS VARIABLE IS  PART OF A PRIMARY KEY
    !   CONSIDER RECODING TO A NON NULL VALUE
    !---------------------------------------------------------------
    !   CHARACTER VARIABLE DUM2  HAS 10 NULL/MISSING VALUES
    !
    \==============================================================

    /==============================================================
    !
    ! TABLE TRANSACT -- TRANSACTION TABLE AJAX COMPANY TRANSACTION
    !---------------------------------------------------------------
    !   NUMERIC VARIABLE DUM  HAS 10 NULL/MISSING VALUES
    !   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER
    !   CONSIDER MODIFY WITH NO MISSING UPATE OPTION
    !
    !   THIS VARIABLE IS IN BOTH TABLES AND THE
    !   TRANSACTION COPY WILL OVERWRITE THE MASTER COPY
    !---------------------------------------------------------------
    !   NUMERIC VARIABLE DUM1  HAS 10 NULL/MISSING VALUES
    !   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER
    !   CONSIDER MODIFY WITH NO MISSING UPATE OPTION
    !
    !   THIS VARIABLE IS IN BOTH TABLES AND THE
    !   TRANSACTION COPY WILL OVERWRITE THE MASTER COPY
    !---------------------------------------------------------------
    !   NUMERIC VARIABLE DUM3  HAS 10 NULL/MISSING VALUES
    !   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER
    !   CONSIDER MODIFY WITH NO MISSING UPATE OPTION
    !
    !   THIS VARIABLE IS IN BOTH TABLES AND THE
    !   TRANSACTION COPY WILL OVERWRITE THE MASTER COPY
    !-----------------------------------------------------------------
    !   CHARACTER VARIABLE DUM2  HAS 10 NULL/MISSING VALUES
    !   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER
    !   CONSIDER MODIFY WITH NO MISSING UPATE OPTION
    !
    !   THIS VARIABLE IS IN BOTH TABLES AND THE
    !   TRANSACTION COPY WILL OVERWRITE THE MASTER COPY
    \=================================================================

     %utlmrck0:
      /*  for checking without  macro
        %let uinmem11=classx;
        %let uinmem21=classy;
        %let ujoin1  =name sex;
        %let ujoin2  =name sex;
        %let uotmem11=jyn;
        %let uin1=work;
        %let uin2=work;
      */

        %local

              U1BY
              UVARNM12
              UVARLN22
              UFDUP2
              UOBS1
              UVARNM11
              UVARLN21
              UVARLB12
              UOBTRAN
              UOBS2
              UVARS2
              UVARLB11
              UINMEM21
              U2BY1
              UNUMS
              U2BY3
              UVARTP22
              U2BY2
              UBIX
              UVARTP21
              UCHRS
              U1BY1
              UVARLN12
              U1BY3
              UOBMSTR
              UPROCES
              U1BY2
              UVARLN11
              UFDUP1
              UOT1
              UVARNM22
              UBI
              UINBOTH
              UQJ1
              UVARS1
              UVARNM21
              UPOS
              UJ
              UVARTP12
              UVARLB22
              UOTMEM11
              ULBL1
              UVARTP11
              UVARLB21
              UINMEM11
              U2BY
              UDSID
              ULBL2
              UI ;
        /*-------------------------------------*\
        | BUILD VECTOR WITH NUMBER OF KEYS AND  |
        | KEY NAMES                             |
        | FOR EACH TABLE                        |
        \*-------------------------------------*/

        %UTL_MARY(UROOT=U1BY,USTR=&UJOIN1);  /* ENCLOSED EXAMPLE U1BY=2 U1BY1=SSN U1BAY2=TAXID */
        RUN;

        run;quit;
        %UTL_MARY(UROOT=U2BY,USTR=&UJOIN2);  /* ENCLOSED EXAMPLE U1BY=2 U1BY1=SOC_NUM U1BAY2=TAXID */
        RUN;


        /*-------------------------------------*\
        | NOT SURE IF THIS IS BETTER THAN       |
        | PROC SQL, HOWEVER IT SEEMS A LITTLE   |
        | MORE DIRECT AND UPGRADABLE            |
        | LOAD MACRO VARS WITH METADATA         |
        \*-------------------------------------*/

        %DO UJ = 1 %TO 2;    /* ONCE FOR EACH TABLE */

            /*
                 %utlnopts;
                 %let uj=1;
                 %put &&UINMEM&UJ.1;
                 %LET UDSID    = %SYSFUNC( OPEN (&&UINMEM&UJ.1, I ) );
                 %put &udsid;
                 %put &&UIN&UJ;
                 %put &&UIN&UJ...&&UINMEM&UJ.1;
            */

            %LET UDSID    = %SYSFUNC( OPEN (&&UIN&UJ...&&UINMEM&UJ.1, I ) );
            %LET UOBS&UJ  = %SYSFUNC(ATTRN(&UDSID,NLOBS));   /* NON DELETED OBS */
            %LET UVARS&UJ = %SYSFUNC(ATTRN(&UDSID,NVARS));   /* NUMBER OF  ARS */
            %LET ULBL&UJ  = %SYSFUNC(ATTRC(&UDSID,LABEL));   /* DATASET LABEL  */
            %LET UBI      = &&U&UJ.BY; /* NUMBER OF KEYS */
            %DO UI = 1 %TO &UBI;   /* ONCE FOR EACH JOIN VARIABLE FIRST TABLE */
                /*
                     %let ubi=2;
                     %let ui=1;
                */
                %LET UBIX = &&U&UJ.BY&UI;  /* WAS EASIER TO DEBUG THIS WAY */
                %LET UPOS = %SYSFUNC ( VARNUM ( &UDSID, &UBIX ) );
                %LET UVARNM&UJ.&UI = %SYSFUNC ( VARNAME  ( &UDSID, &UPOS  ) );
                %LET UVARTP&UJ.&UI = %SYSFUNC ( VARTYPE  ( &UDSID, &UPOS  ) );
                %LET UVARLB&UJ.&UI = %SYSFUNC ( VARLABEL ( &UDSID, &UPOS  ) );
                %LET UVARLN&UJ.&UI = %SYSFUNC ( VARLEN   ( &UDSID, &UPOS  ) );
            %END;

            /*

              %put
                 &&UOBS&UJ
                 &&UVARS&UJ
                 &&ULBL&UJ
                 &=UBI
                 &=upos
                 &&UVARNM&UJ.1
                 &&UVARNM&UJ.2
              ;
            */

            %let  rc=%sysfunc(close(&udsid));

        %END;* JOIN TABLES;    /* ONCE FOR EACH TABLE */



       /*-------------------------------------*\
       | REPORT ON WHAT YOU FOUND              |
       \*-------------------------------------*/
       %IF %QUOTE(&UOBS1) EQ 0 OR   %QUOTE(&UOBS2) EQ 0 %THEN %DO;
          %PUT ;
          %PUT ;
          %PUT /=================================================;
          %PUT !                                                  ;
          %PUT ! -------------------------------------            ;
          %PUT ! NO OBSERVATIONS IN ONE OR BOTH TABLES            ;
          %PUT ! -------------------------------------            ;
          %PUT !                                                  ;
          %PUT !                                                  ;
          %PUT !    &ULBL1 -- DATABASE &UIN1                                       ;
          %PUT !    TABLE &UINMEM11 HAS &UOBS1                    ;
          %PUT !                                                  ;
          %PUT !    &ULBL2 -- DATABASE &UIN2                                       ;
          %PUT !    TABLE &UINMEM21 HAS &UOBS2                    ;
          %PUT !                                                  ;
          %PUT !                                                  ;
          %PUT \=================================================;
          %PUT ;
          %PUT ;
       %END;
       %IF %QUOTE(&U2BY) NE %QUOTE(&U1BY) %THEN %DO;
          %PUT ;
          %PUT ;
          %PUT /=================================================;
          %PUT !                                                  ;
          %PUT ! ---------------------------------------          ;
          %PUT ! DIFFERENT NUMBER OF KEYS FOR EACH TABLE          ;
          %PUT ! ---------------------------------------          ;
          %PUT !                                                  ;
          %PUT !                                                  ;
          %PUT !    &ULBL1 -- DATABASE &UIN1                                       ;
          %PUT !    TABLE &UINMEM11 HAS KEYS &UJOIN1              ;
          %PUT !                                                  ;
          %PUT !    &ULBL2 -- DATABASE &UIN2                                       ;
          %PUT !    TABLE &UINMEM21 HAS KEYS &UJOIN2              ;
          %PUT !                                                  ;
          %PUT !                                                  ;
          %PUT \=================================================;
          %PUT ;
          %PUT ;
       %END;
       %ELSE %DO;
           %DO UI = 1 %TO &U1BY;
               %IF %QUOTE(&&UVARLN1&UI) NE %QUOTE(&&UVARLN2&UI) %THEN %DO;
                  %PUT ;
                  %PUT ;
                  %PUT /===================================================            ;
                  %PUT !                                                                ;
                  %PUT ! --------------------------------------------------             ;
                  %PUT ! CORRESPONDING KEY VARIABLES HAVE DIFFERENT LENGTHS             ;
                  %PUT ! --------------------------------------------------             ;
                  %PUT !                                                                ;
                  %PUT !                                                                ;
                  %PUT ! THE LENGTH OF &&U1BY&UI AND &&U2BY&UI ARE NOT EQUAL            ;
                  %PUT !                                                                ;
                  %PUT !  &ULBL1 -- DATABASE &UIN1              ;
                  %PUT !                                                                ;
                  %PUT !    VARIABLE LABEL -> &&UVARLB1&UI                                 ;
                  %PUT !    TABLE &UINMEM11 VARIABLE  &&U1BY&UI LENGTH &&UVARLN1&UI TYPE &&UVARTP1&UI ;
                  %PUT !                                                                ;
                  %PUT !  &ULBL2 -- DATABASE &UIN2              ;
                  %PUT !                                                                ;
                  %PUT !    VARIABLE LABEL -> &&UVARLB2&UI                                 ;
                  %PUT !    TABLE &UINMEM21 VARIABLE  &&U2BY&UI LENGTH &&UVARLN2&UI  TYPE &&UVARTP2&UI ;
                  %PUT !                                                                ;
                  %PUT !                                                                ;
                  %PUT \===================================================            ;
                  %PUT ;
                  %PUT ;
               %END;
               %IF %QUOTE(&&UVARTP1&UI) NE %QUOTE(&&UVARTP2&UI) %THEN %DO;
                  %PUT ;
                  %PUT ;
                  %PUT /=================================================              ;
                  %PUT !                                                                ;
                  %PUT ! --------------------------------------------------------       ;
                  %PUT ! VARIABLES  &&U1BY&UI AND &&U2BY&UI ARE NOT THE SAME TYPE       ;
                  %PUT ! --------------------------------------------------------       ;
                  %PUT !                                                                ;
                  %PUT !                                                                ;
                  %PUT !  &ULBL1 -- DATABASE &UIN1              ;
                  %PUT !                                                                ;
                  %PUT !    VARIABLE LABEL -> &&UVARLB1&UI                              ;
                  %PUT !    TABLE &UINMEM11 VARIABLE  &&U1BY&UI LENGTH &&UVARLN1&UI TYPE &&UVARTP1&UI ;
                  %PUT !                                                                ;
                  %PUT !  &ULBL2 -- DATABASE &UIN2              ;
                  %PUT !                                                                ;
                  %PUT !    VARIABLE LABEL -> &&UVARLB2&UI                                 ;
                  %PUT !    TABLE &UINMEM21 VARIABLE  &&U2BY&UI LENGTH &&UVARLN2&UI  TYPE &&UVARTP2&UI ;
                  %PUT !                                                                ;
                  %PUT \=================================================              ;
                  %PUT ;
                  %PUT ;
               %END;
           %END;
       %END;


      /*-------------------------------------*\
      | Lets look at the rest of the columns  |
      \*-------------------------------------*/

          PROC SQL
                    NOPRINT;


              /*-------------------------------------*\
              |                                       |
              | COLUMNS in TRANSACTION TABLE ONLY     |
              |                                       |
              \*-------------------------------------*/


               CREATE
                        TABLE UTLMRCK1 AS   /* NAMES IN TRANS  ONLY */

               SELECT
                        NAME AS TRANONLY,  /* NAMES ON TRANS  */
                        TYPE AS TRANOTYP,
                        LENGTH AS TRANOLEN

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN1")       AND
                        MEMNAME = %UPCASE("&UINMEM11")  AND
                        MEMTYPE = %UPCASE("DATA")


               EXCEPT ALL

               SELECT
                        NAME,              /* NAMES IN TRANSACTION */
                        TYPE,
                        LENGTH

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN2")       AND
                        MEMNAME = %UPCASE("&UINMEM21")  AND
                        MEMTYPE = %UPCASE("DATA")
           ;

              /*-------------------------------------*\
              | COLUMNS in MASTER      TABLE ONLY     |
              \*-------------------------------------*/


               CREATE
                        TABLE UTLMRCK2 AS   /* NAMES IN MASTER      ONLY */

               SELECT
                        NAME AS MSTRONLY,
                        TYPE AS MSTROTYP,
                        LENGTH AS MSTROLEN

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN2")       AND
                        MEMNAME = %UPCASE("&UINMEM21")  AND
                        MEMTYPE = %UPCASE("DATA")


               EXCEPT ALL

               SELECT
                        NAME,
                        type,
                        length

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN1")       AND
                        MEMNAME = %UPCASE("&UINMEM11")  AND
                        MEMTYPE = %UPCASE("DATA")
           ;


              /*-------------------------------------*\
              | COLUMNS in MASTER AND TRANSACTION     |
              \*-------------------------------------*/


               CREATE
                        TABLE UTLMRCK3 AS   /* NAMES IN BOTH TABLES */

               SELECT
                        NAME  AS MSTRTRAN,
                        TYPE AS MSTRTTYP,
                        LENGTH AS MSTRTLEN

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN1")       AND
                        MEMNAME = %UPCASE("&UINMEM11")  AND
                        MEMTYPE = %UPCASE("DATA")


               INTERSECT ALL

               SELECT
                        NAME,
                        type,
                        length

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN2")       AND
                        MEMNAME = %UPCASE("&UINMEM21")  AND
                        MEMTYPE = %UPCASE("DATA")
           ;

              /*-------------------------------------*\
              | COLUMNS in MASTER UNION TRANSACTION   |
              \*-------------------------------------*/

               CREATE
                        TABLE UTLMRCK4 AS   /* ALL NAMES */

               SELECT
                        DISTINCT NAME  AS  ALLNAMES

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN1")       AND
                        MEMNAME = %UPCASE("&UINMEM11")  AND
                        MEMTYPE = %UPCASE("DATA")


               UNION ALL

               SELECT
                        NAME

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN2")       AND
                        MEMNAME = %UPCASE("&UINMEM21")  AND
                        MEMTYPE = %UPCASE("DATA")
           ;

              /*-------------------------------------*\
              | COLUMNS in MASTER                     |
              \*-------------------------------------*/


               CREATE
                        TABLE UTLMRCK6 AS   /* NAMES IN MASTER */

               SELECT
                        NAME AS MSTR,
                        TYPE AS  MSTRTYP,
                        LENGTH AS  MSTRLEN

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN2")       AND
                        MEMNAME = %UPCASE("&UINMEM21")  AND
                        MEMTYPE = %UPCASE("DATA")

           ;


              /*-------------------------------------*\
              | COLUMNS in TRANSACTION                |
              \*-------------------------------------*/

               CREATE
                        TABLE UTLMRCK7 AS   /* NAMES IN TRAN */

               SELECT
                        NAME AS TRAN,
                        TYPE AS  TRANTYP,
                        LENGTH AS  TRANLEN

               FROM
                        SASHELP.VCOLUMN

               WHERE
                        LIBNAME = %UPCASE("&UIN1")       AND
                        MEMNAME = %UPCASE("&UINMEM11")  AND
                        MEMTYPE = %UPCASE("DATA")

           ;

              /*-------------------------------------*\
              | PUT IN ALL TOGETHER FOR REPORT        |
              \*-------------------------------------*/



               CREATE
                        TABLE UTLMRCK5 AS   /* WHERE THE NAMES ARE */


               SELECT
                        DISTINCT
                                  *,
                                  '*' AS SPACER

               FROM
                        UTLMRCK4
                                  FULL JOIN UTLMRCK6 ON ALLNAMES = MSTR
                                  FULL JOIN UTLMRCK7 ON ALLNAMES = TRAN
                                  FULL JOIN UTLMRCK1 ON ALLNAMES = TRANONLY
                                  FULL JOIN UTLMRCK2 ON ALLNAMES = MSTRONLY
                                  FULL JOIN UTLMRCK3 ON ALLNAMES = MSTRTRAN

               ORDER BY
                        ALLNAMES

            ;

                        /* NAMES IN BOTH TABLES */
                        /* INTO MACRO VAR       */

               SELECT
                        MSTRTRAN INTO :UINBOTH SEPARATED BY '","'

               FROM
                        UTLMRCK3

               ;

      QUIT;
      RUN;


      OPTIONS MISSING=' ';

      /*-------------------------------------*\
      | PUT PROC REPORT IN THE LOG            |
      \*-------------------------------------*/

      PROC REPORT
                    DATA=UTLMRCK5
                    NOWD
                    BOX
                    MISSING
      ;

      COLS

          ALLNAMES

          SPACER

          (

            '_MASTER_'

            MSTR
            MSTRTYP
            MSTRLEN
          )

          SPACER = SPACER0

          (
            '_TRANS_'

            TRAN
            TRANTYP
            TRANLEN
          )

          SPACER = SPACER1

          (
            '_TRAN ONLY_'
            TRANONLY
            TRANOTYP
            TRANOLEN
          )

          SPACER = SPACER2

          (
            '_MASTER ONLY_'

            MSTRONLY
            MSTROTYP
            MSTROLEN
          )

          SPACER = SPACER3

          (
            '_MASTER TRANS_'
            MSTRTRAN
            MSTRTTYP
            MSTRTLEN
          )
     ;

     DEFINE ALLNAMES  / DISPLAY  'UNION' WIDTH=8 SPACING=0;
     DEFINE SPACER    / DISPLAY  ' '     WIDTH=1 SPACING=0;
     DEFINE MSTR      / DISPLAY  'NAME'  WIDTH=8 SPACING=0;
     DEFINE MSTRTYP   / DISPLAY  'T'     WIDTH=1 SPACING=0;
     DEFINE MSTRLEN   / DISPLAY  'LEN'   WIDTH=3 SPACING=0;
     DEFINE SPACER0   / DISPLAY  ' '     WIDTH=1 SPACING=0;
     DEFINE TRAN      / DISPLAY  'NAME'  WIDTH=8 SPACING=0;
     DEFINE TRANTYP   / DISPLAY  'T'     WIDTH=1 SPACING=0;
     DEFINE TRANLEN   / DISPLAY  'LEN'   WIDTH=3 SPACING=0;
     DEFINE SPACER1   / DISPLAY  ' '     WIDTH=1 SPACING=0;
     DEFINE TRANONLY  / DISPLAY  'NAME'  WIDTH=8 SPACING=0;
     DEFINE TRANOTYP  / DISPLAY  'T'     WIDTH=1 SPACING=0;
     DEFINE TRANOLEN  / DISPLAY  'LEN'   WIDTH=3 SPACING=0;
     DEFINE SPACER2   / DISPLAY  ' '     WIDTH=1 SPACING=0;
     DEFINE MSTRONLY  / DISPLAY  'NAME'  WIDTH=8 SPACING=0;
     DEFINE MSTROTYP  / DISPLAY  'T'     WIDTH=1 SPACING=0;
     DEFINE MSTROLEN  / DISPLAY  'LEN'   WIDTH=3 SPACING=0;
     DEFINE SPACER3   / DISPLAY  ' '     WIDTH=1 SPACING=0;
     DEFINE MSTRTRAN  / DISPLAY  'NAME'  WIDTH=8 SPACING=0;
     DEFINE MSTRTTYP  / DISPLAY  'T'     WIDTH=1 SPACING=0;
     DEFINE MSTRTLEN  / DISPLAY  'LEN'   WIDTH=3 SPACING=0;

    QUIT;
    RUN;


    /*-------------------------------------*\
    |  REDUNDANT BUT EASY                   |
    \*-------------------------------------*/



    DATA
          _NULL_;

          SET UTLMRCK5;

          IF  MSTR EQ TRAN THEN DO;

              IF MSTRTYP NE TRANTYP THEN

                      PUT
                      /
                      /   '/================================================= '
                      /   '!                                                  '
                      /   '! ---------------------------------------          '
                      /   '! VARIABLE TYPE INCONSISTENT                       '
                      /   '!                                                  '
                      /   '! VARIABLE ' MSTR ' IS ' MSTRTYP " ON &UINMEM11 "
                      /   '! AND ' TRANTYP " ON &UINMEM21"
                      /   '! ---------------------------------------          '
                      /   '!                                                  '
                      /   '\================================================= '
                      // ;

              IF MSTRLEN NE TRANLEN THEN

                      PUT
                      /
                      /   '/================================================= '
                      /   '!                                                  '
                      /   '! ---------------------------------------          '
                      /   '! VARIABLE LENGTH INCONSISTENT                     '
                      /   '!                                                  '
                      /   '! VARIABLE ' MSTR ' HAS LENGTH ' MSTRLEN " ON &UINMEM11 "
                      /   '! AND LENGTH ' TRANLEN " ON &UINMEM21"
                      /   '! ---------------------------------------          '
                      /   '!                                                  '
                      /   '\================================================= '
                      //;


          END;

      RUN;

    OPTIONS MISSING='.';


     /*-------------------------------------*\
     |  DETERMINE IF MANY TO MANY PROBLEM    |
     \*-------------------------------------*/

     /*  %unquote(%substr(%nrquote(&renames),2)) */

     %IF %QUPCASE(&UPROCES) EQ %UPCASE(DETAIL) %THEN %DO;


      %LET UFDUP1 = %SYSFUNC(TRANSLATE(&UJOIN1,',',' '));

      %LET UFDUP2 = %SYSFUNC(TRANSLATE(&UJOIN2,',',' '));


      PROC SQL;

          CREATE
                 TABLE UTLMRCK8 AS

          SELECT
                 COUNT(*) AS DUPS1

          FROM
                 &UIN1..&UINMEM11( KEEP= &UJOIN1 )

          GROUP
                 BY &UFDUP1

          HAVING
                 COUNT(*) > 1

          ;


          CREATE
                 TABLE UTLMRCK9 AS

          SELECT
                 COUNT(*) AS DUPS2

          FROM
                 &UIN2..&UINMEM21( KEEP= &UJOIN2 )

          GROUP
                 BY &UFDUP2

          HAVING
                 COUNT(*) > 1

          ;

       QUIT;

       RUN;


       %LET UOBTRAN = %UTLNOBZ(UIN=WORK,UINMEM=UTLMRCK8);

       %LET UOBMSTR = %UTLNOBZ(UIN=WORK,UINMEM=UTLMRCK9);



       %IF %QUOTE(&UOBTRAN) AND %QUOTE(&UOBMSTR) %THEN %DO;

          %PUT ;
          %PUT ;
          %PUT /=====================================================          ;
          %PUT !                                                                ;
          %PUT ! ----------------------------------------------------           ;
          %PUT ! MANY TO MANY MERGE MAY NOT BE SUITABLE FOR SAS MERGE           ;
          %PUT ! CONSIDER PROC SQL CARTESIAN PRODUCT                            ;
          %PUT !                                                                ;
          %PUT ! TRANSACTION AND MASTER DATASET HAVE DUPLICATE KEYS             ;
          %PUT ! ----------------------------------------------------           ;
          %PUT !                                                                ;
          %PUT \=====================================================          ;
          %PUT ;
          %PUT ;


       %END;


       %ELSE %DO;

           %IF %QUOTE(&UOBTRAN) %THEN %DO;

              %PUT ;
              %PUT ;
              %PUT /=====================================================          ;
              %PUT !                                                                ;
              %PUT ! ----------------------------------------------------           ;
              %PUT ! TRANSACTION DATASET HAS DUPLICATE KEYS                         ;
              %PUT ! ----------------------------------------------------           ;
              %PUT !                                                                ;
              %PUT \=====================================================          ;
              %PUT ;
              %PUT ;

           %END;


           %IF %QUOTE(&UOBTRAN) %THEN %DO;

              %PUT ;
              %PUT ;
              %PUT /=====================================================          ;
              %PUT !                                                                ;
              %PUT ! ----------------------------------------------------           ;
              %PUT ! MASTER DATASET HAS DUPLICATE KEYS                         ;
              %PUT ! ----------------------------------------------------           ;
              %PUT !                                                                ;
              %PUT \=====================================================          ;
              %PUT ;
              %PUT ;

           %END;

       %END;


       /*-------------------------------------*\
       | Alert user to missing values and      |
       | missing value overwrite problems      |
       \*-------------------------------------*/





     DATA _NULL_;

         SET &UIN1..&UINMEM11 END=DONE;

         ARRAY CHARVARS{*} _CHARACTER_;
         ARRAY NUMSVARS{*} _NUMERIC_  ;

         IF _N_ EQ 1 THEN DO;

            CHARS = DIM(CHARVARS);
            NUMS  = DIM(NUMSVARS);

            CALL SYMPUT( 'UCHRS', PUT(CHARS,6.) );
            CALL SYMPUT( 'UNUMS', PUT(NUMS ,6.) );

            STOP;

         END;

     RUN;

     *PUT _LOCAL_;

      %LET UQJ1 = %upcase(%SYSFUNC(TRANwrd("&UJOIN1",%STR( ),",")));

      run;quit;

      /*-------------------------------------*\
      | MASTER ( TABLE ON LEFT )              |
      \*-------------------------------------*/


     DATA _NULL_;

         FILE LOG;

         SET &UIN1..&UINMEM11 END=DONE;

         ARRAY NUMS{*} _NUMERIC_;
         ARRAY CNTN{&UNUMS} _TEMPORARY_;

         ARRAY CHRS{*} _CHARACTER_;
         ARRAY CNTC{&UCHRS} _TEMPORARY_;

         LENGTH VNAM $8.;

         IF DIM(NUMS) GT 0 THEN DO;

            DO I = 1 TO DIM(NUMS);

               IF NUMS{I} EQ . THEN CNTN{I} + 1;

            END;

         END;


         IF DIM(CHRS) GT 0 THEN DO;

            DO I = 1 TO DIM(CHRS);

               IF CHRS{I} EQ ' ' THEN CNTC{I} + 1;

            END;

         END;

         IF DONE THEN DO;

             PUT
              /
              /   '/============================================================== '
              /   '!                                                               '
              /   "!   TABLE &UINMEM11  -- &ULBL1  (MASTER)                        "
             ;

            DO I = 1 TO DIM(NUMS);

               IF CNTN{I} GE 1 THEN DO;

                   CALL VNAME( NUMS{I},  VNAM);


                   PUT

                          '!---------------------------------------------------------------'
                      /   '!                                                               '
                      /   '!   NUMERIC VARIABLE ' VNAM ' HAS ' CNTN{I} 'NULL/MISSING VALUES'
                      /   '!                                                               ' ;


                   IF VNAM  IN ( &UQJ1 ) THEN

                      PUT
                          '!   THIS VARIABLE IS  PART OF A PRIMARY KEY                     '
                      /   '!   CONSIDER RECODING TO A NON NULL VALUE                       '
                      ;

                      PUT
                          '!                                                               '
                      ;

               END;

            END;


            DO I = 1 TO DIM(CHRS);

               IF CNTC{I} GE 1 THEN DO;

                   CALL VNAME(CHRS{I},  VNAM );


                      PUT

                          '!---------------------------------------------------------------'
                      /   '!                                                                 '
                      /   '!   CHARACTER VARIABLE ' VNAM ' HAS ' CNTC{I} 'NULL/MISSING VALUES'
                      /   '!                                                                 '
                   ;

                   IF VNAM  IN ( &UQJ1 ) THEN

                      PUT
                          '!   THIS VARIABLE IS  PART OF A PRIMARY KEY                       '
                      /   '!   CONSIDER RECODING TO A NON NULL VALUE                         '
                      ;

                      PUT
                          '!                                                                 '
                      ;

               END;

            END;

            PUT
                  "!                                                               "
              /   '\============================================================== '
                 ;

         END;

    RUN;


      /*-------------------------------------*\
      |                                       |
      | TRANSACION TABLE ( RIGHT TABLE )      |
      |                                       |
      \*-------------------------------------*/

     DATA _NULL_;

         SET &UIN1..&UINMEM21 END=DONE;

         ARRAY CHARVARS{*} _CHARACTER_;
         ARRAY NUMSVARS{*} _NUMERIC_  ;

         IF _N_ EQ 1 THEN DO;

            CHARS = DIM(CHARVARS);
            NUMS  = DIM(NUMSVARS);

            CALL SYMPUT( 'UCHRS', PUT(CHARS,6.) );
            CALL SYMPUT( 'UNUMS', PUT(NUMS ,6.) );

            STOP;

         END;

     RUN;

     *PUT _LOCAL_;


     DATA _NULL_;

         FILE LOG;

         SET &UIN1..&UINMEM21 END=DONE;

         ARRAY NUMS{*} _NUMERIC_;
         ARRAY CNTN{&UNUMS} _TEMPORARY_;

         ARRAY CHRS{*} _CHARACTER_;
         ARRAY CNTC{&UCHRS} _TEMPORARY_ ;

         LENGTH VNAM $8.;

         IF DIM(NUMS) GT 0 THEN DO;

            DO I = 1 TO DIM(NUMS);

               IF NUMS{I} EQ . THEN CNTN{I} + 1;

            END;

         END;


         IF DIM(CHRS) GT 0 THEN DO;

            DO I = 1 TO DIM(CHRS);

               IF CHRS{I} EQ ' ' THEN CNTC{I} + 1;

            END;

         END;

         IF DONE THEN DO;

             PUT
              /
              /   '/============================================================== '
              /   '!                                                               '
              /   "! TABLE &UINMEM21 -- &ULBL2 TRANSACTION                         "
             ;

            DO I = 1 TO DIM(NUMS);

               CALL VNAME( NUMS{I},  VNAM);

               IF CNTN{I} GE 1                   OR
                  VNAM  IN ( "&UINBOTH" ) THEN   DO;

                   %*LET UQJ1 = %SYSFUNC(TRANWRD(%UPCASE(&UJOIN1),%STR( ),","));
                   %LET UQJ1 = %upcase(%SYSFUNC(TRANwrd("&UJOIN1",%STR( ),",")));

                   *PUT _LOCAL_;


                   PUT

                          '!---------------------------------------------------------------'
                      /   '!                                                               '
                      /   '!   NUMERIC VARIABLE ' VNAM ' HAS ' CNTN{I} 'NULL/MISSING VALUES'
                      /   '!   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER    '
                      /   '!   CONSIDER MODIFY WITH NO MISSING UPATE OPTION                  '
                      /   '!                                                               ' ;


                   IF VNAM  IN ( &UQJ1 ) THEN

                      PUT               top
                          '!   THIS VARIABLE IS  PART OF A PRIMARY KEY                     '
                      /   '!   CONSIDER RECODING TO A NON NULL VALUE                       '
                      ;

                   IF VNAM  IN ( "&UINBOTH" ) THEN

                      PUT
                          '!   THIS VARIABLE IS IN BOTH TABLES AND THE                     '
                      /   '!   TRANSACTION COPY WILL OVERWRITE THE MASTER COPY             '
                      ;

                      PUT
                          '!                                                               '
                      ;

               END;

            END;


            DO I = 1 TO DIM(CHRS);

               CALL VNAME( CHRS{I},  VNAM);

               IF CNTC{I} GE 1                   OR

                  VNAM  IN ( "&UINBOTH" ) THEN   DO;

                      PUT

                          '!-----------------------------------------------------------------'
                      /   '!                                                                 '
                      /   '!   CHARACTER VARIABLE ' VNAM ' HAS ' CNTC{I} 'NULL/MISSING VALUES'
                      /   '!   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER    '
                      /   '!   CONSIDER MODIFY WITH NO MISSING UPATE OPTION                  '
                      /   '!                                                                 '
                   ;

                   IF VNAM  IN ( &UQJ1 ) THEN
                      PUT
                          '!   THIS VARIABLE IS  PART OF A PRIMARY KEY                       '
                      /   '!   CONSIDER RECODING TO A NON NULL VALUE                         '
                      ;

                   IF VNAM  IN ( "&UINBOTH" ) THEN

                      PUT
                          '!   THIS VARIABLE IS IN BOTH TABLES AND THE                     '
                      /   '!   TRANSACTION COPY WILL OVERWRITE THE MASTER COPY             '
                      ;
                      PUT
                          '!                                                                 '
                      ;

               END;

            END;

            PUT
                  "!                                                               "
              /   '\================================================================= '
                 ;

         END;

    RUN;



    %END;   /* DETAIL ANALYSIS */

 %end;

%MEND UTL_MERGE;

%macro utl_mary
    (

    uroot=,  /* root macro var for subscripting ie  x1, x2 .. xn    */
             /* macro var x will contain the number of word in list */

    ustr=,   /* blank separated words ie Rover Spotty Fluffy        */

    udlim=%str( )

    )
    /des="macro vars with # words and word list";



    /*----------------------------------------------*\
    |                                                |
    |  WIN95 SAS612                                  |
    |                                                |
    |  Given a macro variable which contains         |
    |  a string of blank separated words. Return the |
    |  number of words in the list.                  |
    |                                                |
    |  Also create a sequence of macro variables.    |
    |  One for each word in the list.                |
    |                                                |
    |================================================|
    |                                                |
    | This code does not create global macro variabls|
    | but does add macro variables to the scope      |
    | of the calling macro                           |
    |                                                |
    | This code cannot be run inside a datastep      |
    |                                                |
    |================================================|
    |                                                |
    |                                                |
    | Sample Usage                                   |
    | ============                                   |
    |                                                |
    | %utlmary(uroot=mvar,ustr=Rover Spotty Fluffy); |
    |                                                |
    | Result                                         |
    |                                                |
    |   &mvar contains 3                             |
    |   &mvar1 contains Rover                        |
    |   &mvar2 contains Spotty                       |
    |   &mvar3 contains Fluffy                       |
    |                                                |
    | %put I have &mvar friends;                     |
    |                                                |
    | Result                                         |
    | ======                                         |
    | I have 3 Friends                               |
    |                                                |
    | %put My first friend was &mvar1;               |
    |                                                |
    | Result;                                        |
    | ======                                         |
    | My first friend was Rover;                     |
    |                                                |
    |                                                |
    | %put My 2nd   friend was &mvar2;               |
    |                                                |
    | Result                                         |
    | ======                                         |
    | My 2nd   friend was Spotty;                    |
    |                                                |
    |                                                |
    |                                                |
    \*----------------------------------------------*/

    /*%^&*------------------------------------------*\
    |                                                |
    | Description:                                   |
    |                                                |
    |                                                |
    |  Given a macro variable which contains         |
    |  a list of blank separated words.              |
    |  ( macro does support other delimiters )       |
    |                                                |
    |  This macro is not bulletproof, it does not    |
    |  check for empty lists and may fail for some   |
    |  when input text has ,&,,& type characters.    |
    |                                                |
    |  IPO                                           |
    |                                                |
    |   INPUTS                                       |
    |   ======                                       |
    |                                                |
    |   A root macro variable name. Numeric          |
    |   subscripts will be attached to this root.    |
    |   If mvar is the root then the code may create |
    |   aditional macro vars mvar1, mvar2 ... mvarn  |
    |                                                |
    |   A string of blank separated words            |
    |                                                |
    |   %let friends = Rover Spotty Fluffy           |
    |                                                |
    |                                                |
    |   PROCESS                                      |
    |   =======                                      |
    |                                                |
    |   Scan the list incrementing and create a      |
    |   macro varable with the number of words and   |
    |   a macro variable for each word in the string |
    |                                                |
    |   OUTPUTS                                      |
    |   =======                                      |
    |                                                |
    |   If the root is X and the string is           |
    |                                                |
    |   Rover Spotty Fluffy, then macro vars         |
    |                                                |
    |   &X will contain 3                            |
    |   &X1 will contain Rover                       |
    |   &X2 will contain Spotty                      |
    |   &X3 will contain Fluffy                      |
    |                                                |
    |                                                |
    |================================================|
    |                                                |
    | This macro does not create global macro        |
    | variables. The macro variables are placed in   |
    | the scope of the calling nacro.                |
    |                                                |
    | This macro will not work inside a datastep.    |
    |                                                |
    \*----------------------------------------------*/



  %local utlmary1 utlmary2 utlmary3;

  /*-------------------------------------*\
  |                                       |
  | I use these terrible names so that    |
  | user defined global macro vars        |
  | will never collide with my utilities  |
  |                                       |
  | The macro keyword arguments are       |
  | registered names.                     |
  |                                       |
  \*-------------------------------------*/


  %do %until(%quote(&utlmary1)=%str());

    %let utlmary2=%eval(&utlmary2 + 1);

    %let utlmary1=%qscan(%str(&ustr), &utlmary2, %str(&udlim));

    %let &uroot.&utlmary2 = &utlmary1;

  %end;


  %let &uroot = %eval ( &utlmary2 - 1 );


  data _null_;

     call symputx ( "&uroot" , "&&&uroot&utlmary3","G" );

     %do utlmary3 = 1 %to &utlmary2;

        call symputx ( "&uroot.&utlmary3" , "&&&uroot&utlmary3","G" );

     %end;

  /*-------------------------------------*\
  |                                       |
  | Do not put a run statement after this |
  | data null. The next run in the        |
  | calling program will assure that      |
  | the macro generated macro             |
  | variables will be contained in the    |
  | scope of the calling program.         |
  |                                       |
  \*-------------------------------------*/

%mend utl_mary;

%MACRO UTLNOBZ
        (
          UTITLE=NUMBER OF OBS IN SAS DATASET,
          UOBJ=UTLNOBZ,

          /*-------------------------------------*\
          | INPUTS                                |
          \*-------------------------------------*/

          UIN=C:\DAT,
          UINMEM=F0022


          /*-------------------------------------*\
          | OUTPUT                                |
          |                                       |
          |    ALL THAT IS LEFT AFTER THIS MACRO  |
          |    EXECUTES IS THE NUMERIC TEXT       |
          |    WHOSE VALUE IS THE NUMBER OF       |
          |    OBSERVATIONS IN UINMEM             |
          |                                       |
          \*-------------------------------------*/


        ) / DES = "NUMBER OF OBS IN SAS DATASET";


 /*----------------------------------------------*\
 |                                                |
 | Win95 SAS612 MS-Access 95 Version 7            |
 |                                                |
 | This code results in the number of obs in a    |
 | SAS dataset.                                   |
 |                                                |
 | Example of usage:                              |
 |                                                |
 | Data whuichone;                                |
 |                                                |
 |   if %utlnobz(uin=c:\dat,uinmem=tst) gt 0      |
 |      then set tablea;                          |
 |   else    set tableb;                          |
 |                                                |
 | end;                                           |
 |                                                |
 |                                                |
 \*----------------------------------------------*/

 /*------------------------------------------------------------*\
 |                                                              |
 |  libname dat "c:\dat";                                       |
 |                                                              |
 |  data dat.tst;                                               |
 |                                                              |
 |      do i=1 to 10;                                           |
 |         output;                                              |
 |      end;                                                    |
 |  run;                                                        |
 |                                                              |
 |                                                              |
 |  data table1;                                                |
 |    table2='table2';                                          |
 |  run;                                                        |
 |                                                              |
 |  data table2;                                                |
 |    table2='table2';                                          |
 |  run;                                                        |
 |                                                              |
 |                                                              |
 |  DATA whichone;                                              |
 |                                                              |
 |     if  %utlnobz(uin=c:\dat,uinmem=tst) gt 0 then set table1;|
 |     else                                          set table2;|
 |                                                              |
 |  RUN;                                                        |
 |                                                              |
 |  proc print;                                                 |
 |  run;                                                        |
 |                                                              |
 \*------------------------------------------------------------*/


 /*----------------------------------------*\
 | Do libname statement as macro statement  |
 | Probably should check to see if libname  |
 | is already used                          |
 \*----------------------------------------*/

 %LET UINSAV = %STR(&UIN);


 %IF %QUPCASE(&UIN) EQ %QUPCASE(WORK) %THEN

     /*----------------------------------------*\
     | Open sas dataset read only               |
     \*----------------------------------------*/

     %LET UDSID = %SYSFUNC(OPEN(WORK.&UINMEM,I));

 %ELSE %DO;

     %IF (%SYSFUNC(LIBNAME(UTLNOBZ,&UINSAV))) %THEN %LET UOBS = %SYSFUNC(SYSMSG());

     /*----------------------------------------*\
     | Open sas dataset read only               |
     \*----------------------------------------*/

     %LET UDSID = %SYSFUNC(OPEN(UTLNOBZ.&UINMEM,I));

 %END;

 /*----------------------------------------*\
 | Get observations                         |
 \*----------------------------------------*/


 %IF &UDSID %THEN  %LET UOBS = %SYSFUNC(ATTRN(&UDSID,NOBS));

 %ELSE %LET UOBS = OPEN FOR &UINMEM FAILED - %SYSFUNC(SYSMSG());

 /*----------------------------------------*\
 | close dataset                            |
 \*----------------------------------------*/

 %LET RC = %SYSFUNC(CLOSE(&UDSID));

 /*----------------------------------------*\
 | clear libname                            |
 \*----------------------------------------*/

 %IF %QUPCASE(&UIN) NE %QUPCASE(WORK) %THEN
     %IF (%SYSFUNC(LIBNAME(UTLNOBZ))) %THEN %LET UOBS = %SYSFUNC(SYSMSG());


 /*----------------------------------------*\
 | All that remains after execution         |
 | Note you could set uons to -1 if error   |
 \*----------------------------------------*/

              &UOBS

%MEND UTLNOBZ;
%macro utlnopts(note2err=nonote2err,nonotes=nonotes)
    / des = "Turn  debugging options off";

OPTIONS
     FIRSTOBS=1
     NONUMBER
     MLOGICNEST
   /*  MCOMPILENOTE */
     MPRINTNEST
     lrecl=384
     MAUTOLOCDISPLAY
     NOFMTERR     /* turn  Format Error off                           */
     NOMACROGEN   /* turn  MACROGENERATON off                         */
     NOSYMBOLGEN  /* turn  SYMBOLGENERATION off                       */
     &NONOTES     /* turn  NOTES off                                  */
     NOOVP        /* never overstike                                  */
     NOCMDMAC     /* turn  CMDMAC command macros on                   */
     NOSOURCE    /* turn  source off * are you sure?                 */
     NOSOURCE2    /* turn  SOURCE2   show gererated source off        */
     NOMLOGIC     /* turn  MLOGIC    macro logic off                  */
     NOMPRINT     /* turn  MPRINT    macro statements off             */
     NOCENTER     /* turn  NOCENTER  I do not like centering          */
     NOMTRACE     /* turn  MTRACE    macro tracing                    */
     NOSERROR     /* turn  SERROR    show unresolved macro refs       */
     NOMERROR     /* turn  MERROR    show macro errors                */
     OBS=MAX      /* turn  max obs on                                 */
     NOFULLSTIMER /* turn  FULLSTIMER  give me all space/time stats   */
     NODATE       /* turn  NODATE      suppress date                  */
     DSOPTIONS=&NOTE2ERR
     ERRORCHECK=STRICT /*  syntax-check mode when an error occurs in a LIBNAME or FILENAME statement */
     DKRICOND=ERROR    /*  variable is missing from input data during a DROP=, KEEP=, or RENAME=     */

     /* NO$SYNTAXCHECK  be careful with this one */
;

RUN;quit;

%MEND UTLNOPTS;
%MACRO UTLOPTS
         / des = "Turn all debugging options off forgiving options";

OPTIONS

   OBS=MAX
   FIRSTOBS=1
   lrecl=384
   NOFMTERR      /* DO NOT FAIL ON MISSING FORMATS                              */
   SOURCE      /* turn sas source statements on                               */
   SOURCe2     /* turn sas source statements on                               */
   MACROGEN    /* turn  MACROGENERATON ON                                     */
   SYMBOLGEN   /* turn  SYMBOLGENERATION ON                                   */
   NOTES       /* turn  NOTES ON                                              */
   NOOVP       /* never overstike                                             */
   CMDMAC      /* turn  CMDMAC command macros on                              */
   /* ERRORS=2    turn  ERRORS=2  max of two errors                           */
   MLOGIC      /* turn  MLOGIC    macro logic                                 */
   MPRINT      /* turn  MPRINT    macro statements                            */
   MRECALL     /* turn  MRECALL   always recall                               */
   MERROR      /* turn  MERROR    show macro errors                           */
   NOCENTER    /* turn  NOCENTER  I do not like centering                     */
   DETAILS     /* turn  DETAILS   show details in dir window                  */
   SERROR      /* turn  SERROR    show unresolved macro refs                  */
   NONUMBER    /* turn  NONUMBER  do not number pages                         */
   FULLSTIMER  /*   turn  FULLSTIMER  give me all space/time stats            */
   NODATE      /* turn  NODATE      suppress date                             */
   /*DSOPTIONS=NOTE2ERR                                                                              */
   /*ERRORCHECK=STRICT /*  syntax-check mode when an error occurs in a LIBNAME or FILENAME statement */
   DKRICOND=WARN      /*  variable is missing from input data during a DROP=, KEEP=, or RENAME=     */
   DKROCOND=WARN      /*  variable is missing from output data during a DROP=, KEEP=, or RENAME=     */
   /* NO$SYNTAXCHECK  be careful with this one */
 ;

run;quit;

%MEND UTLOPTS;
