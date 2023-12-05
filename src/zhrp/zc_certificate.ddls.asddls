
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Certificate projection view - Processor'
@UI: { headerInfo: { typeName: 'Certificate', 
       typeNamePlural: 'Certificates', 
       title: { type: #STANDARD, value: 'CertID' }, 
       description: { value:'CertName' } } }
@Search.searchable: true
define root view entity ZC_CERTIFICATE 
as projection on ZI_CERTIFICATE
{
    @UI.facet: [{ id: 'Certificate',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Certificate',
                 position: 10 }]
    
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH } ],
          identification: [ { position: 10, label: 'Certificate ID' } ] }
      @Search.defaultSearchElement: true
    key certid as CertID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH } ],
          identification: [ { position: 20, label: 'Certificate Name' } ] }
    certname as CertName,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #MEDIUM } ],
          identification: [ { position: 30 } ] }
    certdesc as CertDesc,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #MEDIUM } ],
          identification: [ { position: 40 , label: 'Renewal Required' } ] }
    certrenew as CertRenew,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM } ],
          identification: [ { position: 50 } ] }
    certnote as CertNotes,
    
    @UI.hidden: true
    last_changed_at as LastChangeAt
    
}
