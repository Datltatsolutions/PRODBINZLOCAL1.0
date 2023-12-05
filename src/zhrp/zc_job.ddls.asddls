@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Certificate projection view - Processor'
@UI: { headerInfo: { typeName: 'Job', 
      typeNamePlural: 'Jobs', 
      title: { type: #STANDARD, value: 'JobID' } } }
@Search.searchable: true
define root view entity ZC_JOB
as projection on ZI_JOB
{
    @UI.facet: [{ id: 'Job',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Job',
                 position: 10 }]
    
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Job ID' } ],
          identification: [ { position: 10, label: 'Job ID' } ] }
      @Search.defaultSearchElement: true
    key jobid as JobID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #MEDIUM, label: 'Job Name' } ],
          identification: [ { position: 20, label: 'Job Name' } ] }
    jobname as JobName,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #MEDIUM, label: 'Job Function' } ],
          identification: [ { position: 30, label: 'Job Function' } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_FUNCTION_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @ObjectModel.text.element: ['FuncDesc']
    @UI.textArrangement: #TEXT_ONLY
    jobfunction as JobFunction,
    
    @UI.hidden: true
    _Function.text as FuncDesc,
    
    @UI.hidden: true
    last_changed_at as LastChangeAt
    
}
