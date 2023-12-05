@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model of Job Skill Required'
define root view entity ZI_JOBSKILL
    as select from ztjobskill as JobSkill
    
    /*Associations*/
    association [0..1] to ZI_JOB as _Job on $projection.jobid = _Job.jobid
    association [0..1] to ZI_SKILL as _Skill on $projection.skillid = _Skill.skillid
    association [0..1] to ZI_READ_LEVELNUM5_DOMAIN as _SkillLevel on $projection.skilllevel = _SkillLevel.value_low
{
    key mykey,
    jobid,
    _Job.jobname,
    skillid,
    _Skill.skillname,
    skilllevel,
    skillcoefficient,
    skilllevel1,
    skilllevel2,
    skilllevel3,
    skilllevel4,
    skilllevel5,
    concat(cast(skilllevel1 as abap.char(3)), '%') as skilllevel1text,
    concat(cast(skilllevel2 as abap.char(3)), '%') as skilllevel2text,
    concat(cast(skilllevel3 as abap.char(3)), '%') as skilllevel3text,
    concat(cast(skilllevel4 as abap.char(3)), '%') as skilllevel4text,
    concat(cast(skilllevel5 as abap.char(3)), '%') as skilllevel5text,    
    jobskillnotes,
  
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
    _Skill,
    _SkillLevel
}
