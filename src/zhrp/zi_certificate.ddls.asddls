@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label: 'Data model for Certificate'
define root view entity ZI_CERTIFICATE 
    as select from ztcertificate as Certificate
{
    key certid,
    certname,
    certdesc,
    certrenew,
    certnote,
    
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at
}
