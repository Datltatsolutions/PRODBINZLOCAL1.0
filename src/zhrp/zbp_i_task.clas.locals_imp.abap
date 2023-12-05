CLASS lsc_zi_task DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zi_task IMPLEMENTATION.

  METHOD adjust_numbers.
      DATA: tmp TYPE P.
      SELECT SINGLE FROM ztask FIELDS MAX( taskid ) INTO @DATA(lv_max_taskid).
      DATA(lv_new_key) = lv_max_taskid + 1.
        LOOP AT mapped-task REFERENCE INTO DATA(map).
            map->taskid = lv_new_key.

            " CONDENSE map->taskid

        ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_task DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculatekeytaskid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR task~calculatekeytaskid.




ENDCLASS.

CLASS lhc_task IMPLEMENTATION.

  METHOD calculatekeytaskid.
  ENDMETHOD.


ENDCLASS.
