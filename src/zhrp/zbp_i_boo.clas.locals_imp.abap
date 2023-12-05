CLASS lhc_boo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validatedropdownfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR boo~validatedropdownfields.

    METHODS validatejob FOR VALIDATE ON SAVE
      IMPORTING keys FOR boo~validatejob.
    METHODS validatedaysandhours FOR VALIDATE ON SAVE
      IMPORTING keys FOR boo~validatedaysandhours.

ENDCLASS.

CLASS lhc_boo IMPLEMENTATION.

  METHOD validatedropdownfields.

    " Read relevant dropdown data
    READ ENTITIES OF zi_boo IN LOCAL MODE
    ENTITY BOO
    FIELDS ( boounit bootype ) WITH CORRESPONDING #( keys )
        RESULT DATA(boo_set).

    " Find if the selected fields exists
    " and raise message if the respective field does not match
     LOOP AT boo_set INTO DATA(boo_select).

     " Unit field
        SELECT COUNT( * ) FROM zi_read_unit_domain
        WHERE value_low = @boo_select-boounit
        INTO @DATA(boounit_count).

        IF boounit_count = 0 AND boo_select-boounit IS NOT INITIAL.
          APPEND VALUE #(  mykey = boo_select-mykey ) TO failed-boo.
          APPEND VALUE #(  mykey = boo_select-mykey
                           %msg  = new_message_with_text( text     = 'Unit does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-boounit = if_abap_behv=>mk-on ) TO reported-boo.
        ENDIF.

     " Type field
        SELECT COUNT( * ) FROM zi_read_type_domain
        WHERE value_low = @boo_select-bootype
        INTO @DATA(bootype_count).

        IF bootype_count = 0 AND boo_select-bootype IS NOT INITIAL.
          APPEND VALUE #(  mykey = boo_select-mykey ) TO failed-boo.
          APPEND VALUE #(  mykey = boo_select-mykey
                           %msg  = new_message_with_text( text     = 'Type does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-bootype = if_abap_behv=>mk-on ) TO reported-boo.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validatejob.

    " Read relevant Job ID data
    READ ENTITIES OF zi_boo IN LOCAL MODE
    ENTITY BOO
    FIELDS ( boojob ) WITH CORRESPONDING #( keys )
        RESULT DATA(boo_set).

    " Find if Job ID exists
     LOOP AT boo_set INTO DATA(boo_select).
        SELECT COUNT( * ) FROM zi_job
        WHERE jobid = @boo_select-boojob
        INTO @DATA(boojob_count).

    " Raise message if Job ID does not exist
        IF boojob_count = 0.
          APPEND VALUE #(  mykey = boo_select-mykey ) TO failed-boo.
          APPEND VALUE #(  mykey = boo_select-mykey
                           %msg  = new_message_with_text( text     = 'Job ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-boojob = if_abap_behv=>mk-on ) TO reported-boo.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateDaysandHours.

    " Read relevant dropdown data
    READ ENTITIES OF zi_boo IN LOCAL MODE
    ENTITY BOO
    FIELDS ( booworkingtime booduration ) WITH CORRESPONDING #( keys )
        RESULT DATA(boo_set).

    " Validate working time and Duration fields
    " Check if they are not negative
     LOOP AT boo_set INTO DATA(boo_select).

    " Working time
     IF boo_select-booworkingtime < 0.
          APPEND VALUE #(  mykey = boo_select-mykey ) TO failed-boo.
          APPEND VALUE #(  mykey = boo_select-mykey
                           %msg  = new_message_with_text( text     = 'Working time must not be negative.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-booworkingtime = if_abap_behv=>mk-on ) TO reported-boo.
     ENDIF.

    " Duration
     IF boo_select-booduration < 0.
          APPEND VALUE #(  mykey = boo_select-mykey ) TO failed-boo.
          APPEND VALUE #(  mykey = boo_select-mykey
                           %msg  = new_message_with_text( text     = 'Duration must not be negative.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-booduration = if_abap_behv=>mk-on ) TO reported-boo.
     ENDIF.

   ENDLOOP.

  ENDMETHOD.

ENDCLASS.
