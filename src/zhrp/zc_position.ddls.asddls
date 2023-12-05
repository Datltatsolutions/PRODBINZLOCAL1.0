@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Position'
@UI: { headerInfo: { typeName: 'Position', 
       typeNamePlural: 'Positions', 
       title: { type: #STANDARD, value: 'PositionID' } } }
@Search.searchable: true
define root view entity ZC_POSITION 
as projection on ZI_POSITION
{
    @UI.facet: [{ id: 'Position',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Position',
                 position: 10 }] 
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Position ID' } ],
          identification: [ { position: 10, label: 'Position ID' } ] }
    @Search.defaultSearchElement: true
    key posid as PositionID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH, label: 'Position Description' } ],
          identification: [ { position: 20, label: 'Position Description' } ] }
    posdesc as PositionDesc,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'Job' } ],
          identification: [ { position: 30, label: 'Job ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_JOB', element: 'jobid' } }]
    @ObjectModel.text.element: ['JobName']
    @Search.defaultSearchElement: true
    posjobid as JobID,
    
    @UI.hidden: true
    _Job.jobname as JobName,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #HIGH, label: 'Employee' } ],
          identification: [ { position: 40, label: 'Employee ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_EMPLOYEE', element: 'empid' } }]
    @ObjectModel.text.element: ['EmployeeName']
    @Search.defaultSearchElement: true
    posempid as PositionEmployeeID,
    
    @UI.hidden:true
    empname as EmployeeName, 
    
    @UI: {
          lineItem:       [ { position: 50, importance: #HIGH, label: 'Org. Unit' } ],
          identification: [ { position: 50, label: 'Org. Unit ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_ORG', element: 'orgunitid' } }]
    @ObjectModel.text.element: ['OrgUnitName']
    @Search.defaultSearchElement: true
    posorgid as PositionOrgUnitID,
    
    @UI.hidden:true
    _Org.orgunitname as OrgUnitName,
    
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM, label: 'Expired Date' } ],
          identification: [ { position: 60, label: 'Expired Date' } ] }
    posexpireddate as PositionExpiredDate,
   
    @UI.hidden: true
    last_changed_at as LastChangeAt
}
