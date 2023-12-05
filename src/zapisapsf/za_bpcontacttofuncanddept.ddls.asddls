/********** GENERATED on 10/21/2023 at 14:35:22 by CB9980000011**************/
 @OData.entitySet.name: 'A_BPContactToFuncAndDept' 
 @OData.entityType.name: 'A_BPContactToFuncAndDeptType' 
 define root abstract entity ZA_BPCONTACTTOFUNCANDDEPT { 
 key RelationshipNumber : abap.char( 12 ) ; 
 key BusinessPartnerCompany : abap.char( 10 ) ; 
 key BusinessPartnerPerson : abap.char( 10 ) ; 
 key ValidityEndDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 @Odata.property.valueControl: 'ContactPersonAuthorityType_vc' 
 ContactPersonAuthorityType : abap.char( 1 ) ; 
 ContactPersonAuthorityType_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ContactPersonDepartment_vc' 
 ContactPersonDepartment : abap.char( 4 ) ; 
 ContactPersonDepartment_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ContactPersonDepartmentName_vc' 
 ContactPersonDepartmentName : abap.char( 40 ) ; 
 ContactPersonDepartmentName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ContactPersonFunction_vc' 
 ContactPersonFunction : abap.char( 4 ) ; 
 ContactPersonFunction_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ContactPersonFunctionName_vc' 
 ContactPersonFunctionName : abap.char( 40 ) ; 
 ContactPersonFunctionName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ContactPersonRemarkText_vc' 
 ContactPersonRemarkText : abap.char( 40 ) ; 
 ContactPersonRemarkText_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ContactPersonVIPType_vc' 
 ContactPersonVIPType : abap.char( 1 ) ; 
 ContactPersonVIPType_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'EmailAddress_vc' 
 EmailAddress : abap.char( 241 ) ; 
 EmailAddress_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'FaxNumber_vc' 
 FaxNumber : abap.char( 30 ) ; 
 FaxNumber_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'FaxNumberExtension_vc' 
 FaxNumberExtension : abap.char( 10 ) ; 
 FaxNumberExtension_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PhoneNumber_vc' 
 PhoneNumber : abap.char( 30 ) ; 
 PhoneNumber_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PhoneNumberExtension_vc' 
 PhoneNumberExtension : abap.char( 10 ) ; 
 PhoneNumberExtension_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'RelationshipCategory_vc' 
 RelationshipCategory : abap.char( 6 ) ; 
 RelationshipCategory_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
