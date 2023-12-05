/********** GENERATED on 10/21/2023 at 14:35:27 by CB9980000011**************/
 @OData.entitySet.name: 'A_BPIntlAddressVersion' 
 @OData.entityType.name: 'A_BPIntlAddressVersionType' 
 define root abstract entity ZA_BPINTLADDRESSVERSION { 
 key BusinessPartner : abap.char( 10 ) ; 
 key AddressID : abap.char( 10 ) ; 
 key AddressRepresentationCode : abap.char( 1 ) ; 
 @Odata.property.valueControl: 'AddresseeFullName_vc' 
 AddresseeFullName : abap.char( 80 ) ; 
 AddresseeFullName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AddressIDByExternalSystem_vc' 
 AddressIDByExternalSystem : abap.char( 20 ) ; 
 AddressIDByExternalSystem_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AddressPersonID_vc' 
 AddressPersonID : abap.char( 10 ) ; 
 AddressPersonID_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AddressSearchTerm1_vc' 
 AddressSearchTerm1 : abap.char( 20 ) ; 
 AddressSearchTerm1_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AddressSearchTerm2_vc' 
 AddressSearchTerm2 : abap.char( 20 ) ; 
 AddressSearchTerm2_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AddressTimeZone_vc' 
 AddressTimeZone : abap.char( 6 ) ; 
 AddressTimeZone_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CareOfName_vc' 
 CareOfName : abap.char( 40 ) ; 
 CareOfName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CityName_vc' 
 CityName : abap.char( 40 ) ; 
 CityName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CityNumber_vc' 
 CityNumber : abap.char( 12 ) ; 
 CityNumber_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CompanyPostalCode_vc' 
 CompanyPostalCode : abap.char( 10 ) ; 
 CompanyPostalCode_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Country_vc' 
 Country : abap.char( 3 ) ; 
 Country_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'DeliveryServiceNumber_vc' 
 DeliveryServiceNumber : abap.char( 10 ) ; 
 DeliveryServiceNumber_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'DeliveryServiceTypeCode_vc' 
 DeliveryServiceTypeCode : abap.char( 4 ) ; 
 DeliveryServiceTypeCode_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'DistrictName_vc' 
 DistrictName : abap.char( 40 ) ; 
 DistrictName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'FormOfAddress_vc' 
 FormOfAddress : abap.char( 4 ) ; 
 FormOfAddress_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'HouseNumber_vc' 
 HouseNumber : abap.char( 10 ) ; 
 HouseNumber_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'HouseNumberSupplementText_vc' 
 HouseNumberSupplementText : abap.char( 10 ) ; 
 HouseNumberSupplementText_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Language_vc' 
 Language : abap.char( 2 ) ; 
 Language_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'OrganizationName1_vc' 
 OrganizationName1 : abap.char( 40 ) ; 
 OrganizationName1_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'OrganizationName2_vc' 
 OrganizationName2 : abap.char( 40 ) ; 
 OrganizationName2_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'OrganizationName3_vc' 
 OrganizationName3 : abap.char( 40 ) ; 
 OrganizationName3_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'OrganizationName4_vc' 
 OrganizationName4 : abap.char( 40 ) ; 
 OrganizationName4_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PersonFamilyName_vc' 
 PersonFamilyName : abap.char( 40 ) ; 
 PersonFamilyName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PersonGivenName_vc' 
 PersonGivenName : abap.char( 40 ) ; 
 PersonGivenName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'POBox_vc' 
 POBox : abap.char( 10 ) ; 
 POBox_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'POBoxDeviatingCityName_vc' 
 POBoxDeviatingCityName : abap.char( 40 ) ; 
 POBoxDeviatingCityName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'POBoxDeviatingCountry_vc' 
 POBoxDeviatingCountry : abap.char( 3 ) ; 
 POBoxDeviatingCountry_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'POBoxDeviatingRegion_vc' 
 POBoxDeviatingRegion : abap.char( 3 ) ; 
 POBoxDeviatingRegion_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'POBoxIsWithoutNumber_vc' 
 POBoxIsWithoutNumber : abap_boolean ; 
 POBoxIsWithoutNumber_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'POBoxLobbyName_vc' 
 POBoxLobbyName : abap.char( 40 ) ; 
 POBoxLobbyName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'POBoxPostalCode_vc' 
 POBoxPostalCode : abap.char( 10 ) ; 
 POBoxPostalCode_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PostalCode_vc' 
 PostalCode : abap.char( 10 ) ; 
 PostalCode_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PrfrdCommMediumType_vc' 
 PrfrdCommMediumType : abap.char( 3 ) ; 
 PrfrdCommMediumType_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Region_vc' 
 Region : abap.char( 3 ) ; 
 Region_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'SecondaryRegion_vc' 
 SecondaryRegion : abap.char( 8 ) ; 
 SecondaryRegion_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'SecondaryRegionName_vc' 
 SecondaryRegionName : abap.char( 40 ) ; 
 SecondaryRegionName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'StreetName_vc' 
 StreetName : abap.char( 60 ) ; 
 StreetName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'StreetPrefixName1_vc' 
 StreetPrefixName1 : abap.char( 40 ) ; 
 StreetPrefixName1_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'StreetPrefixName2_vc' 
 StreetPrefixName2 : abap.char( 40 ) ; 
 StreetPrefixName2_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'StreetSuffixName1_vc' 
 StreetSuffixName1 : abap.char( 40 ) ; 
 StreetSuffixName1_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'StreetSuffixName2_vc' 
 StreetSuffixName2 : abap.char( 40 ) ; 
 StreetSuffixName2_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'TaxJurisdiction_vc' 
 TaxJurisdiction : abap.char( 15 ) ; 
 TaxJurisdiction_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'TertiaryRegion_vc' 
 TertiaryRegion : abap.char( 8 ) ; 
 TertiaryRegion_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'TertiaryRegionName_vc' 
 TertiaryRegionName : abap.char( 40 ) ; 
 TertiaryRegionName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'TransportZone_vc' 
 TransportZone : abap.char( 10 ) ; 
 TransportZone_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'VillageName_vc' 
 VillageName : abap.char( 40 ) ; 
 VillageName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
