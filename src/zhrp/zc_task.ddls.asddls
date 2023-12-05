@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Task Management'
@UI: { headerInfo: { typeName: 'Task Management', 
       typeNamePlural: 'Task Management', 
       title: { type: #STANDARD, value: 'TaskID' }, 
       description: { value:'TaskID' } } }

@Search.searchable: true
define root view entity ZC_TASK
as projection on ZI_TASK as Task
{
     @UI.facet: [{ id: 'EmployeeEducation',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                  label: 'Employee Education',
                  position: 10 }]               

    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Task ID' } ],
          identification: [ { position: 10, label: 'Task ID' } ] }      
    key taskid as TaskID,        
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH, label: 'Tags' } ],
          identification: [ { position: 20, label: 'Tags' } ] }
    tags as Tags,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'Description'  } ],
          identification: [ { position: 30, label: 'Description' } ] }    
    description as Descrtiption,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #HIGH, label: 'From' } ],
          identification: [ { position: 40, label: 'From' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_EMPLOYEE', element: 'empid' } }]
    @Search.defaultSearchElement: true
    taskfrom as TaskFrom,
    
    @UI: {
          lineItem:       [ { position: 50, importance: #HIGH, label: 'Assigned Employee ID' } ],
          identification: [ { position: 50,label: 'Assigned Employee ID' } ] }      
    assignemp as AssignedEmployee,
 
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM, label: 'Document ID' } ],
          identification: [ { position: 60, label: 'Document ID' } ] }
    documentid as DocumentID,
    
    @UI: {
          lineItem:       [ { position: 70, importance: #MEDIUM, label: 'Document Type' } ],
          identification: [ { position: 70, label: 'Document Type' } ] }
    documenttype as DocumentType,
    
    @UI: {
          lineItem:       [ { position: 80, importance: #MEDIUM, label: 'Product ID' } ],
          identification: [ { position: 80, label: 'Product ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_BOO', element: 'booproductid' } }]
    @Search.defaultSearchElement: true
    booproductid as TaskBOOProductID,
    
    @UI: {
          lineItem:       [ { position: 90, importance: #MEDIUM, label: 'Process ID' } ],
          identification: [ { position: 90, label: 'Process ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_BOO', element: 'booprocess' } }]
    @Search.defaultSearchElement: true
    booprocess as TaskBOOProcess,
    
    @UI: {
          lineItem:       [ { position: 100, importance: #MEDIUM, label: 'Start Datetime' } ],
          identification: [ { position: 100, label: 'Start Datetime' } ] }
    taskstartdate as TaskStartDate,
    
    @UI: {
          lineItem:       [ { position: 110, importance: #MEDIUM, label: 'Deadline' } ],
          identification: [ { position: 110, label: 'Deadline' } ] }
    taskdeadline as TaskDeadline,
    
    @UI: {
          lineItem:       [ { position: 120, importance: #MEDIUM, label: 'Finish Datetime' } ],
          identification: [ { position: 120, label: 'Finish Datetime' } ] }
    finishdate as TaskFinishDate,
    
    @UI: {
          lineItem:       [ { position: 130, importance: #MEDIUM, label: 'Estimated Time' } ],
          identification: [ { position: 130, label: 'Estimated Time' } ] }
    estimatetime as TaskEstimateDate,
    
    @UI: {
          lineItem:       [ { position: 140, importance: #MEDIUM, label: 'Working Time' } ],
          identification: [ { position: 140, label: 'Working Time' } ] }
    workingtime as TaskWorkingTime,
    
    @UI: {
          lineItem:       [ { position: 150, importance: #MEDIUM, label: 'Duration' } ],
          identification: [ { position: 150, label: 'Duration' } ] }
    duration as TaskDuration,
    
    @UI: {
          lineItem:       [ { position: 160, importance: #MEDIUM, label: 'Priority' } ],
          identification: [ { position: 160, label: 'Priority' } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_TASKPRIORITY_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @UI.fieldGroup: [{ qualifier: 'TaskGeneralGroup', position: 160 }]
    priority as TaskPriority,
    
    @UI: {
          lineItem:       [ { position: 170, importance: #MEDIUM, label: 'Status' } ],
          identification: [ { position: 170, label: 'Status' } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_TASKSTATUS_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @UI.fieldGroup: [{ qualifier: 'TaskGeneralGroup', position: 170 }]
    status as TaskStatus,
    
    @UI: {
          lineItem:       [ { position: 180, importance: #MEDIUM, label: 'Progress' } ],
          identification: [ { position: 180, label: 'Progress' } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_TASKPROGRESS_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @UI.fieldGroup: [{ qualifier: 'TaskGeneralGroup', position: 180 }]
    progress as TaskProgress,
    
    @UI: {
          lineItem:       [ { position: 190, importance: #MEDIUM, label: 'Comments' } ],
          identification: [ { position: 190, label: 'Comments' } ] }
    taskcomment as TaskComment,
    
    @UI: {
          lineItem:       [ { position: 200, importance: #MEDIUM, label: 'Approve By' } ],
          identification: [ { position: 100, label: 'Approve By' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_EMPLOYEE', element: 'empid' } }]
    @Search.defaultSearchElement: true
     approvedby as TaskApprovedBy,
    
    @UI: {
          lineItem:       [ { position: 210, importance: #MEDIUM, label: 'Related Task' } ],
          identification: [ { position: 210, label: 'Related Task' } ] }
    relatedtask as TaskRelated,

    @UI: {
          lineItem:       [ { position: 220, importance: #LOW, label: 'Create At' } ],
          identification: [ { position: 220, label: 'Created At' } ] }
    created_at as CreatedAt, 
        
    @UI: {
          lineItem:       [ { position: 230, importance: #LOW, label: 'Created By' } ],
          identification: [ { position: 230, label: 'Created By' } ] }
    created_by as TaskCreatedBy,
    
    @UI: {
          lineItem:       [ { position: 240, importance: #LOW, label: 'Last Change At' } ],
          identification: [ { position: 240, label: 'Last Changed At' } ] }
    last_changed_at as LastChanged,
    
    @UI: {
          lineItem:       [ { position: 250, importance: #LOW, label: 'Last Modified By' } ],
          identification: [ { position: 250, label: 'Last Modified By' } ] }
    last_modify as TaskLastModifyBy
    
}
