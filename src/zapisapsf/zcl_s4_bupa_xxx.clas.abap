CLASS zcl_s4_bupa_xxx DEFINITION PUBLIC CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
ENDCLASS.



CLASS ZCL_S4_BUPA_XXX IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_cloud_destination(
             i_name = 'SalesForce_S4HC'
             i_authn_mode =  if_a4c_cp_service=>user_propagation
         ).

        cl_web_http_client_manager=>create_by_http_destination(
          EXPORTING
            i_destination = lo_destination
          RECEIVING
            r_client = DATA(lo_http_client)
        ).

**Relative service path**
        lo_http_client->get_http_request( )->set_uri_path( '/sap/opu/odata/sap/API_BUSINESS_PARTNER' ).
        lo_http_client->set_csrf_token( ).

        DATA(lo_client_proxy)  = cl_web_odata_client_factory=>create_v2_remote_proxy(
           iv_service_definition_name = 'ZS4_API_BUSINESS_PARTNER_002'
           io_http_client             = lo_http_client
           iv_relative_service_root   = '/sap/opu/odata/sap/API_BUSINESS_PARTNER' ).

**Entity set A_BUSINESSPARTNER in business partner integration service**
        DATA(lo_create_request) = lo_client_proxy->create_resource_for_entity_set('A_BUSINESSPARTNER')->create_request_for_create( ).

        DATA(lv_userid) = cl_abap_context_info=>get_user_technical_name( ).

        SELECT SINGLE *
        FROM i_businessuserbasic
            WITH PRIVILEGED ACCESS
        WHERE userid = @lv_userid INTO
        @DATA(ls_businessuser).

        IF sy-subrc <> 0.
          response->set_text( |Error retrieving business user { lv_userid }| ).
          RETURN.
        ENDIF.

        DATA(ls_bupa) = VALUE za_businesspartner(
          businesspartnercategory = '1'
          firstname = ls_businessuser-firstname
          lastname = ls_businessuser-lastname
        ).

        lo_create_request->set_business_data( ls_bupa ).

        DATA(lo_create_response) = lo_create_request->execute( ).
        lo_create_response->get_business_data( IMPORTING es_business_data = ls_bupa ).

        response->set_text( |Business partner { ls_bupa-businesspartner } was created| ).

      CATCH cx_root INTO DATA(lx_exception).
        response->set_text( lx_exception->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
