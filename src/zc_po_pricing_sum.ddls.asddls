@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pricing Sum'
@Metadata.allowExtensions: true
define view entity ZC_PO_PRICING_SUM
  as select from I_PurOrdItmPricingElementAPI01
{
  key  PurchaseOrder,
  key  PurchaseOrderItem,
       sum(
           case
             when ConditionType = 'ZOTR'
             then cast(ConditionAmount as abap.dec(23,2))
             else cast(0 as abap.dec(23,2))
           end
         )    as OtherCharges,

       sum(
           case
             when ConditionType = 'ZADD'
             then cast(ConditionAmount as abap.dec(23,2))
             else cast(0 as abap.dec(23,2))
           end
         )     as AdditionalDuty,

       sum(
           case
             when ConditionType = 'ZPKP'
             then cast(ConditionAmount as abap.dec(23,2))
             else cast(0 as abap.dec(23,2))
           end
         )     as PnFCharges,

       sum(
           case
             when ConditionType = 'ZPCK'
             then cast(ConditionAmount as abap.dec(23,2))
             else cast(0 as abap.dec(23,2))
           end
         )     as PackingCharges,

       sum(
           case
             when ConditionType = 'ZLND'
             then cast(ConditionAmount as abap.dec(23,2))
             else cast(0 as abap.dec(23,2))
           end
         )     as LandCharges,

       sum(
           case
             when ConditionType = 'ZNAV'
             then cast(ConditionAmount as abap.dec(23,2))
             else cast(0 as abap.dec(23,2))
           end
         )     as TotalTaxes,

       sum(
           case
             when ConditionType = 'FVA1'
               or ConditionType = 'FQU1'
               or ConditionType = 'ZFRJ'
             then cast(ConditionAmount as abap.dec(23,2))
             else cast(0 as abap.dec(23,2))
           end
         )     as FreightCharges,

       sum(
            case
              when ConditionType = 'ZDCB'
              then cast(ConditionAmount as abap.dec(23,2))
              else cast(0 as abap.dec(23,2))
            end
          )    as BasicCustoms,

       sum(
            case
              when ConditionType = 'ZFRO'
              then cast(ConditionAmount as abap.dec(23,2))
              else cast(0 as abap.dec(23,2))
            end
          )    as OverheadFreight,
          
       sum(
            case
              when ConditionType = 'ZFRB'
              then cast(ConditionAmount as abap.dec(23,2))
              else cast(0 as abap.dec(23,2))
            end
          )    as FreightLocal,
       
       sum(
            case
              when ConditionType = 'ZINU'
              then cast(ConditionAmount as abap.dec(23,2))
              else cast(0 as abap.dec(23,2))
            end
          )    as InsuranceCharges,
       
       sum(
            case
              when ConditionType = 'ZCLR'
              then cast(ConditionAmount as abap.dec(23,2))
              else cast(0 as abap.dec(23,2))
            end
          )    as CHACharges,
          
       sum(
           case
            when ConditionType = 'JSWC'
            then cast( ConditionAmount as abap.dec(23,2) )
            else cast( 0 as abap.dec(23,2) )
           end
          )    as SWSCharges,
          
       sum(
           case
            when ConditionType = 'ZCV1'
            then cast( ConditionAmount as abap.dec(23,2) )
            else cast( 0 as abap.dec(23,2) )
           end
          )    as CVDAmt,
          
       sum(
           case
            when ConditionType = 'ZFRH'
            then cast( ConditionAmount as abap.dec(23,2) )
            else cast( 0 as abap.dec(23,2) )
           end
          )    as FreightDuty
}
where
  (
       ConditionType = 'ZOTR'
    or ConditionType = 'ZADD'
    or ConditionType = 'ZPKP'
    or ConditionType = 'ZPCK'
    or ConditionType = 'ZLND'
    or ConditionType = 'ZNAV'
    or ConditionType = 'FVA1'
    or ConditionType = 'FQU1'
    or ConditionType = 'ZFRJ'
    or ConditionType = 'ZDCB'
    or ConditionType = 'ZFRO'
    or ConditionType = 'ZFRB'
    or ConditionType = 'ZCLR'
    or ConditionType = 'ZINU'
    or ConditionType = 'JSWC'
    or ConditionType = 'ZCV1'
    or ConditionType = 'ZFRH'
  )
group by
  PurchaseOrder,
  PurchaseOrderItem
