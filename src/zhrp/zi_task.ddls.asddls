@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Task Management'
define root view entity ZI_TASK
    as select from ztask as Task
    association [0..1] to ZI_EMPLOYEE as _Employee on $projection.empid = _Employee.empid
{ 
  key taskid,
  tags,
  description,
  taskfrom,
  assignemp,
  documenttype,
  documentid,
  booproductid,
  booprocess,
  taskstartdate,
  taskdeadline,
  finishdate,
  estimatetime,
  workingtime,
  duration,
  priority,
  status,
  progress,
  taskcomment,
  approvedby,
  relatedtask,
  
  _Employee.empid,
  @Semantics.systemDateTime.createdAt: true
  created_at,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at,
  @Semantics.user.createdBy: true
  created_by,
  @Semantics.user.lastChangedBy: true
  last_modify
}
