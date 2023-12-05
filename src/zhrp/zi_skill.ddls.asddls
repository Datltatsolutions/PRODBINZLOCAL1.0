@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Skill'
define root view entity ZI_SKILL
    as select from ztskill
{
    key skillid,
    skillname,
    skillnote,
  
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at
}
