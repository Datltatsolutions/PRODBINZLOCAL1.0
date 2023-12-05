CLASS zcl_generate_skill_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GENERATE_SKILL_DATA IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

    DATA itab TYPE TABLE OF ztskill.

*   fill internal table (itab)
*   for abap_boolean, true = abap_true and false = abap_false, it will display as "X" and " "
    itab = VALUE #(
      ( skillid = 'S01' skillname = 'Negotiation' skillnote = '')
      ( skillid = 'S02' skillname = 'Presentation' skillnote = '')
      ( skillid = 'S03' skillname = 'Java Programming' skillnote = '')
      ( skillid = 'S14' skillname = 'Excel' skillnote = '')
      ( skillid = 'S25' skillname = 'Documentation' skillnote = '')

    ).

*   delete existing entries in the database table
    DELETE FROM ztskill.

*   insert the new table entries
    INSERT ztskill FROM TABLE @itab.

*   output the result as a console message
    out->write( |{ sy-dbcnt } skill entries inserted successfully!| ).

*   insert only one entry
    DATA wa TYPE ztskill.
    wa-skillid = ''.
    wa-skillname = ''.
    wa-skillnote = ''.


    INSERT ztskill FROM @wa.

*   output the result as a console message
    out->write( |{ sy-dbcnt } skill entries inserted successfully!| ).

  ENDMETHOD.
ENDCLASS.
