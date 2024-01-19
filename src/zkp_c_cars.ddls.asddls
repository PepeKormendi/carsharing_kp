@EndUserText.label: 'Car Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['PlatNum']

define root view entity ZKP_C_CARS 
  provider contract transactional_query
  as projection on ZKP_I_CARS as Car
{
  key CarUUID,
      @Search.defaultSearchElement: true
      PlatNum,

      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZKP_I_VH_CARS' , element: 'Brand' }, distinctValues: true }]
      Brand,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZKP_I_VH_MODELS' , element: 'Model' }, distinctValues: true }]
      Model,
      @ObjectModel.text.element: ['EngineName']
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZKP_VH_ENGINES' , element: 'Enginetype' }, distinctValues: true }]
      Enginetype,
      _Engine.text  as EngineName,
//      @Semantics.imageUrl: true
//      @UI.textArrangement: #TEXT_ONLY
      Img,
      Yearmanufact,
      Lastmaint,
      Kilometers,
      Dailyprice,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,
      @ObjectModel.text.element: ['StatusName']
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZKP_VH_MSTATUS' , element: 'value_low' }, distinctValues: true }]
      Status,
      _MStatus.text as StatusName,
      Numofseats,

      Url,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child ZKP_C_CARBOOKINGS,
      _Brand,
      _Currency,
      _Engine,
      _Model,
      _MStatus
}
