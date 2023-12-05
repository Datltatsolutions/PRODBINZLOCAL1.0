CLASS lhc_employee DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validatefunction FOR VALIDATE ON SAVE
      IMPORTING keys FOR job~validatefunction.

ENDCLASS.

CLASS lhc_employee IMPLEMENTATION.

  METHOD validatefunction.

    " Read relevant function data
    READ ENTITIES OF zi_job IN LOCAL MODE
    ENTITY Job
    FIELDS ( jobfunction ) WITH CORRESPONDING #( keys )
        RESULT DATA(job_set).

    " Find if function exists
    LOOP AT job_set INTO DATA(job_select).
        SELECT COUNT( * ) FROM ZI_READ_FUNCTION_DOMAIN
        WHERE value_low = @job_select-jobfunction
        INTO @DATA(function_count).

    " Raise message if function does not exist
        IF function_count = 0.
          APPEND VALUE #(  jobid = job_select-jobid ) TO failed-job.
          APPEND VALUE #(  jobid = job_select-jobid
                           %msg  = new_message_with_text( text     = 'Job function does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-jobfunction = if_abap_behv=>mk-on ) TO reported-job.
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
