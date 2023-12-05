@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Bill of Operation'
@UI: { headerInfo: { typeName: 'Bill of Operation', 
     typeNamePlural: 'Bill of Operation', 
     title: { type: #STANDARD, value: 'BOOProductID' } } }
@Search.searchable: true
define root view entity ZC_BOO 
as projection on ZI_BOO
{
    @UI.facet: [{ id: 'BOO',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Bill of Operation',
                 position: 10 }] 
    @UI.hidden: true
    key mykey as BOOUUID,
    
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Product ID' } ],
          identification: [ { position: 10, label: 'Product ID' } ] }
    @Search.defaultSearchElement: true
    booproductid as BOOProductID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #MEDIUM, label: 'Product Variance' } ],
          identification: [ { position: 20, label: 'Product Variance' } ] }    
    booproductvar as BOOProductVariance,

    @UI: {
          lineItem:       [ { position: 30, importance: #MEDIUM, label: 'Product Model Description' } ],
          identification: [ { position: 30, label: 'Product Model Description' } ] } 
    booproductdesc as BOOProductDesc,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #MEDIUM, label: 'Unit' } ],
          identification: [ { position: 40, label: 'Unit' } ] }     
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_UNIT_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @ObjectModel.text.element: ['UnitDesc']
    @UI.textArrangement: #TEXT_ONLY 
    boounit as BOOUnit,
    
    @UI.hidden: true
    _Unit.text as UnitDesc,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM, label: 'Process/Activity' } ],
          identification: [ { position: 50, label: 'Process/Activity' } ] }     
    booprocess as BOOProcess,
    
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM, label: 'Operation/Activity Type' } ],
          identification: [ { position: 60, label: 'Operation/Activity Type' } ] } 
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_TYPE_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @ObjectModel.text.element: ['TypeDesc']
    @UI.textArrangement: #TEXT_ONLY 
    bootype as BOOType,
    
    @UI.hidden: true
    _Type.text as TypeDesc,
    
    @UI: {
          lineItem:       [ { position: 70, importance: #MEDIUM, label: 'Working Time (Hours)' } ],
          identification: [ { position: 70, label: 'Working Time (Hours)' } ] }     
    booworkingtime as BOOWorkingTime,
    
    @UI: {
          lineItem:       [ { position: 80, importance: #MEDIUM, label: 'Duration (Days)' } ],
          identification: [ { position: 80, label: 'Duration (Days)' } ] }     
    booduration as BOODuration,

    @UI: {
          lineItem:       [ { position: 90, importance: #HIGH, label: 'Job' } ],
          identification: [ { position: 90, label: 'Job' } ] }

    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_JOB', element: 'jobid' } }]
    @ObjectModel.text.element: ['JobName']
    @Search.defaultSearchElement: true
    boojob as BOOJobID,
    
    @UI.hidden: true
    _Job.jobname as JobName,
    
    @UI: {
          lineItem:       [ { position: 100, importance: #MEDIUM, label: 'Cost Estimated' } ],
          identification: [ { position: 100, label: 'Cost Estimated' } ] }     
    boocostest as BOOCostEstimated,
   
    @UI.hidden: true
    last_changed_at as LastChangeAt
    
}
