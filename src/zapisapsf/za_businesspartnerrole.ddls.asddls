/********** GENERATED on 10/21/2023 at 14:35:34 by CB9980000011**************/
 @OData.entitySet.name: 'A_BusinessPartnerRole' 
 @OData.entityType.name: 'A_BusinessPartnerRoleType' 
 define root abstract entity ZA_BUSINESSPARTNERROLE { 
 key BusinessPartner : abap.char( 10 ) ; 
 key BusinessPartnerRole : abap.char( 6 ) ; 
 @Odata.property.valueControl: 'ValidFrom_vc' 
 ValidFrom : tzntstmpl ; 
 ValidFrom_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ValidTo_vc' 
 ValidTo : tzntstmpl ; 
 ValidTo_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AuthorizationGroup_vc' 
 AuthorizationGroup : abap.char( 4 ) ; 
 AuthorizationGroup_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
