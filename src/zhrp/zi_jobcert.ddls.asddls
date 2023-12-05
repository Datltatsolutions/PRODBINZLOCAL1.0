@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Job Certificate'
define root view entity ZI_JOBCERT 
    as select from ztjobcert as JobCertificate
    
    /*Associations*/
    association [0..1] to ZI_JOB as _Job on $projection.jobid = _Job.jobid
    association [0..1] to ZI_CERTIFICATE as _Certificate on $projection.certid = _Certificate.certid
{
    key mykey,
    jobid,
    _Job.jobname,
    certid,
    _Certificate.certname,
    jobcertnotes,
    
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
    _Certificate
}
