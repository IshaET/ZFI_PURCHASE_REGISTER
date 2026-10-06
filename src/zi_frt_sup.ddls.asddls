@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Freight Supplier'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_FRT_SUP
  as select from I_PurOrdItmPricingElementAPI01
{
  PurchaseOrder,
  PurchaseOrderItem,
  max( cast(FreightSupplier as lifnr) ) as FreightSupplier  
}
where ConditionType = 'ZCLR'
group by PurchaseOrder, PurchaseOrderItem
