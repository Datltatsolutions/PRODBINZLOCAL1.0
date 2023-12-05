@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Job Education'
@UI: { headerInfo: { typeName: 'Job Education Required', 
      typeNamePlural: 'Job Education Required', 
      title: { type: #STANDARD, value: 'JobID' }, 
      description: { value:'EduID' } } }

@Search.searchable: true
define root view entity ZC_JOBEDU
as projection on ZI_JOBEDU as JobEducation
{
    @UI.facet: [{ id: 'JobEducation',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Job Education',
                 position: 10 }] 
    @UI.hidden: true
    key mykey              as JobEduUUID,       
    
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Job ID' } ],
          identification: [ { position: 10, label: 'Job ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_JOB', element: 'jobid' } }]
    @Search.defaultSearchElement: true
    jobid as JobID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH, label: 'Job Name' } ],
          identification: [ { position: 20, label: 'Job Name' } ] }
    jobname as JobName,

    @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'Education ID'  } ],
          identification: [ { position: 30, label: 'Education ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_EDUCATION', element: 'eduid' } }]
    @Search.defaultSearchElement: true    
    eduid as EduID,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #HIGH, label: 'Education Name'  } ],
          identification: [ { position: 40, label: 'Education Name' } ] }
    eduname as EducationName,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM, label: 'Level of Education'  } ],
          identification: [ { position: 50, label: 'Level of Education' } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_EDULEVEL_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @ObjectModel.text.element: ['EduLevelDesc']
    edulevel as EduLevel,
    
    @UI.hidden: true
    _EduLevel.text as EduLevelDesc,     
    
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM, label: 'Notes' } ],
          identification: [ { position: 60, label: 'Notes' } ] } 
    jobedunotes as JobEduNotes,
   
    @UI.hidden: true
    last_changed_at as LastChangedAt
}
