@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'composite for DB carbookings'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZKP_I_CARBOOKINGS
  as select from zkp_car_bookings
  association        to parent ZKP_I_CARS        as _Car           on $projection.CarUUID = _Car.CarUUID
  association [1..1] to /DMO/I_Customer          as _Customer      on $projection.CustomerID = _Customer.CustomerID
  association [0..1] to I_Currency               as _Currency      on $projection.CurrencyCode = _Currency.Currency
  association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on $projection.BookingStatus = _BookingStatus.BookingStatus
{
  key booking_uuid          as BookingUUID,
      parent_uuid           as CarUUID,
      booking_id            as BookingID,
      booking_date          as BookingDate,
      booked_from           as BookedFrom,
      booked_to             as BookedTo,
      customer_id           as CustomerID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      book_price            as BookPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Car,
      _Currency,
      _Customer,
      _BookingStatus
}
