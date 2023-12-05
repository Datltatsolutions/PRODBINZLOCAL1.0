class ZCL_S4_BUPA_002 definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_S4_BUPA_002 IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
    Data json type string.

   json = '{"d":{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartne' &&
'r(''1231123125'')","type":"API_BUSINESS_PARTNER.A_BusinessPartnerType"},"BusinessPartner":"1231123125","Customer":"1231123125","Supplier":"","AcademicTitle":"","AuthorizationGroup":"","BusinessPartnerCategory":"2","BusinessPartnerFullName":"","Busi' &&
'nessPartnerGrouping":"","BusinessPartnerName":"","BusinessPartnerUUID":"f9503ea8-fcd9-1ede-9fa7-1dfe572e8539","CorrespondenceLanguage":"","CreatedByUser":"","CreationDate":null,"CreationTime":"PT00H00M00S","FirstName":"","FormOfAddress":"","Industr' &&
'y":"","InternationalLocationNumber1":"0","InternationalLocationNumber2":"0","IsFemale":false,"IsMale":false,"IsNaturalPerson":"","IsSexUnknown":false,"GenderCodeName":"","Language":"","LastChangeDate":null,"LastChangeTime":"PT00H00M00S","LastChange' &&
'dByUser":"","LastName":"","LegalForm":"","OrganizationBPName1":"TEST CUSTOM api","OrganizationBPName2":"","OrganizationBPName3":"","OrganizationBPName4":"","OrganizationFoundationDate":null,"OrganizationLiquidationDate":null,"SearchTerm1":"","Searc' &&
'hTerm2":"","AdditionalLastName":"","BirthDate":null,"BusinessPartnerBirthDateStatus":"","BusinessPartnerBirthplaceName":"","BusinessPartnerDeathDate":null,"BusinessPartnerIsBlocked":false,"BusinessPartnerType":"","ETag":"","GroupBusinessPartnerName' &&
'1":"","GroupBusinessPartnerName2":"","IndependentAddressID":"","InternationalLocationNumber3":"0","MiddleName":"","NameCountry":"","NameFormat":"","PersonFullName":"","PersonNumber":"","IsMarkedForArchiving":false,"BusinessPartnerIDByExtSystem":"",' &&
'"BusinessPartnerPrintFormat":"","BusinessPartnerOccupation":"","BusPartMaritalStatus":"","BusPartNationality":"","BusinessPartnerBirthName":"","BusinessPartnerSupplementName":"","NaturalPersonEmployerName":"","LastNamePrefix":"","LastNameSecondPref' &&
'ix":"","Initials":"","BPDataControllerIsNotRequired":false,"TradingPartner":"","YY1_FATCA_1_bus":true,"YY1_FATCA_1_busF":0,"to_BPCreditWorthiness":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_' &&
'BusinessPartner(''1231123125'')/to_BPCreditWorthiness"}},"to_BPDataController":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BPDataController"}},"to_BPFinServ' &&
'icesReporting":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BPFinServicesReporting"}},"to_BPFiscalYearInformation":{"__deferred":{"uri":"https://my406848-api' &&
'.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BPFiscalYearInformation"}},"to_BPRelationship":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Busine' &&
'ssPartner(''1231123125'')/to_BPRelationship"}},"to_BuPaIdentification":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BuPaIdentification"}},"to_BuPaIndustry":{' &&
'"results":[{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BuPaIndustry(IndustrySector=''91'',IndustrySystemType=''0001'',BusinessPartner=''1231123125'')","uri":"https://my406848-api.s4hana.cloud.' &&
'sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BuPaIndustry(IndustrySector=''91'',IndustrySystemType=''0001'',BusinessPartner=''1231123125'')","type":"API_BUSINESS_PARTNER.A_BuPaIndustryType"},"IndustrySector":"91","IndustrySystemType":"0001","Busine' &&
'ssPartner":"1231123125","IsStandardIndustry":"","IndustryKeyDescription":""}]},"to_BusinessPartner":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BusinessPart' &&
'ner"}},"elements":{"results":[{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner=''1231123125'',AddressID=''760'')","uri":"https://my406848-api' &&
'.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner=''1231123125'',AddressID=''760'')","type":"API_BUSINESS_PARTNER.A_BusinessPartnerAddressType"},"BusinessPartner":"1231123125","AddressID":"760","Valid' &&
'ityStartDate":null,"ValidityEndDate":"/Date(253402300799000+0000)/","AuthorizationGroup":"","AddressUUID":"f9503ea8-fcd9-1ede-9fa7-1dfe572ea539","AdditionalStreetPrefixName":"","AdditionalStreetSuffixName":"","AddressTimeZone":"","CareOfName":"","C' &&
'ityCode":"","CityName":"","CompanyPostalCode":"","Country":"VN","County":"","DeliveryServiceNumber":"","DeliveryServiceTypeCode":"","District":"","FormOfAddress":"","FullName":"","HomeCityName":"","HouseNumber":"","HouseNumberSupplementText":"","La' &&
'nguage":"VI","POBox":"","POBoxDeviatingCityName":"","POBoxDeviatingCountry":"","POBoxDeviatingRegion":"","POBoxIsWithoutNumber":false,"POBoxLobbyName":"","POBoxPostalCode":"","Person":"","PostalCode":"760000","PrfrdCommMediumType":"","Region":"SG",' &&
'"StreetName":"LY THANH TONG","StreetPrefixName":"A","StreetSuffixName":"A","TaxJurisdiction":"","TransportZone":"","AddressIDByExternalSystem":"","CountyCode":"","TownshipCode":"","TownshipName":"","tags":{"results":[{"__metadata":{"id":' &&
'"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BuPaAddressUsage(BusinessPartner=''1231123125'',ValidityEndDate=datetimeoffset''9999-12-31T23%3A59%3A59Z'',AddressUsage=''XXDEFAULT'',AddressID=''760'')","uri":"https:/' &&
'/my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BuPaAddressUsage(BusinessPartner=''1231123125'',ValidityEndDate=datetimeoffset''9999-12-31T23%3A59%3A59Z'',AddressUsage=''XXDEFAULT'',AddressID=''760'')","type":"API_BUSINESS_P' &&
'ARTNER.A_BuPaAddressUsageType"},"BusinessPartner":"1231123125","ValidityEndDate":"/Date(253402300799000+0000)/","AddressUsage":"XXDEFAULT","AddressID":"760","ValidityStartDate":null,"StandardUsage":false,"AuthorizationGroup":""}]},"to_BPAddrDepdntI' &&
'ntlLocNumber":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner=''1231123125'',AddressID=''760'')/to_BPAddrDepdntIntlLocNumber"}},"to_BPIntlAddressVersion":{"' &&
'__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner=''1231123125'',AddressID=''760'')/to_BPIntlAddressVersion"}},"to_EmailAddress":{"__deferred":{"uri":"https://m' &&
'y406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner=''1231123125'',AddressID=''760'')/to_EmailAddress"}},"to_FaxNumber":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/oda' &&
'ta/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner=''1231123125'',AddressID=''760'')/to_FaxNumber"}},"to_MobilePhoneNumber":{"results":[{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PART' &&
'NER/A_AddressPhoneNumber(AddressID=''760'',Person='''',OrdinalNumber=''0'')","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID=''760'',Person='''',OrdinalNumber=''0'')","type":"API_BU' &&
'SINESS_PARTNER.A_AddressPhoneNumberType"},"AddressID":"760","Person":"","OrdinalNumber":"0","DestinationLocationCountry":"VN","IsDefaultPhoneNumber":false,"PhoneNumber":"090922222","PhoneNumberExtension":"","InternationalPhoneNumber":"","PhoneNumbe' &&
'rType":"3","AddressCommunicationRemarkText":""}]},"to_PhoneNumber":{"results":[{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID=''760'',Person='''',OrdinalNumber=''0'')' &&
'","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID=''760'',Person='''',OrdinalNumber=''0'')","type":"API_BUSINESS_PARTNER.A_AddressPhoneNumberType"},"AddressID":"760","Person":"","Or' &&
'dinalNumber":"0","DestinationLocationCountry":"VN","IsDefaultPhoneNumber":true,"PhoneNumber":"123456789","PhoneNumberExtension":"","InternationalPhoneNumber":"","PhoneNumberType":"1","AddressCommunicationRemarkText":""}]},"to_URLAddress":{"results"' &&
':[{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressHomePageURL(AddressID=''760'',Person='''',OrdinalNumber=''0'',ValidityStartDate=datetime''0001-01-01T00%3A00%3A00'',IsDefaultURLAddress=tru' &&
'e)","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressHomePageURL(AddressID=''760'',Person='''',OrdinalNumber=''0'',ValidityStartDate=datetime''0001-01-01T00%3A00%3A00'',IsDefaultURLAddress=true)","type":"' &&
'API_BUSINESS_PARTNER.A_AddressHomePageURLType"},"AddressID":"760","Person":"","OrdinalNumber":"0","ValidityStartDate":"/Date(-62135769600000)/","IsDefaultURLAddress":true,"SearchURLAddress":"","AddressCommunicationRemarkText":"","URLFieldLength":14' &&
',"WebsiteURL":"TEST@GMAIL.COM"}]}}]},"to_BusinessPartnerBank":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BusinessPartnerBank"}},"to_BusinessPartnerContact"' &&
':{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BusinessPartnerContact"}},"to_BusinessPartnerRating":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sa' &&
'p/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BusinessPartnerRating"}},"to_BusinessPartnerRole":{"results":[{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Business' &&
'PartnerRole(BusinessPartner=''1231123125'',BusinessPartnerRole=''FLCU00'')","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerRole(BusinessPartner=''1231123125'',BusinessPartnerRole=''FLCU00'')","t' &&
'ype":"API_BUSINESS_PARTNER.A_BusinessPartnerRoleType"},"BusinessPartner":"1231123125","BusinessPartnerRole":"FLCU00","ValidFrom":null,"ValidTo":null,"AuthorizationGroup":""},{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/s' &&
'ap/API_BUSINESS_PARTNER/A_BusinessPartnerRole(BusinessPartner=''1231123125'',BusinessPartnerRole=''FLCU01'')","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerRole(BusinessPartner=''1231123125'',B' &&
'usinessPartnerRole=''FLCU01'')","type":"API_BUSINESS_PARTNER.A_BusinessPartnerRoleType"},"BusinessPartner":"1231123125","BusinessPartnerRole":"FLCU01","ValidFrom":null,"ValidTo":null,"AuthorizationGroup":""}]},"to_BusinessPartnerTax":{"__deferred":' &&
'{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BusinessPartnerTax"}},"to_BusPartAddrDepdntTaxNmbr":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/' &&
'sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_BusPartAddrDepdntTaxNmbr"}},"to_Customer":{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer(''1231123125'')","uri":"https://my4' &&
'06848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer(''1231123125'')","type":"API_BUSINESS_PARTNER.A_CustomerType"},"Customer":"1231123125","AuthorizationGroup":"","BillingIsBlockedForCustomer":"","CreatedByUser":"","Creatio' &&
'nDate":null,"CustomerAccountGroup":"","CustomerClassification":"B","CustomerFullName":"","BPCustomerFullName":"","CustomerName":"","BPCustomerName":"","DeliveryIsBlocked":"","FreeDefinedAttribute01":"","FreeDefinedAttribute02":"","FreeDefinedAttrib' &&
'ute03":"","FreeDefinedAttribute04":"","FreeDefinedAttribute05":"","FreeDefinedAttribute06":"","FreeDefinedAttribute07":"","FreeDefinedAttribute08":"","FreeDefinedAttribute09":"","FreeDefinedAttribute10":"","NFPartnerIsNaturalPerson":"","OrderIsBloc' &&
'kedForCustomer":"","PostingIsBlocked":false,"Supplier":"","CustomerCorporateGroup":"","FiscalAddress":"","Industry":"","IndustryCode1":"","IndustryCode2":"","IndustryCode3":"","IndustryCode4":"","IndustryCode5":"","InternationalLocationNumber1":"0"' &&
',"InternationalLocationNumber2":"0","InternationalLocationNumber3":"0","NielsenRegion":"","PaymentReason":"","ResponsibleType":"","TaxNumber1":"","TaxNumber2":"","TaxNumber3":"","TaxNumber4":"","TaxNumber5":"","TaxNumberType":"","VATRegistration":"' &&
'","DeletionIndicator":false,"ExpressTrainStationName":"","TrainStationName":"","CityCode":"","County":"","to_CustAddrDepdntExtIdentifier":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer(' &&
'''1231123125'')/to_CustAddrDepdntExtIdentifier"}},"to_CustAddrDepdntInformation":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer(''1231123125'')/to_CustAddrDepdntInformation"}},"to_Custo' &&
'merCompany":{"results":[{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerCompany(Customer='''',CompanyCode=''1010'')","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSI' &&
'NESS_PARTNER/A_CustomerCompany(Customer='''',CompanyCode=''1010'')","type":"API_BUSINESS_PARTNER.A_CustomerCompanyType"},"Customer":"","CompanyCode":"1010","APARToleranceGroup":"","AccountByCustomer":"","AccountingClerk":"","AccountingClerkFaxNumbe' &&
'r":"","AccountingClerkInternetAddress":"","AccountingClerkPhoneNumber":"","AlternativePayerAccount":"","AuthorizationGroup":"","CollectiveInvoiceVariant":"","CustomerAccountNote":"","CustomerHeadOffice":"","CustomerSupplierClearingIsUsed":false,"Ho' &&
'useBank":"","InterestCalculationCode":"","InterestCalculationDate":null,"IntrstCalcFrequencyInMonths":"0","IsToBeLocallyProcessed":false,"ItemIsToBePaidSeparately":false,"LayoutSortingRule":"","PaymentBlockingReason":"","PaymentMethodsList":"","Pay' &&
'mentReason":"","PaymentTerms":"0004","PaytAdviceIsSentbyEDI":false,"PhysicalInventoryBlockInd":false,"ReconciliationAccount":"12100000","RecordPaymentHistoryIndicator":false,"UserAtCustomer":"","DeletionIndicator":false,"CashPlanningGroup":"","Know' &&
'nOrNegotiatedLeave":"","ValueAdjustmentKey":"","CustomerAccountGroup":"","to_CompanyText":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerCompany(Customer='''',CompanyCode=''1010'')/to_Co' &&
'mpanyText"}},"to_CustomerDunning":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerCompany(Customer='''',CompanyCode=''1010'')/to_CustomerDunning"}},"to_WithHoldingTax":{"__deferred":{"uri' &&
'":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerCompany(Customer='''',CompanyCode=''1010'')/to_WithHoldingTax"}}}]},"to_CustomerSalesArea":{"results":[{"__metadata":{"id":"https://my406848-api.s4hana.cloud.' &&
'sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesArea(Customer=''1231123125'',SalesOrganization=''1010'',DistributionChannel=''10'',Division=''00'')","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Cus' &&
'tomerSalesArea(Customer=''1231123125'',SalesOrganization=''1010'',DistributionChannel=''10'',Division=''00'')","type":"API_BUSINESS_PARTNER.A_CustomerSalesAreaType"},"Customer":"1231123125","SalesOrganization":"1010","DistributionChannel":"10","Div' &&
'ision":"00","AccountByCustomer":"","AuthorizationGroup":"","BillingIsBlockedForCustomer":"","CompleteDeliveryIsDefined":false,"CreditControlArea":"","Currency":"VND","CustIsRlvtForSettlmtMgmt":false,"CustomerABCClassification":"","CustomerAccountAs' &&
'signmentGroup":"","CustomerGroup":"","CustomerIsRebateRelevant":false,"CustomerPaymentTerms":"","CustomerPriceGroup":"","CustomerPricingProcedure":"","CustProdProposalProcedure":"","DeliveryIsBlockedForCustomer":"","DeliveryPriority":"0","Incoterms' &&
'Classification":"","IncotermsLocation2":"","IncotermsVersion":"","IncotermsLocation1":"","IncotermsSupChnLoc1AddlUUID":"00000000-0000-0000-0000-000000000000","IncotermsSupChnLoc2AddlUUID":"00000000-0000-0000-0000-000000000000","IncotermsSupChnDvtgL' &&
'ocAddlUUID":"00000000-0000-0000-0000-000000000000","DeletionIndicator":false,"IncotermsTransferLocation":"","InspSbstHasNoTimeOrQuantity":false,"InvoiceDate":"","ItemOrderProbabilityInPercent":"0","ManualInvoiceMaintIsRelevant":false,"MaxNmbrOfPart' &&
'ialDelivery":"0","OrderCombinationIsAllowed":false,"OrderIsBlockedForCustomer":"","OverdelivTolrtdLmtRatioInPct":"0.0","PartialDeliveryIsAllowed":"","PriceListType":"","ProductUnitGroup":"","ProofOfDeliveryTimeValue":"0.00","SalesGroup":"","SalesIt' &&
'emProposal":"","SalesOffice":"","ShippingCondition":"","SlsDocIsRlvtForProofOfDeliv":false,"SlsUnlmtdOvrdelivIsAllwd":false,"SupplyingPlant":"","SalesDistrict":"","UnderdelivTolrtdLmtRatioInPct":"0.0","InvoiceListSchedule":"","ExchangeRateType":"",' &&
'"AdditionalCustomerGroup1":"","AdditionalCustomerGroup2":"","AdditionalCustomerGroup3":"","AdditionalCustomerGroup4":"","AdditionalCustomerGroup5":"","PaymentGuaranteeProcedure":"","CustomerAccountGroup":"","to_PartnerFunction":{"__deferred":{"uri"' &&
':"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesArea(Customer=''1231123125'',SalesOrganization=''1010'',DistributionChannel=''10'',Division=''00'')/to_PartnerFunction"}},"to_SalesAreaTax":{"results":[{"' &&
'__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesAreaTax(Customer=''1231123125'',SalesOrganization=''1010'',DistributionChannel=''10'',Division=''00'',DepartureCountry='''',CustomerTaxCa' &&
'tegory=''TTX1'')","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesAreaTax(Customer=''1231123125'',SalesOrganization=''1010'',DistributionChannel=''10'',Division=''00'',DepartureCountry='''',Custome' &&
'rTaxCategory=''TTX1'')","type":"API_BUSINESS_PARTNER.A_CustomerSalesAreaTaxType"},"Customer":"1231123125","SalesOrganization":"1010","DistributionChannel":"10","Division":"00","DepartureCountry":"","CustomerTaxCategory":"TTX1","CustomerTaxClassific' &&
'ation":"1","to_SlsAreaAddrDepdntTax":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesAreaTax(Customer=''1231123125'',SalesOrganization=''1010'',DistributionChannel=''10'',Division=''' &&
'00'',DepartureCountry='''',CustomerTaxCategory=''TTX1'')/to_SlsAreaAddrDepdntTax"}}}]},"to_SalesAreaText":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesArea(Customer=''1231123125''' &&
',SalesOrganization=''1010'',DistributionChannel=''10'',Division=''00'')/to_SalesAreaText"}},"to_SlsAreaAddrDepdntInfo":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesArea(Customer=' &&
'''1231123125'',SalesOrganization=''1010'',DistributionChannel=''10'',Division=''00'')/to_SlsAreaAddrDepdntInfo"}}}]},"to_CustomerTaxGrouping":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Custo' &&
'mer(''1231123125'')/to_CustomerTaxGrouping"}},"to_CustomerText":{"results":[{"__metadata":{"id":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerText(Customer=''1231123125'',Language=''VI'',LongTextID=''TX01''' &&
')","uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerText(Customer=''1231123125'',Language=''VI'',LongTextID=''TX01'')","type":"API_BUSINESS_PARTNER.A_CustomerTextType"},"Customer":"1231123125","Language"' &&
':"VI","LongTextID":"TX01","LongText":"TESST"}]},"to_CustomerUnloadingPoint":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer(''1231123125'')/to_CustomerUnloadingPoint"}},"to_CustUnldgPtAd' &&
'drDepdntInfo":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer(''1231123125'')/to_CustUnldgPtAddrDepdntInfo"}}},"to_PaymentCard":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sa' &&
'p/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_PaymentCard"}},"to_Supplier":{"__deferred":{"uri":"https://my406848-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(''1231123125'')/to_Suppl' &&
'ier"}}}}'.

    TYPES:
        BEGIN OF ts_AddressUsage,
          ValidityEndDate TYPE string,
          AddressUsage    TYPE string,
        END OF ts_AddressUsage,

        BEGIN OF rs_AddressUsage,
          results    TYPE TABLE OF ts_AddressUsage with DEFAULT KEY,
        END OF rs_AddressUsage,

        BEGIN OF ts_address,
          AddressID         TYPE string,
          cityName          TYPE string,
          StreetName        TYPE string,
          StreetPrefixName  TYPE string,
          tags   TYPE rs_AddressUsage,
        END OF ts_address,

        BEGIN OF rs_address,
          results    TYPE TABLE OF ts_address with DEFAULT KEY,
        END OF rs_address,

        BEGIN OF ts_osm,
          customer  Type string,
          elements TYPE rs_address,
        END OF ts_osm,

        BEGIN OF ts_d,
          d TYPE ts_osm,
        END OF ts_d.

         DATA ls_osm TYPE ts_d.

          " Convert the data from JSON to ABAP using the XCO Library; output the data
        TRY.




          xco_cp_json=>data->from_string( json )->apply( VALUE #(
            ( xco_cp_json=>transformation->pascal_case_to_underscore )
            ( xco_cp_json=>transformation->boolean_to_abap_bool )
          ) )->write_to( REF #( ls_osm ) ).

        LOOP AT ls_osm-d-elements-results ASSIGNING FIELD-SYMBOL(<element>).
            Data: usage type string,
                  addressID type string.

            addressID = <element>-addressid.
            Data(usage_rs) = <element>-tags-results.
            LOOP AT usage_rs ASSIGNING FIELD-SYMBOL(<element1>).
                usage = <element1>-addressusage.
                if usage = 'BILL_TO'.

                ENDIF.

                if usage = 'XXDEFAULT'.

                ENDIF.

                if usage = 'SHIP_TO'.

                ENDIF.
             ENDLOOP.
        ENDLOOP.
    " catch any error
        CATCH cx_root INTO DATA(lx_root).


        ENDTRY.
  endmethod.
ENDCLASS.
