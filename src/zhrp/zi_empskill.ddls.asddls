@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Employee Education'
define root view entity ZI_EMPSKILL
    as select from ztempskill as EmployeeSkill
    
    //Association
    association [0..1] to ZI_EMPLOYEE as _Employee on $projection.empid = _Employee.empid
    association [0..1] to ZI_SKILL as _Skill on $projection.skillid = _Skill.skillid
    association [0..1] to ZI_READ_LEVELNUM5_DOMAIN as _LevelNum on $projection.empskilllevel = _LevelNum.value_low
{
    key mykey,
    empid,
    concat_with_space(concat(_Employee.empfirstname,','),_Employee.emplastname,1) as empname,
    skillid,
    _Skill.skillname as skillname,
    empskilllevel,
    empskillnote,
      
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
    _Skill,
    _LevelNum
}
