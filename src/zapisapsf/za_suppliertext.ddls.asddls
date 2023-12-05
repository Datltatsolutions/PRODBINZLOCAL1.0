/********** GENERATED on 10/21/2023 at 14:35:56 by CB9980000011**************/
 @OData.entitySet.name: 'A_SupplierText' 
 @OData.entityType.name: 'A_SupplierTextType' 
 define root abstract entity ZA_SUPPLIERTEXT { 
 key Supplier : abap.char( 10 ) ; 
 key Language : abap.char( 2 ) ; 
 key LongTextID : abap.char( 4 ) ; 
 @Odata.property.valueControl: 'LongText_vc' 
 LongText : abap.string( 0 ) ; 
 LongText_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
