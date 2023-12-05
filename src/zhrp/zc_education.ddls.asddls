@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Education'
@UI: { headerInfo: { typeName: 'Education', 
       typeNamePlural: 'Educations', 
       title: { type: #STANDARD, value: 'EduID' }, 
       description: { value:'EduName' } } }
@Search.searchable: true
define root view entity ZC_EDUCATION
as projection on ZI_EDUCATION
{
    @UI.facet: [{ id: 'Education',
                 purpose: #STANDARD,
                 type: #IDENTIFICATION_REFERENCE,
                 label: 'Education',
                 position: 10 }]
    
    @UI: {
          lineItem:       [ { position: 10, importance: #HIGH } ],
          identification: [ { position: 10, label: 'Education ID' } ] }
      @Search.defaultSearchElement: true
    key eduid as EduID,
    
    @UI: {
          lineItem:       [ { position: 20, importance: #MEDIUM } ],
          identification: [ { position: 20, label: 'Education Name' } ] }
    eduname as EduName,
    
    @UI: {
          lineItem:       [ { position: 30, importance: #MEDIUM } ],
          identification: [ { position: 30, label: 'Note' } ] }
    edunotes as EduNotes,
    
    @UI.hidden: true
    last_changed_at as LastChangeAt
}
