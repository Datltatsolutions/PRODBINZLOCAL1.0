@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Position'
define root view entity ZI_POSITION 
    as select from ztposition
    
    association [0..1] to ZI_JOB as _Job on $projection.posjobid = _Job.jobid
    association [0..1] to ZI_EMPLOYEE as _Employee on $projection.posempid = _Employee.empid
    association [0..1] to ZI_ORG as _Org on $projection.posorgid = _Org.orgunitid
{
    key posid,
    posdesc,
    posjobid,
    posempid,
    concat_with_space(concat(_Employee.empfirstname,','),_Employee.emplastname,1) as empname,
    posorgid,
    posexpireddate,
      
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at,
  
    _Job,
    _Employee,
    _Org
}
