CLASS lhc_employee DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validatecountry FOR VALIDATE ON SAVE
      IMPORTING keys FOR employee~validatecountry.

    METHODS validateemail FOR VALIDATE ON SAVE
      IMPORTING keys FOR employee~validateemail.

    METHODS validatedropdownfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR employee~validatedropdownfields.

    METHODS validatenumberfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR employee~validatenumberfields.

    METHODS validatenamefields FOR VALIDATE ON SAVE
      IMPORTING keys FOR employee~validatenamefields.

ENDCLASS.

CLASS lhc_employee IMPLEMENTATION.

  METHOD validatecountry.

    " Read relevant country data
    READ ENTITIES OF zi_employee IN LOCAL MODE
    ENTITY Employee
    FIELDS ( empcountry ) WITH CORRESPONDING #( keys )
        RESULT DATA(employee_set).

    " Find if Employee Country exists
    LOOP AT employee_set INTO DATA(employee_select).
        SELECT COUNT( * ) FROM I_Country
        WHERE Country = @employee_select-empcountry
        INTO @DATA(empcountry_count).

    " Raise message if Employee Country does not exist (search in I_Country)
        IF empcountry_count = 0.
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Country does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empcountry = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateemail.

    " Read relevant Employee email data
    READ ENTITIES OF zi_employee IN LOCAL MODE
    ENTITY Employee
    FIELDS ( empemail ) WITH CORRESPONDING #( keys )
        RESULT DATA(employee_set).

    " Validate email
    LOOP AT employee_set INTO DATA(employee_select).
        IF employee_select-empemail IS NOT INITIAL
        AND NOT matches( val = employee_select-empemail pcre = '^[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+$' ).
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Wrong email format.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empemail = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedropdownfields.

    " Read relevant dropdown data
    READ ENTITIES OF zi_employee IN LOCAL MODE
    ENTITY Employee
    FIELDS ( empgender empmarital emptitle empagreement ) WITH CORRESPONDING #( keys )
        RESULT DATA(employee_set).

    " Find if the selected fields exists
    " and raise message if the respective field does not match
     LOOP AT employee_set INTO DATA(employee_select).

    " Gender field
        SELECT COUNT( * ) FROM zi_read_gender_domain
        WHERE value_low = @employee_select-empgender
        INTO @DATA(empgender_count).

        IF empgender_count = 0 AND employee_select-empgender IS NOT INITIAL.
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Gender does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empgender = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Marital Status field
        SELECT COUNT( * ) FROM zi_read_marital_domain
        WHERE value_low = @employee_select-empmarital
        INTO @DATA(empmarital_count).

        IF empmarital_count = 0 AND employee_select-empmarital IS NOT INITIAL.
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Marital Status does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empmarital = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Title field
        SELECT COUNT( * ) FROM zi_read_title_domain
        WHERE value_low = @employee_select-emptitle
        INTO @DATA(emptitle_count).

        IF emptitle_count = 0 AND employee_select-emptitle IS NOT INITIAL.
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Title does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-emptitle = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Organizational Unit field
        SELECT COUNT( * ) FROM zi_read_orgunit_domain
        WHERE value_low = @employee_select-emporgunit
        INTO @DATA(emporgunit_count).

        IF emporgunit_count = 0 AND employee_select-emporgunit IS NOT INITIAL.
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Unit does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-emporgunit = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Work Agreement field
        SELECT COUNT( * ) FROM zi_read_agreement_domain
        WHERE value_low = @employee_select-empagreement
        INTO @DATA(empagreement_count).

        IF empagreement_count = 0 AND employee_select-empagreement IS NOT INITIAL.
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Work agreement does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empagreement = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validatenumberfields.

    " Read relevant number data
    READ ENTITIES OF zi_employee IN LOCAL MODE
    ENTITY Employee
    FIELDS ( emppersid empssn emphours empprivatephone empcommphone empmobilephone )
    WITH CORRESPONDING #( keys )
        RESULT DATA(employee_set).

    " Validate numbers
    LOOP AT employee_set INTO DATA(employee_select).

    " Validate Personal ID and Social Security Numbers
    " Personal ID
        IF NOT matches( val = employee_select-emppersid pcre = '^\d{8,12}$' ).
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Wrong personal ID format.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-emppersid = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Social Security Number
        IF employee_select-empssn IS NOT INITIAL
        AND NOT matches( val = employee_select-empssn pcre = '^\d{8,12}$' ).
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Wrong SSN format.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empssn = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Agreed Working Hours (working hours can only be in range of 30 to 48)
        IF employee_select-emphours IS NOT INITIAL
        AND employee_select-emphours < 30 OR employee_select-emphours > 48.
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Working hours must be from 30 to 48.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-emphours = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Validate phone numbers
    " Private Data - Phone
        IF employee_select-empprivatephone IS NOT INITIAL
        AND NOT matches( val = employee_select-empprivatephone pcre = '^([+]\d{10,14}|\d{9,12})$' ).
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Wrong phone number format.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empprivatephone = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Communication Data - Phone
        IF employee_select-empcommphone IS NOT INITIAL
        AND NOT matches( val = employee_select-empcommphone pcre = '^([+]\d{10,14}|\d{9,12})$' ).
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Wrong phone number format.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empcommphone = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Mobile Phone
        IF employee_select-empmobilephone IS NOT INITIAL
        AND NOT matches( val = employee_select-empmobilephone pcre = '^([+]\d{10,14}|\d{9,12})$' ).
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Wrong phone number format.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empmobilephone = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateNameFields.

    " Read relevant name data
    READ ENTITIES OF zi_employee IN LOCAL MODE
    ENTITY Employee
    FIELDS ( empfirstname emplastname )
    WITH CORRESPONDING #( keys )
        RESULT DATA(employee_set).

    " Validate name fields
    LOOP AT employee_set INTO DATA(employee_select).

    " Validate First Name and Last Name fields
    " First Name (may contains special characters and spaces, no digits)
        IF NOT matches( val = employee_select-empfirstname pcre = '^[^\d]*$' ).
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Wrong First Name format.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empfirstname = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    " Last Name (may contains special characters, no digits or spaces)
        IF NOT matches( val = employee_select-emplastname pcre = '^[^\d\s]*$' ).
          APPEND VALUE #(  empid = employee_select-empid ) TO failed-employee.
          APPEND VALUE #(  empid = employee_select-empid
                           %msg  = new_message_with_text( text     = 'Wrong Last Name format.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-emplastname = if_abap_behv=>mk-on ) TO reported-employee.
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
