@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO First Item'
@Metadata.allowExtensions: true
define view entity ZI_PO_FIRST_ITEM as select from I_PurchaseOrderItemAPI01
{
  key PurchaseOrder,
      min( PurchaseOrderItem ) as PurchaseOrderItem
}
group by PurchaseOrder
