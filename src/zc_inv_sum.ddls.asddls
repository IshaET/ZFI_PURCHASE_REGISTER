@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Summary'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_INV_SUM
  as select distinct from I_SuplrInvcItemPurOrdRefAPI01
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key SupplierInvoice,
  key SupplierInvoiceItem,    
      ReferenceDocument,
      ReferenceDocumentItem,
      FiscalYear,
      IsSubsequentDebitCredit,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(SupplierInvoiceItemAmount) as InvoiceAmount,
      DocumentCurrency,
      TaxCode,
      PurchaseOrderPriceUnit,
      DebitCreditCode,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderPriceUnit'
      QtyInPurchaseOrderPriceUnit,
      PurchaseOrderItemMaterial,
      Plant
}
group by
  PurchaseOrder,
  PurchaseOrderItem,
  SupplierInvoice,
  SupplierInvoiceItem,
  FiscalYear,
  DocumentCurrency,
  ReferenceDocument,
  IsSubsequentDebitCredit,
  TaxCode,
  QtyInPurchaseOrderPriceUnit,
  PurchaseOrderPriceUnit,
  PurchaseOrderItemMaterial,
  Plant,
  ReferenceDocumentItem,
  DebitCreditCode
