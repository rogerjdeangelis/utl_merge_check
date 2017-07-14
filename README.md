# utl_merge_check
Check tables before merge

    ``` Must matching variable attributes be identical when using proc sql to create tables?               ```
    ```                                                                                                    ```
    ``` the code and message is at                                                                         ```
    ``` https://www.dropbox.com/s/qkylzvc49hef3hz/merge_check.sas?dl=0                                     ```
    ```                                                                                                    ```
    ``` Can I Join two tables on Name and Age?                                                             ```
    ```                                                                                                    ```
    ```    WORKING CODE   ( merge keys can be different )                                                  ```
    ```    =============                                                                                   ```
    ```                                                                                                    ```
    ```         %*utl_merge(                                                                               ```
    ```               uin1=work                                                                            ```
    ```              ,uin2=work                                                                            ```
    ```              ,uinmem11=classx                                                                      ```
    ```              ,uinmem21=classy                                                                      ```
    ```              ,ujoin1  =name age                                                                    ```
    ```              ,ujoin2  =name age                                                                    ```
    ```              ,uproces =DETAIL                                                                      ```
    ```             );                                                                                     ```
    ```                                                                                                    ```
    ```      Utility macros on end                                                                         ```
    ```                                                                                                    ```
    ```                                                                                                    ```
    ``` see                                                                                                ```
    ``` https://goo.gl/H2SF9t                                                                              ```
    ``` https://communities.sas.com/t5/General-SAS-Programming/Must-matching-variable-attributes           ```
    ``` -be-identical-when-using-proc/m-p/375786                                                           ```
    ```                                                                                                    ```
    ```                                                                                                    ```
    ``` HAVE ( TWO DATASETS)                                                                               ```
    ``` =====================                                                                              ```
    ```                                                                                                    ```
    ``` WORK.CLASSX  (TRANSACTION)                                                                         ```
    ```                                                                                                    ```
    ``` Up to 40 obs from classx total obs=20                                                              ```
    ```                                                                                                    ```
    ``` Obs    NEWNAME    AGE    SEX    SEQ                                                                ```
    ```                                                                                                    ```
    ```   1    Alfred      14     .       1                                                                ```
    ```   2    Alfred      14     1       1                                                                ```
    ```   3                13     0       2                                                                ```
    ```   4    Barbara     13     0       3                                                                ```
    ```                                                                                                    ```
    ``` WORK.CLASSY (MASTER)                                                                               ```
    ```                                                                                                    ```
    ``` Up to 40 obs from CLASSY total obs=19                                                              ```
    ```                                                                                                    ```
    ``` Obs    OLDNAME    AGE    SEX    HEIGHT    WEIGHT    SEQ                                            ```
    ```                                                                                                    ```
    ```   1    Alfred      14     M      69.0      112.5      1                                            ```
    ```   2    Alfred      14     M      69.0      112.5      1                                            ```
    ```   3    Alice       13     F      56.5       84.0      2                                            ```
    ```   4    Barbara     13            65.3       98.0      .                                            ```
    ```   5    Carol       14     F      62.8      102.5      1                                            ```
    ```                                                                                                    ```
    ``` Comparison of attributes                                                                           ```
    ```                                                                                                    ```
    ```       -------- CLASSX --------   --- CLASSY -----                                                  ```
    ```                                                                                                    ```
    ```       Variable    Type    Len     Type    Len                                                      ```
    ```                                                                                                    ```
    ``` Keys  NAME        Char     32     Char      8  ( different lengths)                                ```
    ```       AGE         Num       4     Num       8  (defferent lengths can be an issue for floats)      ```
    ```                                                                                                    ```
    ```       SEX         Num       8     Char     10  ( different types  )                                ```
    ```                                                                                                    ```
    ```       HEIGHT      Num       8                                                                      ```
    ```       WEIGHT      Num       8                  (not in classy)                                     ```
    ```                                                                                                    ```
    ```       SEQ         Num       8     Num       8                                                      ```
    ```                                                                                                    ```
    ```                                                                                                    ```
    ```                                                                                                    ```
    ``` WANT  Detail analysis                                                                              ```
    ``` ======================                                                                             ```
    ```                                                                                                    ```
    ``` This is complicated                                                                                ```
    ```                                                                                                    ```
    ```  1. Union - all variable                                                                           ```
    ```  2. Master variables                                                                               ```
    ```  3. Transation variables (note HEIGHT, WEIGHT and OLDNAME are missing)                             ```
    ```  4. Transaction only ( variables with non matching type or length are considered Trans only.       ```
    ```     Note type and length differences                                                               ```
    ```  5. Like 4 but WEIGHT and HEIGHT added because they only exist in Master                           ```
    ```  6. Only SEQ has the same type and lenght an is in both datasets                                   ```
    ```                                                                                                    ```
    ```                                                                                                    ```
    ```      1            2                3              4                5                6              ```
    ``` -----------------------------------------------------------------------------------------------    ```
    ``` |           ____MASTER____   ____TRANS_____   __TRAN ONLY___   _MASTER ONLY__   _MASTER TRANS_|    ```
    ``` |UNION      NAME     T LEN   NAME     T LEN   NAME     T LEN   NAME     T LEN   NAME     T LEN|    ```
    ``` |---------------------------------------------------------------------------------------------|    ```
    ``` |AGE     |*|AGE     |n|  8|*|AGE     |n|  4|*|AGE     |n|  4|*|AGE     |n|  8|*|        | |   |    ```
    ``` |--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|    ```
    ``` |HEIGHT  |*|HEIGHT  |n|  8|*|        | |   |*|        | |   |*|HEIGHT  |n|  8|*|        | |   |    ```
    ``` |--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|    ```
    ``` |NEWNAME |*|        | |   |*|NEWNAME |c| 32|*|NEWNAME |c| 32|*|        | |   |*|        | |   |    ```
    ``` |--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|    ```
    ``` |OLDNAME |*|OLDNAME |c|  8|*|        | |   |*|        | |   |*|OLDNAME |c|  8|*|        | |   |    ```
    ``` |--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|    ```
    ``` |SEQ     |*|SEQ     |n|  8|*|SEQ     |n|  8|*|        | |   |*|        | |   |*|SEQ     |n|  8|    ```
    ``` |--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|    ```
    ``` |SEX     |*|SEX     |c| 10|*|SEX     |n|  8|*|SEX     |n|  8|*|SEX     |c| 10|*|        | |   |    ```
    ``` |--------+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---+-+--------+-+---|    ```
    ``` |WEIGHT  |*|WEIGHT  |n|  8|*|        | |   |*|        | |   |*|WEIGHT  |n|  8|*|        | |   |    ```
    ``` -----------------------------------------------------------------------------------------------    ```
    ```                                                                                                    ```
    ``` LOG MESSAGES                                                                                       ```
    ```                                                                                                    ```
    ``` /===================================================                                               ```
    ``` !                                                                                                  ```
    ``` ! --------------------------------------------------                                               ```
    ``` ! CORRESPONDING KEY VARIABLES HAVE DIFFERENT LENGTHS                                               ```
    ``` ! --------------------------------------------------                                               ```
    ``` !                                                                                                  ```
    ``` !                                                                                                  ```
    ``` ! THE LENGTH OF newname AND oldname ARE NOT EQUAL                                                  ```
    ``` !                                                                                                  ```
    ``` !  Transaction Dataset -- DATABASE work                                                            ```
    ``` !                                                                                                  ```
    ``` !    VARIABLE LABEL -> Transact name                                                               ```
    ``` !    TABLE classx VARIABLE  newname LENGTH 32 TYPE C                                               ```
    ``` !                                                                                                  ```
    ``` !  Master Dataset -- DATABASE work                                                                 ```
    ``` !                                                                                                  ```
    ``` !    VARIABLE LABEL -> Master name                                                                 ```
    ``` !    TABLE classy VARIABLE  oldname LENGTH 8  TYPE C                                               ```
    ``` !                                                                                                  ```
    ``` !                                                                                                  ```
    ``` \===================================================                                               ```
    ```                                                                                                    ```
    ``` /===================================================                                               ```
    ``` !                                                                                                  ```
    ``` ! --------------------------------------------------                                               ```
    ``` ! CORRESPONDING KEY VARIABLES HAVE DIFFERENT LENGTHS                                               ```
    ``` ! --------------------------------------------------                                               ```
    ``` !                                                                                                  ```
    ``` !                                                                                                  ```
    ``` ! THE LENGTH OF age AND age ARE NOT EQUAL                                                          ```
    ``` !                                                                                                  ```
    ``` !  Transaction Dataset -- DATABASE work                                                            ```
    ``` !                                                                                                  ```
    ``` !    VARIABLE LABEL -> Transact Age                                                                ```
    ``` !    TABLE classx VARIABLE  age LENGTH 4 TYPE N                                                    ```
    ``` !                                                                                                  ```
    ``` !  Master Dataset -- DATABASE work                                                                 ```
    ``` !                                                                                                  ```
    ``` !    VARIABLE LABEL -> Master Age                                                                  ```
    ``` !    TABLE classy VARIABLE  age LENGTH 8  TYPE N                                                   ```
    ``` !                                                                                                  ```
    ``` !                                                                                                  ```
    ``` \===================================================                                               ```
    ```                                                                                                    ```
    ``` /=================================================                                                 ```
    ``` !                                                                                                  ```
    ``` ! ---------------------------------------                                                          ```
    ``` ! VARIABLE LENGTH INCONSISTENT                                                                     ```
    ``` !                                                                                                  ```
    ``` ! VARIABLE AGE  HAS LENGTH 8  ON classx                                                            ```
    ``` ! AND LENGTH 4  ON classy                                                                          ```
    ``` ! ---------------------------------------                                                          ```
    ``` !                                                                                                  ```
    ``` \=================================================                                                 ```
    ```                                                                                                    ```
    ``` /=================================================                                                 ```
    ``` !                                                                                                  ```
    ``` ! ---------------------------------------                                                          ```
    ``` ! VARIABLE TYPE INCONSISTENT                                                                       ```
    ``` !                                                                                                  ```
    ``` ! VARIABLE SEX  IS char  ON classx                                                                 ```
    ``` ! AND num  ON classy                                                                               ```
    ``` ! ---------------------------------------                                                          ```
    ``` !                                                                                                  ```
    ``` \=================================================                                                 ```
    ```                                                                                                    ```
    ``` /=================================================                                                 ```
    ``` !                                                                                                  ```
    ``` ! ---------------------------------------                                                          ```
    ``` ! VARIABLE LENGTH INCONSISTENT                                                                     ```
    ``` !                                                                                                  ```
    ``` ! VARIABLE SEX  HAS LENGTH 10  ON classx                                                           ```
    ``` ! AND LENGTH 8  ON classy                                                                          ```
    ``` ! ---------------------------------------                                                          ```
    ``` !                                                                                                  ```
    ``` \=================================================                                                 ```
    ```                                                                                                    ```
    ``` /=====================================================                                             ```
    ``` !                                                                                                  ```
    ``` ! ----------------------------------------------------                                             ```
    ``` ! MANY TO MANY MERGE MAY NOT BE SUITABLE FOR SAS MERGE                                             ```
    ``` ! CONSIDER PROC SQL CARTESIAN PRODUCT                                                              ```
    ``` !                                                                                                  ```
    ``` ! TRANSACTION AND MASTER DATASET HAVE DUPLICATE KEYS                                               ```
    ``` ! ----------------------------------------------------                                             ```
    ``` !                                                                                                  ```
    ``` \=====================================================                                             ```
    ```                                                                                                    ```
    ``` /==============================================================                                    ```
    ``` !                                                                                                  ```
    ``` !   TABLE classx  -- Transaction Dataset  (MASTER)                                                 ```
    ``` !---------------------------------------------------------------                                   ```
    ``` !                                                                                                  ```
    ``` !   NUMERIC VARIABLE SEX  HAS 1 NULL/MISSING VALUES                                                ```
    ``` !                                                                                                  ```
    ``` !                                                                                                  ```
    ``` !---------------------------------------------------------------                                   ```
    ``` !                                                                                                  ```
    ``` !   CHARACTER VARIABLE NEWNAME  HAS 1 NULL/MISSING VALUES                                          ```
    ``` !                                                                                                  ```
    ``` !   THIS VARIABLE IS  PART OF A PRIMARY KEY                                                        ```
    ``` !   CONSIDER RECODING TO A NON NULL VALUE                                                          ```
    ``` !                                                                                                  ```
    ``` !                                                                                                  ```
    ``` \==============================================================                                    ```
    ```                                                                                                    ```
    ``` /==============================================================                                    ```
    ``` !                                                                                                  ```
    ``` ! TABLE classy -- Master Dataset TRANSACTION                                                       ```
    ``` !---------------------------------------------------------------                                   ```
    ``` !                                                                                                  ```
    ``` !   NUMERIC VARIABLE SEQ  HAS 1 NULL/MISSING VALUES                                                ```
    ``` !   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER                                     ```
    ``` !   CONSIDER MODIFY WITH NO MISSING UPATE OPTION                                                   ```
    ``` !                                                                                                  ```
    ``` !   THIS VARIABLE IS IN BOTH TABLES AND THE                                                        ```
    ``` !   TRANSACTION COPY WILL OVERWRITE THE MASTER COPY                                                ```
    ``` !                                                                                                  ```
    ``` !-----------------------------------------------------------------                                 ```
    ``` !                                                                                                  ```
    ``` !   CHARACTER VARIABLE SEX  HAS 1 NULL/MISSING VALUES                                              ```
    ``` !   MISSING VALUES WILL OVERWRITE NON-MISSING VALUES IN MASTER                                     ```
    ``` !   CONSIDER MODIFY WITH NO MISSING UPATE OPTION                                                   ```
    ``` !                                                                                                  ```
    ``` !                                                                                                  ```
    ``` !                                                                                                  ```
    ``` \=================================================================                                 ```


 
