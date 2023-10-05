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
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Customer_StdVH', element: 'CustomerID' }, useForValidation: true}]
      CustomerID,
      _Customer.LastName        as CustomerName,
      BookPrice,
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
      _Customer
}
