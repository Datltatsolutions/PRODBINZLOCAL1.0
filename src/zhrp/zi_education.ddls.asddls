@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Education'
define root view entity ZI_EDUCATION
    as select from zteducation
{
    key eduid,
    eduname,
    edunotes,
     
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at
}
