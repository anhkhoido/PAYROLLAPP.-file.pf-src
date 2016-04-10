     FSHIFTRATESif   e             disk    RENAME(SHIFTRATES:SHIFTRATER)
     FALLSHIFT  if   e           K disk    RENAME(ALLSHIFT:ALLSHIFTR)
     FCONFIRMPAYcf   e             workstn
     FPAYRPT    o    e             printer OFLIND(*IN01)
     DHOURSOVER        S              3  0
     F/FREE
       READ SHIFTRATES;
       WRITE TITLE;
       WRITE COLHDG;
       READ ALLSHIFT;
       DOW NOT %EOF;
      *Execute subroutine named PAYSR.
         EXSR PAYSR;

         IF *IN01;
           WRITE TITLE;
           WRITE COLHDG;
           *IN01 = *OFF;
         ENDIF;

         WRITE EMPDETAIL;
         READ ALLSHIFT;
       ENDDO;

       TOTEMPPAY = TOTREGPAY + TOTOVTPAY;
       WRITE TOTALS;

       EXFMT RECORD1;
       *INLR = *ON;
       RETURN;

       BEGSR PAYSR;
         SELECT;
           WHEN WORKSHIFT = 'D';
             HOURLYRATE = DAYRATE;
           WHEN WORKSHIFT = 'N';
             HOURLYRATE = NIGHTRATE;
           WHEN WORKSHIFT = 'A';
             HOURLYRATE = AFTNRATE;
         ENDSL;

         SELECT;
           WHEN PAYGRADE = '1';
             EVAL(H) HOURLYRATE=HOURLYRATE*1.073;
           WHEN PAYGRADE = '2';
             EVAL(H) HOURLYRATE=HOURLYRATE*1.054;
           WHEN PAYGRADE = '3';
             EVAL(H) HOURLYRATE=HOURLYRATE*0.95;
         ENDSL;

         IF HRSWORKED >= 41;
           EVAL(H) REGULARPAY = 40 * HOURLYRATE;
           EVAL(H) OVERPAY = (HRSWORKED - 40)*(HOURLYRATE*1.5);
         ENDIF;

         IF HRSWORKED <= 40;
           EVAL(H) REGULARPAY = HRSWORKED*HOURLYRATE;
           OVERPAY = 0;
         ENDIF;

         TOTALPAY = REGULARPAY + OVERPAY;
         TOTREGPAY = TOTREGPAY + REGULARPAY;
         TOTOVTPAY = TOTOVTPAY + OVERPAY;


       ENDSR; 
