/********** GENERATED on 10/21/2023 at 14:35:24 by CB9980000011**************/
 @OData.entitySet.name: 'A_BPDataController' 
 @OData.entityType.name: 'A_BPDataControllerType' 
 define root abstract entity ZA_BPDATACONTROLLER { 
 key BusinessPartner : abap.char( 10 ) ; 
 key DataController : abap.char( 30 ) ; 
 key PurposeForPersonalData : abap.char( 30 ) ; 
 @Odata.property.valueControl: 'DataControlAssignmentStatus_vc' 
 DataControlAssignmentStatus : abap.char( 1 ) ; 
 DataControlAssignmentStatus_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'BPDataControllerIsDerived_vc' 
 BPDataControllerIsDerived : abap.char( 1 ) ; 
 BPDataControllerIsDerived_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PurposeDerived_vc' 
 PurposeDerived : abap.char( 1 ) ; 
 PurposeDerived_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PurposeType_vc' 
 PurposeType : abap.char( 1 ) ; 
 PurposeType_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'BusinessPurposeFlag_vc' 
 BusinessPurposeFlag : abap.char( 1 ) ; 
 BusinessPurposeFlag_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
