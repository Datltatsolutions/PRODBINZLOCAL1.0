@EndUserText.label: 'Org. Units projection view - Processor'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: { headerInfo: { typeName: 'Organizational Unit', 
       typeNamePlural: 'Organizational Units', 
       title: { type: #STANDARD, value: 'OrgUnitID' }, 
       description: { value:'OrgUnitName' } } }
@Search.searchable: true
define root view entity ZC_ORG 
as projection on ZI_ORG
{
    @UI.facet: [{ id: 'Org',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Org. Unit',
                 position: 10 }]
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Org. Unit ID' } ],
          identification: [ { position: 10, label: 'Org. Unit ID' } ] }
    @Search.defaultSearchElement: true
    key orgunitid as OrgUnitID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH, label: 'Name' } ],
          identification: [ { position: 20, label: 'Name' } ] }
    orgunitname as OrgUnitName,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'Manager' } ],
          identification: [ { position: 30, label: 'Manager' } ] }
    orgunitmanager as OrgUnitManager,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #MEDIUM, label: 'Company' } ],
          identification: [ { position: 40, label: 'Company' } ] }
    orgcompany as OrgCompany,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM, label: 'Business Residence' } ],
          identification: [ { position: 50, label: 'Business Residence' } ] }    
    orgbusinessres as OrgBusinessResidence,
    
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM, label: 'Segment' } ],
          identification: [ { position: 60, label: 'Segment' } ] }    
    orgsegment as OrgSegment,

    @UI: {
          lineItem:       [ { position: 70, importance: #MEDIUM, label: 'Profit Center' } ],
          identification: [ { position: 70, label: 'Profit Center' } ] }
    orgprofitcenter as OrgProfitCenter,

    @UI: {
          lineItem:       [ { position: 80, importance: #MEDIUM, label: 'Cost Center' } ],
          identification: [ { position: 80, label: 'Cost Center' } ] }
    orgcostcenter as OrgCostCenter,

    @UI: {
          lineItem:       [ { position: 90, importance: #MEDIUM, label: 'Reporting Line Unit' } ],
          identification: [ { position: 90, label: 'Reporting Line Unit' } ] }
    orgreportinglineunit as OrgReportingLineUnit,

    @UI: {
          lineItem:       [ { position: 100, importance: #MEDIUM, label: 'Sales Organization' } ],
          identification: [ { position: 100, label: 'Sales Organization' } ] }
    orgsalesorg as OrgSalesOrg,
   
    @UI.hidden: true
    last_changed_at           as LastChangeAt
}
