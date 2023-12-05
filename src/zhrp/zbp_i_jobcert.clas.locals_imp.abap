CLASS lhc_jobcert DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validatecertificate FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobcertificate~validatecertificate.

    METHODS validatejob FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobcertificate~validatejob.

    METHODS validateUniqueIDs FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobcertificate~validateUniqueIDs.

ENDCLASS.

CLASS lhc_jobcert IMPLEMENTATION.

  METHOD validatecertificate.

    " Read relevant Certificate ID data
    READ ENTITIES OF zi_jobcert IN LOCAL MODE
    ENTITY JobCertificate
    FIELDS ( certid ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobcert_set).

    " Find if Certificate ID exists
     LOOP AT jobcert_set INTO DATA(jobcert_select).
        SELECT COUNT( * ) FROM zi_certificate
        WHERE certid = @jobcert_select-certid
        INTO @DATA(certid_count).

    " Raise message if Certificate ID does not exist
        IF certid_count = 0.
          APPEND VALUE #(  mykey = jobcert_select-mykey ) TO failed-jobcertificate.
          APPEND VALUE #(  mykey = jobcert_select-mykey
                           %msg  = new_message_with_text( text     = 'Certificate ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-certid = if_abap_behv=>mk-on ) TO reported-jobcertificate.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validatejob.

    " Read relevant Job ID data
    READ ENTITIES OF zi_jobcert IN LOCAL MODE
    ENTITY JobCertificate
    FIELDS ( jobid ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobcert_set).

    " Find if Job ID exists
     LOOP AT jobcert_set INTO DATA(jobcert_select).
        SELECT COUNT( * ) FROM zi_job
        WHERE jobid = @jobcert_select-jobid
        INTO @DATA(jobid_count).

    " Raise message if Job ID does not exist
        IF jobid_count = 0.
          APPEND VALUE #(  mykey = jobcert_select-mykey ) TO failed-jobcertificate.
          APPEND VALUE #(  mykey = jobcert_select-mykey
                           %msg  = new_message_with_text( text     = 'Job ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-jobid = if_abap_behv=>mk-on ) TO reported-jobcertificate.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateUniqueIDs.

    " Read relevant IDs data
    READ ENTITIES OF zi_jobcert IN LOCAL MODE
    ENTITY JobCertificate
    FIELDS ( jobid certid ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobcert_set).

    " Check if the object is unique
     LOOP AT jobcert_set INTO DATA(jobcert_select).
        SELECT COUNT( * ) FROM zi_jobcert
        WHERE jobid = @jobcert_select-jobid
        AND certid = @jobcert_select-certid
        INTO @DATA(id_count).

        IF id_count <> 0.
          APPEND VALUE #(  mykey = jobcert_select-mykey ) TO failed-jobcertificate.
          APPEND VALUE #(  mykey = jobcert_select-mykey
                           %msg  = new_message_with_text( text     = 'Object already exists.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-jobid  = if_abap_behv=>mk-on
                           %element-certid = if_abap_behv=>mk-on ) TO reported-jobcertificate.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

ENDCLASS.
