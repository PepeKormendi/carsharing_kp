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
  association [1..1] to ZSZAKD_I_CUSTOMER        as _CustomerNew   on $projection.CustomerUuid = _CustomerNew.CustomerUuid
  association [0..1] to I_Currency               as _Currency      on $projection.CurrencyCode = _Currency.Currency
  association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on $projection.BookingStatus = _BookingStatus.BookingStatus
  association [0..1] to zszakd_curren_ex         as _CurExchange   on $projection.CurrencyCode = _CurExchange.currency_code
{
  key booking_uuid                     as BookingUUID,
      parent_uuid                      as CarUUID,
      customer_uuid                    as CustomerUuid,
      booking_id                       as BookingID,
      booking_date                     as BookingDate,
      booked_from                      as BookedFrom,
      booked_to                        as BookedTo,
      customer_id                      as CustomerID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      book_price                       as BookPrice,
      //      case currency_code
      //      when 'HUF' then cast ( book_price as abap.int4 )
      //      else cast( 0 as abap.int4 )
      //      end                   as PriceInHuf,
      cast( 0 as abap.int4 )           as PriceInHuf,
      cast( '' as /dmo/currency_code ) as CurCodeDummy,
      currency_code                    as CurrencyCode,
      booking_status                   as BookingStatus,

      customer_uuid                    as CustName,
      _CustomerNew.LastName            as CustomerName,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at            as LocalLastChangedAt,

      _Car,
      _Currency,
      _Customer,
      _CustomerNew,
      _BookingStatus,
      _CurExchange
}
