CLASS zcl_generate_certificate_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GENERATE_CERTIFICATE_DATA IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

    DATA itab TYPE TABLE OF ztcertificate.

*   fill internal table (itab)
*   for abap_boolean, true = abap_true and false = abap_false, it will display as "X" and " "
    itab = VALUE #(
      ( certid = 'TOEIC-L1' certname = 'Test of English for International Communication-Level 1'
      certdesc = 'English language for workplace' certrenew = abap_true certnote = '405-500, valid for 02 years' )
      ( certid = 'TOEIC-L2' certname = 'Test of English for International Communication-Level 2'
      certdesc = 'English language for workplace' certrenew = abap_true certnote = '505-600, valid for 02 years' )
      ( certid = 'TOEIC-L3' certname = 'Test of English for International Communication-Level 3'
      certdesc = 'English language for workplace' certrenew = abap_true certnote = '605-700, valid for 02 years' )
      ( certid = 'TOEIC-L4' certname = 'Test of English for International Communication-Level 4'
      certdesc = 'English language for workplace' certrenew = abap_true certnote = '705-800, valid for 02 years' )
      ( certid = 'TOEIC-L5' certname = 'Test of English for International Communication-Level 5'
      certdesc = 'English language for workplace' certrenew = abap_true certnote = '805-990, valid for 02 years' )
    ).

*   delete existing entries in the database table
    DELETE FROM ztcertificate.

*   insert the new table entries
    INSERT ztcertificate FROM TABLE @itab.

*   output the result as a console message
    out->write( |{ sy-dbcnt } certificate entries inserted successfully!| ).

*   insert only one entry
    DATA wa TYPE ztcertificate.
    wa-certid = 'ISTQBAF'.
    wa-certname = 'ISTQB Agile Foundation Level'.
    wa-certdesc = 'ISTQB Agile Foundation Level For Testing'.
    wa-certrenew = abap_false.
    wa-certnote = 'test'.

    INSERT ztcertificate FROM @wa.

*   output the result as a console message
    out->write( |{ sy-dbcnt } certificate entries inserted successfully!| ).

  ENDMETHOD.
ENDCLASS.
