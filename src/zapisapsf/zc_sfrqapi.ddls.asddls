@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for SFRQAPI'
@UI: 
    { headerInfo: { typeName: 'SF Request API', 
      typeNamePlural: 'SF Request API' } }
@Search.searchable: true
//@Metadata.allowExtensions: true
define root view entity ZC_SFRQAPI
provider contract transactional_query
as projection on ZI_SFRQAPI as SalesForceRequestAPI
{

 @UI.facet: [{ id: 'mykey',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                  label: 'SalesForce Request API',
                  position: 10 }]                  

      @UI: {
          lineItem:       [ { position: 40, importance: #HIGH, label: 'SalesForce Account ID'  } ],
          identification: [ { position: 40, label: 'SalesForce Account ID' } ] }
          @EndUserText.label: 'SalesForce Account ID'
    key salesforceaccountid as SalesForceAccountID,
        @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Auth Token'  }],
          identification: [ { position: 10, label: 'Auth Token' }, {type: #FOR_ACTION, dataAction: 'ActionUpdateAuthToken', label:'Update Auth Token'} ] }
         @Search.defaultSearchElement: true
    authtoken as AuthToken,
    @UI: {
          lineItem:       [ { position: 20, importance: #MEDIUM, label: 'Status'  } ],
          identification: [ { position: 20, label: 'Status' } ] }
         @Search.defaultSearchElement: true
    status as Status,
    @UI: {
          lineItem:       [ { position: 30, importance: #MEDIUM, label: 'Create At'  } ],
          identification: [ { position: 30, label: 'Create At' } ] }
          @EndUserText.label: 'Create At'
    created_at as CreateAt,
    
    
    
    @UI: {
          lineItem:       [ { position: 40, importance: #MEDIUM, label: 'Business Partner Category'  } ],
          identification: [ { position: 40, label: 'Business Partner Category' } ] }
          @EndUserText.label: 'Business Partner Category'
    businesspartnercategory as BusinessPartnerCategory,
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM, label: 'First Name'  } ],
          identification: [ { position: 50, label: 'First Name' } ] }
          @EndUserText.label: 'First Name'
    firstname as FirstName,
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM, label: 'Last Name'  } ],
          identification: [ { position: 60, label: 'Last Name' } ] }
          @EndUserText.label: 'Last Name'
    lastname as LastName,
    @UI: {
          lineItem:       [ { position: 70, importance: #MEDIUM, label: 'Organization BP Name'  } ],
          identification: [ { position: 70, label: 'Organization BP Name' } ] }
          @EndUserText.label: 'Organization BP Name'
    organizationbpname1 as OrganizationBPName1,
    @UI: {
          lineItem:       [ { position: 80, importance: #MEDIUM, label: 'YY1_Address_1_bus'  } ],
          identification: [ { position: 80, label: 'YY1_Address_1_bus' } ] }
          @EndUserText.label: 'YY1_Address_1_bus'
    yy1_address_1_bus as YY1_Address_1_bus,
    @UI: {
          lineItem:       [ { position: 90, importance: #MEDIUM, label: 'YY1_Fatca_1_bus'  } ],
          identification: [ { position: 90, label: 'YY1_Fatca_1_bus' } ] }
          @EndUserText.label: 'YY1_Fatca_1_bus'
    yy1_fatca_1_bus as YY1_Fatca_1_bus,
    @UI: {
          lineItem:       [ { position: 100, importance: #MEDIUM, label: 'Register Postal Code'  } ],
          identification: [ { position: 100, label: 'Register Postal Code' } ] }
          @EndUserText.label: 'Register Postal Code'
    register_postalcode as Register_PostalCode,
    @UI: {
          lineItem:       [ { position: 110, importance: #MEDIUM, label: 'Register Country'  } ],
          identification: [ { position: 110, label: 'Register Country' } ] }
          @EndUserText.label: 'Register Country'
    register_country as Register_Country,
    @UI: {
          lineItem:       [ { position: 120, importance: #MEDIUM, label: 'Register State'  } ],
          identification: [ { position: 120, label: 'Register State' } ] }
          @EndUserText.label: 'Register State'
    register_state as Register_State,
    @UI: {
          lineItem:       [ { position: 130, importance: #MEDIUM, label: 'Register Streetname'  } ],
          identification: [ { position: 130, label: 'Register Streetname' } ] }
          @EndUserText.label: 'Register Streetname'
    register_streetname as Register_Streetname,
    @UI: {
          lineItem:       [ { position: 140, importance: #MEDIUM, label: 'Register Street Prefix Name'  } ],
          identification: [ { position: 140, label: 'Register Street Prefix Name' } ] }
          @EndUserText.label: 'Register Street Prefix Name'
    register_streetprefixname as Register_StreetPrefixName,
    @UI: {
          lineItem:       [ { position: 150, importance: #MEDIUM, label: 'Register Street Suffix Name'  } ],
          identification: [ { position: 150, label: 'Register Street Suffix Name' } ] }
          @EndUserText.label: 'Register Street Suffix Name'
    register_streetsuffixname as Register_StreetSuffixName,
    @UI: {
          lineItem:       [ { position: 160, importance: #MEDIUM, label: 'Bill to Postal Code'  } ],
          identification: [ { position: 160, label: 'Bill to Postal Code' } ] }
          @EndUserText.label: 'Bill to Postal Code'
    billto_postalcode as Billto_PostalCode,
    @UI: {
          lineItem:       [ { position: 170, importance: #MEDIUM, label: 'Bill to Country'  } ],
          identification: [ { position: 170, label: 'Bill to Country' } ] }
          @EndUserText.label: 'Bill to Country'
    billto_country as Billto_Country,
    @UI: {
          lineItem:       [ { position: 180, importance: #MEDIUM, label: 'Bill to State'  } ],
          identification: [ { position: 180, label: 'Bill to State' } ] }
          @EndUserText.label: 'Bill to State'
    billto_state as Billto_State,
    @UI: {
          lineItem:       [ { position: 190, importance: #MEDIUM, label: 'Bill to Street Name'  } ],
          identification: [ { position: 190, label: 'Bill to Street Name' } ] }
          @EndUserText.label: 'Bill to Street Name'
    billto_streetname as Billto_StreetName,
    @UI: {
          lineItem:       [ { position: 200, importance: #MEDIUM, label: 'Bill to Street Prefix Name'  } ],
          identification: [ { position: 200, label: 'Bill to Street Prefix Name' } ] }
          @EndUserText.label: 'Bill to Street Prefix Name'
    billto_streetprefixname as Billto_StreetPrefixName,
    @UI: {
          lineItem:       [ { position: 210, importance: #MEDIUM, label: 'Bill to Street Suffix Name'  } ],
          identification: [ { position: 210, label: 'Bill to Street Suffix Name' } ] }
          @EndUserText.label: 'Bill to Street Suffix Name'
    billto_streetsuffixname as Billto_StreetSuffixName,
    @UI: {
          lineItem:       [ { position: 220, importance: #MEDIUM, label: 'Ship to Postal Code'  } ],
          identification: [ { position: 220, label: 'Ship to Postal Code' } ] }
          @EndUserText.label: 'Ship to Postal Code'
    shipto_postalcode as Shipto_PostalCode,
    @UI: {
          lineItem:       [ { position: 230, importance: #MEDIUM, label: 'Ship to Country'  } ],
          identification: [ { position: 230, label: 'Ship to Country' } ] }
          @EndUserText.label: 'Ship to Country'
    shipto_country as Shipto_Country,
    @UI: {
          lineItem:       [ { position: 240, importance: #MEDIUM, label: 'Ship to State'  } ],
          identification: [ { position: 240, label: 'Ship to State' } ] }
          @EndUserText.label: 'Ship to State'
    shipto_state as Shipto_State,
    @UI: {
          lineItem:       [ { position: 250, importance: #MEDIUM, label: 'Ship to Street Name'  } ],
          identification: [ { position: 250, label: 'Ship to Street Name' } ] }
          @EndUserText.label: 'Ship to Street Name'
    shipto_streetname as Shipto_StreetName,
    @UI: {
          lineItem:       [ { position: 260, importance: #MEDIUM, label: 'Ship to Street Prefix Name'  } ],
          identification: [ { position: 260, label: 'Ship to Street Prefix Name' } ] }
          @EndUserText.label: 'Ship to Street Prefix Name'
    shipto_streetprefixname as Shipto_StreetPrefixName,
    @UI: {
          lineItem:       [ { position: 270, importance: #MEDIUM, label: 'Ship to Street Suffix Name'  } ],
          identification: [ { position: 270, label: 'Ship to Street Suffix Name' } ] }
          @EndUserText.label: 'Ship to Street Suffix Name'
    shipto_streetsuffixname as Shipto_StreetSuffixName,
    @UI: {
          lineItem:       [ { position: 280, importance: #MEDIUM, label: 'Ship to Street Suffix Name'  } ],
          identification: [ { position: 280, label: 'Ship to Street Suffix Name' } ] }
          @EndUserText.label: 'Ship to Street Suffix Name'
    emailaddress as EmailAddress,
    @UI: {
          lineItem:       [ { position: 290, importance: #MEDIUM, label: 'Destination Location Country'  } ],
          identification: [ { position: 290, label: 'Destination Location Country' } ] }
          @EndUserText.label: 'Destination Location Country'
    destinationlocationcountry as DestinationLocationCountry,

    @UI: {
          lineItem:       [ { position: 300, importance: #MEDIUM, label: 'Is Default Phone Numer'  } ],
          identification: [ { position: 300, label: 'Is Default Phone Numer' } ] }
          @EndUserText.label: 'Is Default Phone Numer'
    isdefaultphonenumber as IsDefaultPhoneNumber,
    @UI: {
          lineItem:       [ { position: 310, importance: #MEDIUM, label: 'Is Default Mobile Phone Number'  } ],
          identification: [ { position: 310, label: 'Is Default Mobile Phone Number' } ] }
          @EndUserText.label: 'Is Default Mobile Phone Number'
    isdefaultmobilephonenumber as IsDefaultMobilePhoneNumber,
    @UI: {
          lineItem:       [ { position: 320, importance: #MEDIUM, label: 'Phone Number'  } ],
          identification: [ { position: 320, label: 'Phone Number' } ] }
          @EndUserText.label: 'Phone Number'
    phonenumber as PhoneNumber,
    @UI: {
          lineItem:       [ { position: 330, importance: #MEDIUM, label: 'Mobiphone Number'  } ],
          identification: [ { position: 330, label: 'Mobiphone Number' } ] }
          @EndUserText.label: 'Mobiphone Number'
    mobilephone as MobilePhone,
            @UI: {
          lineItem:       [ { position: 340, importance: #MEDIUM, label: 'Ordinal Number Phone'  } ],
          identification: [ { position: 340, label: 'Ordinal Number Phone' } ] }
          @EndUserText.label: 'Ordinal Number Phone'
    ordinalnumber_phone as OrdinalNumberPhone,
        @UI: {
          lineItem:       [ { position: 350, importance: #MEDIUM, label: 'Ordinal Number Mobile'  } ],
          identification: [ { position: 350, label: 'Ordinal Number Mobile' } ] }
          @EndUserText.label: 'Ordinal Number Mobile'
    ordinalnumber_mobile as OrdinalNumberMobile,
    @UI: {
          lineItem:       [ { position: 360, importance: #MEDIUM, label: 'Website URL'  } ],
          identification: [ { position: 360, label: 'Website URL' } ] }
          @EndUserText.label: 'Website URL'
    websiteurl as WebsiteURL,
    @UI: {
          lineItem:       [ { position: 370, importance: #MEDIUM, label: 'Industry Sector'  } ],
          identification: [ { position: 370, label: 'Industry Sector' } ] }
          @EndUserText.label: 'Industry Sector'
    industrysector as IndustrySector,
    @UI: {
          lineItem:       [ { position: 380, importance: #MEDIUM, label: 'Industry System Type'  } ],
          identification: [ { position: 380, label: 'Industry System Type' } ] }
          @EndUserText.label: 'Industry System Type'
    industrysystemtype as IndustrySystemType,
    @UI: {
          lineItem:       [ { position: 390, importance: #MEDIUM, label: 'Customer Classification'  } ],
          identification: [ { position: 390, label: 'Customer Classification' } ] }
          @EndUserText.label: 'Customer Classification'
    customerclassification as CustomerClassification,
    @UI: {
          lineItem:       [ { position: 400, importance: #MEDIUM, label: 'Text'  } ],
          identification: [ { position: 400, label: 'Text' } ] }
          @EndUserText.label: 'Text'
    text as Text,
    @UI: {
          lineItem:       [ { position: 410, importance: #MEDIUM, label: 'Sales Organization'  } ],
          identification: [ { position: 410, label: 'Sales Organization' } ] }
          @EndUserText.label: 'Sales Organization'
    salesorganization as SalesOrganization,
    @UI: {
          lineItem:       [ { position: 420, importance: #MEDIUM, label: 'Distribution Channel'  } ],
          identification: [ { position: 420, label: 'Distribution Channel' } ] }
          @EndUserText.label: 'Distribution Channel'
    distributionchannel as DistributionChannel,
    @UI: {
          lineItem:       [ { position: 430, importance: #MEDIUM, label: 'Division'  } ],
          identification: [ { position: 430, label: 'Division' } ] }
          @EndUserText.label: 'Division'
    division as Division,
    @UI: {
          lineItem:       [ { position: 440, importance: #MEDIUM, label: 'Currency'  } ],
          identification: [ { position: 440, label: 'Currency' } ] }
          @EndUserText.label: 'Currency'
    currency as Currency,
    @UI: {
          lineItem:       [ { position: 440, importance: #MEDIUM, label: 'Customer Tax Classification'  } ],
          identification: [ { position: 440, label: 'Customer Tax Classification' } ] }
          @EndUserText.label: 'Customer Tax Classification'
    customertaxclassification as CustomerTaxClassification,
    @UI: {
          lineItem:       [ { position: 450, importance: #MEDIUM, label: 'Company Code'  } ],
          identification: [ { position: 450, label: 'Company Code' } ] }
          @EndUserText.label: 'Company Code'
    companycode as CompanyCode,
    @UI: {
          lineItem:       [ { position: 460, importance: #MEDIUM, label: 'Reconciliation Account'  } ],
          identification: [ { position: 460, label: 'Reconciliation Account' } ] }
          @EndUserText.label: 'Reconciliation Account'
    reconciliationaccount as ReconciliationAccount,
    @UI: {
          lineItem:       [ { position: 470, importance: #MEDIUM, label: 'Payment Terms'  } ],
          identification: [ { position: 470, label: 'Payment Terms' } ] }
          @EndUserText.label: 'Payment Terms'
    paymentterms as PaymentTerms,
        @UI: {
          lineItem:       [ { position: 480, importance: #MEDIUM, label: 'Shipto Address ID'  } ],
          identification: [ { position: 480, label: 'Shipto Address ID' } ] }
          @EndUserText.label: 'Shipto Address ID'
    shipto_addressid as Shipto_AddressID,
        @UI: {
          lineItem:       [ { position: 490, importance: #MEDIUM, label: 'Billto Address ID'  } ],
          identification: [ { position: 490, label: 'Billto Address ID' } ] }
          @EndUserText.label: 'Billto Address ID'
    billto_addressid as Billto_AddressID,
        @UI: {
          lineItem:       [ { position: 500, importance: #MEDIUM, label: 'Register Address ID'  } ],
          identification: [ { position: 500, label: 'Register Address ID' } ] }
          @EndUserText.label: 'Reconciliation Account'
    register_addressid as Register_AddressID,
        @UI: {
          lineItem:       [ { position: 510, importance: #MEDIUM, label: 'Language'  } ],
          identification: [ { position: 510, label: 'Language' } ] }
          @EndUserText.label: 'Language'
    language as Language,
    @UI: {
          lineItem:       [ { position: 520, importance: #MEDIUM, label: 'API Result'  } ],
          identification: [ { position: 520, label: 'API Result' } ] }
          @EndUserText.label: 'API Result'
    api_result as APIResult, 
        @UI: {
          lineItem:       [ { position: 530, importance: #MEDIUM, label: 'Last Change At'  } ],
          identification: [ { position: 530, label: 'Last Change At' } ] }
          @EndUserText.label: 'Last Change At'
    last_changed_at as LastChangeAt,
        @UI: {
          lineItem:       [ { position: 540, importance: #MEDIUM, label: 'Is Contact'  } ],
          identification: [ { position: 540, label: 'Is Contact' } ] }
          @EndUserText.label: 'Is Contact'
    is_contact as IsContact, 
       @UI: {
          lineItem:       [ { position: 550, importance: #MEDIUM, label: 'Business Partner ID'  } ],
          identification: [ { position: 550, label: 'Business Partner ID' } ] }
          @EndUserText.label: 'Business Partner ID'
    businesspartnerid as BusinessPartnerID,
    
        @UI: {
          lineItem:       [ { position: 560, importance: #MEDIUM, label: 'Ship to City Name'  } ],
          identification: [ { position: 560, label: 'Ship to City Name' } ] }
          @EndUserText.label: 'Ship to City Name'
    shipto_cityname as Shipto_CityName,
        @UI: {
          lineItem:       [ { position: 570, importance: #MEDIUM, label: 'Bill to City Name'  } ],
          identification: [ { position: 570, label: 'Bill to City Name' } ] }
          @EndUserText.label: 'Bill to City Name'
    billto_cityname as Billto_CityName, 
       @UI: {
          lineItem:       [ { position: 580, importance: #MEDIUM, label: 'Register City Name'  } ],
          identification: [ { position: 580, label: 'Register City Name' } ] }
          @EndUserText.label: 'Register City Name'
    register_cityname as Register_CityName,
       @UI: {
          lineItem:       [ { position: 590, importance: #MEDIUM, label: 'Changed Datetime'  } ],
          identification: [ { position: 590, label: 'Changed Datetime' } ] }
          @EndUserText.label: 'Changed Datetime'
    changeddatetime as Changed_Date_Tme,
        @UI: {
          lineItem:       [ { position: 600, importance: #MEDIUM, label: 'UUID'  } ],
          identification: [ { position: 600, label: 'UUID' } ] }
          @EndUserText.label: 'UUID'
    mykey as UUID 
} 
