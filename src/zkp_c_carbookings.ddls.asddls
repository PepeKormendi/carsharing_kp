@EndUserText.label: 'Booking Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['BookingID']
define view entity ZKP_C_CARBOOKINGS
  as projection on ZKP_I_CARBOOKINGS
{
  key BookingUUID,
      CarUUID,
      @Search.defaultSearchElement: true
      BookingID,
      BookingDate,
      BookedFrom,
      BookedTo,
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZSZAKD_I_VH_CUSTOMERALL', element: 'CustomerUuid' }, useForValidation: true}]
      CustomerUuid,
      @ObjectModel.text.element: ['CustomerName']
      CustName,
      CustomerName,
      //      _CustomerNew.CustomerUuid as CustName,
      //      _CustomerNew.LastName     as CustomerName,
      BookPrice,
      PriceInHuf,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZSZAKD_I_CUR_EXVH', element: 'CurrencyCode' }, useForValidation: true }]
      CurCodeDummy,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,
      @ObjectModel.text.element: ['BookingStatusText']
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Booking_Status_VH', element: 'BookingStatus' }}]
      BookingStatus,
      _BookingStatus._Text.Text as BookingStatusText : localized,
      LocalLastChangedAt,
      /* Associations */

      _BookingStatus,

      _Car : redirected to parent ZKP_C_CARS,
      _Currency,
      _CustomerNew
}
