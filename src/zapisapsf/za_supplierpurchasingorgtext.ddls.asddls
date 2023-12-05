/********** GENERATED on 10/21/2023 at 14:35:55 by CB9980000011**************/
 @OData.entitySet.name: 'A_SupplierPurchasingOrgText' 
 @OData.entityType.name: 'A_SupplierPurchasingOrgTextType' 
 define root abstract entity ZA_SUPPLIERPURCHASINGORGTEXT { 
 key Supplier : abap.char( 10 ) ; 
 key PurchasingOrganization : abap.char( 4 ) ; 
 key Language : abap.char( 2 ) ; 
 key LongTextID : abap.char( 4 ) ; 
 @Odata.property.valueControl: 'LongText_vc' 
 LongText : abap.string( 0 ) ; 
 LongText_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
