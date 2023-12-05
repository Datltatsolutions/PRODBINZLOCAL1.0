@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Job Education'
define root view entity ZI_JOBEDU
    as select from ztjobedu as JobEducation
    
    //Association
    association [0..1] to ZI_JOB as _Job on $projection.jobid = _Job.jobid
    association [0..1] to ZI_EDUCATION as _Education on $projection.eduid = _Education.eduid
    association [0..1] to ZI_READ_EDULEVEL_DOMAIN as _EduLevel on $projection.edulevel = _EduLevel.value_low
{
    key mykey,
    jobid,
    eduid,
    jobname,
    eduname,
    edulevel,
    jobedunotes,
  
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at,
  
    /* Public associations */
    _Job,
    _Education,
    _EduLevel
}
