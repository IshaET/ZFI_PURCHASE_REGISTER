@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'First GRN'
@Metadata.allowExtensions: true
define view entity ZI_GR_FIRST
  as select distinct from I_MaterialDocumentItem_2 as a
  left outer join I_MaterialDocumentHeader_2 as b on a.MaterialDocument = b.MaterialDocument
{
  key a.PurchaseOrder,
  key a.PurchaseOrderItem,
      a.MaterialDocument,
      a.MaterialDocumentItem,
      a.Material,
      a.GoodsMovementType,
      a.IsAutomaticallyCreated,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      a.QuantityInEntryUnit,
      a.EntryUnit,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      sum( a.TotalGoodsMvtAmtInCCCrcy ) as NetAmount,
      a.CompanyCodeCurrency,
      b.ReferenceDocument 
}
where
  (
        a.GoodsMovementType      <> '321'
    and a.GoodsMovementType      <> '641'
    and a.GoodsMovementType      <> '543'
  )
  and   a.IsAutomaticallyCreated <> 'X'
  and   a.PurchaseOrder          <> ''
group by
  a.PurchaseOrder,
  a.PurchaseOrderItem,
  a.MaterialDocument,
  a.MaterialDocumentItem,
  a.Material,
  a.GoodsMovementType,
  a.IsAutomaticallyCreated,
  a.QuantityInEntryUnit,
  a.EntryUnit,
  a.CompanyCodeCurrency,
  b.ReferenceDocument
