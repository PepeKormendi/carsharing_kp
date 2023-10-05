@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Cars'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZKP_I_VH_MODELS
  as select from zkp_cars
{
      @Semantics.text: true
  key model             as Model,
      max( kilometers ) as Km

}
group by
  model,
  kilometers
