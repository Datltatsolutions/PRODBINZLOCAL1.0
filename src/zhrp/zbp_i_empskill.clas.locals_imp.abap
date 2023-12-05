CLASS lhc_EmpSkill DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateEmployee FOR VALIDATE ON SAVE
      IMPORTING keys FOR EmployeeSkill~validateEmployee.

    METHODS validateSkill FOR VALIDATE ON SAVE
      IMPORTING keys FOR EmployeeSkill~validateSkill.

    METHODS validateSkillLevel FOR VALIDATE ON SAVE
      IMPORTING keys FOR EmployeeSkill~validateSkillLevel.

    METHODS validateUniqueIDs FOR VALIDATE ON SAVE
      IMPORTING keys FOR EmployeeSkill~validateUniqueIDs.

ENDCLASS.

CLASS lhc_EmpSkill IMPLEMENTATION.

  METHOD validateEmployee.

    " Read relevant employee ID data
    READ ENTITIES OF zi_empskill IN LOCAL MODE
    ENTITY EmployeeSkill
    FIELDS ( empid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empskill_set).

    " Find if Employee ID exists
     LOOP AT empskill_set INTO DATA(empskill_select).
        SELECT COUNT( * ) FROM zi_employee
        WHERE empid = @empskill_select-empid
        INTO @DATA(empid_count).

    " Raise message if Employee ID does not exist
        IF empid_count = 0.
          APPEND VALUE #(  mykey = empskill_select-mykey ) TO failed-employeeskill.
          APPEND VALUE #(  mykey = empskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Employee ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empid = if_abap_behv=>mk-on ) TO reported-employeeskill.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateSkill.

    " Read relevant Skill ID data
    READ ENTITIES OF zi_empskill IN LOCAL MODE
    ENTITY EmployeeSkill
    FIELDS ( skillid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empskill_set).

    " Find if Skill ID exists
     LOOP AT empskill_set INTO DATA(empskill_select).
        SELECT COUNT( * ) FROM zi_skill
        WHERE skillid = @empskill_select-skillid
        INTO @DATA(skillid_count).

    " Raise message if Skill ID does not exist
        IF skillid_count = 0.
          APPEND VALUE #(  mykey = empskill_select-mykey ) TO failed-employeeskill.
          APPEND VALUE #(  mykey = empskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill ID does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-skillid = if_abap_behv=>mk-on ) TO reported-employeeskill.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateSkillLevel.

    " Read relevant skill level data
    READ ENTITIES OF zi_empskill IN LOCAL MODE
    ENTITY EmployeeSkill
    FIELDS ( empskilllevel ) WITH CORRESPONDING #( keys )
        RESULT DATA(empskill_set).

    " Find if skill level exists
     LOOP AT empskill_set INTO DATA(empskill_select).
        SELECT COUNT( * ) FROM zi_read_levelnum5_domain
        WHERE value_low = @empskill_select-empskilllevel
        INTO @DATA(skilllevel_count).

    " Raise message if skill level does not exist
        IF skilllevel_count = 0.
          APPEND VALUE #(  mykey = empskill_select-mykey ) TO failed-employeeskill.
          APPEND VALUE #(  mykey = empskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Skill level does not exist.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empskilllevel = if_abap_behv=>mk-on ) TO reported-employeeskill.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

  METHOD validateUniqueIDs.

    " Read relevant IDs data
    READ ENTITIES OF zi_empskill IN LOCAL MODE
    ENTITY EmployeeSkill
    FIELDS ( empid skillid ) WITH CORRESPONDING #( keys )
        RESULT DATA(empskill_set).

    " Check if the object is unique
     LOOP AT empskill_set INTO DATA(empskill_select).
        SELECT COUNT( * ) FROM zi_empskill
        WHERE empid = @empskill_select-empid
        AND skillid = @empskill_select-skillid
        INTO @DATA(id_count).

        IF id_count <> 0.
          APPEND VALUE #(  mykey = empskill_select-mykey ) TO failed-employeeskill.
          APPEND VALUE #(  mykey = empskill_select-mykey
                           %msg  = new_message_with_text( text     = 'Object already exists.'
                                                          severity = if_abap_behv_message=>severity-error )
                           %element-empid   = if_abap_behv=>mk-on
                           %element-skillid = if_abap_behv=>mk-on ) TO reported-employeeskill.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

ENDCLASS.
