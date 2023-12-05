@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label: 'Data model for Employee'
define root view entity ZI_EMPLOYEE 
    as select from ztemployee as Employee
    
    association [0..1] to ZI_READ_GENDER_DOMAIN as _Gender on $projection.empgender = _Gender.value_low
    association [0..1] to ZI_READ_MARITAL_DOMAIN as _Marital on $projection.empmarital = _Marital.value_low
    association [0..1] to ZI_READ_TITLE_DOMAIN as _Title on $projection.emptitle = _Title.value_low
    association [0..1] to ZI_READ_ORGUNIT_DOMAIN as _OrgUnit on $projection.emporgunit = _OrgUnit.value_low
    association [0..1] to ZI_READ_AGREEMENT_DOMAIN as _Agreement on $projection.empagreement = _Agreement.value_low
    association [0..1] to I_CountryVH as _Country on $projection.empcountry = _Country.Country
{
    key empid,
    emppersid,
    empfirstname,
    emplastname,
    concat_with_space(concat(empfirstname,','),emplastname,1) as empname,
    empssn,
    empgender,
    emptitle,
    empmarital,
    empcountry,
    emphomestreet,
    emphomecity,
    emphomestate,
    empprivatephone,
    empjobtitle,
    emporgunit,
    emphiredate,
    empagreement,
    emphours,
    concat_with_space(cast(emphours as abap.char(3)), 'per week',1) as emphourstext,
    empofficeaddr,
    empofficecity,
    empcommphone,
    empmobilephone,
    empemail,
    
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at,
    
    /*Associations*/
    _Gender,
    _Marital,
    _Title,
    _OrgUnit,
    _Agreement,
    _Country
}
