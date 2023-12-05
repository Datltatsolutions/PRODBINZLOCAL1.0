@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Organizational Structure'
define root view entity ZI_ORG 
    as select from ztorg
{
    key orgunitid,
    orgunitname,
    orgunitmanager,
    orgcompany,
    orgbusinessres,
    orgsegment,
    orgprofitcenter,
    orgcostcenter,
    orgreportinglineunit,
    orgsalesorg,
    
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at    
}
