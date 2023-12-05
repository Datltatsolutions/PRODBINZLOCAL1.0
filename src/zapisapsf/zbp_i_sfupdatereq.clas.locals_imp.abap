CLASS lhc_sfupdatereq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR sfupdatereq RESULT result.

    METHODS approverequest FOR MODIFY
      IMPORTING keys FOR ACTION sfupdatereq~approverequest RESULT result.

    METHODS setdefaultapprove FOR DETERMINE ON SAVE
      IMPORTING keys FOR sfupdatereq~setdefaultapprove.

ENDCLASS.

CLASS lhc_sfupdatereq IMPLEMENTATION.

  METHOD get_instance_features.

  "%control-<fieldname> specifies which fields are read from the entities

  READ ENTITY zi_sfupdatereq FROM VALUE #( FOR keyval IN keys
                                         ( %key = keyval-%key
                                           %control-checkapprove = if_abap_behv=>mk-on
                                         ) )
                             RESULT DATA(lt_sfrequest_result).

  result = VALUE #( FOR ls_sfrequest IN lt_sfrequest_result
                  ( %key                             = ls_sfrequest-%key
                    %features-%action-approverequest = COND #( WHEN ls_sfrequest-checkapprove = abap_true
                                                               THEN if_abap_behv=>fc-o-disabled
                                                               ELSE if_abap_behv=>fc-o-enabled
                                                             ) ) ).
  ENDMETHOD.

  METHOD approverequest.

  " Modify in local mode: BO-related updates that are not relevant for authorization checks

  MODIFY ENTITIES OF zi_sfupdatereq IN LOCAL MODE
         ENTITY sfupdatereq
         UPDATE FROM VALUE #( FOR key IN keys ( requestid             = key-requestid
                                                checkapprove          = abap_true
                                                %control-checkapprove = if_abap_behv=>mk-on
                                              ) )
         FAILED   failed
         REPORTED reported.

  " Read changed data for action result

  READ ENTITIES OF zi_sfupdatereq IN LOCAL MODE
        ENTITY sfupdatereq
        FROM VALUE #( FOR key IN keys ( requestid = key-requestid
                                        %control  = VALUE #(
                                                            requestdatetime = if_abap_behv=>mk-on
                                                            bodyrequest     = if_abap_behv=>mk-on
                                                            checkapprove    = if_abap_behv=>mk-on
                                                            approveemployee = if_abap_behv=>mk-on
                                                            approvedatetime = if_abap_behv=>mk-on
                                      ) ) )
        RESULT DATA(lt_sfrequest).

    result = VALUE #( FOR sfrequest IN lt_sfrequest ( requestid = sfrequest-requestid
                                                      %param    = sfrequest
                                                    ) ).
  ENDMETHOD.

  METHOD setdefaultapprove.
  ENDMETHOD.

ENDCLASS.
