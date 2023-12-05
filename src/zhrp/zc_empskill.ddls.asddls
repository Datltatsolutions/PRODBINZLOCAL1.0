@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Employee Skill'
@UI: { headerInfo: { typeName: 'Employee Skill', 
      typeNamePlural: 'Employee Skills', 
      title: { type: #STANDARD, value: 'EmployeeID' }, 
      description: { value:'Skillid' } } }
@Search.searchable: true
define root view entity ZC_EMPSKILL
as projection on ZI_EMPSKILL as EmployeeSkill
{
    @UI.facet: [{ id: 'EmployeeSkill',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Employee Skill',
                 position: 10 }] 
    @UI.hidden: true
    key mykey as EmpEduuuid,              

    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Employee' } ],
          identification: [ { position: 10, label: 'Employee ID' } ] }

    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_EMPLOYEE', element: 'empid' } }]
    @Search.defaultSearchElement: true
    empid as EmployeeID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH, label: 'Employee Name' } ],
          identification: [ { position: 20, label: 'Employee Name' } ] }
    empname as EmployeeName,            
    
    @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'Skill ID'  } ],
          identification: [ { position: 30, label: 'Skill ID' } ] }      
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_SKILL', element: 'skillid' } }]
    @Search.defaultSearchElement: true    
    skillid as Skillid,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #HIGH, label: 'Skill ID'  } ],
          identification: [ { position: 40, label: 'Skill ID' } ] }
     skillname as SkillName,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM, label: 'Level (1-5)' } ],
          identification: [ { position: 50,label: 'Level (1-5)' } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_LEVELNUM5_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @ObjectModel.text.element: ['SkillLevel']
    @UI.textArrangement: #TEXT_ONLY
    empskilllevel as EmpSkillLevel,
    
    @UI.hidden: true
    _LevelNum.text as SkillLevel,
    
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM, label: 'Note' } ],
          identification: [ { position: 60, label: 'Note' } ] }
    empskillnote as EmSkillNote,
    
    @UI.hidden: true
    last_changed_at as LastChangeAt
}
