@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EmpCert projection view - Processor'
@UI: {headerInfo: { typeName: 'Employee Certificate', 
      typeNamePlural: 'Employee Certificates', 
      title: { type: #STANDARD, value: 'EmployeeID' }, 
      description: { value:'CertificateID' } } }
@Search.searchable: true
define root view entity ZC_EMPCERT 
as projection on ZI_EMPCERT as EmployeeCertificate
{
    @UI.facet: [{id: 'EmployeeCertificate',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Employee Certificate',
                 position: 10 }] 
    
    @UI.hidden: true
    key mykey as EmpCertUUID,              
                  
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Employee' } ],
          identification: [ { position: 10, label: 'Employee ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_EMPLOYEE', element: 'empid' } }]
    @ObjectModel.text.element: ['empname']
    @Search.defaultSearchElement: true
    empid as EmployeeID, 
    
    @UI.hidden: true
    empname,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH, label: 'Certificate'  } ],
          identification: [ { position: 20, label: 'Certificate ID' } ] }     
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CERTIFICATE', element: 'certid' } }]
    @ObjectModel.text.element: ['CertificateName']
    @Search.defaultSearchElement: true    
    certid as CertificateID,
    
    @UI.hidden: true
    _Certificate.certname as CertificateName,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #MEDIUM } ],
          identification: [ { position: 30 } ] }
    certstart as CertStartDate,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #MEDIUM } ],
          identification: [ { position: 40 } ] }
    certend as CertEndDate,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM } ],
          identification: [ { position: 50 } ] }
    empcertnotes as EmpCertNotes,
    
    @UI.hidden: true
    last_changed_at as LastChangeAt,
    
    @UI.hidden: true
    _Certificate.certdesc as CertDesc,    
    
    @UI.hidden: true
    _Certificate.certrenew as CertRenew
}
