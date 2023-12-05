@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Employee Education'
define root view entity ZI_EMPEDU
    as select from ztempedu as EmployeeEducation
    
    //Association
    association [0..1] to ZI_EMPLOYEE as _Employee on $projection.empid = _Employee.empid
    association [0..1] to ZI_EDUCATION as _Education on $projection.eduid = _Education.eduid
    association [0..1] to ZI_READ_EDULEVEL_DOMAIN as _EduLevel on $projection.empedulevel = _EduLevel.value_low
{
    key mykey,
    empid,
    concat_with_space(concat(_Employee.empfirstname,','),_Employee.emplastname,1) as empname,
    eduid,
    empeduname,
    empedulevel,
    empeduinstitution,
    empedustart,
    empeduend,
    empedugrade,
    empedunote,
  
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at,
  
  /* Public associations */
    _Employee,
    _Education,
    _EduLevel
}
