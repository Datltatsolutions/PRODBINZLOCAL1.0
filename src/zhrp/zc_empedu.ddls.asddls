@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Employee Education'
@UI: { headerInfo: { typeName: 'Employee Education', 
       typeNamePlural: 'Employee Education', 
       title: { type: #STANDARD, value: 'EmployeeID' }, 
       description: { value:'EduID' } } }

@Search.searchable: true
define root view entity ZC_EMPEDU
as projection on ZI_EMPEDU as EmployeeEducation
{
     @UI.facet: [{ id: 'EmployeeEducation',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                  label: 'Employee Education',
                  position: 10 }] 
    @UI.hidden: true
    key mykey as EmpEduuuid,              

    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Employee ID' } ],
          identification: [ { position: 10, label: 'Employee ID' } ] }      
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_EMPLOYEE', element: 'empid' } }]
    @Search.defaultSearchElement: true
    empid as EmployeeID,        
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH, label: 'Employee Name' } ],
          identification: [ { position: 20, label: 'Employee Name' } ] }
    empname as EmployeeName,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'Education ID'  } ],
          identification: [ { position: 30, label: 'Education ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_EDUCATION', element: 'eduid' } }]
    @Search.defaultSearchElement: true    
    eduid as Eduid,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #HIGH, label: 'Education Name' } ],
          identification: [ { position: 40, label: 'Education Name' } ] }
    _Education.eduname as EducationName,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM, label: 'Level of Education' } ],
          identification: [ { position: 50,label: 'Level of Education' } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_EDULEVEL_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @ObjectModel.text.element: ['EduLevelDesc']
    @UI.textArrangement: #TEXT_ONLY      
    empedulevel as EmpEduLevel,
    
    @UI.hidden: true
    _EduLevel.text as EduLevelDesc,
 
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM, label: 'Institution' } ],
          identification: [ { position: 60, label: 'Institution' } ] }
    empeduinstitution as EmpEduInstitution,
    
    @UI: {
          lineItem:       [ { position: 70, importance: #MEDIUM, label: 'Start Date' } ],
          identification: [ { position: 70, label: 'Start Date' } ] }
    empedustart as EmpEduStartDate,
    
    @UI: {
          lineItem:       [ { position: 80, importance: #MEDIUM, label: 'End Date' } ],
          identification: [ { position: 80, label: 'End Date' } ] }
    empeduend as EmpEduEndDate,
    
    @UI: {
          lineItem:       [ { position: 90, importance: #MEDIUM, label: 'Grade (GPA)' } ],
          identification: [ { position: 90, label: 'Grade (GPA)' } ] }
    empedugrade as EmpEduGrade,
    
    @UI: {
          lineItem:       [ { position: 100, importance: #MEDIUM, label: 'Note' } ],
          identification: [ { position: 100, label: 'Note' } ] }
    empedunote as EmpEduNote,
   
    @UI.hidden: true
    last_changed_at as LastChangeAt
}
