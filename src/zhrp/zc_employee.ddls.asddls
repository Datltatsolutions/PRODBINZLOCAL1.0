@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee projection view - Processor'
@UI: 
    { headerInfo: { typeName: 'Employee', 
      typeNamePlural: 'Employees', 
      title: { type: #STANDARD, value: 'EmployeeID' }, 
      description: { value:'EmployeeName' } } }
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_EMPLOYEE
provider contract transactional_query
as projection on ZI_EMPLOYEE as Employee

association [0..*] to ZC_EMPCERT as _EmpCertificate on $projection.EmployeeID = _EmpCertificate.EmployeeID
{
    @UI.facet: [{ id: 'EmployeeInfo',
                  purpose: #STANDARD,
                  type: #COLLECTION,
                  label: 'Employee Information',
                  position: 10 },
                      
                { id: 'EmployeeGeneralInfo',
                  purpose: #STANDARD,
                  type: #FIELDGROUP_REFERENCE,
                  parentId: 'EmployeeInfo',
                  label: 'General Info',
                  position: 10,
                  targetQualifier: 'EmployeeGeneralGroup'},
                  
                { id: 'EmployeeContactInfo',
                  purpose: #STANDARD,
                  type: #FIELDGROUP_REFERENCE,
                  parentId: 'EmployeeInfo',
                  label: 'Contact Info',
                  position: 20,
                  targetQualifier: 'EmployeeContactGroup'},
                  
                { id: 'OfficeInfo',
                  purpose: #STANDARD,
                  type: #COLLECTION,
                  label: 'Office Information',
                  position: 20 },
                            
                { id: 'OfficeGeneralInfo',
                  purpose: #STANDARD,
                  type: #FIELDGROUP_REFERENCE,
                  parentId: 'OfficeInfo',
                  label: 'General Info',
                  position: 10,
                  targetQualifier: 'OfficeGeneralGroup'},
                  
                { id: 'OfficeContactInfo',
                  purpose: #STANDARD,
                  type: #FIELDGROUP_REFERENCE,
                  parentId: 'OfficeInfo',
                  label: 'Contact Info',
                  position: 20,
                  targetQualifier: 'OfficeContactGroup'}]
                
    @UI: {
          selectionField: [ { position: 10 } ],
          lineItem:       [ { position: 10, importance: #HIGH } ],
          identification: [ { position: 10, label: 'Employee ID' } ] }
    @UI.fieldGroup: [{ qualifier: 'EmployeeGeneralGroup', position: 10 }]
    @Search.defaultSearchElement: true
    key empid as EmployeeID,
    
    @UI: {
          selectionField: [ { position: 20 } ],
          lineItem:       [ { position: 20, importance: #HIGH } ],
          identification: [ { position: 20 } ] }
    @UI.fieldGroup: [{ qualifier: 'EmployeeGeneralGroup', position: 20 }]
    @Search.defaultSearchElement: true
    emppersid as EmployeePersonalID,
            
    @UI: {
          selectionField: [ { position: 30 } ],
          lineItem:       [ { position: 30, importance: #MEDIUM } ],
          identification: [ { position: 30 } ] }
    @UI.fieldGroup: [{ qualifier: 'EmployeeGeneralGroup', position: 30 }]
    empfirstname as EmployeeFirstName,
    
    @UI: {
          selectionField: [ { position: 40 } ],
          lineItem:       [ { position: 40, importance: #MEDIUM } ],
          identification: [ { position: 40 } ] }
    @UI.fieldGroup: [{ qualifier: 'EmployeeGeneralGroup', position: 40 }]
    emplastname as EmployeeLastName,
    
    @UI.hidden: true
    empname as EmployeeName,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM } ],
          identification: [ { position: 50 } ] }
    @UI.fieldGroup: [{ qualifier: 'EmployeeGeneralGroup', position: 50 }]
    empssn as EmployeeSSN, 
    
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM } ],
          identification: [ { position: 60 } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_GENDER_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @ObjectModel.text.element: ['GenderDesc']
    @UI.textArrangement: #TEXT_ONLY
    @UI.fieldGroup: [{ qualifier: 'EmployeeGeneralGroup', position: 60 }]
    empgender as EmployeeGender,
    
    @UI.hidden: true
    _Gender.text as GenderDesc,
    
    @UI: {
          lineItem:       [ { position: 70, importance: #MEDIUM } ],
          identification: [ { position: 70 } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_TITLE_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @UI.fieldGroup: [{ qualifier: 'EmployeeGeneralGroup', position: 70 }]
    emptitle as EmployeeTitle,
    
    @UI: {
          lineItem:       [ { position: 80, importance: #MEDIUM } ],
          identification: [ { position: 80 } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_MARITAL_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @ObjectModel.text.element: ['MaritalDesc'] 
    @UI.textArrangement: #TEXT_ONLY         
    @UI.fieldGroup: [{ qualifier: 'EmployeeGeneralGroup', position: 80 }]
    empmarital as EmployeeMaritalStatus,
    
    @UI.hidden: true
    _Marital.text as MaritalDesc,
    
    @UI: {
          lineItem:       [ { position: 90, importance: #MEDIUM } ],
          identification: [ { position: 90 } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'I_CountryVH' , element: 'Country' },
    distinctValues: true}]      
    @ObjectModel.text.element: ['CountryName']
    @UI.textArrangement: #TEXT_ONLY
    @UI.fieldGroup: [{ qualifier: 'EmployeeContactGroup', position: 10 }]
    empcountry as EmployeeCountry, 
    
    @UI.hidden: true
    _Country.Description as CountryName,
    
    @UI: {
          lineItem:       [ { position: 100, importance: #MEDIUM } ],
          identification: [ { position: 100 } ] }
    @UI.fieldGroup: [{ qualifier: 'EmployeeContactGroup', position: 20 }]
    emphomestreet as EmployeeHomeStreet,
    
    @UI: {
          lineItem:       [ { position: 110, importance: #MEDIUM } ],
          identification: [ { position: 110 } ] }
    @UI.fieldGroup: [{ qualifier: 'EmployeeContactGroup', position: 30 }]
    emphomecity as EmployeeHomeCity,
    
    @UI: {
          lineItem:       [ { position: 120, importance: #MEDIUM } ],
          identification: [ { position: 120 } ] }
    @UI.fieldGroup: [{ qualifier: 'EmployeeContactGroup', position: 40 }]
    emphomestate as EmployeeHomeState,
    
    @UI: {
          lineItem:       [ { position: 130, importance: #MEDIUM } ],
          identification: [ { position: 130 } ] }
    @UI.fieldGroup: [{ qualifier: 'EmployeeContactGroup', position: 50 }]
    empprivatephone as EmployeePrivatePhone,
    
    @UI: {
          lineItem:       [ { position: 140, importance: #MEDIUM } ],
          identification: [ { position: 140 } ] }
    @UI.fieldGroup: [{ qualifier: 'OfficeGeneralGroup', position: 10 }]          
    empjobtitle as EmployeeJobTitle, 
    
    @UI: {
          lineItem:       [ { position: 150, importance: #MEDIUM } ],
          identification: [ { position: 150 } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_ORGUNIT_DOMAIN' , element: 'value_low' },
    distinctValues: true}]      
    @ObjectModel.text.element: ['UnitDesc']
    @UI.textArrangement: #TEXT_ONLY          
    @UI.fieldGroup: [{ qualifier: 'OfficeGeneralGroup', position: 20 }] 
    emporgunit as EmployeeOrgUnit,
    
    @UI.hidden: true
    _OrgUnit.text as UnitDesc,
    
    @UI: {
          lineItem:       [ { position: 160, importance: #MEDIUM } ],
          identification: [ { position: 160 } ] }
    @UI.fieldGroup: [{ qualifier: 'OfficeGeneralGroup', position: 30 }] 
    emphiredate as EmployeeHireDate,
    
    @UI: {
          lineItem:       [ { position: 170, importance: #MEDIUM } ],
          identification: [ { position: 170 } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_AGREEMENT_DOMAIN' , element: 'value_low' },
    distinctValues: true}] 
    @UI.fieldGroup: [{ qualifier: 'OfficeGeneralGroup', position: 40 }]           
    empagreement as EmployeeAgreement,
    
    @UI: {
          lineItem:       [ { position: 180, importance: #MEDIUM } ],
          identification: [ { position: 180 } ] }
    @ObjectModel.text.element: ['EmployeeHoursText']
    @UI.textArrangement: #TEXT_ONLY
    @UI.fieldGroup: [{ qualifier: 'OfficeGeneralGroup', position: 50 }] 
    emphours as EmployeeHours,
    
    @UI.hidden: true
    emphourstext as EmployeeHoursText,
    
    @UI: {
          lineItem:       [ { position: 190, importance: #MEDIUM } ],
          identification: [ { position: 190 } ] }
    @UI.fieldGroup: [{ qualifier: 'OfficeContactGroup', position: 10 }] 
    empofficeaddr as EmployeeOfficeAddress,
    
    @UI: {
          lineItem:       [ { position: 200, importance: #MEDIUM } ],
          identification: [ { position: 200 } ] }
    @UI.fieldGroup: [{ qualifier: 'OfficeContactGroup', position: 20 }] 
    empofficecity as EmployeeOfficeCity, 
    
    @UI: {
          lineItem:       [ { position: 210, importance: #MEDIUM } ],
          identification: [ { position: 210 } ] }
    @UI.fieldGroup: [{ qualifier: 'OfficeContactGroup', position: 30 }] 
    empcommphone as EmployeeCommPhone,
    
    @UI: {
          lineItem:       [ { position: 220, importance: #MEDIUM } ],
          identification: [ { position: 220 } ] }
    @UI.fieldGroup: [{ qualifier: 'OfficeContactGroup', position: 40 }] 
    empmobilephone as EmployeeMobile,
    
    @UI: {
          lineItem:       [ { position: 230, importance: #MEDIUM } ],
          identification: [ { position: 230 } ] }
    @UI.fieldGroup: [{ qualifier: 'OfficeContactGroup', position: 50 }] 
    empemail as EmployeeEmail,
    
    @UI.hidden: true
    last_changed_at as LastChangeAt
}
