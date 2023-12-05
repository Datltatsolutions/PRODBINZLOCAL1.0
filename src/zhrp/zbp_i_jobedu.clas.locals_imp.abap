CLASS lhc_jobedu DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateeducation FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobeducation~validateeducation.

    METHODS validateedulevel FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobeducation~validateedulevel.

    METHODS validatejob FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobeducation~validatejob.

    METHODS validateuniqueids FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobeducation~validateuniqueids.

ENDCLASS.

CLASS lhc_jobedu IMPLEMENTATION.

  METHOD validateeducation.

    " Read relevant Education ID data
    READ ENTITIES OF zi_jobedu IN LOCAL MODE
    ENTITY JobEducation
    FIELDS ( eduid ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobedu_set).

    " Find if Education ID exists
     LOOP AT jobedu_set INTO DATA(jobedu_select).
        SELECT COUNT( * ) FROM zi_education
        WHERE eduid = @jobedu_select-eduid
        INTO @DATA(eduid_count).

    " Raise message if Education ID does not exist
        IF eduid_count = 0.
          APPEND VALUE #(  mykey = jobedu_select-mykey ) TO failed-jobeducation.
          APPEND VALUE #(  mykey = jobedu_select-mykey
                           %msg  = new_message_with_text( text     = 'Education ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-eduid = if_abap_behv=>mk-on ) TO reported-jobeducation.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateedulevel.

    " Read relevant Education Level data
    READ ENTITIES OF zi_jobedu IN LOCAL MODE
    ENTITY JobEducation
    FIELDS ( edulevel ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobedu_set).

    " Find if Education Level exists
     LOOP AT jobedu_set INTO DATA(jobedu_select).
        SELECT COUNT( * ) FROM zi_read_edulevel_domain
        WHERE value_low = @jobedu_select-edulevel
        INTO @DATA(edulevel_count).

    " Raise message if Education Level does not exist
        IF edulevel_count = 0.
          APPEND VALUE #(  mykey = jobedu_select-mykey ) TO failed-jobeducation.
          APPEND VALUE #(  mykey = jobedu_select-mykey
                           %msg  = new_message_with_text( text     = 'Education Level does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-edulevel = if_abap_behv=>mk-on ) TO reported-jobeducation.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validatejob.

    " Read relevant Job ID data
    READ ENTITIES OF zi_jobedu IN LOCAL MODE
    ENTITY JobEducation
    FIELDS ( jobid ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobedu_set).

    " Find if Job ID exists
     LOOP AT jobedu_set INTO DATA(jobedu_select).
        SELECT COUNT( * ) FROM zi_job
        WHERE jobid = @jobedu_select-jobid
        INTO @DATA(jobid_count).

    " Raise message if Job ID does not exist
        IF jobid_count = 0.
          APPEND VALUE #(  mykey = jobedu_select-mykey ) TO failed-jobeducation.
          APPEND VALUE #(  mykey = jobedu_select-mykey
                           %msg  = new_message_with_text( text     = 'Job ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-jobid = if_abap_behv=>mk-on ) TO reported-jobeducation.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateUniqueIDs.

    " Read relevant IDs data
    READ ENTITIES OF zi_jobedu IN LOCAL MODE
    ENTITY JobEducation
    FIELDS ( jobid eduid ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobedu_set).

    " Check if the object is unique
     LOOP AT jobedu_set INTO DATA(jobedu_select).
        SELECT COUNT( * ) FROM zi_jobedu
        WHERE jobid = @jobedu_select-jobid
        AND eduid = @jobedu_select-eduid
        INTO @DATA(id_count).

        IF id_count <> 0.
          APPEND VALUE #(  mykey = jobedu_select-mykey ) TO failed-jobeducation.
          APPEND VALUE #(  mykey = jobedu_select-mykey
                           %msg  = new_message_with_text( text     = 'Object already exists.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-jobid = if_abap_behv=>mk-on
                           %element-eduid = if_abap_behv=>mk-on ) TO reported-jobeducation.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

ENDCLASS.
