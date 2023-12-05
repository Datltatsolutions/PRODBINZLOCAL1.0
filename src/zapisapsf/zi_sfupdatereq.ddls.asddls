@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Update Reqs from SF'
define root view entity ZI_SFUPDATEREQ
as select from ztsfupdatereq as SFUpdateReq
{
    key requestid,
    requestdatetime,
    bodyrequest,
    checkapprove,
    approveemployee,
    approvedatetime
}
