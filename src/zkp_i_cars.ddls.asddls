@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'composite for DB cars'
define root view entity ZKP_I_CARS
  as select from zkp_cars as Car
  composition [0..*] of ZKP_I_CARBOOKINGS as _Booking
  association [0..1] to I_Currency        as _Currency on $projection.CurrencyCode = _Currency.Currency
  association [1..1] to ZKP_VH_ENGINES    as _Engine   on $projection.Enginetype = _Engine.value_low
  association [1..1] to ZKP_VH_MSTATUS    as _MStatus  on $projection.Status = _MStatus.value_low
  association [1..1] to ZKP_I_VH_CARS     as _Brand    on $projection.Brand = _Brand.Brand
  association [1..1] to ZKP_I_VH_MODELS   as _Model    on $projection.Model = _Model.Model

{
  key car_uuid              as CarUUID,
      platenum              as PlatNum,
      brand                 as Brand,
      model                 as Model,
      enginetype            as Enginetype,
      img                   as Img,
      yearmanufact          as Yearmanufact,
      lastmaint             as Lastmaint,
      kilometers            as Kilometers,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      dailyprice            as Dailyprice,
      currency_code         as CurrencyCode,
      status                as Status,
      numofseats            as Numofseats,
      url                   as Url,
      
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      //total ETag field
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Booking, // Make association public
      _Currency,
      _Engine,
      _MStatus,
      _Brand,
      _Model
}
