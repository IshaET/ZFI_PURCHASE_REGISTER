@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Entry'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_JOURNALENTRY
  as select distinct from I_OperationalAcctgDocItem
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
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      abs( TaxBaseAmountInTransCrcy ) as TaxBaseAmount,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      max( case when TransactionTypeDetermination = 'JIC'
                then cast( abs(AmountInCompanyCodeCurrency) as abap.dec(23,2) )
                else cast( 0 as abap.dec(23,2) )
           end ) as CGSTAmount,
           
           @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      max( case when TransactionTypeDetermination = 'JIS'
                then cast( abs(AmountInCompanyCodeCurrency) as abap.dec(23,2) )
                else cast( 0 as abap.dec(23,2) )
           end ) as SGSTAmount,
           
           @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      max( case when TransactionTypeDetermination = 'JII'
                then cast( abs(AmountInCompanyCodeCurrency) as abap.dec(23,2) )
                else cast( 0 as abap.dec(23,2) )
           end ) as IGSTAmount,
      
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      max( case when TransactionTypeDetermination = 'JIM'
                then cast( abs(AmountInCompanyCodeCurrency) as abap.dec(23,2) )
                else cast( 0 as abap.dec(23,2) )
           end ) as ImpGSTDedAmt_INR,
           
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( TaxBaseAmountInTransCrcy ) as TotalTaxBaseAmount,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case when TransactionTypeDetermination = 'JIM'
                then cast( TaxAmountInCoCodeCrcy as abap.dec(23,2) )
                else cast( 0 as abap.dec(23,2) )
           end ) as TotalImpGSTDedAmt_JIM,
           
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
  TransactionCurrency
