@EndUserText.label: 'Projection view for Update Reqs from SF'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: 
    { headerInfo: { typeName: 'SF Update Req', 
      typeNamePlural: 'SF Update Req' } }
@Search.searchable: true
define root view entity ZC_SFUPDATEREQ
as projection on ZI_SFUPDATEREQ as SFUpdateReq
{
    @UI.facet: [{ id: 'SFUpdateReq',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'SF Update Request',
                 position: 10 }]
                 
    @UI: {
         lineItem:       [ { position: 10, importance: #HIGH, label: 'Request ID' } ],
         identification: [ { position: 10, label: 'ID' } ] }
    @EndUserText.label: 'Request ID'
    @Search.defaultSearchElement: true
    key requestid as RequestID,
    
    @UI: {
         lineItem:       [ { position: 20, importance: #HIGH, label: 'Request Date Time' } ],
         identification: [ { position: 20, label: 'Date Time' } ] }    
    @EndUserText.label: 'Request Date Time'
    requestdatetime as RequestDateTime,
    
    @UI: {
         lineItem:       [ { position: 30, importance: #HIGH, label: 'Body Request' } ],
         identification: [ { position: 30, label: 'Body Request' } ] }    
    @EndUserText.label: 'Body Request'    
    bodyrequest as BodyRequest,
    
    @UI: {
         lineItem:       [ { position: 40, importance: #HIGH, label: 'Approved' },
                           { type: #FOR_ACTION, dataAction: 'approveRequest', label: 'Approve Request' }],
         identification: [ { position: 40, label: 'Approved' } ] }    
    @EndUserText.label: 'Approved'
    checkapprove as CheckApprove,
    
    @UI: {
         lineItem:       [ { position: 50, importance: #HIGH, label: 'Approve Employee' } ],
         identification: [ { position: 50, label: 'Approve Employee' } ] }    
    @EndUserText.label: 'Approve Employee'    
    approveemployee as AppoveEmployee,
    
    @UI: {
         lineItem:       [ { position: 60, importance: #HIGH, label: 'Approve Date Time' } ],
         identification: [ { position: 60, label: 'Approve Date Time' } ] }    
    @EndUserText.label: 'Approve Date Time'    
    approvedatetime as ApproveDateTime
}
