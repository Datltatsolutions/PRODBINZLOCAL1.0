CLASS lhc_EmpEdu DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR EmployeeEducation~validateDates.

    METHODS validateEducation FOR VALIDATE ON SAVE
      IMPORTING keys FOR EmployeeEducation~validateEducation.

    METHODS validateEmployee FOR VALIDATE ON SAVE
      IMPORTING keys FOR EmployeeEducation~validateEmployee.

    METHODS validateGrade FOR VALIDATE ON SAVE
      IMPORTING keys FOR EmployeeEducation~validateGrade.

    METHODS validateUniqueIDs FOR VALIDATE ON SAVE
      IMPORTING keys FOR EmployeeEducation~validateUniqueIDs.

    METHODS EmployeeNameUpdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR employeeEducation~EmployeeNameUpdate.
    METHODS EducationNameUpdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR EmployeeEducation~EducationNameUpdate.


ENDCLASS.

CLASS lhc_EmpEdu IMPLEMENTATION.

  METHOD validateDates.

    " Read relevant dates instance data
    READ ENTITIES OF zi_empedu IN LOCAL MODE
    ENTITY EmployeeEducation
    FIELDS ( empedustart empeduend ) WITH CORRESPONDING #( keys )
        RESULT DATA(empedu_set).

    " Check if end date is after start date
    LOOP AT empedu_set INTO DATA(empedu_select).
      IF empedu_select-empeduend <= empedu_select-empedustart.

       APPEND VALUE #( mykey = empedu_select-mykey ) TO failed-employeeeducation.

       APPEND VALUE #( mykey = empedu_select-mykey
                       %msg = new_message_with_text( text     = 'Start date must be before end date.'
                                                     severity = if_abap_behv_message=>severity-error )
                       %element-empedustart = if_abap_behv=>mk-on
                       %element-empeduend   = if_abap_behv=>mk-on ) TO reported-employeeeducation.

    " Check if start date is in the future
      ELSEIF empedu_select-empedustart > cl_abap_context_info=>get_system_date( ).

       APPEND VALUE #( mykey = empedu_select-mykey ) TO failed-employeeeducation.
       APPEND VALUE #( mykey = empedu_select-mykey
                        %msg = new_message_with_text( text     = 'Start date must not be after today.'
                                                      severity = if_abap_behv_message=>severity-error )
                        %element-empedustart = if_abap_behv=>mk-on ) TO reported-employeeeducation.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateEducation.

    " Read relevant employee ID data
    READ ENTITIES OF zi_empedu IN LOCAL MODE
    ENTITY EmployeeEducation
    FIELDS ( eduid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empedu_set).

    " Find if Education ID exists
     LOOP AT empedu_set INTO DATA(empedu_select).
        SELECT COUNT( * ) FROM zi_education
        WHERE eduid = @empedu_select-eduid
        INTO @DATA(eduid_count).

    " Raise message if Education ID does not exist
        IF eduid_count = 0.
          APPEND VALUE #(  mykey = empedu_select-mykey ) TO failed-employeeeducation.
          APPEND VALUE #(  mykey = empedu_select-mykey
                           %msg  = new_message_with_text( text     = 'Education ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-eduid = if_abap_behv=>mk-on ) TO reported-employeeeducation.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateEmployee.

    " Read relevant employee ID data
    READ ENTITIES OF zi_empedu IN LOCAL MODE
    ENTITY EmployeeEducation
    FIELDS ( empid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empedu_set).

    " Find if Employee ID exists
     LOOP AT empedu_set INTO DATA(empedu_select).
        SELECT COUNT( * ) FROM zi_employee
        WHERE empid = @empedu_select-empid
        INTO @DATA(empid_count).

    " Raise message if Employee ID does not exist
        IF empid_count = 0.
          APPEND VALUE #(  mykey = empedu_select-mykey ) TO failed-employeeeducation.
          APPEND VALUE #(  mykey = empedu_select-mykey
                           %msg  = new_message_with_text( text     = 'Employee ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empid = if_abap_behv=>mk-on ) TO reported-employeeeducation.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateGrade.

    " Read relevant dates instance data
    READ ENTITIES OF zi_empedu IN LOCAL MODE
    ENTITY EmployeeEducation
    FIELDS ( empedugrade ) WITH CORRESPONDING #( keys )
        RESULT DATA(empedu_set).

    " Check if grade is in correct range
    LOOP AT empedu_set INTO DATA(empedu_select).
      IF empedu_select-empedugrade < 0 OR empedu_select-empedugrade > 4.

       APPEND VALUE #( mykey = empedu_select-mykey ) TO failed-employeeeducation.

       APPEND VALUE #( mykey = empedu_select-mykey
                       %msg = new_message_with_text( text     = 'Grade must be in range of 0 to 4.'
                                                     severity = if_abap_behv_message=>severity-error )
                       %element-empedugrade = if_abap_behv=>mk-on ) TO reported-employeeeducation.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateUniqueIDs.

    " Read relevant IDs data
    READ ENTITIES OF zi_empedu IN LOCAL MODE
    ENTITY EmployeeEducation
    FIELDS ( empid eduid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empedu_set).

    " Check if the object is unique
     LOOP AT empedu_set INTO DATA(empedu_select).
        SELECT COUNT( * ) FROM zi_empedu
        WHERE empid = @empedu_select-empid
        AND eduid = @empedu_select-eduid
        INTO @DATA(id_count).

        IF id_count <> 0.
          APPEND VALUE #(  mykey = empedu_select-mykey ) TO failed-employeeeducation.
          APPEND VALUE #(  mykey = empedu_select-mykey
                           %msg  = new_message_with_text( text     = 'Object already exists.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empid = if_abap_behv=>mk-on
                           %element-eduid = if_abap_behv=>mk-on ) TO reported-employeeeducation.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

   METHOD employeenameupdate.
   " Read relevant IDs data
   DATA itab TYPE TABLE OF zi_employee.
    READ ENTITIES OF zi_empedu IN LOCAL MODE
    ENTITY EmployeeEducation
    FIELDS ( empid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empedu_set).

     LOOP AT empedu_set INTO DATA(empedu_select).
        SELECT * FROM zi_employee
        WHERE empid = @empedu_select-empid
        INTO TABLE @itab.
        LOOP AT itab INTO DATA(employee_select).

        MODIFY ENTITIES OF zi_empedu IN LOCAL MODE
                  ENTITY EmployeeEducation
                    UPDATE FIELDS ( empedunote )
                    WITH VALUE #( (
                                      %tky       = empedu_select-%tky
                                      empedunote = 'Mouse'
                                    ) ).
        ENDLOOP.
     ENDLOOP.







    READ ENTITIES OF zi_employee
    ENTITY Employee
    FIELDS ( empid ) WITH CORRESPONDING #( keys )
        RESULT DATA(employee_set).


   ENDMETHOD.

  METHOD EducationNameUpdate.
  ENDMETHOD.

ENDCLASS.
