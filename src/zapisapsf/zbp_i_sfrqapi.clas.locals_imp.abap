CLASS lhc_salesforcerequestapi DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS updateauthtoken FOR DETERMINE ON SAVE
      IMPORTING keys FOR salesforcerequestapi~updateauthtoken.
    METHODS updatefirstname FOR DETERMINE ON MODIFY
      IMPORTING keys FOR salesforcerequestapi~updatefirstname.
    METHODS validatebusinesspartnerid FOR VALIDATE ON SAVE
      IMPORTING keys FOR salesforcerequestapi~validatebusinesspartnerid.
    METHODS setupdateauthtoken FOR MODIFY
      IMPORTING keys FOR ACTION salesforcerequestapi~setupdateauthtoken.


ENDCLASS.

CLASS lhc_salesforcerequestapi IMPLEMENTATION.

  METHOD updateauthtoken.
    TRY.
        "create http destination by url; API endpoint for API sandbox
      "DATA(pr_keys) = VALUE ZTSFRQAPI( businesspartnerid = KEYS[ 1 ]-businesspartnerid ).

        Data: sucess type if_web_http_response=>http_status,
              notAuth type if_web_http_response=>http_status,
              Update type if_web_http_response=>http_status,
              create type if_web_http_response=>http_status,
              businessPartnerID type string.
        "SET VALUE
        sucess-code = 200.
        create-code = 201.
        Update-code = 204.
        notAuth-code = 401.
        notAuth-reason = 'Unauthorized'.

        READ ENTITIES OF zi_sfrqapi IN LOCAL MODE
        ENTITY SalesForceRequestAPI
        FIELDS ( salesforceaccountid ) WITH CORRESPONDING #( keys )
        RESULT DATA(sfrqapi_result).

        LOOP AT sfrqapi_result INTO DATA(sfrqapi_select).
        IF sfrqapi_select-salesforceaccountid is INITIAL OR sfrqapi_select-salesforceaccountid = ''.
            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_Salesforce_AccountID'
                                %msg            = new_message_with_text( text     = 'Salesforce AccountID is initial.'
                               severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
           MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
            return.
        ENDIF.

        try.
            data(lo_http_destination) =
                 cl_http_destination_provider=>create_by_url( 'https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner?$top=1' ).
          catch cx_http_dest_provider_error.
            "handle exception
        endtry.
        "create HTTP client by destination
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

        "adding headers with API Key for API Sandbox
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        lo_web_http_request->set_header_fields( VALUE #(
        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
        (  name = 'Accept' value = 'application/json' )
        (  name = 'x-csrf-token' value = 'FETCH' )
         ) ).

        "set request method and execute request
        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>GET ).
        DATA(lv_response_status) = lo_web_http_response->get_status( )."GET RESPONSE STATUS


        IF lv_response_status = notAuth.
            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                            %state_area     = 'VALIDATE_AUTHORIZATION'
                            %msg            = new_message_with_text( text     = '401 Not Unauthorized. Check authToken'
                                                           severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
            sfrqapi_select-api_result = '401 Not Unauthorized. Check authToken'.
            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
              ENTITY SalesForceRequestAPI
                UPDATE FIELDS ( businesspartnerid api_result )
                WITH VALUE #( (
                                  %tky       = sfrqapi_select-%tky
                                  api_result = '400'
                                ) ).
            RETURN.
        ELSEIF lv_response_status-code <> sucess-code.
            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                            %state_area     = 'VALIDATE_ERROR'
                            %msg            = new_message_with_text( text     = |{ lv_response_status-code } - { lv_response_status-reason }|
                                                           severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
            DATA(lv_response_text) = lo_web_http_response->get_text( )."GET RESPONSE STATUS
            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
              ENTITY SalesForceRequestAPI
                UPDATE FIELDS ( businesspartnerid api_result )
                WITH VALUE #( (
                                  %tky       = sfrqapi_select-%tky
                                  api_result = '400'
                                ) ).
            RETURN.

        ENDIF.

        DATA(lv_response_x_csrf_token) = lo_web_http_response->get_header_field( 'x-csrf-token' ).
        DATA(lv_response_cookie_z91) = lo_web_http_response->get_cookie(
                                     i_name = 'SAP_SESSIONID_ZI3_100'
*                                     i_path = ``
                                   ).
        DATA(lv_response_cookie_usercontext) = lo_web_http_response->get_cookie(
         i_name = 'sap-usercontext'
*         i_path = ``
        ).

        SELECT Count( * ) FROM zi_sfrqapi WHERE salesforceaccountid = @sfrqapi_select-salesforceaccountid INTO @DATA(id_count).
        IF lv_response_x_csrf_token IS NOT INITIAL AND id_count > 0." BUSINESS PARTNER EXSIST
            DATA: BP_ID                         TYPE string,
                  BP_ADDRESS_ID_DEFAULT         TYPE string,
                  BP_ADDRESS_ID_SHIPTO          TYPE string,
                  BP_ADDRESS_ID_BILLTO          TYPE string,
                  BP_Personel                   TYPE string.
            SELECT * FROM zi_sfrqapi WHERE salesforceaccountid = @sfrqapi_select-salesforceaccountid INTO @DATA(Rec_recei).


            IF Rec_recei IS INITIAL.
                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                            %state_area     = 'VALIDATE_ERROR'
                            %msg            = new_message_with_text( text     = |Sales Force Account ID Not Found|
                                                           severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
                RETURN.
            ENDIF.
            BP_ID = Rec_recei-businesspartnerid.
            BP_ADDRESS_ID_DEFAULT = Rec_recei-register_addressid.
            BP_ADDRESS_ID_SHIPTO  = Rec_recei-shipto_addressid.
            BP_ADDRESS_ID_BILLTO  = Rec_recei-billto_addressid.

            if BP_ID is INITIAL.
                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                            %state_area     = 'VALIDATE_ERROR'
                            %msg            = new_message_with_text( text     = |Business Partner ID Not Found|
                                                           severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
                RETURN.
            ENDIF.

            DATA: bodyjson_update_1      TYPE string,
                  bodyjson_update_2      TYPE string,
                  bodyjson_update_3      TYPE string,
                  bodyjson_update_4      TYPE string,

                  bodyjson_create_2      TYPE string,
                  bodyjson_create_3      TYPE string,
                  bodyjson_create_4      TYPE string,

                  bodyjson_update_5      TYPE string,
                  bodyjson_update_6      TYPE string,
                  bodyjson_update_7      TYPE string,
                  bodyjson_update_8      TYPE string,
                  bodyjson_update_9      TYPE string,
                  bodyjson_update_10      TYPE string,
                  bodyjson_update_11      TYPE string,
                  bodyjson_update_12      TYPE string,
                  bodyjson_update_13      TYPE string,
                  bodyjson_update_14      TYPE string,
                  bodyjson_update_15      TYPE string,
                  bodyjson_update_16      TYPE string,
                  URL                     TYPE string.
                  if Rec_recei-is_contact = 'X'.
                      """""""""""""""""""""HEADER""""""""""""""""""""""""""""""
                      IF sfrqapi_select-firstname IS NOT INITIAL.
                        bodyjson_update_1 = |"FirstName": "{ sfrqapi_select-firstname }",|.
                      ENDIF.
                      IF sfrqapi_select-yy1_fatca_1_bus IS NOT INITIAL.
                        bodyjson_update_1 = bodyjson_update_1 && |"YY1_FATCA_2_bus":true,|.
                      ENDIF.
                      IF sfrqapi_select-lastname IS NOT INITIAL.
                        bodyjson_update_1 = bodyjson_update_1 && |"LastName":"{ sfrqapi_select-lastname }",|.
                      ENDIF.
                      IF bodyjson_update_1 IS NOT INITIAL.
                        bodyjson_update_1 = SUBSTRING( val = bodyjson_update_1 len = strlen( bodyjson_update_1 ) - 1 ).
                        bodyjson_update_1 = '{' && bodyjson_update_1 && '}'.
                      ENDIF.

                      IF Rec_recei-register_addressid IS NOT INITIAL.
                          try.
                            lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ Rec_recei-register_addressid }|
        && |')?$select=Person| ).
                          catch cx_http_dest_provider_error.
                            "handle exception
                          endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                        "set request method and execute request
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>GET ).
                        DATA(lv_response_status1) = lo_web_http_response->get_status( )."GET RESPONSE STATUS
                        DATA(lv_response_person) = lo_web_http_response->get_text( ).
                        TYPES:
                        BEGIN OF address_reg,
                          Person    TYPE string,
                        END OF address_reg,
                        BEGIN OF d_reg,
                          d    TYPE address_reg,
                        END OF d_reg.
                         DATA ls_osm_reg TYPE d_reg.

                        TRANSLATE lv_response_person TO LOWER CASE.
                          xco_cp_json=>data->from_string( lv_response_person )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm_reg ) ).

                          IF ls_osm_reg-d-person is not INITIAL.
                                BP_Personel = ls_osm_reg-d-person.
                          ENDIF.
                          """"""""""""""""PATH""""""""""""""""""""""""""""
                          IF sfrqapi_select-register_postalcode IS NOT INITIAL.
                            bodyjson_update_2 = |"PostalCode":"{ sfrqapi_select-register_postalcode }",|.
                          ENDIF.
                          IF sfrqapi_select-register_country IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"Country":"{ sfrqapi_select-register_country }",|.
                          ENDIF.
                          IF sfrqapi_select-register_cityname IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"CityName":"{ sfrqapi_select-register_cityname }",|.
                          ENDIF.
                          IF sfrqapi_select-register_state IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"Region":"{ sfrqapi_select-register_state }",|.
                          ENDIF.
                          IF sfrqapi_select-Register_Streetname IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"StreetName":"{ sfrqapi_select-Register_Streetname }",|.
                          ENDIF.
                          IF sfrqapi_select-Register_StreetPrefixName IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"StreetPrefixName":"{ sfrqapi_select-Register_StreetPrefixName }",|.
                          ENDIF.
                          IF sfrqapi_select-Register_StreetSuffixName IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"StreetSuffixName":"{ sfrqapi_select-Register_StreetSuffixName }",|.
                          ENDIF.
                          IF sfrqapi_select-language IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"Language":"{ sfrqapi_select-language }",|.
                          ENDIF.


                          """""""""""""""""END UPDATE 2"""""""""""""""""""""""""""
                          IF bodyjson_update_2 IS NOT INITIAL.
                            bodyjson_update_2 = SUBSTRING( val = bodyjson_update_2 len = strlen( bodyjson_update_2 ) - 1 ).
                            bodyjson_update_2 = '{' && bodyjson_update_2 && '}'.
                          ENDIF.
                      ELSE.
                          """""""""""""""""POST"""""""""""""""""""""""""""
                          IF sfrqapi_select-register_country IS NOT INITIAL.
                              IF sfrqapi_select-register_postalcode IS NOT INITIAL.
                                bodyjson_update_2 = |"PostalCode":"{ sfrqapi_select-register_postalcode }",|.
                              ENDIF.
                              IF sfrqapi_select-register_country IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"Country":"{ sfrqapi_select-register_country }",|.
                              ENDIF.
                              IF sfrqapi_select-register_cityname IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"CityName":"{ sfrqapi_select-register_cityname }",|.
                              ENDIF.
                              IF sfrqapi_select-register_state IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"Region":"{ sfrqapi_select-register_state }",|.
                              ENDIF.
                              IF sfrqapi_select-Register_Streetname IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"StreetName":"{ sfrqapi_select-Register_Streetname }",|.
                              ENDIF.
                              IF sfrqapi_select-Register_StreetPrefixName IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"StreetPrefixName":"{ sfrqapi_select-Register_StreetPrefixName }",|.
                              ENDIF.
                              IF sfrqapi_select-Register_StreetSuffixName IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"StreetSuffixName":"{ sfrqapi_select-Register_StreetSuffixName }",|.
                              ENDIF.
                              IF sfrqapi_select-language IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"Language":"{ sfrqapi_select-language }",|.
                              else.
                                bodyjson_update_2 = bodyjson_update_2 && |"Language":"{ rec_recei-language }",|.
                              ENDIF.

                              """""""""""""""""""""PHONE""""""""""""""""""""""""""
                                if sfrqapi_select-destinationlocationcountry is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ rec_recei-destinationlocationcountry }",|.
                                ENDIF.
                                if sfrqapi_select-isdefaultphonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":false,|.
                                ENDIF.
                                if sfrqapi_select-phonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ sfrqapi_select-phonenumber }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ rec_recei-phonenumber }",|.
                                ENDIF.

                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = '"to_PhoneNumber": {"results": [{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""CELLPHONE""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-destinationlocationcountry is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ rec_recei-destinationlocationcountry }",|.
                                ENDIF.
                                if sfrqapi_select-isdefaultmobilephonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                else.
                                    if rec_recei-isdefaultmobilephonenumber is not INITIAL.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                    else.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":false,|.
                                    ENDIF.
                                ENDIF.
                                if sfrqapi_select-mobilephone is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ sfrqapi_select-mobilephone }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ rec_recei-mobilephone }",|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_MobilePhoneNumber":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""URL""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-websiteurl is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"WebsiteURL":"{ sfrqapi_select-websiteurl }",|.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultURLAddress": true,|.
                                ELSE.
                                    bodyjson_create_2 = bodyjson_create_2 && |"WebsiteURL":"{ rec_recei-websiteurl }",|.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultURLAddress": true,|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_URLAddress":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""EMAIL""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-emailaddress is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"EmailAddress":"{ sfrqapi_select-emailaddress }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"EmailAddress":"{ rec_recei-emailaddress }",|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_EmailAddress":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.



                              bodyjson_update_2 = bodyjson_update_2 && '"to_AddressUsage": {'."2
                              bodyjson_update_2 = bodyjson_update_2 && '"results": ['.        "3
                                bodyjson_update_2 = bodyjson_update_2 && '{'."4
                                    bodyjson_update_2 = bodyjson_update_2 && '"AddressUsage": "XXDEFAULT",'.
                                    bodyjson_update_2 = bodyjson_update_2 && '"StandardUsage": false'.
                                bodyjson_update_2 = bodyjson_update_2 && '}'."4
                            bodyjson_update_2 = bodyjson_update_2 && ']'."3
                            bodyjson_update_2 = bodyjson_update_2 && '},'."2
                            """""""""""""""""END UPDATE 2"""""""""""""""""""""""""""
                              IF bodyjson_update_2 IS NOT INITIAL.
                                if bodyjson_create_3 is not INITIAL.
                                    bodyjson_create_3 = SUBSTRING( val = bodyjson_create_3 len = strlen( bodyjson_create_3 ) - 1 ).
                                else.
                                    bodyjson_update_2 = SUBSTRING( val = bodyjson_update_2 len = strlen( bodyjson_update_2 ) - 1 ).
                                ENDIF.

                                bodyjson_update_2 = '{' && bodyjson_update_2 && bodyjson_create_3 && '}'.
                              ENDIF.
                        ENDIF.
                      ENDIF.

                    """""""""""""""""""""PHONE""""""""""""""""""""""""""
                    if sfrqapi_select-destinationlocationcountry is not INITIAL.
                        bodyjson_update_5 = bodyjson_update_5 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                    ENDIF.
                    if sfrqapi_select-isdefaultphonenumber is not INITIAL.
                        bodyjson_update_5 = bodyjson_update_5 && |"IsDefaultPhoneNumber":true,|.
                    ELSE.
                        bodyjson_update_5 = bodyjson_update_5 && |"IsDefaultPhoneNumber":false,|.
                    ENDIF.
                    if sfrqapi_select-phonenumber is not INITIAL.
                        bodyjson_update_5 = bodyjson_update_5 && |"PhoneNumber":"{ sfrqapi_select-phonenumber }",|.
                    ENDIF.

                    IF bodyjson_update_5 IS NOT INITIAL.
                        bodyjson_update_5 = SUBSTRING( val = bodyjson_update_5 len = strlen( bodyjson_update_5 ) - 1 ).
                        bodyjson_update_5 = '{' && bodyjson_update_5 && '}'.
                    ENDIF.

                    """""""""""""""""""""CELLPHONE""""""""""""""""""""""""""
                    if sfrqapi_select-destinationlocationcountry is not INITIAL.
                        bodyjson_update_6 = bodyjson_update_6 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                    ENDIF.
                    if sfrqapi_select-isdefaultmobilephonenumber is not INITIAL.
                        bodyjson_update_6 = bodyjson_update_6 && |"IsDefaultPhoneNumber":true,|.
                    else.
                        bodyjson_update_6 = bodyjson_update_6 && |"IsDefaultPhoneNumber":false,|.
                    ENDIF.
                    if sfrqapi_select-mobilephone is not INITIAL.
                        bodyjson_update_6 = bodyjson_update_6 && |"PhoneNumber":"{ sfrqapi_select-mobilephone }",|.
                    ENDIF.
                    IF bodyjson_update_6 IS NOT INITIAL.
                        bodyjson_update_6 = SUBSTRING( val = bodyjson_update_6 len = strlen( bodyjson_update_6 ) - 1 ).
                        bodyjson_update_6 = '{' && bodyjson_update_6 && '}'.
                    ENDIF.

                    """""""""""""""""""""URL""""""""""""""""""""""""""
                    if sfrqapi_select-websiteurl is not INITIAL.
                        bodyjson_update_7 = bodyjson_update_7 && |"WebsiteURL":"{ sfrqapi_select-websiteurl }",|.
                        bodyjson_update_7 = bodyjson_update_7 && |"IsDefaultURLAddress":true,|.
                    ENDIF.
                    IF bodyjson_update_7 IS NOT INITIAL.
                        bodyjson_update_7 = SUBSTRING( val = bodyjson_update_7 len = strlen( bodyjson_update_7 ) - 1 ).
                        bodyjson_update_7 = '{' && bodyjson_update_7 && '}'.
                    ENDIF.

                    """""""""""""""""""""EMAIL""""""""""""""""""""""""""
                    if sfrqapi_select-emailaddress is not INITIAL.
                        bodyjson_update_8 = bodyjson_update_8 && |"EmailAddress":"{ sfrqapi_select-emailaddress }",|.
                    ENDIF.
                    IF bodyjson_update_8 IS NOT INITIAL.
                        bodyjson_update_8 = SUBSTRING( val = bodyjson_update_8 len = strlen( bodyjson_update_8 ) - 1 ).
                        bodyjson_update_8 = '{' && bodyjson_update_8 && '}'.
                    ENDIF.
                  ELSE.
                      """"""""""""""""""""""HEADER""""""""""""""""""""""""""
                      IF sfrqapi_select-organizationbpname1 IS NOT INITIAL.
                        bodyjson_update_1 = '"OrganizationBPName1":"' && sfrqapi_select-organizationbpname1 && '",'.
                      ENDIF.
                      IF sfrqapi_select-yy1_fatca_1_bus IS NOT INITIAL.
                        bodyjson_update_1 = bodyjson_update_1 && |"YY1_FATCA_2_bus":true,|.
                      ENDIF.

                      IF bodyjson_update_1 IS NOT INITIAL.
                        bodyjson_update_1 = SUBSTRING( val = bodyjson_update_1 len = strlen( bodyjson_update_1 ) - 1 ).
                        bodyjson_update_1 = '{ ' && bodyjson_update_1 && ' }'.
                      ENDIF.

                      """"""""""""""""""""ADDRESS-Register""""""""""""""""""""""""""""
                      IF Rec_recei-register_addressid IS NOT INITIAL.
                          """"""""""""""""PATH""""""""""""""""""""""""""""
                          IF sfrqapi_select-register_postalcode IS NOT INITIAL.
                            bodyjson_update_2 = |"PostalCode":"{ sfrqapi_select-register_postalcode }",|.
                          ENDIF.
                          IF sfrqapi_select-register_country IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"Country":"{ sfrqapi_select-register_country }",|.
                          ENDIF.
                          IF sfrqapi_select-register_cityname IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"CityName":"{ sfrqapi_select-register_cityname }",|.
                          ENDIF.
                          IF sfrqapi_select-register_state IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"Region":"{ sfrqapi_select-register_state }",|.
                          ENDIF.
                          IF sfrqapi_select-Register_Streetname IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"StreetName":"{ sfrqapi_select-Register_Streetname }",|.
                          ENDIF.
                          IF sfrqapi_select-Register_StreetPrefixName IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"StreetPrefixName":"{ sfrqapi_select-Register_StreetPrefixName }",|.
                          ENDIF.
                          IF sfrqapi_select-Register_StreetSuffixName IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"StreetSuffixName":"{ sfrqapi_select-Register_StreetSuffixName }",|.
                          ENDIF.
                          IF sfrqapi_select-language IS NOT INITIAL.
                            bodyjson_update_2 = bodyjson_update_2 && |"Language":"{ sfrqapi_select-language }",|.
                          ENDIF.


                          """""""""""""""""END UPDATE 2"""""""""""""""""""""""""""
                          IF bodyjson_update_2 IS NOT INITIAL.
                            bodyjson_update_2 = SUBSTRING( val = bodyjson_update_2 len = strlen( bodyjson_update_2 ) - 1 ).
                            bodyjson_update_2 = '{' && bodyjson_update_2 && '}'.
                          ENDIF.
                      ELSE.
                          """""""""""""""""POST"""""""""""""""""""""""""""
                          IF sfrqapi_select-register_country IS NOT INITIAL.
                              IF sfrqapi_select-register_postalcode IS NOT INITIAL.
                                bodyjson_update_2 = |"PostalCode":"{ sfrqapi_select-register_postalcode }",|.
                              ENDIF.
                              IF sfrqapi_select-register_country IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"Country":"{ sfrqapi_select-register_country }",|.
                              ENDIF.
                              IF sfrqapi_select-register_cityname IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"CityName":"{ sfrqapi_select-register_cityname }",|.
                              ENDIF.
                              IF sfrqapi_select-register_state IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"Region":"{ sfrqapi_select-register_state }",|.
                              ENDIF.
                              IF sfrqapi_select-Register_Streetname IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"StreetName":"{ sfrqapi_select-Register_Streetname }",|.
                              ENDIF.
                              IF sfrqapi_select-Register_StreetPrefixName IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"StreetPrefixName":"{ sfrqapi_select-Register_StreetPrefixName }",|.
                              ENDIF.
                              IF sfrqapi_select-Register_StreetSuffixName IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"StreetSuffixName":"{ sfrqapi_select-Register_StreetSuffixName }",|.
                              ENDIF.
                              IF sfrqapi_select-language IS NOT INITIAL.
                                bodyjson_update_2 = bodyjson_update_2 && |"Language":"{ sfrqapi_select-language }",|.
                              else.
                                bodyjson_update_2 = bodyjson_update_2 && |"Language":"{ rec_recei-language }",|.
                              ENDIF.

                              """""""""""""""""""""PHONE""""""""""""""""""""""""""
                                if sfrqapi_select-destinationlocationcountry is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ rec_recei-destinationlocationcountry }",|.
                                ENDIF.
                                if sfrqapi_select-isdefaultphonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":false,|.
                                ENDIF.
                                if sfrqapi_select-phonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ sfrqapi_select-phonenumber }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ rec_recei-phonenumber }",|.
                                ENDIF.

                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = '"to_PhoneNumber": {"results": [{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""CELLPHONE""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-destinationlocationcountry is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ rec_recei-destinationlocationcountry }",|.
                                ENDIF.
                                if sfrqapi_select-isdefaultmobilephonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                else.
                                    if rec_recei-isdefaultmobilephonenumber is not INITIAL.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                    else.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":false,|.
                                    ENDIF.
                                ENDIF.
                                if sfrqapi_select-mobilephone is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ sfrqapi_select-mobilephone }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ rec_recei-mobilephone }",|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_MobilePhoneNumber":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""URL""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-websiteurl is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"WebsiteURL":"{ sfrqapi_select-websiteurl }",|.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultURLAddress": true,|.
                                ELSE.
                                    bodyjson_create_2 = bodyjson_create_2 && |"WebsiteURL":"{ rec_recei-websiteurl }",|.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultURLAddress": true,|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_URLAddress":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""EMAIL""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-emailaddress is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"EmailAddress":"{ sfrqapi_select-emailaddress }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"EmailAddress":"{ rec_recei-emailaddress }",|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_EmailAddress":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.



                              bodyjson_update_2 = bodyjson_update_2 && '"to_AddressUsage": {'."2
                              bodyjson_update_2 = bodyjson_update_2 && '"results": ['.        "3
                                bodyjson_update_2 = bodyjson_update_2 && '{'."4
                                    bodyjson_update_2 = bodyjson_update_2 && '"AddressUsage": "XXDEFAULT",'.
                                    bodyjson_update_2 = bodyjson_update_2 && '"StandardUsage": false'.
                                bodyjson_update_2 = bodyjson_update_2 && '}'."4
                            bodyjson_update_2 = bodyjson_update_2 && ']'."3
                            bodyjson_update_2 = bodyjson_update_2 && '},'."2
                            """""""""""""""""END UPDATE 2"""""""""""""""""""""""""""
                              IF bodyjson_update_2 IS NOT INITIAL.
                                if bodyjson_create_3 is not INITIAL.
                                    bodyjson_create_3 = SUBSTRING( val = bodyjson_create_3 len = strlen( bodyjson_create_3 ) - 1 ).
                                else.
                                    bodyjson_update_2 = SUBSTRING( val = bodyjson_update_2 len = strlen( bodyjson_update_2 ) - 1 ).
                                ENDIF.

                                bodyjson_update_2 = '{' && bodyjson_update_2 && bodyjson_create_3 && '}'.
                              ENDIF.
                        ENDIF.
                      ENDIF.


                      """"""""""""""""""""ADDRESS-Billto""""""""""""""""""""""""""""
                      IF Rec_recei-billto_addressid IS NOT INITIAL.
                          """"""""""""""""PATH""""""""""""""""""""""""""""
                          IF sfrqapi_select-billto_postalcode IS NOT INITIAL.
                            bodyjson_update_3 = |"PostalCode":"{ sfrqapi_select-billto_postalcode }",|.
                          ENDIF.
                          IF sfrqapi_select-billto_country IS NOT INITIAL.
                            bodyjson_update_3 = bodyjson_update_3 && |"Country":"{ sfrqapi_select-billto_country }",|.
                          ENDIF.
                          IF sfrqapi_select-billto_cityname IS NOT INITIAL.
                            bodyjson_update_3 = bodyjson_update_3 && |"CityName":"{ sfrqapi_select-billto_cityname }",|.
                          ENDIF.
                          IF sfrqapi_select-billto_state IS NOT INITIAL.
                            bodyjson_update_3 = bodyjson_update_3 && |"Region":"{ sfrqapi_select-billto_state }",|.
                          ENDIF.
                          IF sfrqapi_select-billto_Streetname IS NOT INITIAL.
                            bodyjson_update_3 = bodyjson_update_3 && |"StreetName":"{ sfrqapi_select-billto_Streetname }",|.
                          ENDIF.
                          IF sfrqapi_select-billto_StreetPrefixName IS NOT INITIAL.
                            bodyjson_update_3 = bodyjson_update_3 && |"StreetPrefixName":"{ sfrqapi_select-billto_StreetPrefixName }",|.
                          ENDIF.
                          IF sfrqapi_select-billto_StreetSuffixName IS NOT INITIAL.
                            bodyjson_update_3 = bodyjson_update_3 && |"StreetSuffixName":"{ sfrqapi_select-billto_StreetSuffixName }",|.
                          ENDIF.
                          IF sfrqapi_select-language IS NOT INITIAL.
                            bodyjson_update_3 = bodyjson_update_3 && |"Language":"{ sfrqapi_select-language }",|.
                          ENDIF.

                          """""""""""""""""END UPDATE 2"""""""""""""""""""""""""""
                          IF bodyjson_update_3 IS NOT INITIAL.
                            bodyjson_update_3 = SUBSTRING( val = bodyjson_update_3 len = strlen( bodyjson_update_3 ) - 1 ).
                            bodyjson_update_3 = '{' && bodyjson_update_3  && '}'.
                          ENDIF.
                      ELSE.
                          """""""""""""""""POST"""""""""""""""""""""""""""
                          IF sfrqapi_select-billto_country IS NOT INITIAL.
                              IF sfrqapi_select-billto_postalcode IS NOT INITIAL.
                                bodyjson_update_3 = |"PostalCode": "{ sfrqapi_select-billto_postalcode }",|.
                              ENDIF.
                              IF sfrqapi_select-billto_country IS NOT INITIAL.
                                bodyjson_update_3 = bodyjson_update_3 && |"Country":"{ sfrqapi_select-billto_country }",|.
                              ENDIF.
                              IF sfrqapi_select-billto_cityname IS NOT INITIAL.
                                bodyjson_update_3 = bodyjson_update_3 && |"CityName":"{ sfrqapi_select-billto_cityname }",|.
                              ENDIF.
                              IF sfrqapi_select-billto_state IS NOT INITIAL.
                                bodyjson_update_3 = bodyjson_update_3 && |"Region":"{ sfrqapi_select-billto_state }",|.
                              ENDIF.
                              IF sfrqapi_select-billto_Streetname IS NOT INITIAL.
                                bodyjson_update_3 = bodyjson_update_3 && |"StreetName":"{ sfrqapi_select-billto_Streetname }",|.
                              ENDIF.
                              IF sfrqapi_select-billto_StreetPrefixName IS NOT INITIAL.
                                bodyjson_update_3 = bodyjson_update_3 && |"StreetPrefixName":"{ sfrqapi_select-billto_StreetPrefixName }",|.
                              ENDIF.
                              IF sfrqapi_select-billto_StreetSuffixName IS NOT INITIAL.
                                bodyjson_update_3 = bodyjson_update_3 && |"StreetSuffixName":"{ sfrqapi_select-billto_StreetSuffixName }",|.
                              ENDIF.
                              IF sfrqapi_select-language IS NOT INITIAL.
                                bodyjson_update_3 = bodyjson_update_3 && |"Language":"{ sfrqapi_select-language }",|.
                              else.
                                bodyjson_update_3 = bodyjson_update_3 && |"Language":"{ rec_recei-language }",|.
                              ENDIF.
                              bodyjson_update_3 = bodyjson_update_3 && '"to_AddressUsage":{'."2
                              bodyjson_update_3 = bodyjson_update_3 && '"results": ['.        "3
                                bodyjson_update_3 = bodyjson_update_3 && '{'."4
                                    bodyjson_update_3 = bodyjson_update_3 && '"AddressUsage":"BILL_TO",'.
                                    bodyjson_update_3 = bodyjson_update_3 && '"StandardUsage":true'.
                                bodyjson_update_3 = bodyjson_update_3 && '}'."4
                            bodyjson_update_3 = bodyjson_update_3 && ']'."3
                            bodyjson_update_3 = bodyjson_update_3 && '},'."2

                             """""""""""""""""""""PHONE""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                bodyjson_create_3 = ''.
                                if sfrqapi_select-destinationlocationcountry is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ rec_recei-destinationlocationcountry }",|.
                                ENDIF.
                                if sfrqapi_select-isdefaultphonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                else.
                                    if rec_recei-isdefaultphonenumber is not INITIAL.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                    else.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":false,|.
                                    ENDIF.
                                ENDIF.
                                if sfrqapi_select-phonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ sfrqapi_select-phonenumber }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ rec_recei-phonenumber }",|.
                                ENDIF.

                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = '"to_PhoneNumber":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""CELLPHONE""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-destinationlocationcountry is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ rec_recei-destinationlocationcountry }",|.
                                ENDIF.
                                if sfrqapi_select-isdefaultmobilephonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                else.
                                    if rec_recei-isdefaultmobilephonenumber is not INITIAL.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                    else.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":false,|.
                                    ENDIF.
                                ENDIF.
                                if sfrqapi_select-mobilephone is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ sfrqapi_select-mobilephone }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ rec_recei-mobilephone }",|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_MobilePhoneNumber":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""URL""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-websiteurl is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"WebsiteURL":"{ sfrqapi_select-websiteurl }",|.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultURLAddress":true,|.
                                ELSE.
                                    bodyjson_create_2 = bodyjson_create_2 && |"WebsiteURL":"{ rec_recei-websiteurl }",|.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultURLAddress":true,|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_URLAddress":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""EMAIL""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-emailaddress is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"EmailAddress":"{ sfrqapi_select-emailaddress }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"EmailAddress":"{ rec_recei-emailaddress }",|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_EmailAddress":{"results": [{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                            IF bodyjson_update_3 IS NOT INITIAL.
                                "bodyjson_update_3 = SUBSTRING( val = bodyjson_update_3 len = strlen( bodyjson_update_3 ) - 1 ).
                                IF bodyjson_create_3 is INITIAL.
                                    bodyjson_update_3 = SUBSTRING( val = bodyjson_update_3 len = strlen( bodyjson_update_3 ) - 1 ).
                                else.
                                    bodyjson_create_3 = SUBSTRING( val = bodyjson_create_3 len = strlen( bodyjson_create_3 ) - 1 ).
                                ENDIF.

                                bodyjson_update_3 = '{' && bodyjson_update_3 && bodyjson_create_3 && '}'.
                              ENDIF.
                        ENDIF.
                      ENDIF.



                      """"""""""""""""""""ADDRESS-shipto""""""""""""""""""""""""""""
                      IF Rec_recei-shipto_addressid IS NOT INITIAL.
                          """"""""""""""""PATH""""""""""""""""""""""""""""
                          IF sfrqapi_select-shipto_postalcode IS NOT INITIAL.
                            bodyjson_update_4 = |"PostalCode":"{ sfrqapi_select-shipto_postalcode }",|.
                          ENDIF.
                          IF sfrqapi_select-shipto_country IS NOT INITIAL.
                            bodyjson_update_4 = bodyjson_update_4 && |"Country":"{ sfrqapi_select-shipto_country }",|.
                          ENDIF.
                          IF sfrqapi_select-shipto_cityname IS NOT INITIAL.
                            bodyjson_update_4 = bodyjson_update_4 && |"CityName":"{ sfrqapi_select-shipto_cityname }",|.
                          ENDIF.
                          IF sfrqapi_select-shipto_state IS NOT INITIAL.
                            bodyjson_update_4 = bodyjson_update_4 && |"Region":"{ sfrqapi_select-shipto_state }",|.
                          ENDIF.
                          IF sfrqapi_select-language IS NOT INITIAL.
                            bodyjson_update_4 = bodyjson_update_4 && |"Language":"{ sfrqapi_select-language }",|.
                          ENDIF.
                          IF sfrqapi_select-shipto_Streetname IS NOT INITIAL.
                            bodyjson_update_4 = bodyjson_update_4 && |"StreetName":"{ sfrqapi_select-shipto_Streetname }",|.
                          ENDIF.
                          IF sfrqapi_select-shipto_StreetPrefixName IS NOT INITIAL.
                            bodyjson_update_4 = bodyjson_update_4 && |"StreetPrefixName":"{ sfrqapi_select-shipto_StreetPrefixName }",|.
                          ENDIF.
                          IF sfrqapi_select-shipto_StreetSuffixName IS NOT INITIAL.
                            bodyjson_update_4 = bodyjson_update_4 && |"StreetSuffixName":"{ sfrqapi_select-shipto_StreetSuffixName }",|.
                          ENDIF.

                          """""""""""""""""END UPDATE 2"""""""""""""""""""""""""""
                          IF bodyjson_update_4 IS NOT INITIAL.
                            bodyjson_update_4 = SUBSTRING( val = bodyjson_update_4 len = strlen( bodyjson_update_4 ) - 1 ).
                            bodyjson_update_4 = '{' && bodyjson_update_4 && bodyjson_create_3 && '}'.
                          ENDIF.


                      ELSE.
                          """""""""""""""""POST"""""""""""""""""""""""""""
                          IF sfrqapi_select-shipto_country IS NOT INITIAL.
                              IF sfrqapi_select-shipto_postalcode IS NOT INITIAL.
                                bodyjson_update_4 = |"PostalCode":"{ sfrqapi_select-shipto_postalcode }",|.
                              ENDIF.
                              IF sfrqapi_select-shipto_country IS NOT INITIAL.
                                bodyjson_update_4 = bodyjson_update_4 && |"Country":"{ sfrqapi_select-shipto_country }",|.
                              ENDIF.
                              IF sfrqapi_select-shipto_cityname IS NOT INITIAL.
                                bodyjson_update_4 = bodyjson_update_4 && |"CityName":"{ sfrqapi_select-shipto_cityname }",|.
                              ENDIF.
                              IF sfrqapi_select-shipto_state IS NOT INITIAL.
                                bodyjson_update_4 = bodyjson_update_4 && |"Region":"{ sfrqapi_select-shipto_state }",|.
                              ENDIF.
                              IF sfrqapi_select-shipto_Streetname IS NOT INITIAL.
                                bodyjson_update_4 = bodyjson_update_4 && |"StreetName":"{ sfrqapi_select-shipto_Streetname }",|.
                              ENDIF.
                              IF sfrqapi_select-shipto_StreetPrefixName IS NOT INITIAL.
                                bodyjson_update_4 = bodyjson_update_4 && |"StreetPrefixName":"{ sfrqapi_select-shipto_StreetPrefixName }",|.
                              ENDIF.
                              IF sfrqapi_select-language IS NOT INITIAL.
                                bodyjson_update_4 = bodyjson_update_4 && |"Language":"{ sfrqapi_select-language }",|.
                              else.
                                bodyjson_update_4 = bodyjson_update_4 && |"Language":"{ rec_recei-language }",|.
                              ENDIF.
                              IF sfrqapi_select-shipto_StreetSuffixName IS NOT INITIAL.
                                bodyjson_update_4 = bodyjson_update_4 && |"StreetSuffixName":"{ sfrqapi_select-shipto_StreetSuffixName }",|.
                              ENDIF.
                              bodyjson_update_4 = bodyjson_update_4 && '"to_AddressUsage":{'."2
                              bodyjson_update_4 = bodyjson_update_4 && '"results":['.        "3
                                bodyjson_update_4 = bodyjson_update_4 && '{'."4
                                    bodyjson_update_4 = bodyjson_update_4 && '"AddressUsage":"SHIP_TO",'.
                                    bodyjson_update_4 = bodyjson_update_4 && '"StandardUsage":true'.
                                bodyjson_update_4 = bodyjson_update_4 && '}'."4
                            bodyjson_update_4 = bodyjson_update_4 && ']'."3
                            bodyjson_update_4 = bodyjson_update_4 && '},'."2

                            """""""""""""""""""""PHONE""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                bodyjson_create_3 = ''.
                                if sfrqapi_select-destinationlocationcountry is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ rec_recei-destinationlocationcountry }",|.
                                ENDIF.
                                if sfrqapi_select-isdefaultphonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                else.
                                    if rec_recei-isdefaultphonenumber is not INITIAL.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                    else.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":false,|.
                                    ENDIF.
                                ENDIF.
                                if sfrqapi_select-phonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ sfrqapi_select-phonenumber }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ rec_recei-phonenumber }",|.
                                ENDIF.

                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = '"to_PhoneNumber":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""CELLPHONE""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-destinationlocationcountry is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"DestinationLocationCountry":"{ rec_recei-destinationlocationcountry }",|.
                                ENDIF.
                                if sfrqapi_select-isdefaultmobilephonenumber is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                else.
                                    if rec_recei-isdefaultmobilephonenumber is not INITIAL.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":true,|.
                                    else.
                                        bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultPhoneNumber":false,|.
                                    ENDIF.
                                ENDIF.
                                if sfrqapi_select-mobilephone is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ sfrqapi_select-mobilephone }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"PhoneNumber":"{ rec_recei-mobilephone }",|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_MobilePhoneNumber":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""URL""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-websiteurl is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"WebsiteURL":"{ sfrqapi_select-websiteurl }",|.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultURLAddress":true,|.
                                ELSE.
                                    bodyjson_create_2 = bodyjson_create_2 && |"WebsiteURL":"{ rec_recei-websiteurl }",|.
                                    bodyjson_create_2 = bodyjson_create_2 && |"IsDefaultURLAddress":true,|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_URLAddress":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                                """""""""""""""""""""EMAIL""""""""""""""""""""""""""
                                bodyjson_create_2 = ''.
                                if sfrqapi_select-emailaddress is not INITIAL.
                                    bodyjson_create_2 = bodyjson_create_2 && |"EmailAddress":"{ sfrqapi_select-emailaddress }",|.
                                else.
                                    bodyjson_create_2 = bodyjson_create_2 && |"EmailAddress":"{ rec_recei-emailaddress }",|.
                                ENDIF.
                                IF bodyjson_create_2 IS NOT INITIAL.
                                    bodyjson_create_2 = SUBSTRING( val = bodyjson_create_2 len = strlen( bodyjson_create_2 ) - 1 ).
                                    bodyjson_create_3 = bodyjson_create_3 && '"to_EmailAddress":{"results":[{' && bodyjson_create_2 && '}]},'.
                                ENDIF.

                            IF bodyjson_update_4 IS NOT INITIAL.
                                "bodyjson_update_4 = SUBSTRING( val = bodyjson_update_4 len = strlen( bodyjson_update_4 ) - 1 ).
                                if  bodyjson_create_3 is INITIAL.
                                    bodyjson_update_4 = SUBSTRING( val = bodyjson_update_4 len = strlen( bodyjson_update_4 ) - 1 ).
                                else.
                                    bodyjson_create_3 = SUBSTRING( val = bodyjson_create_3 len = strlen( bodyjson_create_3 ) - 1 ).
                                ENDIF.
                                bodyjson_update_4 = '{' && bodyjson_update_4 && bodyjson_create_3 && '}'.
                              ENDIF.
                        ENDIF.
                      ENDIF.

                      """""""""""""""""""""PHONE""""""""""""""""""""""""""
                        if sfrqapi_select-destinationlocationcountry is not INITIAL.
                            bodyjson_update_5 = bodyjson_update_5 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                        ENDIF.
                        if sfrqapi_select-isdefaultphonenumber is not INITIAL.
                            bodyjson_update_5 = bodyjson_update_5 && |"IsDefaultPhoneNumber":true,|.
                        ENDIF.
                        if sfrqapi_select-phonenumber is not INITIAL.
                            bodyjson_update_5 = bodyjson_update_5 && |"PhoneNumber":"{ sfrqapi_select-phonenumber }",|.
                        ENDIF.

                        IF bodyjson_update_5 IS NOT INITIAL.
                            bodyjson_update_5 = SUBSTRING( val = bodyjson_update_5 len = strlen( bodyjson_update_5 ) - 1 ).
                            bodyjson_update_5 = '{' && bodyjson_update_5 && '}'.
                        ENDIF.

                        """""""""""""""""""""CELLPHONE""""""""""""""""""""""""""
                        if sfrqapi_select-destinationlocationcountry is not INITIAL.
                            bodyjson_update_6 = bodyjson_update_6 && |"DestinationLocationCountry":"{ sfrqapi_select-destinationlocationcountry }",|.
                        ENDIF.
                        if sfrqapi_select-isdefaultmobilephonenumber is not INITIAL.
                            bodyjson_update_6 = bodyjson_update_6 && |"IsDefaultPhoneNumber":true,|.
                        ENDIF.
                        if sfrqapi_select-mobilephone is not INITIAL.
                            bodyjson_update_6 = bodyjson_update_6 && |"PhoneNumber":"{ sfrqapi_select-mobilephone }",|.
                        ENDIF.
                        IF bodyjson_update_6 IS NOT INITIAL.
                            bodyjson_update_6 = SUBSTRING( val = bodyjson_update_6 len = strlen( bodyjson_update_6 ) - 1 ).
                            bodyjson_update_6 = '{' && bodyjson_update_6 && '}'.
                        ENDIF.

                        """""""""""""""""""""URL""""""""""""""""""""""""""
                        if sfrqapi_select-websiteurl is not INITIAL.
                            bodyjson_update_7 = bodyjson_update_7 && |"WebsiteURL":"{ sfrqapi_select-websiteurl }",|.
                            bodyjson_update_7 = bodyjson_update_7 && |"IsDefaultURLAddress":true,|.
                        ENDIF.
                        IF bodyjson_update_7 IS NOT INITIAL.
                            bodyjson_update_7 = SUBSTRING( val = bodyjson_update_7 len = strlen( bodyjson_update_7 ) - 1 ).
                            bodyjson_update_7 = '{' && bodyjson_update_7 && '}'.
                        ENDIF.

                        """""""""""""""""""""EMAIL""""""""""""""""""""""""""
                        if sfrqapi_select-emailaddress is not INITIAL.
                            bodyjson_update_8 = bodyjson_update_8 && |"EmailAddress":"{ sfrqapi_select-emailaddress }",|.
                        ENDIF.
                        IF bodyjson_update_8 IS NOT INITIAL.
                            bodyjson_update_8 = SUBSTRING( val = bodyjson_update_8 len = strlen( bodyjson_update_8 ) - 1 ).
                            bodyjson_update_8 = '{' && bodyjson_update_8 && '}'.
                        ENDIF.


                     """"""""""""""""""TABLE CONTAINT DIFF"""""""""""""""""""""""""""
                     Types: begin of it_bcode_value_Division_DIFF,
                               Division type string,
                               end of it_bcode_value_Division_DIFF.
                        data: itab_Division type table of it_bcode_value_Division_DIFF.

                     Types: begin of it_bcode_value_Distribu_DIFF,
                               Distribution type string,
                               end of it_bcode_value_Distribu_DIFF.
                        data: itab_Distribution type table of it_bcode_value_Distribu_DIFF.

                     Types: begin of it_bcode_value_DIFF,
                               SalesOrg type string,
                               end of it_bcode_value_DIFF.
                        data: itab_SalesOrg type table of it_bcode_value_DIFF.


                     """""""""""""""""""""SalesArea_sfrqapi_select""""""""""""""""""""""""""
                     IF rec_recei-salesorganization is INITIAL and rec_recei-distributionchannel is INITIAL and rec_recei-division is INITIAL.
                         """""""""""""""""""""""""""""Division""""""""""""""""""""""""""""""""
                        data : it_bcode_value_Division1 type STANDARD TABLE OF string.
                        data : gv_bcode_value_Division1 type string ,
                               sep_Division1 type string value ';'.
                        gv_bcode_value_Division1 = sfrqapi_select-division.
                        FIELD-SYMBOLS : <sep_Division1> type any.

                        ASSIGN sep_Division1 TO <sep_Division1>.

                        SPLIT gv_bcode_value_Division1 AT <sep_Division1> INTO:
                        TABLE it_bcode_value_Division1 IN CHARACTER MODE.

                        """""""""""""""""""""""""""""Distribution""""""""""""""""""""""""""""""""
                        data : it_bcode_value_Distribution1 type STANDARD TABLE OF string.
                        data : gv_bcode_value_Distribution1 type string ,
                               sep_Distribution1 type string value ';'.
                        gv_bcode_value_Distribution1 = sfrqapi_select-distributionchannel.
                        FIELD-SYMBOLS : <sep_Distribution1> type any.

                        ASSIGN sep_Distribution1 TO <sep_Distribution1>.

                        SPLIT gv_bcode_value_Distribution1 AT <sep_Distribution1> INTO:
                        TABLE it_bcode_value_Distribution1 IN CHARACTER MODE.

                        """""""""""""""""""""""""""""SalesOrganization"""""""""""""""""""""""""""""""""""""""""
                        data : it_bcode_value1 type STANDARD TABLE OF string.
                        data : gv_bcode_value1 type string ,
                               sep1 type string value ';'.
                        gv_bcode_value1 = sfrqapi_select-salesorganization.
                        FIELD-SYMBOLS : <sep1> type any.

                        ASSIGN sep1 TO <sep1>.

                        SPLIT gv_bcode_value1 AT <sep1> INTO:
                        TABLE it_bcode_value1 IN CHARACTER MODE.
                    else.
                        """""""""""""""""""""SalesArea_rec_recei""""""""""""""""""""""""""
                        data : it_bcode_value_Division2 type STANDARD TABLE OF string.
                        data : gv_bcode_value_Division2 type string ,
                               sep_Division2 type string value ';'.
                        IF sfrqapi_select-division IS NOT INITIAL.
                            gv_bcode_value_Division2 = sfrqapi_select-division.
                        ELSE.
                            gv_bcode_value_Division2 = rec_recei-division.
                        ENDIF.
                        FIELD-SYMBOLS : <sep_Division2> type any.

                        ASSIGN sep_Division2 TO <sep_Division2>.

                        SPLIT gv_bcode_value_Division2 AT <sep_Division2> INTO:
                        TABLE it_bcode_value_Division2 IN CHARACTER MODE.

                        """""""""""""""""""""""""""""Distribution""""""""""""""""""""""""""""""""
                        data : it_bcode_value_Distribution2 type STANDARD TABLE OF string.
                        data : gv_bcode_value_Distribution2 type string ,
                               sep_Distribution2 type string value ';'.
                        IF sfrqapi_select-distributionchannel IS NOT INITIAL.
                            gv_bcode_value_Distribution2 = sfrqapi_select-distributionchannel.
                        ELSE.
                            gv_bcode_value_Distribution2 = rec_recei-distributionchannel.
                        ENDIF.
                        FIELD-SYMBOLS : <sep_Distribution2> type any.

                        ASSIGN sep_Distribution2 TO <sep_Distribution2>.

                        SPLIT gv_bcode_value_Distribution2 AT <sep_Distribution2> INTO:
                        TABLE it_bcode_value_Distribution2 IN CHARACTER MODE.

                        """""""""""""""""""""""""""""SalesOrganization"""""""""""""""""""""""""""""""""""""""""
                        data : it_bcode_value2 type STANDARD TABLE OF string.
                        data : gv_bcode_value2 type string ,
                               sep2 type string value ';'.
                        IF sfrqapi_select-salesorganization IS NOT INITIAL.
                            gv_bcode_value2 = sfrqapi_select-salesorganization.
                        ELSE.
                            gv_bcode_value2 = rec_recei-salesorganization.
                        ENDIF.
                        FIELD-SYMBOLS : <sep2> type any.

                        ASSIGN sep2 TO <sep2>.

                        SPLIT gv_bcode_value2 AT <sep2> INTO:
                        TABLE it_bcode_value2 IN CHARACTER MODE.
                     ENDIF.
                     """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

                     """""""""""""""""""""SalesArea-Tax""""""""""""""""""""""""""

                      """""""""""""""""""""CompanyCode""""""""""""""""""""""""""
                        IF  rec_recei-companycode is INITIAL.
                            if sfrqapi_select-companycode is not INITIAL.
                                bodyjson_update_13 = bodyjson_update_13 && |"CompanyCode":"{ sfrqapi_select-companycode }",|.
                            ENDIF.
                            if sfrqapi_select-reconciliationaccount is not INITIAL.
                                bodyjson_update_13 = bodyjson_update_13 && |"ReconciliationAccount":"{ sfrqapi_select-reconciliationaccount }",|.
                            ENDIF.
                            if sfrqapi_select-paymentterms is not INITIAL.
                                bodyjson_update_13 = bodyjson_update_13 && |"PaymentTerms":"{ sfrqapi_select-paymentterms }",|.
                            ENDIF.
                            IF bodyjson_update_13 IS NOT INITIAL.
                                bodyjson_update_13 = SUBSTRING( val = bodyjson_update_13 len = strlen( bodyjson_update_13 ) - 1 ).
                                bodyjson_update_13 = '{' + bodyjson_update_13 + '}'.
                            ENDIF.
                        else.
                            if sfrqapi_select-reconciliationaccount is not INITIAL.
                                bodyjson_update_13 = bodyjson_update_13 && |"ReconciliationAccount":"{ sfrqapi_select-reconciliationaccount }",|.
                            ENDIF.
                            if sfrqapi_select-paymentterms is not INITIAL.
                                bodyjson_update_13 = bodyjson_update_13 && |"PaymentTerms":"{ sfrqapi_select-paymentterms }",|.
                            ENDIF.
                            IF bodyjson_update_13 IS NOT INITIAL.
                                bodyjson_update_13 = SUBSTRING( val = bodyjson_update_13 len = strlen( bodyjson_update_13 ) - 1 ).
                                bodyjson_update_13 = '{' && bodyjson_update_13 && '}'.
                            ENDIF.
                        ENDIF.

                        """"""""""""""""""""""Industry """"""""""""""""""""""""
                        IF rec_recei-industrysector is INITIAL and rec_recei-industrysystemtype is INITIAL.
                            if sfrqapi_select-industrysector is not INITIAL.
                                bodyjson_update_14 = bodyjson_update_14 && |"IndustrySector":"{ sfrqapi_select-industrysector }",|.
                            ENDIF.
                            if sfrqapi_select-industrysystemtype is not INITIAL.
                                bodyjson_update_14 = bodyjson_update_14 && |"IndustrySystemType":"{ sfrqapi_select-industrysystemtype }",|.
                            ENDIF.
                            IF bodyjson_update_14 IS NOT INITIAL.
                                bodyjson_update_14 = SUBSTRING( val = bodyjson_update_14 len = strlen( bodyjson_update_14 ) - 1 ).
                                bodyjson_update_14 = '{' && bodyjson_update_14 && '}'.
                            ENDIF.
                        ENDIF.

                        """"""""""""""""""""""CustomerClassification""""""""""""""""""""""""

                        if sfrqapi_select-customerclassification is not INITIAL.
                            IF sfrqapi_select-customerclassification = 'Hot'.
                                bodyjson_update_15 = bodyjson_update_15 && |"CustomerClassification": "A",|.
                            ELSEIF sfrqapi_select-customerclassification = 'Warm'.
                                bodyjson_update_15 = bodyjson_update_15 && |"CustomerClassification": "B",|.
                            else.
                                bodyjson_update_15 = bodyjson_update_15 && |"CustomerClassification": "C",|.
                            ENDIF.
                        else.
                            IF rec_recei-customerclassification = 'Hot'.
                                bodyjson_update_15 = bodyjson_update_15 && |"CustomerClassification": "A",|.
                            ELSEIF sfrqapi_select-customerclassification = 'Warm'.
                                bodyjson_update_15 = bodyjson_update_15 && |"CustomerClassification": "B",|.
                            else.
                                bodyjson_update_15 = bodyjson_update_15 && |"CustomerClassification": "C",|.
                            ENDIF.
                        ENDIF.
                        IF bodyjson_update_15 IS NOT INITIAL.
                            bodyjson_update_15 = SUBSTRING( val = bodyjson_update_15 len = strlen( bodyjson_update_15 ) - 1 ).
                            bodyjson_update_15 = '{' && bodyjson_update_15 && '}'.
                        ENDIF.

                        if rec_recei-text is INITIAL AND sfrqapi_select-text IS NOT INITIAL.
                            bodyjson_update_16 = bodyjson_update_16 && |"Language":"VI",|.
                            bodyjson_update_16 = bodyjson_update_16 && |"LongTextID":"TX01",|.
                            bodyjson_update_16 = bodyjson_update_16 && |"LongText":"{ sfrqapi_select-text }",|.
                        elseIF rec_recei-text is NOT INITIAL AND sfrqapi_select-text IS NOT INITIAL.
                            bodyjson_update_16 = bodyjson_update_16 && |"LongText":"{ sfrqapi_select-text }",|.
                        ENDIF.
                        IF bodyjson_update_16 IS NOT INITIAL.
                            bodyjson_update_16 = SUBSTRING( val = bodyjson_update_16 len = strlen( bodyjson_update_16 ) - 1 ).
                            bodyjson_update_16 = '{' && bodyjson_update_16 && '}'.
                        ENDIF.

                  ENDIF.


                      """""""""""""""""""""""CALL HEADER""""""""""""""""""""""""""""""""""
                IF bodyjson_update_1 is not INITIAL.
                try.
                    try.
                        URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('{ bp_id }')|.
                        lo_http_destination =
                         cl_http_destination_provider=>create_by_url( URL ).
                    catch cx_http_dest_provider_error.
                    "handle exception
                    endtry.
                    "create HTTP client by destination
                    lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                    "adding headers with API Key for API Sandbox
                    lo_web_http_request = lo_web_http_client->get_http_request( ).
                    lo_web_http_request->delete_header_field( 'Authorization').
                    lo_web_http_request->delete_header_field( 'Accept').
                    lo_web_http_request->delete_header_field( 'x-csrf-token').
                    lo_web_http_request->set_header_fields( VALUE #(
                    (  name = 'DataServiceVersion' value = '2.0' )
                    (  name = 'Content-Type' value = 'application/json' )
                    (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                    (  name = 'Accept' value = 'application/json' )
                    (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                     ) ).
                    lo_web_http_request->set_cookie(
                      EXPORTING
                        i_name    = 'SAP_SESSIONID_ZI3_100'
                        i_value   = lv_response_cookie_z91-value
                    ).
                    lo_web_http_request->set_cookie(
                      EXPORTING
                        i_name    = 'sap-usercontext'
                        i_value   = lv_response_cookie_usercontext-value
                    ).
                lo_web_http_request->set_text( bodyjson_update_1 ).

                lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).

                lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                DATA(lv_response_1) = lo_web_http_response->get_text( ).

                IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.
                    TYPES:
                    BEGIN OF message1,
                      lang TYPE string,
                      value TYPE string,
                    END OF message1,

                    BEGIN OF ts_error1,
                      code TYPE string,
                      message TYPE message1,
                    END OF ts_error1,

                    BEGIN OF error1,
                      error TYPE ts_error1,
                    END OF error1.
                    DATA ls_osm1 TYPE error1.

                     xco_cp_json=>data->from_string( lv_response_1 )->apply( VALUE #(
                        ( xco_cp_json=>transformation->pascal_case_to_underscore )
                        ( xco_cp_json=>transformation->boolean_to_abap_bool )
                      ) )->write_to( REF #( ls_osm1 ) ).
                    IF ls_osm1-error is INITIAL.
                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                    %state_area     = 'VALIDATE_ERROR'
                                    %msg            = new_message_with_text( text = |{ lv_response_1 }|
                                    severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                    MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                      ENTITY SalesForceRequestAPI
                        UPDATE FIELDS ( businesspartnerid api_result )
                        WITH VALUE #( (
                                          %tky       = sfrqapi_select-%tky
                                          api_result = '400'
                                        ) ).
                    else.

                    APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                    %state_area     = 'VALIDATE_ERROR'
                                    %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                    severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                    MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                      ENTITY SalesForceRequestAPI
                        UPDATE FIELDS ( businesspartnerid api_result )
                        WITH VALUE #( (
                                          %tky       = sfrqapi_select-%tky
                                          api_result = '400'
                                        ) ).
                    ENDIF.
                    RETURN.
                ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.
                ENDIF.
                """"""""""""""""""""""""CALL ADDRESS_Register"""""""""""""""""""""""""""""""""
                IF  bodyjson_update_2 is not INITIAL.
                try.
                    try.
                        IF bp_address_id_default IS INITIAL.
                            URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('{ bp_id }')/to_BusinessPartnerAddress|.
                            lo_http_destination =
                             cl_http_destination_provider=>create_by_url( URL ).
                        ELSE.
                            URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_default }')|.
                            lo_http_destination =
                             cl_http_destination_provider=>create_by_url( URL ).
                        ENDIF.
                    catch cx_http_dest_provider_error.
                    "handle exception
                    endtry.
                    "create HTTP client by destination
                    lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                    "adding headers with API Key for API Sandbox
                    lo_web_http_request = lo_web_http_client->get_http_request( ).
                    lo_web_http_request->delete_header_field( 'Authorization').
                    lo_web_http_request->delete_header_field( 'Accept').
                    lo_web_http_request->delete_header_field( 'x-csrf-token').
                    lo_web_http_request->set_header_fields( VALUE #(
                    (  name = 'Content-Type' value = 'application/json' )
                    (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                    (  name = 'Accept' value = 'application/json' )
                    (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                     ) ).
                    lo_web_http_request->set_cookie(
                      EXPORTING
                        i_name    = 'SAP_SESSIONID_ZI3_100'
                        i_value   = lv_response_cookie_z91-value
                    ).
                    lo_web_http_request->set_cookie(
                      EXPORTING
                        i_name    = 'sap-usercontext'
                        i_value   = lv_response_cookie_usercontext-value
                    ).
                lo_web_http_request->set_text( bodyjson_update_2 ).
                IF bp_address_id_default IS INITIAL.
                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                ELSE.
                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                ENDIF.
                lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                DATA(lv_response_2) = lo_web_http_response->get_text( ).

                IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                     xco_cp_json=>data->from_string( lv_response_2 )->apply( VALUE #(
                        ( xco_cp_json=>transformation->pascal_case_to_underscore )
                        ( xco_cp_json=>transformation->boolean_to_abap_bool )
                      ) )->write_to( REF #( ls_osm1 ) ).
                    IF ls_osm1-error is INITIAL.
                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                    %state_area     = 'VALIDATE_ERROR'
                                    %msg            = new_message_with_text( text = |{ lv_response_2 }|
                                    severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                    MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                      ENTITY SalesForceRequestAPI
                        UPDATE FIELDS ( businesspartnerid api_result )
                        WITH VALUE #( (
                                          %tky       = sfrqapi_select-%tky
                                          api_result = '400'
                                        ) ).
                    else.

                    APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                    %state_area     = 'VALIDATE_ERROR'
                                    %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                    severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                    MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                      ENTITY SalesForceRequestAPI
                        UPDATE FIELDS ( businesspartnerid api_result )
                        WITH VALUE #( (
                                          %tky       = sfrqapi_select-%tky
                                          api_result = '400'
                                        ) ).
                    ENDIF.
                    RETURN.
                ENDIF.
                IF rec_recei-register_addressid IS INITIAL.
                TYPES:
                    BEGIN OF address_default,
                      AddressID    TYPE string,
                    END OF address_default,
                    BEGIN OF d_default,
                      d    TYPE address_default,
                    END OF d_default.
                     DATA ls_osm_default TYPE d_default.

                    TRANSLATE lv_response_2 TO LOWER CASE.
                      xco_cp_json=>data->from_string( lv_response_2 )->apply( VALUE #(
                        ( xco_cp_json=>transformation->pascal_case_to_underscore )
                        ( xco_cp_json=>transformation->boolean_to_abap_bool )
                      ) )->write_to( REF #( ls_osm_default ) ).

                      IF ls_osm_default-d-addressid is not INITIAL.
                      MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                  ENTITY SalesForceRequestAPI
                                    UPDATE FIELDS ( register_addressid )
                                    WITH VALUE #( (
                                                      %tky       = sfrqapi_select-%tky
                                                      register_addressid = ls_osm_default-d-addressid
                                                    ) ).
                        ENDIF.
                ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.
                ENDIF.


                if Rec_recei-is_contact <> 'X'. "NOT CONTACT
                    IF  bodyjson_update_3 is not INITIAL.
                    try.
                        try.
                            IF bp_address_id_billto IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('{ bp_id }')/to_BusinessPartnerAddress|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_billto }')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_3 ).
                    IF bp_address_id_billto IS INITIAL.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                    ELSE.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                    ENDIF.
                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    DATA(lv_response_3) = lo_web_http_response->get_text( ).
                    IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_3 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_3 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    IF rec_recei-billto_addressid IS INITIAL.
                    TYPES:
                        BEGIN OF address_billto,
                          AddressID    TYPE string,
                        END OF address_billto,
                        BEGIN OF d_billto,
                          d    TYPE address_billto,
                        END OF d_billto.
                         DATA ls_osm_billto TYPE d_billto.

                        TRANSLATE lv_response_3 TO LOWER CASE.
                          xco_cp_json=>data->from_string( lv_response_3 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm_billto ) ).

                          IF ls_osm_billto-d-addressid is not INITIAL.
                          MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                      ENTITY SalesForceRequestAPI
                                        UPDATE FIELDS ( billto_addressid )
                                        WITH VALUE #( (
                                                          %tky       = sfrqapi_select-%tky
                                                          billto_addressid = ls_osm_billto-d-addressid
                                                        ) ).
                            ENDIF.
                    ENDIF.
                            "bodyjson_update =
                    catch cx_http_dest_provider_error.
                        "handle exception
                    endtry.
                    ENDIF.


                    IF  bodyjson_update_4 is not INITIAL.
                    try.
                        try.
                            IF bp_address_id_shipto IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('{ bp_id }')/to_BusinessPartnerAddress|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_shipto }')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_4 ).
                    IF bp_address_id_shipto IS INITIAL.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                    ELSE.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                    ENDIF.
                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    DATA(lv_response_4) = lo_web_http_response->get_text( ).

                    IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_4 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_4 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    IF rec_recei-shipto_addressid IS INITIAL.
                    TYPES:
                        BEGIN OF address_shipto,
                          AddressID    TYPE string,
                        END OF address_shipto,
                        BEGIN OF d_shipto,
                          d    TYPE address_shipto,
                        END OF d_shipto.
                         DATA ls_osm_shipto TYPE d_shipto.

                        TRANSLATE lv_response_4 TO LOWER CASE.
                          xco_cp_json=>data->from_string( lv_response_4 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm_shipto ) ).

                          IF ls_osm_shipto-d-addressid is not INITIAL.
                          MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                      ENTITY SalesForceRequestAPI
                                        UPDATE FIELDS ( shipto_addressid )
                                        WITH VALUE #( (
                                                          %tky       = sfrqapi_select-%tky
                                                          shipto_addressid = ls_osm_shipto-d-addressid
                                                        ) ).
                            ENDIF.
                    ENDIF.
                            "bodyjson_update =
                    catch cx_http_dest_provider_error.
                        "handle exception
                    endtry.
                    ENDIF.
                ENDIF.

                IF  bodyjson_update_5 is not INITIAL.
                try.
                    IF bp_address_id_default IS NOT INITIAL.
                        try.
                            IF rec_recei-phonenumber IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_default }')/to_PhoneNumber|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID='{ bp_address_id_default }',Person='{ BP_Personel }',OrdinalNumber='1')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                        lo_web_http_request->set_text( bodyjson_update_5 ).
                        IF rec_recei-phonenumber IS INITIAL.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                        ELSE.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                        ENDIF.
                        lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                        DATA(lv_response_5) = lo_web_http_response->get_text( ).

                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                             xco_cp_json=>data->from_string( lv_response_5 )->apply( VALUE #(
                                ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                ( xco_cp_json=>transformation->boolean_to_abap_bool )
                              ) )->write_to( REF #( ls_osm1 ) ).
                            IF ls_osm1-error is INITIAL.
                                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ lv_response_5 }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            else.

                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |Register.{ ls_osm1-error-message-value }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            ENDIF.
                            RETURN.
                        ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                try.
                    IF bp_address_id_billto IS NOT INITIAL.
                        try.
                            IF rec_recei-phonenumber IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_billto }')/to_PhoneNumber|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID='{ bp_address_id_billto }',Person='{ BP_Personel }',OrdinalNumber='1')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                        lo_web_http_request->set_text( bodyjson_update_5 ).
                        IF rec_recei-phonenumber IS INITIAL.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                        ELSE.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                        ENDIF.
                        lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                        lv_response_5 = lo_web_http_response->get_text( ).

                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                             xco_cp_json=>data->from_string( lv_response_5 )->apply( VALUE #(
                                ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                ( xco_cp_json=>transformation->boolean_to_abap_bool )
                              ) )->write_to( REF #( ls_osm1 ) ).
                            IF ls_osm1-error is INITIAL.
                                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ lv_response_5 }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            else.

                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |BILL TO.{ ls_osm1-error-message-value }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            ENDIF.
                            RETURN.
                        ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                try.
                    IF bp_address_id_shipto IS NOT INITIAL.
                        try.
                            IF rec_recei-phonenumber IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_shipto }')/to_PhoneNumber|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID='{ bp_address_id_shipto }',Person='{ BP_Personel }',OrdinalNumber='1')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_5 ).
                    IF rec_recei-phonenumber IS INITIAL.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                    ELSE.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                    ENDIF.
                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    lv_response_5 = lo_web_http_response->get_text( ).
                    IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_5 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_5 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |SHIP TO.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.
                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                ENDIF.

                IF  bodyjson_update_6 is not INITIAL.
                try.
                    IF bp_address_id_default IS NOT INITIAL.
                        try.
                            IF rec_recei-mobilephone IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_default }')/to_MobilePhoneNumber|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID='{ bp_address_id_default }',Person='{ BP_Personel }',OrdinalNumber='2')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                        lo_web_http_request->set_text( bodyjson_update_6 ).
                        IF rec_recei-mobilephone IS INITIAL.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                        ELSE.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                        ENDIF.
                        lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                        DATA(lv_response_6) = lo_web_http_response->get_text( ).

                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_6 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_6 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |Register.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                try.
                    IF bp_address_id_billto IS NOT INITIAL.
                        try.
                            IF rec_recei-mobilephone IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_billto }')/to_MobilePhoneNumber|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID='{ bp_address_id_billto }',Person='{ BP_Personel }',OrdinalNumber='2')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                        lo_web_http_request->set_text( bodyjson_update_6 ).
                        IF rec_recei-mobilephone IS INITIAL.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                        ELSE.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                        ENDIF.
                        lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                        lv_response_6 = lo_web_http_response->get_text( ).

                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_6 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_6 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |BILL TO.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                try.
                    IF bp_address_id_shipto IS NOT INITIAL.
                        try.
                            IF rec_recei-mobilephone IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_shipto }')/to_MobilePhoneNumber|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID='{ bp_address_id_shipto }',Person='{ BP_Personel }',OrdinalNumber='2')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                        lo_web_http_request->set_text( bodyjson_update_6 ).
                        IF rec_recei-mobilephone IS INITIAL.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                        ELSE.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                        ENDIF.
                        lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                        lv_response_6 = lo_web_http_response->get_text( ).

                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_6 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_6 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |SHIP TO.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                ENDIF.


                IF  bodyjson_update_7 is not INITIAL.
                try.
                    IF bp_address_id_default IS NOT INITIAL.
                        try.
                            IF rec_recei-websiteurl IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_default }')/to_URLAddress|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressHomePageURL(AddressID='{ bp_address_id_default }',Person='{ BP_Personel }'|.
                                URL = URL && |,OrdinalNumber='1',ValidityStartDate=datetime'0001-01-01T00%3A00%3A00',IsDefaultURLAddress=true)|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                        lo_web_http_request->set_text( bodyjson_update_7 ).
                        IF rec_recei-websiteurl IS INITIAL.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                        ELSE.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                        ENDIF.
                        lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                        DATA(lv_response_7) = lo_web_http_response->get_text( ).

                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_7 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_7 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |Register.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                try.
                    IF bp_address_id_billto IS NOT INITIAL.
                        try.
                            IF rec_recei-websiteurl IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_billto }')/to_URLAddress|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressHomePageURL(AddressID='{ bp_address_id_billto }',Person='{ BP_Personel }'|.
                                URL = URL && |,OrdinalNumber='1',ValidityStartDate=datetime'0001-01-01T00%3A00%3A00',IsDefaultURLAddress=true)|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_7 ).
                    IF rec_recei-websiteurl IS INITIAL.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                    ELSE.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                    ENDIF.
                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    lv_response_7 = lo_web_http_response->get_text( ).
                    IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_7 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_7 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |BILL TO.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.
                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                try.
                    IF bp_address_id_shipto IS NOT INITIAL.
                        try.
                            IF rec_recei-websiteurl IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_shipto }')/to_URLAddress|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressHomePageURL(AddressID='{ bp_address_id_shipto }',Person='{ BP_Personel }'|.
                                URL = URL && |,OrdinalNumber='1',ValidityStartDate=datetime'0001-01-01T00%3A00%3A00',IsDefaultURLAddress=true)|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                        lo_web_http_request->set_text( bodyjson_update_7 ).
                        IF rec_recei-websiteurl IS INITIAL.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                        ELSE.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                        ENDIF.
                        lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                        lv_response_7 = lo_web_http_response->get_text( ).

                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_7 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_7 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |SHIP TO.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.


                ENDIF.

                IF  bodyjson_update_8 is not INITIAL.
                try.
                    IF bp_address_id_default IS NOT INITIAL.
                        try.
                            IF rec_recei-emailaddress IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_default }')/to_EmailAddress|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressEmailAddress(AddressID='{ bp_address_id_default }',Person='{ BP_Personel }',OrdinalNumber='1')| .
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                        lo_web_http_request->set_text( bodyjson_update_8 ).
                        IF rec_recei-emailaddress IS INITIAL.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                        ELSE.
                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                        ENDIF.
                        lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                        DATA(lv_response_8) = lo_web_http_response->get_text( ).

                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_8 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_8 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |Register.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                try.
                    IF bp_address_id_billto IS NOT INITIAL.
                        try.
                            IF rec_recei-emailaddress IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_billto }')/to_EmailAddress|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressEmailAddress(AddressID='{ bp_address_id_billto }',Person='{ BP_Personel }',OrdinalNumber='1')| .
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_8 ).
                    IF rec_recei-emailaddress IS INITIAL.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                    ELSE.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                    ENDIF.
                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    lv_response_8 = lo_web_http_response->get_text( ).

                    IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_8 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_8 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |BILL TO.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.

                try.
                    IF bp_address_id_shipto IS NOT INITIAL.
                        try.
                            IF rec_recei-emailaddress IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='{ bp_id }',AddressID='{ bp_address_id_shipto }')/to_EmailAddress|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressEmailAddress(AddressID='{ bp_address_id_shipto }',Person='{ BP_Personel }',OrdinalNumber='1')| .
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_8 ).
                    IF rec_recei-emailaddress IS INITIAL.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                    ELSE.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                    ENDIF.
                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    lv_response_8 = lo_web_http_response->get_text( ).

                    IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                         xco_cp_json=>data->from_string( lv_response_8 )->apply( VALUE #(
                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                          ) )->write_to( REF #( ls_osm1 ) ).
                        IF ls_osm1-error is INITIAL.
                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |{ lv_response_8 }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        else.

                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                        %state_area     = 'VALIDATE_ERROR'
                                        %msg            = new_message_with_text( text = |SHIP TO.{ ls_osm1-error-message-value }|
                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              api_result = '400'
                                            ) ).
                        ENDIF.
                        RETURN.
                    ENDIF.

                    ENDIF.
                        "bodyjson_update =
                catch cx_http_dest_provider_error.
                    "handle exception
                endtry.


                ENDIF.

                if Rec_recei-is_contact <> 'X'. "NOT CONTACT
                    IF rec_recei-salesorganization is INITIAL and rec_recei-distributionchannel is INITIAL and rec_recei-division is INITIAL." ONLY CREATE

                        LOOP AT it_bcode_value1 INTO DATA(sfrqapi_Each_salesorg_CRE).
                            LOOP AT it_bcode_value_Distribution1 INTO DATA(sfrqapi_Each_Distribution_CRE).
                                LOOP AT it_bcode_value_Division1 INTO DATA(sfrqapi_Each_Division1_CRE).
                                    URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer('{ bp_id }')/to_CustomerSalesArea|.
                                    lo_http_destination =
                                     cl_http_destination_provider=>create_by_url( URL ).

                                     lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                                    "adding headers with API Key for API Sandbox
                                    lo_web_http_request = lo_web_http_client->get_http_request( ).
                                    lo_web_http_request->delete_header_field( 'Authorization').
                                    lo_web_http_request->delete_header_field( 'Accept').
                                    lo_web_http_request->delete_header_field( 'x-csrf-token').
                                    lo_web_http_request->set_header_fields( VALUE #(
                                    (  name = 'Content-Type' value = 'application/json' )
                                    (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                                    (  name = 'Accept' value = 'application/json' )
                                    (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                                     ) ).
                                    lo_web_http_request->set_cookie(
                                      EXPORTING
                                        i_name    = 'SAP_SESSIONID_ZI3_100'
                                        i_value   = lv_response_cookie_z91-value
                                    ).
                                    lo_web_http_request->set_cookie(
                                      EXPORTING
                                        i_name    = 'sap-usercontext'
                                        i_value   = lv_response_cookie_usercontext-value
                                    ).
                                    bodyjson_update_11 = ''.
                                    bodyjson_update_11 = bodyjson_update_11 && |"SalesOrganization":"{ sfrqapi_Each_salesorg_CRE }",|.
                                    bodyjson_update_11 = bodyjson_update_11 && |"DistributionChannel":"{ sfrqapi_Each_Distribution_CRE }",|.
                                    bodyjson_update_11 = bodyjson_update_11 && |"Division":"{ sfrqapi_Each_Division1_CRE }",|.

                                    if sfrqapi_select-currency is not INITIAL.
                                        bodyjson_update_11 = bodyjson_update_11 && |"Currency":"{ sfrqapi_select-currency }",|.
                                    ELSE.
                                        bodyjson_update_11 = bodyjson_update_11 && |"Currency":"{ rec_recei-currency }",|.
                                    ENDIF.
                                    IF bodyjson_update_11 IS NOT INITIAL.
                                        bodyjson_update_11 = SUBSTRING( val = bodyjson_update_11 len = strlen( bodyjson_update_11 ) - 1 ).
                                        bodyjson_update_11 = '{' && bodyjson_update_11 && '}'.
                                    ENDIF.

                                lo_web_http_request->set_text( bodyjson_update_11 ).
                                IF rec_recei-salesorganization IS INITIAL and rec_recei-distributionchannel is INITIAL and rec_recei-division is INITIAL .
                                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                                ELSE.
                                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                                ENDIF.

                                lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                                DATA(lv_response_11) = lo_web_http_response->get_text( ).
                                IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                                         xco_cp_json=>data->from_string( lv_response_11 )->apply( VALUE #(
                                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                                          ) )->write_to( REF #( ls_osm1 ) ).
                                        IF ls_osm1-error is INITIAL.
                                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                                        %state_area     = 'VALIDATE_ERROR'
                                                        %msg            = new_message_with_text( text = |{ lv_response_11 }|
                                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                          ENTITY SalesForceRequestAPI
                                            UPDATE FIELDS ( businesspartnerid api_result )
                                            WITH VALUE #( (
                                                              %tky       = sfrqapi_select-%tky
                                                              api_result = '400'
                                                            ) ).
                                        else.

                                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                                        %state_area     = 'VALIDATE_ERROR'
                                                        %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                          ENTITY SalesForceRequestAPI
                                            UPDATE FIELDS ( businesspartnerid api_result )
                                            WITH VALUE #( (
                                                              %tky       = sfrqapi_select-%tky
                                                              api_result = '400'
                                                            ) ).
                                        ENDIF.
                                        RETURN.
                                    ENDIF.

                                    URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesArea(Customer='{ bp_id }',SalesOrganization='{ sfrqapi_Each_salesorg_CRE }'|.
                                    URL = URL && |,DistributionChannel='{ sfrqapi_Each_Distribution_CRE }',Division='{ sfrqapi_Each_Division1_CRE }')/to_SalesAreaTax|.
                                    lo_http_destination =
                                     cl_http_destination_provider=>create_by_url( URL ).
                                     lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                                    "adding headers with API Key for API Sandbox
                                    lo_web_http_request = lo_web_http_client->get_http_request( ).
                                    lo_web_http_request->delete_header_field( 'Authorization').
                                    lo_web_http_request->delete_header_field( 'Accept').
                                    lo_web_http_request->delete_header_field( 'x-csrf-token').
                                    lo_web_http_request->set_header_fields( VALUE #(
                                    (  name = 'Content-Type' value = 'application/json' )
                                    (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                                    (  name = 'Accept' value = 'application/json' )
                                    (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                                     ) ).
                                    lo_web_http_request->set_cookie(
                                      EXPORTING
                                        i_name    = 'SAP_SESSIONID_ZI3_100'
                                        i_value   = lv_response_cookie_z91-value
                                    ).
                                    lo_web_http_request->set_cookie(
                                      EXPORTING
                                        i_name    = 'sap-usercontext'
                                        i_value   = lv_response_cookie_usercontext-value
                                    ).

                                SELECT * FROM I_SalesOrganization WHERE SalesOrganization = @sfrqapi_Each_salesorg_CRE INTO @DATA(Rec_SalesOrg).
                                IF Rec_SalesOrg IS NOT INITIAL.
                                    SELECT * FROM I_CompanyCode WHERE CompanyCode = @Rec_SalesOrg-CompanyCode INTO @DATA(Rec_Company).
                                        if rec_recei-customertaxclassification is INITIAL.
                                            if Rec_Company-Country = 'US'.
                                                bodyjson_update_12 = bodyjson_update_12 && |"CustomerTaxCategory":"UTXJ",|.
                                            ELSE.
                                                bodyjson_update_12 = bodyjson_update_12 && |"CustomerTaxCategory":"TTX1",|.
                                            ENDIF.
                                            if Rec_Company-Country is not INITIAL.
                                                bodyjson_update_12 = bodyjson_update_12 && |"DepartureCountry":"{ Rec_Company-Country }",|.
                                            ENDIF.
                                        ENDIF.
                                        if sfrqapi_select-customertaxclassification is not INITIAL.
                                            bodyjson_update_12 = bodyjson_update_12 && |"CustomerTaxClassification":"{ sfrqapi_select-customertaxclassification }",|.
                                        ELSE.
                                            bodyjson_update_12 = bodyjson_update_12 && |"CustomerTaxClassification":"{ rec_recei-customertaxclassification }",|.
                                        ENDIF.
                                        IF bodyjson_update_12 IS NOT INITIAL.
                                            bodyjson_update_12 = SUBSTRING( val = bodyjson_update_12 len = strlen( bodyjson_update_12 ) - 1 ).
                                            bodyjson_update_12 = '{' && bodyjson_update_12 && '}'.
                                        ENDIF.
                                    ENDSELECT.
                                ENDIF.
                                ENDSELECT.
                                lo_web_http_request->set_text( bodyjson_update_12 ).
                                IF rec_recei-customertaxclassification IS INITIAL.
                                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                                ELSE.
                                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                                ENDIF.
                                lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                                DATA(lv_response_12) = lo_web_http_response->get_text( ).
                                    IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                                         xco_cp_json=>data->from_string( lv_response_12 )->apply( VALUE #(
                                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                                          ) )->write_to( REF #( ls_osm1 ) ).
                                        IF ls_osm1-error is INITIAL.
                                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                                        %state_area     = 'VALIDATE_ERROR'
                                                        %msg            = new_message_with_text( text = |{ lv_response_12 }|
                                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                          ENTITY SalesForceRequestAPI
                                            UPDATE FIELDS ( businesspartnerid api_result )
                                            WITH VALUE #( (
                                                              %tky       = sfrqapi_select-%tky
                                                              api_result = '400'
                                                            ) ).
                                        else.

                                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                                        %state_area     = 'VALIDATE_ERROR'
                                                        %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                          ENTITY SalesForceRequestAPI
                                            UPDATE FIELDS ( businesspartnerid api_result )
                                            WITH VALUE #( (
                                                              %tky       = sfrqapi_select-%tky
                                                              api_result = '400'
                                                            ) ).
                                        ENDIF.
                                        RETURN.
                                    ENDIF.
                                ENDLOOP.
                            ENDLOOP.
                        ENDLOOP.

                    ELSE." CHECK FOR UPSERT
                        LOOP AT it_bcode_value2 INTO DATA(sfrqapi_Each_salesorg_UPS).
                            LOOP AT it_bcode_value_distribution2 INTO DATA(sfrqapi_Each_Distribution1_UPS).
                                LOOP AT it_bcode_value_Division2 INTO DATA(sfrqapi_Each_Division_UPS).
                                    DATA(res_value2) = find( val = rec_recei-salesorganization sub = sfrqapi_Each_salesorg_UPS ). "-1
                                    DATA(res_Distribution2) = find( val = rec_recei-distributionchannel sub = sfrqapi_Each_Distribution1_UPS ). "-1
                                    DATA(res_Division2) = find( val = rec_recei-division sub = sfrqapi_Each_Division_UPS ). "-1
                                    DATA(flag) = 0." 0: create ; 1: Update
                                    IF res_value2 = -1 OR res_Distribution2 = -1 OR res_Division2 = -1.
                                        flag = 0.
                                        URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer('{ bp_id }')/to_CustomerSalesArea|.
                                        lo_http_destination =
                                         cl_http_destination_provider=>create_by_url( URL ).
                                    ELSE.
                                        URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesArea(Customer='{ bp_id }',SalesOrganization='{ sfrqapi_Each_salesorg_UPS }'| && |,DistributionChannel='{
        sfrqapi_Each_Distribution1_UPS }',Division='{ sfrqapi_Each_Division_UPS }')|.
                                        lo_http_destination =
                                         cl_http_destination_provider=>create_by_url( URL ).
                                        flag = 1.
                                    ENDIF.

                                    lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                                    "adding headers with API Key for API Sandbox
                                    lo_web_http_request = lo_web_http_client->get_http_request( ).
                                    lo_web_http_request->delete_header_field( 'Authorization').
                                    lo_web_http_request->delete_header_field( 'Accept').
                                    lo_web_http_request->delete_header_field( 'x-csrf-token').
                                    lo_web_http_request->set_header_fields( VALUE #(
                                    (  name = 'Content-Type' value = 'application/json' )
                                    (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                                    (  name = 'Accept' value = 'application/json' )
                                    (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                                     ) ).
                                    lo_web_http_request->set_cookie(
                                      EXPORTING
                                        i_name    = 'SAP_SESSIONID_ZI3_100'
                                        i_value   = lv_response_cookie_z91-value
                                    ).
                                    lo_web_http_request->set_cookie(
                                      EXPORTING
                                        i_name    = 'sap-usercontext'
                                        i_value   = lv_response_cookie_usercontext-value
                                    ).

                                IF flag = 0.
                                    bodyjson_update_11 = ''.
                                    bodyjson_update_11 = bodyjson_update_11 && |"SalesOrganization":"{ sfrqapi_Each_salesorg_UPS }",|.
                                    bodyjson_update_11 = bodyjson_update_11 && |"DistributionChannel":"{ sfrqapi_Each_Distribution1_UPS }",|.
                                    bodyjson_update_11 = bodyjson_update_11 && |"Division":"{ sfrqapi_Each_Division_UPS }",|.

                                    if sfrqapi_select-currency is not INITIAL.
                                        bodyjson_update_11 = bodyjson_update_11 && |"Currency":"{ sfrqapi_select-currency }",|.
                                    ELSE.
                                        bodyjson_update_11 = bodyjson_update_11 && |"Currency":"{ rec_recei-currency }",|.
                                    ENDIF.
                                    IF bodyjson_update_11 IS NOT INITIAL.
                                        bodyjson_update_11 = SUBSTRING( val = bodyjson_update_11 len = strlen( bodyjson_update_11 ) - 1 ).
                                        bodyjson_update_11 = '{' && bodyjson_update_11 && '}'.
                                    ENDIF.
                                    lo_web_http_request->set_text( bodyjson_update_11 ).
                                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).

                                ELSEIF flag = 1 AND sfrqapi_select-currency IS NOT INITIAL.
                                    bodyjson_update_11 = ''.

                                    bodyjson_update_11 = bodyjson_update_11 && |"Currency":"{ sfrqapi_select-currency }",|.

                                    IF bodyjson_update_11 IS NOT INITIAL.
                                        bodyjson_update_11 = SUBSTRING( val = bodyjson_update_11 len = strlen( bodyjson_update_11 ) - 1 ).
                                        bodyjson_update_11 = '{' && bodyjson_update_11 && '}'.
                                    ENDIF.
                                    lo_web_http_request->set_text( bodyjson_update_11 ).
                                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                                ELSE.
                                    CONTINUE.
                                ENDIF.

                                lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                                lv_response_11 = lo_web_http_response->get_text( ).
                                IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                                         xco_cp_json=>data->from_string( lv_response_11 )->apply( VALUE #(
                                            ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                            ( xco_cp_json=>transformation->boolean_to_abap_bool )
                                          ) )->write_to( REF #( ls_osm1 ) ).
                                        IF ls_osm1-error is INITIAL.
                                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                                        %state_area     = 'VALIDATE_ERROR'
                                                        %msg            = new_message_with_text( text = |{ lv_response_11 }|
                                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                          ENTITY SalesForceRequestAPI
                                            UPDATE FIELDS ( businesspartnerid api_result )
                                            WITH VALUE #( (
                                                              %tky       = sfrqapi_select-%tky
                                                              api_result = '400'
                                                            ) ).
                                        else.

                                        APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                                        %state_area     = 'VALIDATE_ERROR'
                                                        %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                                        severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                          ENTITY SalesForceRequestAPI
                                            UPDATE FIELDS ( businesspartnerid api_result )
                                            WITH VALUE #( (
                                                              %tky       = sfrqapi_select-%tky
                                                              api_result = '400'
                                                            ) ).
                                        ENDIF.
                                        RETURN.
                                    ENDIF.
                                ENDLOOP.
                            ENDLOOP.
                        ENDLOOP.
                    ENDIF.

                    IF sfrqapi_select-customertaxclassification IS NOT INITIAL.
                        LOOP AT it_bcode_value2 INTO DATA(sfrqapi_Each_salesorg_UPS1).
                            LOOP AT it_bcode_value_Distribution2 INTO DATA(sfrqapi_Each_DIS_UPS1).
                                LOOP AT it_bcode_value_Division2 INTO DATA(sfrqapi_Each_Division_UPS1).
                                    DATA(res_value3) = find( val = rec_recei-salesorganization sub = sfrqapi_Each_salesorg_UPS1 ). "-1
                                    DATA(res_Distribution3) = find( val = rec_recei-distributionchannel sub = sfrqapi_Each_DIS_UPS1 ). "-1
                                    DATA(res_Division3) = find( val = rec_recei-division sub = sfrqapi_Each_Division_UPS1 ). "-1
                                    DATA(flag1) = 0." 0: create ; 1: Update
                                    DATA:
                                          TaxableEntity TYPE string,
                                          Country       TYPE string.
                                    SELECT * FROM I_SalesOrganization WHERE SalesOrganization = @sfrqapi_Each_salesorg_UPS1 INTO @DATA(Rec_SalesOrg1).
                                    IF Rec_SalesOrg1 IS NOT INITIAL.
                                        SELECT * FROM I_CompanyCode WHERE CompanyCode = @Rec_SalesOrg1-CompanyCode INTO @DATA(Rec_Company1).
                                            if Rec_Company1-Country is not INITIAL.
                                                if Rec_Company1-Country = 'US'.
                                                    TaxableEntity = 'UTXJ'.
                                                ELSE.
                                                    TaxableEntity = 'TTX1'.
                                                ENDIF.
                                                Country = Rec_Company1-Country.
                                            ENDIF.
                                        ENDSELECT.
                                    ENDIF.
                                    ENDSELECT.
                                    IF res_value3 <> -1 OR res_Distribution3 <> -1 OR res_Division3 <> -1.

                                        URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesAreaTax(Customer='{ bp_id }',SalesOrganization='{ sfrqapi_Each_salesorg_UPS1 }'|.
                                        URL = URL && |,DistributionChannel='{ sfrqapi_Each_DIS_UPS1 }',Division='{ sfrqapi_Each_Division_UPS1 }',DepartureCountry='{ country }',CustomerTaxCategory='{ taxableentity }')|.
                                        lo_http_destination =
                                         cl_http_destination_provider=>create_by_url( URL ).
                                        flag1 = 1.

                                        if sfrqapi_select-customertaxclassification is not INITIAL.
                                            bodyjson_update_12 = bodyjson_update_12 && |"CustomerTaxClassification":"{ sfrqapi_select-customertaxclassification }",|.
                                        ELSE.
                                            bodyjson_update_12 = bodyjson_update_12 && |"CustomerTaxClassification":"{ rec_recei-customertaxclassification }",|.
                                        ENDIF.
                                        IF bodyjson_update_12 IS NOT INITIAL.
                                            bodyjson_update_12 = SUBSTRING( val = bodyjson_update_12 len = strlen( bodyjson_update_12 ) - 1 ).
                                            bodyjson_update_12 = '{' && bodyjson_update_12 && '}'.
                                        ENDIF.
                                    ENDIF.

                                    IF bodyjson_update_12 IS NOT INITIAL.
                                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                                        "adding headers with API Key for API Sandbox
                                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                                        lo_web_http_request->delete_header_field( 'Authorization').
                                        lo_web_http_request->delete_header_field( 'Accept').
                                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                                        lo_web_http_request->set_header_fields( VALUE #(
                                        (  name = 'Content-Type' value = 'application/json' )
                                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                                        (  name = 'Accept' value = 'application/json' )
                                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                                         ) ).
                                        lo_web_http_request->set_cookie(
                                          EXPORTING
                                            i_name    = 'SAP_SESSIONID_ZI3_100'
                                            i_value   = lv_response_cookie_z91-value
                                        ).
                                        lo_web_http_request->set_cookie(
                                          EXPORTING
                                            i_name    = 'sap-usercontext'
                                            i_value   = lv_response_cookie_usercontext-value
                                        ).
                                        lo_web_http_request->set_text( bodyjson_update_12 ).
                                        IF rec_recei-customertaxclassification IS INITIAL.
                                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                                        ELSE.
                                            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                                        ENDIF.
                                        lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                                        lv_response_12 = lo_web_http_response->get_text( ).
                                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                                             xco_cp_json=>data->from_string( lv_response_12 )->apply( VALUE #(
                                                ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                                ( xco_cp_json=>transformation->boolean_to_abap_bool )
                                              ) )->write_to( REF #( ls_osm1 ) ).
                                            IF ls_osm1-error is INITIAL.
                                                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                                            %state_area     = 'VALIDATE_ERROR'
                                                            %msg            = new_message_with_text( text = |{ lv_response_12 }|
                                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                              ENTITY SalesForceRequestAPI
                                                UPDATE FIELDS ( businesspartnerid api_result )
                                                WITH VALUE #( (
                                                                  %tky       = sfrqapi_select-%tky
                                                                  api_result = '400'
                                                                ) ).
                                            else.

                                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                                            %state_area     = 'VALIDATE_ERROR'
                                                            %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                              ENTITY SalesForceRequestAPI
                                                UPDATE FIELDS ( businesspartnerid api_result )
                                                WITH VALUE #( (
                                                                  %tky       = sfrqapi_select-%tky
                                                                  api_result = '400'
                                                                ) ).
                                            ENDIF.
                                            RETURN.
                                        ENDIF.
                                    ENDIF.
                                ENDLOOP.
                           ENDLOOP.
                       ENDLOOP.
                    ENDIF.

                    IF  bodyjson_update_13 is not INITIAL.
                    try.
                        try.
                            IF rec_recei-companycode IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer('{ bp_id }')/to_CustomerCompany|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ELSE.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerCompany(Customer='{ bp_id }',CompanyCode='{ rec_recei-companycode }')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_13 ).
                    IF rec_recei-companycode IS INITIAL.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                    ELSE.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                    ENDIF.
                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    DATA(lv_response_13) = lo_web_http_response->get_text( ).
                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                             xco_cp_json=>data->from_string( lv_response_13 )->apply( VALUE #(
                                ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                ( xco_cp_json=>transformation->boolean_to_abap_bool )
                              ) )->write_to( REF #( ls_osm1 ) ).
                            IF ls_osm1-error is INITIAL.
                                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ lv_response_13 }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            else.

                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            ENDIF.
                            RETURN.
                        ENDIF.
                            "bodyjson_update =
                    catch cx_http_dest_provider_error.
                        "handle exception
                    endtry.
                    ENDIF.

                    IF  bodyjson_update_14 is not INITIAL.
                    try.
                        try.
                            IF rec_recei-industrysector IS INITIAL and rec_recei-industrysystemtype IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('{ bp_id }')/to_BuPaIndustry|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_14 ).

                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).

                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    DATA(lv_response_14) = lo_web_http_response->get_text( ).
                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                             xco_cp_json=>data->from_string( lv_response_14 )->apply( VALUE #(
                                ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                ( xco_cp_json=>transformation->boolean_to_abap_bool )
                              ) )->write_to( REF #( ls_osm1 ) ).
                            IF ls_osm1-error is INITIAL.
                                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ lv_response_14 }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            else.

                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            ENDIF.
                            RETURN.
                        ENDIF.
                            "bodyjson_update =
                    catch cx_http_dest_provider_error.
                        "handle exception
                    endtry.
                    ENDIF.

                    IF  bodyjson_update_15 is not INITIAL.
                    try.
                        try.

                            URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer('{ bp_id }')|.
                            lo_http_destination =
                             cl_http_destination_provider=>create_by_url( URL ).

                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_15 ).

                    lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).

                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    DATA(lv_response_15) = lo_web_http_response->get_text( ).
                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                             xco_cp_json=>data->from_string( lv_response_15 )->apply( VALUE #(
                                ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                ( xco_cp_json=>transformation->boolean_to_abap_bool )
                              ) )->write_to( REF #( ls_osm1 ) ).
                            IF ls_osm1-error is INITIAL.
                                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ lv_response_15 }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            else.

                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            ENDIF.
                            RETURN.
                        ENDIF.
                            "bodyjson_update =
                    catch cx_http_dest_provider_error.
                        "handle exception
                    endtry.
                    ENDIF.

                    IF  bodyjson_update_16 is not INITIAL.
                    try.
                        try.
                            IF rec_recei-text IS INITIAL.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer('{ bp_id }')/to_CustomerText|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            else.
                                URL = |https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerText(Customer='{ bp_id }',Language='VI',LongTextID='TX01')|.
                                lo_http_destination =
                                 cl_http_destination_provider=>create_by_url( URL ).
                            ENDIF.
                        catch cx_http_dest_provider_error.
                        "handle exception
                        endtry.
                        "create HTTP client by destination
                        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

                        "adding headers with API Key for API Sandbox
                        lo_web_http_request = lo_web_http_client->get_http_request( ).
                        lo_web_http_request->delete_header_field( 'Authorization').
                        lo_web_http_request->delete_header_field( 'Accept').
                        lo_web_http_request->delete_header_field( 'x-csrf-token').
                        lo_web_http_request->set_header_fields( VALUE #(
                        (  name = 'Content-Type' value = 'application/json' )
                        (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
                        (  name = 'Accept' value = 'application/json' )
                        (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
                         ) ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'SAP_SESSIONID_ZI3_100'
                            i_value   = lv_response_cookie_z91-value
                        ).
                        lo_web_http_request->set_cookie(
                          EXPORTING
                            i_name    = 'sap-usercontext'
                            i_value   = lv_response_cookie_usercontext-value
                        ).
                    lo_web_http_request->set_text( bodyjson_update_16 ).
                    IF rec_recei-text IS INITIAL.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).
                    ELSE.
                        lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>PATCH ).
                    ENDIF.
                    lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS\
                    DATA(lv_response_16) = lo_web_http_response->get_text( ).
                        IF lv_response_status-code <> create-code AND lv_response_status-code <> Update-code.

                             xco_cp_json=>data->from_string( lv_response_16 )->apply( VALUE #(
                                ( xco_cp_json=>transformation->pascal_case_to_underscore )
                                ( xco_cp_json=>transformation->boolean_to_abap_bool )
                              ) )->write_to( REF #( ls_osm1 ) ).
                            IF ls_osm1-error is INITIAL.
                                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ lv_response_16 }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            else.

                            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                            %state_area     = 'VALIDATE_ERROR'
                                            %msg            = new_message_with_text( text = |{ ls_osm1-error-message-value }|
                                            severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                            MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( businesspartnerid api_result )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  api_result = '400'
                                                ) ).
                            ENDIF.
                            RETURN.
                        ENDIF.
                            "bodyjson_update =
                    catch cx_http_dest_provider_error.
                        "handle exception
                    endtry.
                    ENDIF.
                ENDIF.
                RETURN.
            ENDSELECT.
        ELSEIF lv_response_x_csrf_token IS NOT INITIAL AND id_count = 0." BUSINESS PARTNER NOT EXSIST
            IF sfrqapi_select-businesspartnercategory IS INITIAL.
                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_CATEGORY'
                                %msg            = new_message_with_text( text     = '400 Bad Request. Business Category is null'
                                                               severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                sfrqapi_select-api_result = '400 Bad Request. Business Category is null'.
                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
                RETURN.
            ENDIF.
            try.
                lo_http_destination =
                     cl_http_destination_provider=>create_by_url( 'https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner' ).
              catch cx_http_dest_provider_error.
                "handle exception
            endtry.
            "create HTTP client by destination
            lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

            "adding headers with API Key for API Sandbox
            lo_web_http_request = lo_web_http_client->get_http_request( ).
            lo_web_http_request->delete_header_field( 'Authorization').
            lo_web_http_request->delete_header_field( 'Accept').
            lo_web_http_request->delete_header_field( 'x-csrf-token').
            lo_web_http_request->set_header_fields( VALUE #(
            (  name = 'Content-Type' value = 'application/json' )
            (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
            (  name = 'Accept' value = 'application/json' )
            (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
             ) ).
            lo_web_http_request->set_cookie(
              EXPORTING
                i_name    = 'SAP_SESSIONID_ZI3_100'
*                i_path    = ``
                i_value   = lv_response_cookie_z91-value
*                i_domain  = ``
*                i_expires = ``
*                i_secure  = 0
*              RECEIVING
*                r_value   =
            ).
            lo_web_http_request->set_cookie(
              EXPORTING
                i_name    = 'sap-usercontext'
*                i_path    = ``
                i_value   = lv_response_cookie_usercontext-value
*                i_domain  = ``
*                i_expires = ``
*                i_secure  = 0
*              RECEIVING
*                r_value   =
            ).
*            CATCH cx_web_message_error.
*            CATCH cx_web_message_error.
            DATA: bodyjson      TYPE string,
                  bill_to       type string,
                  ship_to       type string,
                  regis_to      type string.

            """""""""""""""""""""""""""BILL TO"""""""""""""""""""""""""""""""
            IF sfrqapi_select-billto_country IS NOT INITIAL AND sfrqapi_select-language IS NOT INITIAL.
                "bill_to = bill_to && '{'."1
                bill_to = bill_to && |"PostalCode": "{ sfrqapi_select-billto_postalcode }",|.
                bill_to = bill_to && |"Country": "{ sfrqapi_select-billto_country }",|.
                bill_to = bill_to && |"CityName": "{ sfrqapi_select-billto_cityname }",|.
                bill_to = bill_to && |"Region": "{ sfrqapi_select-billto_state }",|.
                bill_to = bill_to && |"Language": "{ sfrqapi_select-language }",|.
                bill_to = bill_to && |"StreetName": "{ sfrqapi_select-billto_streetname }",|.
                bill_to = bill_to && |"StreetPrefixName": "{ sfrqapi_select-billto_streetprefixname }",|.
                bill_to = bill_to && |"StreetSuffixName": "{ sfrqapi_select-billto_streetsuffixname }",|.
                    bill_to = bill_to && '"to_AddressUsage": {'."2
                    bill_to = bill_to && '"results": ['.        "3
                        bill_to = bill_to && '{'."4
                            bill_to = bill_to && '"AddressUsage": "BILL_TO",'.
                            bill_to = bill_to && '"StandardUsage": false'.
                        bill_to = bill_to && '}'."4
                    bill_to = bill_to && ']'."3
                    bill_to = bill_to && '}'."2

                    IF sfrqapi_select-phonenumber IS NOT INITIAL.
                        bill_to = bill_to && ',"to_PhoneNumber": {'."2
                        bill_to = bill_to && '"results": ['.        "3
                            bill_to = bill_to && '{'."4
                                bill_to = bill_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                                IF sfrqapi_select-isdefaultphonenumber = 'X'.
                                    bill_to = bill_to && |"IsDefaultPhoneNumber": true ,|.
                                else.
                                    bill_to = bill_to && |"IsDefaultPhoneNumber": false ,|.
                                ENDIF.
                                bill_to = bill_to && |"PhoneNumber": "{ sfrqapi_select-phonenumber }"|.
                            bill_to = bill_to && '}'."4
                        bill_to = bill_to && ']'."3
                        bill_to = bill_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-mobilephone IS NOT INITIAL.
                    bill_to = bill_to && ',"to_MobilePhoneNumber": {'."2
                    bill_to = bill_to && '"results": ['.        "3
                        bill_to = bill_to && '{'."4
                            bill_to = bill_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                            IF sfrqapi_select-isdefaultmobilephonenumber = 'X'.
                                bill_to = bill_to && |"IsDefaultPhoneNumber": true ,|.
                            else.
                                bill_to = bill_to && |"IsDefaultPhoneNumber": false ,|.
                            ENDIF.
                            bill_to = bill_to && |"PhoneNumber": "{ sfrqapi_select-mobilephone }"|.
                        bill_to = bill_to && '}'."4
                    bill_to = bill_to && ']'."3
                    bill_to = bill_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-emailaddress IS NOT INITIAL.
                    bill_to = bill_to && ',"to_EmailAddress": {'."2
                    bill_to = bill_to && '"results": ['.        "3
                        bill_to = bill_to && '{'."4
                            bill_to = bill_to && '"IsDefaultEmailAddress": true,'.
                            bill_to = bill_to && |"EmailAddress": "{ sfrqapi_select-emailaddress }"|.
                        bill_to = bill_to && '}'."4
                    bill_to = bill_to && ']'."3
                    bill_to = bill_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-websiteurl IS NOT INITIAL.
                    bill_to = bill_to && ',"to_URLAddress": {'."2
                    bill_to = bill_to && '"results": ['.        "3
                        bill_to = bill_to && '{'."4
                            bill_to = bill_to && '"IsDefaultURLAddress": true,'.
                            bill_to = bill_to && |"WebsiteURL": "{ sfrqapi_select-websiteurl }"|.
                        bill_to = bill_to && '}'."4
                    bill_to = bill_to && ']'."3
                    bill_to = bill_to && '}'."2
                    ENDIF.

                "bill_to = bill_to && '}'."1
            ENDIF.

            """""""""""""""""""""""""SHIP TO"""""""""""""""""""""""""""""""""
            IF sfrqapi_select-shipto_country IS NOT INITIAL AND sfrqapi_select-language IS NOT INITIAL.
                "ship_to = ship_to && '{'."1
                ship_to = ship_to && |"PostalCode": "{ sfrqapi_select-shipto_postalcode }",|.
                ship_to = ship_to && |"Country": "{ sfrqapi_select-shipto_country }",|.
                ship_to = ship_to && |"CityName": "{ sfrqapi_select-shipto_cityname }",|.
                ship_to = ship_to && |"Region": "{ sfrqapi_select-shipto_state }",|.
                ship_to = ship_to && |"Language": "{ sfrqapi_select-language }",|.
                ship_to = ship_to && |"StreetName": "{ sfrqapi_select-shipto_streetname }",|.
                ship_to = ship_to && |"StreetPrefixName": "{ sfrqapi_select-shipto_streetprefixname }",|.
                ship_to = ship_to && |"StreetSuffixName": "{ sfrqapi_select-shipto_streetsuffixname }",|.
                    ship_to = ship_to && '"to_AddressUsage": {'."2
                        ship_to = ship_to && '"results": ['.        "3
                        ship_to = ship_to && '{'."4
                            ship_to = ship_to && '"AddressUsage": "SHIP_TO",'.
                            ship_to = ship_to && '"StandardUsage": false'.
                        ship_to = ship_to && '}'."4
                        ship_to = ship_to && ']'."3
                    ship_to = ship_to && '}'."2

                    IF sfrqapi_select-phonenumber IS NOT INITIAL.
                        ship_to = ship_to && ',"to_PhoneNumber": {'."2
                        ship_to = ship_to && '"results": ['.        "3
                            ship_to = ship_to && '{'."4
                                ship_to = ship_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                                "ship_to = ship_to && |"IsDefaultPhoneNumber":{ sfrqapi_select-isdefaultphonenumber } ,|.
                                IF sfrqapi_select-isdefaultmobilephonenumber = 'X'.
                                    ship_to = ship_to && |"IsDefaultPhoneNumber": true ,|.
                                else.
                                    ship_to = ship_to && |"IsDefaultPhoneNumber": false ,|.
                                ENDIF.
                                ship_to = ship_to && |"PhoneNumber": "{ sfrqapi_select-phonenumber }"|.
                            ship_to = ship_to && '}'."4
                        ship_to = ship_to && ']'."3
                        ship_to = ship_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-mobilephone IS NOT INITIAL.
                    ship_to = ship_to && ',"to_MobilePhoneNumber": {'."2
                    ship_to = ship_to && '"results": ['.        "3
                        ship_to = ship_to && '{'."4
                            ship_to = ship_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                            "ship_to = ship_to && |"IsDefaultPhoneNumber": { sfrqapi_select-isdefaultmobilephonenumber },|.
                            IF sfrqapi_select-isdefaultmobilephonenumber = 'X'.
                                ship_to = ship_to && |"IsDefaultPhoneNumber": true ,|.
                            else.
                                ship_to = ship_to && |"IsDefaultPhoneNumber": false ,|.
                            ENDIF.
                            ship_to = ship_to && |"PhoneNumber": "{ sfrqapi_select-mobilephone }"|.
                        ship_to = ship_to && '}'."4
                    ship_to = ship_to && ']'."3
                    ship_to = ship_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-emailaddress IS NOT INITIAL.
                    ship_to = ship_to && ',"to_EmailAddress": {'."2
                    ship_to = ship_to && '"results": ['.        "3
                        ship_to = ship_to && '{'."4
                            ship_to = ship_to && '"IsDefaultEmailAddress": true,'.
                            ship_to = ship_to && |"EmailAddress": "{ sfrqapi_select-emailaddress }"|.
                        ship_to = ship_to && '}'."4
                    ship_to = ship_to && ']'."3
                    ship_to = ship_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-websiteurl IS NOT INITIAL.
                    ship_to = ship_to && ',"to_URLAddress": {'."2
                    ship_to = ship_to && '"results": ['.        "3
                        ship_to = ship_to && '{'."4
                            ship_to = ship_to && '"IsDefaultURLAddress": true,'.
                            ship_to = ship_to && |"WebsiteURL": "{ sfrqapi_select-websiteurl }"|.
                        ship_to = ship_to && '}'."4
                    ship_to = ship_to && ']'."3
                    ship_to = ship_to && '}'."2
                    ENDIF.

                "ship_to = ship_to && '}'."1
            ENDIF.

            """"""""""""""""""""""""""""REGISTER TO""""""""""""""""""""""""""""""
            IF sfrqapi_select-register_country IS NOT INITIAL AND sfrqapi_select-language IS NOT INITIAL.
                "regis_to = regis_to && '{'."1
                regis_to = regis_to && |"PostalCode": "{ sfrqapi_select-register_postalcode }",|.
                regis_to = regis_to && |"Country": "{ sfrqapi_select-register_country }",|.
                regis_to = regis_to && |"CityName": "{ sfrqapi_select-register_cityname }",|.
                regis_to = regis_to && |"Region": "{ sfrqapi_select-register_state }",|.
                regis_to = regis_to && |"Language": "{ sfrqapi_select-language }",|.
                regis_to = regis_to && |"StreetName": "{ sfrqapi_select-register_streetname }",|.
                regis_to = regis_to && |"StreetPrefixName": "{ sfrqapi_select-register_streetprefixname }",|.
                regis_to = regis_to && |"StreetSuffixName": "{ sfrqapi_select-register_streetsuffixname }",|.
                    regis_to = regis_to && '"to_AddressUsage": {'."2
                        regis_to = regis_to && '"results": ['.        "3
                        regis_to = regis_to && '{'."4
                            regis_to = regis_to && '"AddressUsage": "XXDEFAULT",'.
                            regis_to = regis_to && '"StandardUsage": false'.
                        regis_to = regis_to && '}'."4
                    regis_to = regis_to && ']'."3
                    regis_to = regis_to && '}'."2

                    IF sfrqapi_select-phonenumber IS NOT INITIAL.
                        regis_to = regis_to && ',"to_PhoneNumber": {'."2
                        regis_to = regis_to && '"results": ['.        "3
                            regis_to = regis_to && '{'."4
                                regis_to = regis_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                                "regis_to = regis_to && |"IsDefaultPhoneNumber": { sfrqapi_select-isdefaultphonenumber },|.
                                IF sfrqapi_select-isdefaultphonenumber = 'X'.
                                    regis_to = regis_to && |"IsDefaultPhoneNumber": true ,|.
                                else.
                                    regis_to = regis_to && |"IsDefaultPhoneNumber": false ,|.
                                ENDIF.
                                regis_to = regis_to && |"PhoneNumber": "{ sfrqapi_select-phonenumber }"|.
                            regis_to = regis_to && '}'."4
                        regis_to = regis_to && ']'."3
                        regis_to = regis_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-mobilephone IS NOT INITIAL.
                    regis_to = regis_to && ',"to_MobilePhoneNumber": {'."2
                    regis_to = regis_to && '"results": ['.        "3
                        regis_to = regis_to && '{'."4
                            regis_to = regis_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                            "regis_to = regis_to && |"IsDefaultPhoneNumber": { sfrqapi_select-isdefaultmobilephonenumber },|.
                            IF sfrqapi_select-isdefaultmobilephonenumber = 'X'.
                                regis_to = regis_to && |"IsDefaultPhoneNumber": true ,|.
                            else.
                                regis_to = regis_to && |"IsDefaultPhoneNumber": false ,|.
                            ENDIF.
                            regis_to = regis_to && |"PhoneNumber": "{ sfrqapi_select-mobilephone }"|.
                        regis_to = regis_to && '}'."4
                    regis_to = regis_to && ']'."3
                    regis_to = regis_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-emailaddress IS NOT INITIAL.
                    regis_to = regis_to && ',"to_EmailAddress": {'."2
                    regis_to = regis_to && '"results": ['.        "3
                        regis_to = regis_to && '{'."4
                            regis_to = regis_to && '"IsDefaultEmailAddress": true,'.
                            regis_to = regis_to && |"EmailAddress": "{ sfrqapi_select-emailaddress }"|.
                        regis_to = regis_to && '}'."4
                    regis_to = regis_to && ']'."3
                    regis_to = regis_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-websiteurl IS NOT INITIAL.
                    regis_to = regis_to && ',"to_URLAddress": {'."2
                    regis_to = regis_to && '"results": ['.        "3
                        regis_to = regis_to && '{'."4
                            regis_to = regis_to && '"IsDefaultURLAddress": true,'.
                            regis_to = regis_to && |"WebsiteURL": "{ sfrqapi_select-websiteurl }"|.
                        regis_to = regis_to && '}'."4
                    regis_to = regis_to && ']'."3
                    regis_to = regis_to && '}'."2
                    ENDIF.

                "regis_to = regis_to && '}'."1
           ENDIF.

            """"""""""""""""""""""""""""""BODY REQUEST"""""""""""""""""""""""""""""
            bodyjson = '{'."Header
            "bodyjson = bodyjson && |"BusinessPartner":"{ sfrqapi_select-businesspartnerid }",|.
            bodyjson = bodyjson && |"BusinessPartnerCategory": "{ sfrqapi_select-businesspartnercategory }",|.


            IF sfrqapi_select-yy1_fatca_1_bus = 'X'.

                bodyjson = bodyjson && |"YY1_FATCA_2_bus": true,|.
            ELSE.
                bodyjson = bodyjson && '"YY1_FATCA_2_bus": false,'.
            ENDIF.

            IF regis_to IS INITIAL AND ship_to IS INITIAL AND bill_to IS INITIAL.
                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_ADDRESS'
                                %msg            = new_message_with_text( text     = 'Address Country Or Language is null'
                                severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
                RETURN.
            ENDIF.

            bodyjson = bodyjson && '"to_BusinessPartnerAddress": {'."to_BusinessPartnerAddress
                bodyjson = bodyjson && '"results": ['."1
                IF regis_to IS NOT INITIAL.
                    bodyjson = bodyjson && '{'.
                    bodyjson = bodyjson && regis_to.
                    bodyjson = bodyjson && '},'.
                ENDIF.

                IF ship_to IS NOT INITIAL.
                    bodyjson = bodyjson && '{'.
                    bodyjson = bodyjson && ship_to.
                    bodyjson = bodyjson && '},'.
                ENDIF.

                IF bill_to IS NOT INITIAL.
                    bodyjson = bodyjson && '{'.
                    bodyjson = bodyjson && bill_to.
                    bodyjson = bodyjson && '},'.
                ENDIF.
                bodyjson = shift_right( val = bodyjson places = 1 ).
                bodyjson = bodyjson && ']'."1
            bodyjson = bodyjson && '},'."to_BusinessPartnerAddress

            IF sfrqapi_select-is_contact = 'X' OR sfrqapi_select-is_contact = 'true'.
                bodyjson = bodyjson && |"YY1_SalesforceAccountI_bus": "{ sfrqapi_select-salesforceaccountid }",|.
                bodyjson = bodyjson && |"FirstName": "{ sfrqapi_select-firstname }",|.
                bodyjson = bodyjson && |"LastName": "{ sfrqapi_select-lastname }",|.
                bodyjson = bodyjson && '"to_BusinessPartnerRole": {'."to_BusinessPartnerRole
                    bodyjson = bodyjson && '"results": ['."1
                        bodyjson = bodyjson && '{'."2
                            bodyjson = bodyjson && '"BusinessPartnerRole": "BUP001"'.
                        bodyjson = bodyjson && '}'."2
                    bodyjson = bodyjson && ']'."1
                bodyjson = bodyjson && '}'."to_BusinessPartnerRole

            ELSE.
                bodyjson = bodyjson && |"YY1_SalesforceAccountI_bus": "{ sfrqapi_select-salesforceaccountid }",|.
                bodyjson = bodyjson && |"OrganizationBPName1": "{ sfrqapi_select-organizationbpname1 }",|.
                bodyjson = bodyjson && '"to_BusinessPartnerRole": {'."to_BusinessPartnerRole
                    bodyjson = bodyjson && '"results": ['."1
                        bodyjson = bodyjson && '{'."2
                            bodyjson = bodyjson && '"BusinessPartnerRole": "FLCU00"'.
                        bodyjson = bodyjson && '},'."2
                        bodyjson = bodyjson && '{'."3
                            bodyjson = bodyjson && '"BusinessPartnerRole": "FLCU01"'.
                        bodyjson = bodyjson && '}'."3
                    bodyjson = bodyjson && ']'."1
                bodyjson = bodyjson && '},'."to_BusinessPartnerRole


                IF sfrqapi_select-industrysector <> '' AND sfrqapi_select-industrysystemtype <> ''.
                    bodyjson = bodyjson && '"to_BuPaIndustry": {'."to_BuPaIndustry
                        bodyjson = bodyjson && '"results": ['."1
                            bodyjson = bodyjson && '{'."2
                                bodyjson = bodyjson && |"IndustrySector": "{ sfrqapi_select-industrysector }",|.
                                bodyjson = bodyjson && |"IndustrySystemType": "{ sfrqapi_select-industrysystemtype }"|.
                            bodyjson = bodyjson && '}'."2
                        bodyjson = bodyjson && ']'."1
                    bodyjson = bodyjson && '},'."to_BuPaIndustry
                ENDIF.

                bodyjson = bodyjson && '"to_Customer": {'."Customer
                    IF sfrqapi_select-customerclassification = 'Hot'.
                        bodyjson = bodyjson && |"CustomerClassification": "A",|.
                    ELSEIF sfrqapi_select-customerclassification = 'Warm'.
                        bodyjson = bodyjson && |"CustomerClassification": "B",|.
                    else.
                        bodyjson = bodyjson && |"CustomerClassification": "C",|.
                    ENDIF.
                    bodyjson = bodyjson && '"to_CustomerText": {'."1
                        bodyjson = bodyjson && '"results": ['."2
                            bodyjson = bodyjson && '{'."3
                                bodyjson = bodyjson && '"Language": "VI",'.
                                bodyjson = bodyjson && '"LongTextID": "TX01",'.
                                bodyjson = bodyjson && |"LongText": "{ sfrqapi_select-text }"|.
                            bodyjson = bodyjson && '}'."3
                        bodyjson = bodyjson && ']'."2
                    bodyjson = bodyjson && '},'."1

        """""""""""""""""""""""""""""Division""""""""""""""""""""""""""""""""
        data : it_bcode_value_Division type STANDARD TABLE OF string.
        data : gv_bcode_value_Division type string ,
               sep_Division type string value ';'.
        gv_bcode_value_Division = sfrqapi_select-division.
        FIELD-SYMBOLS : <sep_Division> type any.

        ASSIGN sep_Division TO <sep_Division>.

        SPLIT gv_bcode_value_Division AT <sep_Division> INTO:
        TABLE it_bcode_value_Division IN CHARACTER MODE.

        """""""""""""""""""""""""""""Distribution""""""""""""""""""""""""""""""""
        data : it_bcode_value_Distribution type STANDARD TABLE OF string.
        data : gv_bcode_value_Distribution type string ,
               sep_Distribution type string value ';'.
        gv_bcode_value_Distribution = sfrqapi_select-distributionchannel.
        FIELD-SYMBOLS : <sep_Distribution> type any.

        ASSIGN sep_Distribution TO <sep_Distribution>.

        SPLIT gv_bcode_value_Distribution AT <sep_Distribution> INTO:
        TABLE it_bcode_value_Distribution IN CHARACTER MODE.

        """""""""""""""""""""""""""""SalesOrganization"""""""""""""""""""""""""""""""""""""""""
        data : it_bcode_value type STANDARD TABLE OF string.
        data : gv_bcode_value type string ,
               sep type string value ';'.
        gv_bcode_value = sfrqapi_select-salesorganization.
        FIELD-SYMBOLS : <sep> type any.

        ASSIGN sep TO <sep>.

        SPLIT gv_bcode_value AT <sep> INTO:
        TABLE it_bcode_value IN CHARACTER MODE.

        bodyjson = bodyjson && '"to_CustomerSalesArea": {'."1
        bodyjson = bodyjson && '"results": ['."2
        "bodyjson = bodyjson && '{'."3
        DATA(count) = 1.

        DATA(count_salesorganization) = lines( it_bcode_value ).
        DATA(count_Distribution) = lines( it_bcode_value_Distribution ).
        DATA(count_Division) = lines( it_bcode_value_Division ).

        DATA(multiple) = count_salesorganization * count_Distribution * count_Division.

        LOOP AT it_bcode_value INTO DATA(sfrqapi_Each_salesorganization).
            LOOP AT it_bcode_value_Distribution INTO DATA(sfrqapi_Each_Distribution).
                LOOP AT it_bcode_value_Division INTO DATA(sfrqapi_Each_Division).

                    bodyjson = bodyjson && '{'."3
                    bodyjson = bodyjson && |"SalesOrganization": "{ sfrqapi_Each_salesorganization }",|.
                    bodyjson = bodyjson && |"DistributionChannel": "{ sfrqapi_Each_Distribution }",|.
                    bodyjson = bodyjson && |"Division": "{ sfrqapi_Each_Division }",|.
                    bodyjson = bodyjson && |"Currency": "{ sfrqapi_select-currency }",|.
                    bodyjson = bodyjson && '"to_SalesAreaTax": {'."4
                        bodyjson = bodyjson && '"results": ['."5
                            bodyjson = bodyjson && '{'."6
                                bodyjson = bodyjson && '"CustomerTaxCategory": "TTX1",'.
                                bodyjson = bodyjson && |"CustomerTaxClassification": "{ sfrqapi_select-customertaxclassification }"|.
                            bodyjson = bodyjson && '}'."6
                        bodyjson = bodyjson && ']'."5
                    bodyjson = bodyjson && '}'."4

                if count < multiple.
                    bodyjson = bodyjson && '},'."3
                    count = count + 1.
                else.
                    bodyjson = bodyjson && '}'."3
                ENDIF.

                ENDLOOP.
            ENDLOOP.
        ENDLOOP.
                        bodyjson = bodyjson && ']'."2
                    bodyjson = bodyjson && '},'."1

                    bodyjson = bodyjson && '"to_CustomerCompany": {'."1
                        bodyjson = bodyjson && '"results": ['."2
                            bodyjson = bodyjson && '{'."3
                                bodyjson = bodyjson && |"CompanyCode": "{ sfrqapi_select-companycode }",|.
                                bodyjson = bodyjson && |"ReconciliationAccount": "{ sfrqapi_select-reconciliationaccount }",|.
                                bodyjson = bodyjson && |"PaymentTerms": "{ sfrqapi_select-paymentterms }"|.
                            bodyjson = bodyjson && '}'."3
                        bodyjson = bodyjson && ']'."2
                    bodyjson = bodyjson && '}'."1
                bodyjson = bodyjson && '}'."Customer
            ENDIF.
            bodyjson = bodyjson && '}'.

            "set request method and execute request

            lo_web_http_request->set_text( bodyjson ).

            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).

            lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS
            DATA(lv_response) = lo_web_http_response->get_text( ).

            IF lv_response_status-code <> create-code.
                TYPES:
                BEGIN OF message,
                  lang TYPE string,
                  value TYPE string,
                END OF message,

                BEGIN OF ts_error,
                  code TYPE string,
                  message TYPE message,
                END OF ts_error,

                BEGIN OF error,
                  error TYPE ts_error,
                END OF error.
                DATA ls_osm TYPE error.

                 xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
                    ( xco_cp_json=>transformation->pascal_case_to_underscore )
                    ( xco_cp_json=>transformation->boolean_to_abap_bool )
                  ) )->write_to( REF #( ls_osm ) ).
                IF ls_osm-error is INITIAL.
                    APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_ERROR'
                                %msg            = new_message_with_text( text = |{ lv_response }|
                                severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
                else.
                    APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                    %state_area     = 'VALIDATE_ERROR'
                                    %msg            = new_message_with_text( text = |{ ls_osm-error-message-value }|
                                    severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                    MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                      ENTITY SalesForceRequestAPI
                        UPDATE FIELDS ( businesspartnerid api_result )
                        WITH VALUE #( (
                                          %tky       = sfrqapi_select-%tky
                                          api_result = '400'
                                        ) ).
                ENDIF.
            else.
                """"""""""""""""""""""""HANDLE JSON""""""""""""""""""""""""""""""
                REPLACE ALL OCCURRENCES OF `to_BusinessPartnerAddress` IN lv_response WITH `elements`.
                REPLACE ALL OCCURRENCES OF `to_AddressUsage` IN lv_response WITH `tags`.
                TYPES:
                    BEGIN OF ts_AddressUsage,
                      AddressUsage    TYPE string,
                    END OF ts_AddressUsage,
                    BEGIN OF rs_AddressUsage,
                      results    TYPE STANDARD TABLE OF ts_AddressUsage WITH EMPTY KEY,
                    END OF rs_AddressUsage,
                    BEGIN OF Address_ID,
                      AddressID    TYPE string,
                      tags   TYPE rs_AddressUsage,
                    END OF Address_ID,
                    BEGIN OF BusinessPartnerAddress,
                      results    TYPE STANDARD TABLE OF Address_ID WITH EMPTY KEY,
                    END OF BusinessPartnerAddress,
                    BEGIN OF BusinessPartnerHeader,
                      BusinessPartner    TYPE string,
                      Customer    TYPE string,
                      elements TYPE BusinessPartnerAddress,
                    END OF BusinessPartnerHeader,
                    BEGIN OF d_root,
                      d    TYPE BusinessPartnerHeader,
                    END OF d_root.
                     DATA ls_osm_1 TYPE d_root.

                      " Convert the data from JSON to ABAP using the XCO Library; output the data
                    TRY.
                      TRANSLATE lv_response TO LOWER CASE.
                      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
                        ( xco_cp_json=>transformation->pascal_case_to_underscore )
                        ( xco_cp_json=>transformation->boolean_to_abap_bool )
                      ) )->write_to( REF #( ls_osm_1 ) ).

                    businessPartnerID = ls_osm_1-d-businesspartner.

                    LOOP AT ls_osm_1-d-elements-results ASSIGNING FIELD-SYMBOL(<element>).
                        Data: usage type string,
                              addressID type string.

                        addressID = <element>-addressid.
                        Data(usage_rs) = <element>-tags-results.
                        LOOP AT usage_rs ASSIGNING FIELD-SYMBOL(<element1>).
                            usage = <element1>-addressusage.
                            if usage = 'bill_to'.
                                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                  ENTITY SalesForceRequestAPI
                                    UPDATE FIELDS ( billto_addressid )
                                    WITH VALUE #( (
                                                      %tky       = sfrqapi_select-%tky
                                                      billto_addressid = addressID
                                                    ) ).
                            ENDIF.

                            if usage = 'xxdefault'.
                                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( register_addressid )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  register_addressid = addressid
                                                ) ).
                            ENDIF.

                            if usage = 'ship_to'.
                                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                  ENTITY SalesForceRequestAPI
                                    UPDATE FIELDS ( shipto_addressid )
                                    WITH VALUE #( (
                                                      %tky       = sfrqapi_select-%tky
                                                      shipto_addressid = addressid
                                                    ) ).
                            ENDIF.
                         ENDLOOP.
                    ENDLOOP.
                    APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_SUCCESS'
                                %msg            = new_message_with_text( text     = |Business Partner created: { businessPartnerID }|
                               severity    = if_abap_behv_message=>severity-success ) ) TO reported-salesforcerequestapi.

                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              businesspartnerid = businessPartnerID
                                              api_result = '200'
                                            ) ).
                " catch any error
                    CATCH cx_root INTO DATA(lx_root).


                    ENDTRY.

            ENDIF.
        ELSE."SOMETHING


        ENDIF.

        ENDLOOP.

        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
            "error handling
        ENDTRY.

        "uncomment the following line for console output; prerequisite: code snippet is implementation of if_oo_adt_classrun~main
        "out->write( |response:  { lv_response }| ).
  ENDMETHOD.

  METHOD updatefirstname.
  ENDMETHOD.

  METHOD ValidateBusinessPartnerID.
    READ ENTITIES OF zi_sfrqapi IN LOCAL MODE
        ENTITY SalesForceRequestAPI
        FIELDS ( salesforceaccountid ) WITH CORRESPONDING #( keys )
        RESULT DATA(sfrqapi_result).
    LOOP AT sfrqapi_result INTO DATA(sfrqapi_select).
        IF sfrqapi_select-api_result = '400'.
            APPEND VALUE #( %tky            = sfrqapi_select-%tky ) TO failed-salesforcerequestapi.
        ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD SetUpdateAuthToken.
    TRY.
        "create http destination by url; API endpoint for API sandbox
      "DATA(pr_keys) = VALUE ZTSFRQAPI( businesspartnerid = KEYS[ 1 ]-businesspartnerid ).

        Data: sucess type if_web_http_response=>http_status,
              notAuth type if_web_http_response=>http_status,
              Update type if_web_http_response=>http_status,
              create type if_web_http_response=>http_status,
              businessPartnerID type string.
        "SET VALUE
        sucess-code = 200.
        create-code = 201.
        Update-code = 204.
        notAuth-code = 401.
        notAuth-reason = 'Unauthorized'.

        READ ENTITIES OF zi_sfrqapi IN LOCAL MODE
        ENTITY SalesForceRequestAPI
        FIELDS ( salesforceaccountid ) WITH CORRESPONDING #( keys )
        RESULT DATA(sfrqapi_result).

        LOOP AT sfrqapi_result INTO DATA(sfrqapi_select).
        IF sfrqapi_select-salesforceaccountid is INITIAL OR sfrqapi_select-salesforceaccountid = ''.
            APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_Salesforce_AccountID'
                                %msg            = new_message_with_text( text     = 'Salesforce AccountID is initial.'
                               severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
           MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
            return.
        ENDIF.

        IF sfrqapi_select-businesspartnercategory IS NOT INITIAL.
            try.
                data(lo_http_destination) =
                     cl_http_destination_provider=>create_by_url( 'https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner?$top=1' ).
              catch cx_http_dest_provider_error.
                "handle exception
            endtry.
            "create HTTP client by destination
            DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

            "adding headers with API Key for API Sandbox
            DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
            lo_web_http_request->set_header_fields( VALUE #(
            (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
            (  name = 'Accept' value = 'application/json' )
            (  name = 'x-csrf-token' value = 'FETCH' )
             ) ).

            "set request method and execute request
            DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>GET ).
            DATA(lv_response_status) = lo_web_http_response->get_status( )."GET RESPONSE STATUS


            IF lv_response_status = notAuth.
                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_AUTHORIZATION'
                                %msg            = new_message_with_text( text     = '401 Not Unauthorized. Check authToken'
                                                               severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                sfrqapi_select-api_result = '401 Not Unauthorized. Check authToken'.
                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
                RETURN.
            ELSEIF lv_response_status-code <> sucess-code.
                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_ERROR'
                                %msg            = new_message_with_text( text     = |{ lv_response_status-code } - { lv_response_status-reason }|
                                                               severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                DATA(lv_response_text) = lo_web_http_response->get_text( )."GET RESPONSE STATUS
                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
                RETURN.

            ENDIF.

            DATA(lv_response_x_csrf_token) = lo_web_http_response->get_header_field( 'x-csrf-token' ).
            DATA(lv_response_cookie_z91) = lo_web_http_response->get_cookie(
                                         i_name = 'SAP_SESSIONID_ZI3_100'
*                                         i_path = ``
                                       ).
            DATA(lv_response_cookie_usercontext) = lo_web_http_response->get_cookie(
             i_name = 'sap-usercontext'
*             i_path = ``
            ).
        ENDIF.

        SELECT Count( * ) FROM zi_sfrqapi WHERE salesforceaccountid = @sfrqapi_select-salesforceaccountid INTO @DATA(id_count).

        IF lv_response_x_csrf_token IS NOT INITIAL AND id_count > 0." BUSINESS PARTNER EXSIST


        ELSEIF lv_response_x_csrf_token IS NOT INITIAL AND id_count = 0." BUSINESS PARTNER NOT EXSIST

            try.
                lo_http_destination =
                     cl_http_destination_provider=>create_by_url( 'https://my407521-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner' ).
              catch cx_http_dest_provider_error.
                "handle exception
            endtry.
            "create HTTP client by destination
            lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

            "adding headers with API Key for API Sandbox
            lo_web_http_request = lo_web_http_client->get_http_request( ).
            lo_web_http_request->delete_header_field( 'Authorization').
            lo_web_http_request->delete_header_field( 'Accept').
            lo_web_http_request->delete_header_field( 'x-csrf-token').
            lo_web_http_request->set_header_fields( VALUE #(
            (  name = 'Content-Type' value = 'application/json' )
            (  name = 'Authorization' value = |Basic U0FNTF9CRUFSRVJfQVNTRVJUSU9OOlZNTVNRdENyaHdYa3Ztem10bEVTamdBI3NCM0FVYXpRR21VU051U1A=| )
            (  name = 'Accept' value = 'application/json' )
            (  name = 'x-csrf-token' value = |{ lv_response_x_csrf_token }| )
             ) ).
            lo_web_http_request->set_cookie(
              EXPORTING
                i_name    = 'SAP_SESSIONID_ZI3_100'
*                i_path    = ``
                i_value   = lv_response_cookie_z91-value
*                i_domain  = ``
*                i_expires = ``
*                i_secure  = 0
*              RECEIVING
*                r_value   =
            ).
            lo_web_http_request->set_cookie(
              EXPORTING
                i_name    = 'sap-usercontext'
*                i_path    = ``
                i_value   = lv_response_cookie_usercontext-value
*                i_domain  = ``
*                i_expires = ``
*                i_secure  = 0
*              RECEIVING
*                r_value   =
            ).
*            CATCH cx_web_message_error.
*            CATCH cx_web_message_error.
            DATA: bodyjson      TYPE string,
                  bill_to       type string,
                  ship_to       type string,
                  regis_to      type string.

            """""""""""""""""""""""""""BILL TO"""""""""""""""""""""""""""""""
            IF sfrqapi_select-billto_country IS NOT INITIAL AND sfrqapi_select-language IS NOT INITIAL.
                "bill_to = bill_to && '{'."1
                bill_to = bill_to && |"PostalCode": "{ sfrqapi_select-billto_postalcode }",|.
                bill_to = bill_to && |"Country": "{ sfrqapi_select-billto_country }",|.
                bill_to = bill_to && |"CityName": "{ sfrqapi_select-billto_cityname }",|.
                bill_to = bill_to && |"Region": "{ sfrqapi_select-billto_state }",|.
                bill_to = bill_to && |"Language": "{ sfrqapi_select-language }",|.
                bill_to = bill_to && |"StreetName": "{ sfrqapi_select-billto_streetname }",|.
                bill_to = bill_to && |"StreetPrefixName": "{ sfrqapi_select-billto_streetprefixname }",|.
                bill_to = bill_to && |"StreetSuffixName": "{ sfrqapi_select-billto_streetsuffixname }",|.
                    bill_to = bill_to && '"to_AddressUsage": {'."2
                    bill_to = bill_to && '"results": ['.        "3
                        bill_to = bill_to && '{'."4
                            bill_to = bill_to && '"AddressUsage": "BILL_TO",'.
                            bill_to = bill_to && '"StandardUsage": false'.
                        bill_to = bill_to && '}'."4
                    bill_to = bill_to && ']'."3
                    bill_to = bill_to && '}'."2

                    IF sfrqapi_select-phonenumber IS NOT INITIAL.
                        bill_to = bill_to && ',"to_PhoneNumber": {'."2
                        bill_to = bill_to && '"results": ['.        "3
                            bill_to = bill_to && '{'."4
                                bill_to = bill_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                                IF sfrqapi_select-isdefaultphonenumber = 'X'.
                                    bill_to = bill_to && |"IsDefaultPhoneNumber": true ,|.
                                else.
                                    bill_to = bill_to && |"IsDefaultPhoneNumber": false ,|.
                                ENDIF.
                                bill_to = bill_to && |"PhoneNumber": "{ sfrqapi_select-phonenumber }"|.
                            bill_to = bill_to && '}'."4
                        bill_to = bill_to && ']'."3
                        bill_to = bill_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-mobilephone IS NOT INITIAL.
                    bill_to = bill_to && ',"to_MobilePhoneNumber": {'."2
                    bill_to = bill_to && '"results": ['.        "3
                        bill_to = bill_to && '{'."4
                            bill_to = bill_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                            IF sfrqapi_select-isdefaultmobilephonenumber = 'X'.
                                bill_to = bill_to && |"IsDefaultPhoneNumber": true ,|.
                            else.
                                bill_to = bill_to && |"IsDefaultPhoneNumber": false ,|.
                            ENDIF.
                            bill_to = bill_to && |"PhoneNumber": "{ sfrqapi_select-mobilephone }"|.
                        bill_to = bill_to && '}'."4
                    bill_to = bill_to && ']'."3
                    bill_to = bill_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-emailaddress IS NOT INITIAL.
                    bill_to = bill_to && ',"to_EmailAddress": {'."2
                    bill_to = bill_to && '"results": ['.        "3
                        bill_to = bill_to && '{'."4
                            bill_to = bill_to && '"IsDefaultEmailAddress": true,'.
                            bill_to = bill_to && |"EmailAddress": "{ sfrqapi_select-emailaddress }"|.
                        bill_to = bill_to && '}'."4
                    bill_to = bill_to && ']'."3
                    bill_to = bill_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-websiteurl IS NOT INITIAL.
                    bill_to = bill_to && ',"to_URLAddress": {'."2
                    bill_to = bill_to && '"results": ['.        "3
                        bill_to = bill_to && '{'."4
                            bill_to = bill_to && '"IsDefaultURLAddress": true,'.
                            bill_to = bill_to && |"WebsiteURL": "{ sfrqapi_select-websiteurl }"|.
                        bill_to = bill_to && '}'."4
                    bill_to = bill_to && ']'."3
                    bill_to = bill_to && '}'."2
                    ENDIF.

                "bill_to = bill_to && '}'."1
            ENDIF.

            """""""""""""""""""""""""SHIP TO"""""""""""""""""""""""""""""""""
            IF sfrqapi_select-shipto_country IS NOT INITIAL AND sfrqapi_select-language IS NOT INITIAL.
                "ship_to = ship_to && '{'."1
                ship_to = ship_to && |"PostalCode": "{ sfrqapi_select-shipto_postalcode }",|.
                ship_to = ship_to && |"Country": "{ sfrqapi_select-shipto_country }",|.
                ship_to = ship_to && |"CityName": "{ sfrqapi_select-shipto_cityname }",|.
                ship_to = ship_to && |"Region": "{ sfrqapi_select-shipto_state }",|.
                ship_to = ship_to && |"Language": "{ sfrqapi_select-language }",|.
                ship_to = ship_to && |"StreetName": "{ sfrqapi_select-shipto_streetname }",|.
                ship_to = ship_to && |"StreetPrefixName": "{ sfrqapi_select-shipto_streetprefixname }",|.
                ship_to = ship_to && |"StreetSuffixName": "{ sfrqapi_select-shipto_streetsuffixname }",|.
                    ship_to = ship_to && '"to_AddressUsage": {'."2
                        ship_to = ship_to && '"results": ['.        "3
                        ship_to = ship_to && '{'."4
                            ship_to = ship_to && '"AddressUsage": "SHIP_TO",'.
                            ship_to = ship_to && '"StandardUsage": false'.
                        ship_to = ship_to && '}'."4
                        ship_to = ship_to && ']'."3
                    ship_to = ship_to && '}'."2

                    IF sfrqapi_select-phonenumber IS NOT INITIAL.
                        ship_to = ship_to && ',"to_PhoneNumber": {'."2
                        ship_to = ship_to && '"results": ['.        "3
                            ship_to = ship_to && '{'."4
                                ship_to = ship_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                                "ship_to = ship_to && |"IsDefaultPhoneNumber":{ sfrqapi_select-isdefaultphonenumber } ,|.
                                IF sfrqapi_select-isdefaultmobilephonenumber = 'X'.
                                    ship_to = ship_to && |"IsDefaultPhoneNumber": true ,|.
                                else.
                                    ship_to = ship_to && |"IsDefaultPhoneNumber": false ,|.
                                ENDIF.
                                ship_to = ship_to && |"PhoneNumber": "{ sfrqapi_select-phonenumber }"|.
                            ship_to = ship_to && '}'."4
                        ship_to = ship_to && ']'."3
                        ship_to = ship_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-mobilephone IS NOT INITIAL.
                    ship_to = ship_to && ',"to_MobilePhoneNumber": {'."2
                    ship_to = ship_to && '"results": ['.        "3
                        ship_to = ship_to && '{'."4
                            ship_to = ship_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                            "ship_to = ship_to && |"IsDefaultPhoneNumber": { sfrqapi_select-isdefaultmobilephonenumber },|.
                            IF sfrqapi_select-isdefaultmobilephonenumber = 'X'.
                                ship_to = ship_to && |"IsDefaultPhoneNumber": true ,|.
                            else.
                                ship_to = ship_to && |"IsDefaultPhoneNumber": false ,|.
                            ENDIF.
                            ship_to = ship_to && |"PhoneNumber": "{ sfrqapi_select-mobilephone }"|.
                        ship_to = ship_to && '}'."4
                    ship_to = ship_to && ']'."3
                    ship_to = ship_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-emailaddress IS NOT INITIAL.
                    ship_to = ship_to && ',"to_EmailAddress": {'."2
                    ship_to = ship_to && '"results": ['.        "3
                        ship_to = ship_to && '{'."4
                            ship_to = ship_to && '"IsDefaultEmailAddress": true,'.
                            ship_to = ship_to && |"EmailAddress": "{ sfrqapi_select-emailaddress }"|.
                        ship_to = ship_to && '}'."4
                    ship_to = ship_to && ']'."3
                    ship_to = ship_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-websiteurl IS NOT INITIAL.
                    ship_to = ship_to && ',"to_URLAddress": {'."2
                    ship_to = ship_to && '"results": ['.        "3
                        ship_to = ship_to && '{'."4
                            ship_to = ship_to && '"IsDefaultURLAddress": true,'.
                            ship_to = ship_to && |"WebsiteURL": "{ sfrqapi_select-websiteurl }"|.
                        ship_to = ship_to && '}'."4
                    ship_to = ship_to && ']'."3
                    ship_to = ship_to && '}'."2
                    ENDIF.

                "ship_to = ship_to && '}'."1
            ENDIF.

            """"""""""""""""""""""""""""REGISTER TO""""""""""""""""""""""""""""""
            IF sfrqapi_select-register_country IS NOT INITIAL AND sfrqapi_select-language IS NOT INITIAL.
                "regis_to = regis_to && '{'."1
                regis_to = regis_to && |"PostalCode": "{ sfrqapi_select-register_postalcode }",|.
                regis_to = regis_to && |"Country": "{ sfrqapi_select-register_country }",|.
                regis_to = regis_to && |"CityName": "{ sfrqapi_select-register_cityname }",|.
                regis_to = regis_to && |"Region": "{ sfrqapi_select-register_state }",|.
                regis_to = regis_to && |"Language": "{ sfrqapi_select-language }",|.
                regis_to = regis_to && |"StreetName": "{ sfrqapi_select-register_streetname }",|.
                regis_to = regis_to && |"StreetPrefixName": "{ sfrqapi_select-register_streetprefixname }",|.
                regis_to = regis_to && |"StreetSuffixName": "{ sfrqapi_select-register_streetsuffixname }",|.
                    regis_to = regis_to && '"to_AddressUsage": {'."2
                        regis_to = regis_to && '"results": ['.        "3
                        regis_to = regis_to && '{'."4
                            regis_to = regis_to && '"AddressUsage": "XXDEFAULT",'.
                            regis_to = regis_to && '"StandardUsage": false'.
                        regis_to = regis_to && '}'."4
                    regis_to = regis_to && ']'."3
                    regis_to = regis_to && '}'."2

                    IF sfrqapi_select-phonenumber IS NOT INITIAL.
                        regis_to = regis_to && ',"to_PhoneNumber": {'."2
                        regis_to = regis_to && '"results": ['.        "3
                            regis_to = regis_to && '{'."4
                                regis_to = regis_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                                "regis_to = regis_to && |"IsDefaultPhoneNumber": { sfrqapi_select-isdefaultphonenumber },|.
                                IF sfrqapi_select-isdefaultphonenumber = 'X'.
                                    regis_to = regis_to && |"IsDefaultPhoneNumber": true ,|.
                                else.
                                    regis_to = regis_to && |"IsDefaultPhoneNumber": false ,|.
                                ENDIF.
                                regis_to = regis_to && |"PhoneNumber": "{ sfrqapi_select-phonenumber }"|.
                            regis_to = regis_to && '}'."4
                        regis_to = regis_to && ']'."3
                        regis_to = regis_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-mobilephone IS NOT INITIAL.
                    regis_to = regis_to && ',"to_MobilePhoneNumber": {'."2
                    regis_to = regis_to && '"results": ['.        "3
                        regis_to = regis_to && '{'."4
                            regis_to = regis_to && |"DestinationLocationCountry": "{ sfrqapi_select-destinationlocationcountry }",|.
                            "regis_to = regis_to && |"IsDefaultPhoneNumber": { sfrqapi_select-isdefaultmobilephonenumber },|.
                            IF sfrqapi_select-isdefaultmobilephonenumber = 'X'.
                                regis_to = regis_to && |"IsDefaultPhoneNumber": true ,|.
                            else.
                                regis_to = regis_to && |"IsDefaultPhoneNumber": false ,|.
                            ENDIF.
                            regis_to = regis_to && |"PhoneNumber": "{ sfrqapi_select-mobilephone }"|.
                        regis_to = regis_to && '}'."4
                    regis_to = regis_to && ']'."3
                    regis_to = regis_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-emailaddress IS NOT INITIAL.
                    regis_to = regis_to && ',"to_EmailAddress": {'."2
                    regis_to = regis_to && '"results": ['.        "3
                        regis_to = regis_to && '{'."4
                            regis_to = regis_to && '"IsDefaultEmailAddress": true,'.
                            regis_to = regis_to && |"EmailAddress": "{ sfrqapi_select-emailaddress }"|.
                        regis_to = regis_to && '}'."4
                    regis_to = regis_to && ']'."3
                    regis_to = regis_to && '}'."2
                    ENDIF.

                    IF sfrqapi_select-websiteurl IS NOT INITIAL.
                    regis_to = regis_to && ',"to_URLAddress": {'."2
                    regis_to = regis_to && '"results": ['.        "3
                        regis_to = regis_to && '{'."4
                            regis_to = regis_to && '"IsDefaultURLAddress": true,'.
                            regis_to = regis_to && |"WebsiteURL": "{ sfrqapi_select-websiteurl }"|.
                        regis_to = regis_to && '}'."4
                    regis_to = regis_to && ']'."3
                    regis_to = regis_to && '}'."2
                    ENDIF.

                "regis_to = regis_to && '}'."1
           ENDIF.

            """"""""""""""""""""""""""""""BODY REQUEST"""""""""""""""""""""""""""""
            bodyjson = '{'."Header
            "bodyjson = bodyjson && |"BusinessPartner":"{ sfrqapi_select-businesspartnerid }",|.
            bodyjson = bodyjson && |"BusinessPartnerCategory": "{ sfrqapi_select-businesspartnercategory }",|.


            IF sfrqapi_select-yy1_fatca_1_bus = 'X'.

                bodyjson = bodyjson && |"YY1_FATCA_2_bus": true,|.
            ELSE.
                bodyjson = bodyjson && '"YY1_FATCA_2_bus": false,'.
            ENDIF.

            IF regis_to IS INITIAL AND ship_to IS INITIAL AND bill_to IS INITIAL.
                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_ADDRESS'
                                %msg            = new_message_with_text( text     = 'Address Country Or Language is null'
                                severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).
                RETURN.
            ENDIF.

            bodyjson = bodyjson && '"to_BusinessPartnerAddress": {'."to_BusinessPartnerAddress
                bodyjson = bodyjson && '"results": ['."1
                IF regis_to IS NOT INITIAL.
                    bodyjson = bodyjson && '{'.
                    bodyjson = bodyjson && regis_to.
                    bodyjson = bodyjson && '},'.
                ENDIF.

                IF ship_to IS NOT INITIAL.
                    bodyjson = bodyjson && '{'.
                    bodyjson = bodyjson && ship_to.
                    bodyjson = bodyjson && '},'.
                ENDIF.

                IF bill_to IS NOT INITIAL.
                    bodyjson = bodyjson && '{'.
                    bodyjson = bodyjson && bill_to.
                    bodyjson = bodyjson && '},'.
                ENDIF.
                bodyjson = shift_right( val = bodyjson places = 1 ).
                bodyjson = bodyjson && ']'."1
            bodyjson = bodyjson && '},'."to_BusinessPartnerAddress

            IF sfrqapi_select-is_contact = 'X' OR sfrqapi_select-is_contact = 'true'.
                bodyjson = bodyjson && |"FirstName": "{ sfrqapi_select-firstname }",|.
                bodyjson = bodyjson && |"LastName": "{ sfrqapi_select-lastname }",|.
                bodyjson = bodyjson && '"to_BusinessPartnerRole": {'."to_BusinessPartnerRole
                    bodyjson = bodyjson && '"results": ['."1
                        bodyjson = bodyjson && '{'."2
                            bodyjson = bodyjson && '"BusinessPartnerRole": "BUP001"'.
                        bodyjson = bodyjson && '}'."2
                    bodyjson = bodyjson && ']'."1
                bodyjson = bodyjson && '}'."to_BusinessPartnerRole

            ELSE.
                bodyjson = bodyjson && |"OrganizationBPName1": "{ sfrqapi_select-organizationbpname1 }",|.
                bodyjson = bodyjson && '"to_BusinessPartnerRole": {'."to_BusinessPartnerRole
                    bodyjson = bodyjson && '"results": ['."1
                        bodyjson = bodyjson && '{'."2
                            bodyjson = bodyjson && '"BusinessPartnerRole": "FLCU00"'.
                        bodyjson = bodyjson && '},'."2
                        bodyjson = bodyjson && '{'."3
                            bodyjson = bodyjson && '"BusinessPartnerRole": "FLCU01"'.
                        bodyjson = bodyjson && '}'."3
                    bodyjson = bodyjson && ']'."1
                bodyjson = bodyjson && '},'."to_BusinessPartnerRole


                IF sfrqapi_select-industrysector <> '' AND sfrqapi_select-industrysystemtype <> ''.
                    bodyjson = bodyjson && '"to_BuPaIndustry": {'."to_BuPaIndustry
                        bodyjson = bodyjson && '"results": ['."1
                            bodyjson = bodyjson && '{'."2
                                bodyjson = bodyjson && |"IndustrySector": "{ sfrqapi_select-industrysector }",|.
                                bodyjson = bodyjson && |"IndustrySystemType": "{ sfrqapi_select-industrysystemtype }"|.
                            bodyjson = bodyjson && '}'."2
                        bodyjson = bodyjson && ']'."1
                    bodyjson = bodyjson && '},'."to_BuPaIndustry
                ENDIF.

                bodyjson = bodyjson && '"to_Customer": {'."Customer
                    IF sfrqapi_select-customerclassification = 'Hot'.
                        bodyjson = bodyjson && |"CustomerClassification": "A",|.
                    ELSEIF sfrqapi_select-customerclassification = 'Warm'.
                        bodyjson = bodyjson && |"CustomerClassification": "B",|.
                    else.
                        bodyjson = bodyjson && |"CustomerClassification": "C",|.
                    ENDIF.
                    bodyjson = bodyjson && '"to_CustomerText": {'."1
                        bodyjson = bodyjson && '"results": ['."2
                            bodyjson = bodyjson && '{'."3
                                bodyjson = bodyjson && '"Language": "VI",'.
                                bodyjson = bodyjson && '"LongTextID": "TX01",'.
                                bodyjson = bodyjson && |"LongText": "{ sfrqapi_select-text }"|.
                            bodyjson = bodyjson && '}'."3
                        bodyjson = bodyjson && ']'."2
                    bodyjson = bodyjson && '},'."1

                    bodyjson = bodyjson && '"to_CustomerSalesArea": {'."1
                        bodyjson = bodyjson && '"results": ['."2
                            bodyjson = bodyjson && '{'."3
                                bodyjson = bodyjson && |"SalesOrganization": "{ sfrqapi_select-salesorganization }",|.
                                bodyjson = bodyjson && |"DistributionChannel": "{ sfrqapi_select-distributionchannel }",|.
                                bodyjson = bodyjson && |"Division": "{ sfrqapi_select-division }",|.
                                bodyjson = bodyjson && |"Currency": "{ sfrqapi_select-currency }",|.
                                bodyjson = bodyjson && '"to_SalesAreaTax": {'."4
                                    bodyjson = bodyjson && '"results": ['."5
                                        bodyjson = bodyjson && '{'."6
                                            bodyjson = bodyjson && '"CustomerTaxCategory": "TTX1",'.
                                            bodyjson = bodyjson && |"CustomerTaxClassification": "{ sfrqapi_select-customertaxclassification }"|.
                                        bodyjson = bodyjson && '}'."6
                                    bodyjson = bodyjson && ']'."5
                                bodyjson = bodyjson && '}'."4
                            bodyjson = bodyjson && '}'."3
                        bodyjson = bodyjson && ']'."2
                    bodyjson = bodyjson && '},'."1

                    bodyjson = bodyjson && '"to_CustomerCompany": {'."1
                        bodyjson = bodyjson && '"results": ['."2
                            bodyjson = bodyjson && '{'."3
                                bodyjson = bodyjson && |"CompanyCode": "{ sfrqapi_select-companycode }",|.
                                bodyjson = bodyjson && |"ReconciliationAccount": "{ sfrqapi_select-reconciliationaccount }",|.
                                bodyjson = bodyjson && |"PaymentTerms": "{ sfrqapi_select-paymentterms }"|.
                            bodyjson = bodyjson && '}'."3
                        bodyjson = bodyjson && ']'."2
                    bodyjson = bodyjson && '}'."1
                bodyjson = bodyjson && '}'."Customer
            ENDIF.
            bodyjson = bodyjson && '}'.

            "set request method and execute request

            lo_web_http_request->set_text( bodyjson ).

            lo_web_http_response = lo_web_http_client->execute( if_web_http_client=>POST ).

            lv_response_status = lo_web_http_response->get_status( )."GET RESPONSE STATUS
            DATA(lv_response) = lo_web_http_response->get_text( ).

            IF lv_response_status-code <> create-code.
                APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_ERROR'
                                %msg            = new_message_with_text( text     = |{ lv_response_status-code } - { lv_response_status-reason }|
                                severity    = if_abap_behv_message=>severity-error ) ) TO reported-salesforcerequestapi.
                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                  ENTITY SalesForceRequestAPI
                    UPDATE FIELDS ( businesspartnerid api_result )
                    WITH VALUE #( (
                                      %tky       = sfrqapi_select-%tky
                                      api_result = '400'
                                    ) ).

            else.
                """"""""""""""""""""""""HANDLE JSON""""""""""""""""""""""""""""""

                TYPES:
                    BEGIN OF ts_AddressUsage,
                      AddressUsage    TYPE string,
                    END OF ts_AddressUsage,
                    BEGIN OF rs_AddressUsage,
                      results    TYPE STANDARD TABLE OF ts_AddressUsage WITH EMPTY KEY,
                    END OF rs_AddressUsage,
                    BEGIN OF Address_ID,
                      AddressID    TYPE string,
                      to_AddressUsage   TYPE rs_AddressUsage,
                    END OF Address_ID,
                    BEGIN OF BusinessPartnerAddress,
                      results    TYPE STANDARD TABLE OF Address_ID WITH EMPTY KEY,
                    END OF BusinessPartnerAddress,
                    BEGIN OF BusinessPartnerHeader,
                      BusinessPartner    TYPE string,
                      Customer    TYPE string,
                      to_BusinessPartnerAddress TYPE BusinessPartnerAddress,
                    END OF BusinessPartnerHeader,
                    BEGIN OF d_root,
                      d    TYPE BusinessPartnerHeader,
                    END OF d_root.
                     DATA ls_osm TYPE d_root.

                      " Convert the data from JSON to ABAP using the XCO Library; output the data
                    TRY.

                      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
                        ( xco_cp_json=>transformation->pascal_case_to_underscore )
                        ( xco_cp_json=>transformation->boolean_to_abap_bool )
                      ) )->write_to( REF #( ls_osm ) ).
                    IF sfrqapi_select-is_contact = 'X' OR sfrqapi_select-is_contact = 'true'.
                        businessPartnerID = ls_osm-d-businesspartner.
                        data(temp) = 'A_BusinessPartner('.
                        IF lv_response CS temp.
                            temp = substring( val = lv_response off = sy-fdpos + 19 len = 7 ).
                            businessPartnerID = temp.
                        ENDIF.
                    else.
                        businessPartnerID = ls_osm-d-customer.
                    ENDIF.
                    LOOP AT ls_osm-d-to_businesspartneraddress-results ASSIGNING FIELD-SYMBOL(<element>).
                        Data: usage type string,
                              addressID type string.

                        addressID = <element>-addressid.
                        Data(usage_rs) = <element>-to_addressusage-results.
                        LOOP AT usage_rs ASSIGNING FIELD-SYMBOL(<element1>).
                            usage = <element1>-addressusage.
                            if usage = 'BILL_TO'.
                                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                  ENTITY SalesForceRequestAPI
                                    UPDATE FIELDS ( billto_addressid )
                                    WITH VALUE #( (
                                                      %tky       = sfrqapi_select-%tky
                                                      billto_addressid = addressID
                                                    ) ).
                            ENDIF.

                            if usage = 'XXDEFAULT'.
                                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                              ENTITY SalesForceRequestAPI
                                UPDATE FIELDS ( register_addressid )
                                WITH VALUE #( (
                                                  %tky       = sfrqapi_select-%tky
                                                  register_addressid = addressid
                                                ) ).
                            ENDIF.

                            if usage = 'SHIP_TO'.
                                MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                                  ENTITY SalesForceRequestAPI
                                    UPDATE FIELDS ( shipto_addressid )
                                    WITH VALUE #( (
                                                      %tky       = sfrqapi_select-%tky
                                                      shipto_addressid = addressid
                                                    ) ).
                            ENDIF.
                         ENDLOOP.
                    ENDLOOP.
                    APPEND VALUE #( %tky            = sfrqapi_select-%tky
                                %state_area     = 'VALIDATE_SUCCESS'
                                %msg            = new_message_with_text( text     = |Business Partner created: { businessPartnerID }|
                               severity    = if_abap_behv_message=>severity-success ) ) TO reported-salesforcerequestapi.

                        MODIFY ENTITIES OF zi_sfrqapi IN LOCAL MODE
                          ENTITY SalesForceRequestAPI
                            UPDATE FIELDS ( businesspartnerid api_result )
                            WITH VALUE #( (
                                              %tky       = sfrqapi_select-%tky
                                              businesspartnerid = businessPartnerID
                                              api_result = '200'
                                            ) ).
                " catch any error
                    CATCH cx_root INTO DATA(lx_root).


                    ENDTRY.

            ENDIF.
        ELSE."SOMETHING


        ENDIF.

        ENDLOOP.

        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
            "error handling
        ENDTRY.

        "uncomment the following line for console output; prerequisite: code snippet is implementation of if_oo_adt_classrun~main
        "out->write( |response:  { lv_response }| ).
  ENDMETHOD.

ENDCLASS.
