@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Ref'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSUPLRINVITMPURORDEREF as select from I_SuplrInvcItemPurOrdRefAPI01 as Invoice
  left outer join I_JournalEntryItem as JE
    on Invoice.SupplierInvoice = JE.ReferenceDocument
    and Invoice.SupplierInvoiceItem = JE.ReferenceDocumentItem
   and JE.ReferenceDocumentContext  = 'RMRP'
   // and map the item levels appropriately 
{
    key Invoice.SupplierInvoice,
    key Invoice.SupplierInvoiceItem,
    // Foreign Currency
    Invoice.DocumentCurrency,
    @Semantics.amount.currencyCode: 'DocumentCurrency'
    Invoice.SupplierInvoiceItemAmount,
    // Base INR Currency from Finance
    JE.CompanyCodeCurrency,
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    JE.AmountInCompanyCodeCurrency 
}
