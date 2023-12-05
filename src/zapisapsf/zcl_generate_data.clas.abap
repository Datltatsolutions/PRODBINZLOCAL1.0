CLASS zcl_generate_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GENERATE_DATA IMPLEMENTATION.


    METHOD if_oo_adt_classrun~main.

    delete from ztsfrqapi.

    DATA wa TYPE ztsfupdatereq.
    wa-requestid = 'R1'.
    wa-requestdatetime = '20231010235959'.
    wa-bodyrequest = 'abaptestingreq'.
    wa-checkapprove = abap_true.
    wa-approveemployee = 'E1'.
    wa-approvedatetime = '20231111235959'.

    "insert ztsfupdatereq from @wa.

    "out->write( |{ sy-dbcnt } entries inserted !| ).
    ENDMETHOD.
ENDCLASS.
