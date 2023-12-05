/********** GENERATED on 10/21/2023 at 14:35:33 by CB9980000011**************/
 @OData.entitySet.name: 'A_BusinessPartnerPaymentCard' 
 @OData.entityType.name: 'A_BusinessPartnerPaymentCardType' 
 define root abstract entity ZA_BUSINESSPARTNERPAYMENTCARD { 
 key BusinessPartner : abap.char( 10 ) ; 
 key PaymentCardID : abap.char( 6 ) ; 
 key PaymentCardType : abap.char( 4 ) ; 
 key CardNumber : abap.char( 25 ) ; 
 @Odata.property.valueControl: 'IsStandardCard_vc' 
 IsStandardCard : abap_boolean ; 
 IsStandardCard_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CardDescription_vc' 
 CardDescription : abap.char( 40 ) ; 
 CardDescription_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ValidityDate_vc' 
 ValidityDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 ValidityDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ValidityEndDate_vc' 
 ValidityEndDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 ValidityEndDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CardHolder_vc' 
 CardHolder : abap.char( 40 ) ; 
 CardHolder_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CardIssuingBank_vc' 
 CardIssuingBank : abap.char( 40 ) ; 
 CardIssuingBank_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CardIssueDate_vc' 
 CardIssueDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 CardIssueDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PaymentCardLock_vc' 
 PaymentCardLock : abap.char( 2 ) ; 
 PaymentCardLock_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'MaskedCardNumber_vc' 
 MaskedCardNumber : abap.char( 25 ) ; 
 MaskedCardNumber_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
