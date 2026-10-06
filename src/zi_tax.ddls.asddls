@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tax'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TAX as select from I_OperationalAcctgDocItem
{
  key CompanyCode,
  key AccountingDocument,
  key FiscalYear,
  key TaxCode,
      TaxItemAcctgDocItemRef,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      AmountInCompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TaxBaseAmountInTransCrcy,
      
      GLAccount,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      max( case when TransactionTypeDetermination = 'JIM'
                then cast( AmountInCompanyCodeCurrency as abap.dec(23,2) )
                else cast( 0 as abap.dec(23,2) )
           end ) as ImpGSTDedAmt_INR,
           
      CompanyCodeCurrency,
      TransactionCurrency
}
where 
AccountingDocumentItemType = 'T'
group by
  CompanyCode,
  AccountingDocument,
  FiscalYear,
  TaxCode,
  TaxItemAcctgDocItemRef,
  TaxBaseAmountInTransCrcy,
  AmountInCompanyCodeCurrency,
  CompanyCodeCurrency,
  TransactionCurrency,
  GLAccount
