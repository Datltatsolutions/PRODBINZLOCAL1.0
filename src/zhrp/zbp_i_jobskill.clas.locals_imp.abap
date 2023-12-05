CLASS lhc_jobskill DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validatejob FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobskill~validatejob.

    METHODS validatelevelfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobskill~validatelevelfields.

    METHODS validateskill FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobskill~validateskill.
    METHODS validateuniqueids FOR VALIDATE ON SAVE
      IMPORTING keys FOR jobskill~validateuniqueids.

ENDCLASS.

CLASS lhc_jobskill IMPLEMENTATION.

  METHOD validatejob.

    " Read relevant Job ID data
    READ ENTITIES OF zi_jobskill IN LOCAL MODE
    ENTITY JobSkill
    FIELDS ( jobid ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobskill_set).

    " Find if Job ID exists
     LOOP AT jobskill_set INTO DATA(jobskill_select).
        SELECT COUNT( * ) FROM zi_job
        WHERE jobid = @jobskill_select-jobid
        INTO @DATA(jobid_count).

    " Raise message if Job ID does not exist
        IF jobid_count = 0.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Job ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-jobid = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validatelevelfields.

    " Read relevant skill level data
    READ ENTITIES OF zi_jobskill IN LOCAL MODE
    ENTITY JobSkill
    FIELDS ( skilllevel skillcoefficient skilllevel1 skilllevel2
    skilllevel3 skilllevel4 skilllevel5 ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobskill_set).

    " Validate skill level fields
     LOOP AT jobskill_set INTO DATA(jobskill_select).

    " Find if skill level exists
        SELECT COUNT( * ) FROM zi_read_levelnum5_domain
        WHERE value_low = @jobskill_select-skilllevel
        INTO @DATA(skilllevel_count).

    " Raise message if skill level does not exist
        IF skilllevel_count = 0.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill level does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-skilllevel = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

    " Check if skill coefficient is in range 1 to 5
        IF jobskill_select-skillcoefficient < 1 OR jobskill_select-skillcoefficient > 5.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill coefficient range is from 1 to 5.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-skillcoefficient = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

    " Check if skill levels are in percent range (0 to 100)
    " Skill level 1
        IF jobskill_select-skilllevel1 < 0 OR jobskill_select-skilllevel1 > 100.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill level range is from 0 to 100.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-skilllevel1 = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

    " Skill level 2
        IF jobskill_select-skilllevel2 < 0 OR jobskill_select-skilllevel2 > 100.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill level range is from 0 to 100.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-skilllevel2 = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

    " Skill level 3
        IF jobskill_select-skilllevel3 < 0 OR jobskill_select-skilllevel3 > 100.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill level range is from 0 to 100.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-skilllevel3 = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

    " Skill level 4
        IF jobskill_select-skilllevel4 < 0 OR jobskill_select-skilllevel4 > 100.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill level range is from 0 to 100.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-skilllevel4 = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

    " Skill level 5
        IF jobskill_select-skilllevel5 < 0 OR jobskill_select-skilllevel5 > 100.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill level range is from 0 to 100.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-skilllevel5 = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateskill.

    " Read relevant Skill ID data
    READ ENTITIES OF zi_jobskill IN LOCAL MODE
    ENTITY JobSkill
    FIELDS ( skillid ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobskill_set).

    " Find if Skill ID exists
     LOOP AT jobskill_set INTO DATA(jobskill_select).
        SELECT COUNT( * ) FROM zi_skill
        WHERE skillid = @jobskill_select-skillid
        INTO @DATA(skillid_count).

    " Raise message if Skill ID does not exist
        IF skillid_count = 0.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-skillid = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateUniqueIDs.

    " Read relevant IDs data
    READ ENTITIES OF zi_jobskill IN LOCAL MODE
    ENTITY JobSkill
    FIELDS ( jobid skillid ) WITH CORRESPONDING #( keys )
        RESULT DATA(jobskill_set).

    " Check if the object is unique
     LOOP AT jobskill_set INTO DATA(jobskill_select).
        SELECT COUNT( * ) FROM zi_jobskill
        WHERE jobid = @jobskill_select-jobid
        AND skillid = @jobskill_select-skillid
        INTO @DATA(id_count).

        IF id_count <> 0.
          APPEND VALUE #(  mykey = jobskill_select-mykey ) TO failed-jobskill.
          APPEND VALUE #(  mykey = jobskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Object already exists.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-jobid   = if_abap_behv=>mk-on
                           %element-skillid = if_abap_behv=>mk-on ) TO reported-jobskill.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

ENDCLASS.
