@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label: 'Data model for Certificate'
define root view entity ZI_EMPCERT 
    as select from ztempcert as EmployeeCertificate
    
    /*Associations*/
    association [0..1] to ZI_EMPLOYEE as _Employee on $projection.empid = _Employee.empid
    association [0..1] to ZI_CERTIFICATE as _Certificate on $projection.certid = _Certificate.certid
{
    key mykey,
    empid,
    concat_with_space(concat(_Employee.empfirstname,','),_Employee.emplastname,1) as empname,
    certid,
    certstart,
    certend,
    empcertnotes,
    
    @Semantics.user.createdBy: true
    created_by,
    @Semantics.systemDateTime.createdAt: true
    created_at,
    @Semantics.user.lastChangedBy: true
    last_changed_by,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at,
    
    /* Public associations */
    _Employee,
    _Certificate
}
