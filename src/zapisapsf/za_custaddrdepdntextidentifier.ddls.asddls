/********** GENERATED on 10/21/2023 at 14:35:37 by CB9980000011**************/
 @OData.entitySet.name: 'A_CustAddrDepdntExtIdentifier' 
 @OData.entityType.name: 'A_CustAddrDepdntExtIdentifierType' 
 define root abstract entity ZA_CUSTADDRDEPDNTEXTIDENTIFIER { 
 key Customer : abap.char( 10 ) ; 
 key AddressID : abap.char( 10 ) ; 
 @Odata.property.valueControl: 'CustomerExternalRefID_vc' 
 CustomerExternalRefID : abap.char( 12 ) ; 
 CustomerExternalRefID_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
