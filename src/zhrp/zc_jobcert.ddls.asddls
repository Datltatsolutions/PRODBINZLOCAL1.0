@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Job Certificate'
@UI: { headerInfo: { typeName: 'Job Certificate Required', 
      typeNamePlural: 'Job Certificates Required', 
      title: { type: #STANDARD, value: 'JobID' }, 
      description: { value:'CertificateID' } } }
@Search.searchable: true
define root view entity ZC_JOBCERT 
as projection on ZI_JOBCERT as JobCertificate
{
    @UI.facet: [{ id: 'JobCertificate',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Job Certificate',
                 position: 10 }] 
    
    @UI.hidden: true
    key mykey as JobCertUUID,       
    
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Job ID' } ],
          identification: [ { position: 10, label: 'Job ID' } ] }

    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_JOB', element: 'jobid' } }]
    @Search.defaultSearchElement: true
    jobid as JobID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #MEDIUM, label: 'Job Name' } ],
          identification: [ { position: 20, label: 'Job Name' } ] }
    jobname as JobName,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'Certificate ID'  } ],
          identification: [ { position: 30, label: 'Certificate ID' } ] }
          
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CERTIFICATE', element: 'certid' } }]
    @Search.defaultSearchElement: true    
    certid as CertificateID,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #MEDIUM, label: 'Certificate Name'  } ],
          identification: [ { position: 40, label: 'Certificate Name' } ] }
    certname as CertificateName,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM, label: 'Note' } ],
          identification: [ { position: 50, label: 'Certificate ID' } ] } 
    jobcertnotes as JobCertNotes,
   
    @UI.hidden: true
    last_changed_at as LastChangedAt
}
