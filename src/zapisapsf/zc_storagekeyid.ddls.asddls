@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Storagekeyid projection view - Processor'
@UI: 
    { headerInfo: { typeName: 'Storage Key ID', 
      typeNamePlural: 'Storage Key ID' } }
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_STORAGEKEYID
provider contract transactional_query
as projection on ZI_STORAGEKEYID as StorageKeyID
{
    @UI.facet: [{ id: 'sapid',
                     purpose: #STANDARD,
                     type: #IDENTIFICATION_REFERENCE,
                      label: 'Storage Key API',
                      position: 10 }]   
        @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'SAP ID'  } ],
          identification: [ { position: 10, label: 'SAP ID' } ] }
         @Search.defaultSearchElement: true
    key sapid as SAPID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #HIGH, label: 'Bussiness Partner ID'  } ],
          identification: [ { position: 20, label: 'Bussiness Partner ID' } ] }
    bussinesspartnerid as BussinessPartnerID,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #HIGH, label: 'SalesForce Key'  } ],
          identification: [ { position: 30, label: 'SalesForce Key' } ] }
    sfkey as SalesForceID,
    
    @UI: {
          lineItem:       [ { position: 40, importance: #HIGH, label: 'Create At'  } ],
          identification: [ { position: 40, label: 'Create At' } ] }
    created_at as CreateAt
}
