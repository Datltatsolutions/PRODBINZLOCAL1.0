@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Job'
define root view entity ZI_JOB 
    as select from ztjob as Job

    association [0..1] to ZI_READ_FUNCTION_DOMAIN as _Function on $projection.jobfunction = _Function.value_low
{
    key jobid,
    jobname,
    jobfunction,
     
   @Semantics.user.createdBy: true
   created_by,
   @Semantics.systemDateTime.createdAt: true
   created_at,
   @Semantics.user.lastChangedBy: true
   last_changed_by,
   @Semantics.systemDateTime.lastChangedAt: true
   last_changed_at,
     
   _Function
}
