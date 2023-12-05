@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Bill of Operation'
define root view entity ZI_BOO
as select from ztboo
    association [0..1] to ZI_JOB as _Job on $projection.boojob = _Job.jobid 
    association [0..1] to ZI_READ_UNIT_DOMAIN as _Unit on $projection.boounit = _Unit.value_low
    association [0..1] to ZI_READ_TYPE_DOMAIN as _Type on $projection.bootype = _Type.value_low
{
    key mykey,
    booproductid,
    booproductvar,
    booproductdesc,
    boounit,
    booprocess,
    bootype,
    booworkingtime,
    booduration,
    boojob,
    boocostest,
    
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at,    
    
    _Job,
    _Unit,
    _Type
}
