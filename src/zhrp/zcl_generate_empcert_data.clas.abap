CLASS zcl_generate_empcert_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GENERATE_EMPCERT_DATA IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

    DATA itab TYPE TABLE OF ztempcert.

*   delete existing entries in the database table
    DELETE FROM ztempcert.

    itab = VALUE #(
      ( mykey = '02D5290E594C1EDA93815057FD946624' empid = 'E1' certid = 'ISTQBAF'
      certstart = '20210815' certend = '20210822' empcertnotes = 'test 1' )
      ( mykey = '02D5290E594C1EDA93815C50CD7AE62A' empid = 'E1' certid = 'TOEIC-L2'
      certstart = '20210816' certend = '20210823' empcertnotes = 'test 2' )
      ( mykey = '02D5290E594C1EDA93858EED2DA2EB0B' empid = 'E4' certid = 'TOEIC-L2'
      certstart = '20150101' certend = '20170101' empcertnotes = 'test 3' )
    ).

*   delete existing entries in the database table
    DELETE FROM ztempcert.

*   insert the new table entries
    INSERT ztempcert FROM TABLE @itab.

*   output the result as a console message
    out->write( |{ sy-dbcnt } employee-certificate entries inserted successfully!| ).
  ENDMETHOD.
ENDCLASS.
