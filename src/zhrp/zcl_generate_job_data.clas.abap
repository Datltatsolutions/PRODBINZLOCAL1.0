CLASS zcl_generate_job_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GENERATE_JOB_DATA IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

    DATA itab TYPE TABLE OF ztjob.

*   fill internal table (itab)
    itab = VALUE #(
      ( jobid = 'J01' jobname = 'CEO' jobfunction = 'Operation')
      ( jobid = 'J02' jobname = 'CFO' jobfunction = 'Finance')
      ( jobid = 'J03' jobname = 'VP of Sales' jobfunction = 'Sales')
      ( jobid = 'T02' jobname = 'Senior Software Tester' jobfunction = 'IT')
      ( jobid = 'JV1' jobname = 'Java Developer' jobfunction = 'IT')
    ).

*   delete existing entries in the database table
    DELETE FROM ztjob.

*   insert the new table entries
    INSERT ztjob FROM TABLE @itab.

*   output the result as a console message
    out->write( |{ sy-dbcnt } job entries inserted successfully!| ).

*   insert only one entry
    DATA wa TYPE ztjob.
    wa-jobid = 'PV1'.
    wa-jobname = 'Python Developer'.
    wa-jobfunction = 'IT'.

    INSERT ztjob FROM @wa.

*   output the result as a console message
    out->write( |{ sy-dbcnt } job entries inserted successfully!| ).


  ENDMETHOD.
ENDCLASS.
