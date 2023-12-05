CLASS lhc_empcert DEFINITION INHERITING FROM cl_abap_behavior_handler.

    PRIVATE SECTION.

      METHODS validate_employee FOR VALIDATE ON SAVE
        IMPORTING keys FOR EmployeeCertificate~validateEmployee.

      METHODS validate_certificate FOR VALIDATE ON SAVE
        IMPORTING keys FOR EmployeeCertificate~validateCertificate.

      METHODS validate_dates FOR VALIDATE ON SAVE
        IMPORTING keys FOR EmployeeCertificate~validateDates.

      METHODS validateUniqueIDs FOR VALIDATE ON SAVE
        IMPORTING keys FOR EmployeeCertificate~validateUniqueIDs.

 ENDCLASS.

CLASS lhc_empcert IMPLEMENTATION.

METHOD validate_employee.

    " Read relevant employee ID data
    READ ENTITIES OF zi_empcert IN LOCAL MODE
    ENTITY EmployeeCertificate
    FIELDS ( empid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empcert_set).

    " Find if Employee ID exists
     LOOP AT empcert_set INTO DATA(empcert_select).
        SELECT COUNT( * ) FROM zi_employee
        WHERE empid = @empcert_select-empid
        INTO @DATA(empid_count).

    " Raise message if Employee ID does not exist
        IF empid_count = 0.
          APPEND VALUE #(  mykey = empcert_select-mykey ) TO failed-employeecertificate.
          APPEND VALUE #(  mykey = empcert_select-mykey
                           %msg  = new_message_with_text( text     = 'Employee ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empid = if_abap_behv=>mk-on ) TO reported-employeecertificate.
        ENDIF.
      ENDLOOP.

ENDMETHOD.

METHOD validate_certificate.

    " Read relevant Certificate ID data
    READ ENTITIES OF zi_empcert IN LOCAL MODE
    ENTITY EmployeeCertificate
    FIELDS ( certid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empcert_set).

    " Find if Certificate ID exists
     LOOP AT empcert_set INTO DATA(empcert_select).
        SELECT COUNT( * ) FROM zi_certificate
        WHERE certid = @empcert_select-certid
        INTO @DATA(certid_count).

    " Raise message if Certificate ID does not exist
        IF certid_count = 0.
          APPEND VALUE #(  mykey = empcert_select-mykey ) TO failed-employeecertificate.
          APPEND VALUE #(  mykey = empcert_select-mykey
                           %msg  = new_message_with_text( text     = 'Certificate ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-certid = if_abap_behv=>mk-on ) TO reported-employeecertificate.
        ENDIF.
      ENDLOOP.

ENDMETHOD.

METHOD validate_dates.

    " Read relevant dates instance data
    READ ENTITIES OF zi_empcert IN LOCAL MODE
    ENTITY EmployeeCertificate
    FIELDS ( certid certstart certend ) WITH CORRESPONDING #( keys )
        RESULT DATA(empcert_set).

    " Validate date fields
    LOOP AT empcert_set INTO DATA(empcert_select).

    " Dates must not exist if certificate ID is empty
      IF empcert_select-certid IS INITIAL
      AND ( empcert_select-certstart IS NOT INITIAL
      OR empcert_select-certend IS NOT INITIAL ).

       APPEND VALUE #( mykey = empcert_select-mykey ) TO failed-employeecertificate.

       APPEND VALUE #( mykey = empcert_select-mykey
                       %msg = new_message_with_text( text     = 'Certificate must be filled first before dates.'
                                                     severity = if_abap_behv_message=>severity-error )
                       %element-certid = if_abap_behv=>mk-on ) TO reported-employeecertificate.

    " If start date exists but end date does not exist, raise an error
      ELSEIF empcert_select-certstart IS INITIAL
      AND empcert_select-certend IS NOT INITIAL.

       APPEND VALUE #( mykey = empcert_select-mykey ) TO failed-employeecertificate.

       APPEND VALUE #( mykey = empcert_select-mykey
                       %msg = new_message_with_text( text     = 'Start date exists but end date does not.'
                                                     severity = if_abap_behv_message=>severity-error )
                       %element-certstart = if_abap_behv=>mk-on
                       %element-certend   = if_abap_behv=>mk-on ) TO reported-employeecertificate.

    " Check if end date is after start date
      ELSEIF empcert_select-certstart IS NOT INITIAL
      AND empcert_select-certend IS NOT INITIAL
      AND empcert_select-certend <= empcert_select-certstart.

       APPEND VALUE #( mykey = empcert_select-mykey ) TO failed-employeecertificate.

       APPEND VALUE #( mykey = empcert_select-mykey
                       %msg = new_message_with_text( text     = 'Start date must be before end date.'
                                                     severity = if_abap_behv_message=>severity-error )
                       %element-certstart = if_abap_behv=>mk-on
                       %element-certend   = if_abap_behv=>mk-on ) TO reported-employeecertificate.

    " Check if start date is in the future
      ELSEIF empcert_select-certstart > cl_abap_context_info=>get_system_date( ).

       APPEND VALUE #( mykey = empcert_select-mykey ) TO failed-employeecertificate.
       APPEND VALUE #( mykey = empcert_select-mykey
                        %msg = new_message_with_text( text     = 'Start date must not be after today.'
                                                      severity = if_abap_behv_message=>severity-error )
                        %element-certstart = if_abap_behv=>mk-on ) TO reported-employeecertificate.
      ENDIF.

    ENDLOOP.

ENDMETHOD.

METHOD validateUniqueIDs.

    " Read relevant IDs data
    READ ENTITIES OF zi_empcert IN LOCAL MODE
    ENTITY EmployeeCertificate
    FIELDS ( empid certid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empcert_set).

    " Check if the object is unique
     LOOP AT empcert_set INTO DATA(empcert_select).
        SELECT COUNT( * ) FROM zi_empcert
        WHERE empid = @empcert_select-empid
        AND certid = @empcert_select-certid
        INTO @DATA(id_count).

        IF id_count <> 0.
          APPEND VALUE #(  mykey = empcert_select-mykey ) TO failed-employeecertificate.
          APPEND VALUE #(  mykey = empcert_select-mykey
                           %msg  = new_message_with_text( text     = 'Object already exists.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empid  = if_abap_behv=>mk-on
                           %element-certid = if_abap_behv=>mk-on ) TO reported-employeecertificate.
        ENDIF.

      ENDLOOP.

ENDMETHOD.

ENDCLASS.
