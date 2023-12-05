@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Skill'
@UI: { headerInfo: { typeName: 'Skill', 
       typeNamePlural: 'Skills', 
       title: { type: #STANDARD, value: 'SkillID' }, 
       description: { value:'SkillName' } } }
@Search.searchable: true
define root view entity ZC_SKILL
as projection on ZI_SKILL
{
     @UI.facet: [{ id: 'Skill',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Skill',
                 position: 10 }]
    
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH } ],
          identification: [ { position: 10, label: 'Skill ID' } ] }
    @Search.defaultSearchElement: true
    key skillid as SkillID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #MEDIUM } ],
          identification: [ { position: 20, label: 'Skill Name' } ] }
    skillname as SkillName,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #MEDIUM } ],
          identification: [ { position: 30, label: 'Note' } ] }
    skillnote as SkillNote,
    
    @UI.hidden: true
    last_changed_at as LastChangeAt
}
