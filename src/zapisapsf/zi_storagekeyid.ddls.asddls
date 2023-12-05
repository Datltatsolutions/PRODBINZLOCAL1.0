@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data model for Storage Key ID'
define root view entity ZI_STORAGEKEYID 
as select from ztstoragekeyid as StorageKeyID
{
    key sapid,
    bussinesspartnerid,
    sfkey,
    s4hckey,
    pathurlkey,
    
    @Semantics.systemDateTime.createdAt: true
    created_at
}
