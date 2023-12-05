CLASS zcl_generate_empedu_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GENERATE_EMPEDU_DATA IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

    DATA itab TYPE TABLE OF ztempedu.

*   delete existing entries in the database table
    DELETE FROM ztempedu.

  ENDMETHOD.
ENDCLASS.
