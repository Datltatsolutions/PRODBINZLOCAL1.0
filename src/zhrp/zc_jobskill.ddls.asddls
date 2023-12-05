@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Job Skill Required'
@UI: { headerInfo: { typeName: 'Job Skill Required', 
       typeNamePlural: 'Job Skill Required', 
       title: { type: #STANDARD, value: 'JobID' }, 
       description: { value:'Skillid' } } }

@Search.searchable: true
define root view entity ZC_JOBSKILL
as projection on ZI_JOBSKILL as JobSkill
{
    @UI.facet: [{ id: 'JobSkill',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Job Skill',
                 position: 10 }] 
    @UI.hidden: true
    key mykey as JobEduUUID,       
    
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Job ID' } ],
          identification: [ { position: 10, label: 'Job ID' } ] }
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_JOB', element: 'jobid' } }]
    @Search.defaultSearchElement: true
    jobid as JobID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH, label: 'Job Name' } ],
          identification: [ { position: 20, label: 'Job Name' } ] }
    jobname as JobName,  
    
    @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'Skill ID'  } ],
          identification: [ { position: 30, label: 'Skill ID' } ] }
          
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_SKILL', element: 'skillid' } }]
    @Search.defaultSearchElement: true    
    skillid as Skillid,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #HIGH, label: 'Skill Name'  } ],
          identification: [ { position: 40, label: 'Skill Name' } ] }
    skillname as SkillName,

    @UI: {
          lineItem:       [ { position: 50, importance: #MEDIUM, label: 'Level (1-5)'  } ],
          identification: [ { position: 50, label: 'Level (1-5)' } ] }
    @Consumption.valueHelpDefinition: [{ entity: {name: 'ZI_READ_LEVELNUM5_DOMAIN' , element: 'value_low' },
    distinctValues: true}]
    @ObjectModel.text.element: ['LevelDesc']
    @UI.textArrangement: #TEXT_ONLY
    skilllevel as SkillLevel,
     
    @UI.hidden: true
    _SkillLevel.text as LevelDesc,
    
    @UI: {
          lineItem:       [ { position: 60, importance: #MEDIUM, label: 'Coefficient' } ],
          identification: [ { position: 60, label: 'Coefficient' } ] } 
    skillcoefficient as SkillCoefficient,
    
    @UI: {
          lineItem:       [ { position: 70, importance: #MEDIUM, label: 'Level 1' } ],
          identification: [ { position: 70, label: 'Level 1' } ] } 
    @ObjectModel.text.element: ['SkillLevel1Text']
    @UI.textArrangement: #TEXT_ONLY
    skilllevel1 as SkillLevel1,
    
    @UI.hidden: true
    skilllevel1text as SkillLevel1Text,
    
    @UI: {
          lineItem:       [ { position: 80, importance: #MEDIUM, label: 'Level 2' } ],
          identification: [ { position: 80, label: 'Level 2' } ] } 
    @ObjectModel.text.element: ['SkillLevel2Text']
    @UI.textArrangement: #TEXT_ONLY
    skilllevel2 as SkillLevel2,
    
    @UI.hidden: true
    skilllevel2text as SkillLevel2Text,
    
    @UI: {
          lineItem:       [ { position: 90, importance: #MEDIUM, label: 'Level 3' } ],
          identification: [ { position: 90, label: 'Level 3' } ] } 
    @ObjectModel.text.element: ['SkillLevel3Text']
    @UI.textArrangement: #TEXT_ONLY
    skilllevel3 as SkillLevel3,
    
    @UI.hidden: true
    skilllevel3text as SkillLevel3Text,
    
    @UI: {
          lineItem:       [ { position: 100, importance: #MEDIUM, label: 'Level 4' } ],
          identification: [ { position: 100, label: 'Level 4' } ] } 
    @ObjectModel.text.element: ['SkillLevel4Text']
    @UI.textArrangement: #TEXT_ONLY
    skilllevel4 as SkillLevel4,
    
    @UI.hidden: true
    skilllevel4text as SkillLevel4Text,
    
    @UI: {
          lineItem:       [ { position: 110, importance: #MEDIUM, label: 'Level 5' } ],
          identification: [ { position: 110, label: 'Level 5' } ] } 
    @ObjectModel.text.element: ['SkillLevel5Text']
    @UI.textArrangement: #TEXT_ONLY
    skilllevel5 as SkillLevel5,
    
    @UI.hidden: true
    skilllevel5text as SkillLevel5Text,
   
    @UI: {
          lineItem:       [ { position: 120, importance: #MEDIUM, label: 'Note' } ],
          identification: [ { position: 120, label: 'Note' } ] } 
    jobskillnotes as JobSkillNote,
    
    @UI.hidden: true
    last_changed_at as LastChangedAt
}
