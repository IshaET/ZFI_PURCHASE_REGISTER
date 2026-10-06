@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI Invoice Summary'
@Metadata.allowExtensions: true
define view entity ZI_INV_FI_SUMMARY
  as select distinct from I_AccountingDocumentJournal( P_Language: 'E' )
{
  key ReferenceDocument,
  key FiscalYear,
  key CompanyCode,
  key AccountingDocument,
      PostingDate,
      InvoiceReference,
      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      @DefaultAggregation: #SUM
      sum(DebitAmountInTransCrcy)  as DebitAmountInTransCrcy,
      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      @DefaultAggregation: #SUM
      sum(CreditAmountInTransCrcy) as CreditAmountInTransCrcy,
      TransactionCurrency,
      max(
      case
      when TransactionTypeDetermination = 'PRD' then 'A_PRD'
      when (TransactionTypeDetermination like 'JI%'
         or TransactionTypeDetermination like 'JR%'
         or TransactionTypeDetermination like 'JC%')
      then 'B_GST'
      else ''
      end
      )                            as TransactionTypeDetermination,

      sum(
        case when TransactionTypeDetermination = 'JIC'
             then case when DebitCreditCode = 'S'
                       then cast(DebitAmountInTransCrcy as abap.dec(23,2))
                       else - cast(CreditAmountInTransCrcy as abap.dec(23,2))
                  end
             else cast(0 as abap.dec(23,2))
        end )                      as CGSTAmount,

      sum(
        case
                   when TransactionTypeDetermination = 'JIS'
                   then
                       case
                           when DebitCreditCode = 'S'
                           then cast( DebitAmountInTransCrcy as abap.dec(23,2) )
                           else - cast( CreditAmountInTransCrcy as abap.dec(23,2) )
                       end
                   else cast( 0 as abap.dec(23,2) )
               end )               as SGSTAmount,

      sum(
        case
                   when TransactionTypeDetermination = 'JII'
                   then
                       case
                           when DebitCreditCode = 'S'
                           then cast( DebitAmountInTransCrcy as abap.dec(23,2) )
                           else - cast( CreditAmountInTransCrcy as abap.dec(23,2) )
                       end
                   else cast( 0 as abap.dec(23,2) )
               end )               as IGSTAmount,

      sum(
        case
                   when TransactionTypeDetermination = 'PRD'
                   then
                       case
                           when DebitCreditCode = 'S'
                           then cast( DebitAmountInTransCrcy as abap.dec(23,2) )
                           else - cast( CreditAmountInTransCrcy as abap.dec(23,2) )
                       end
                   else cast( 0 as abap.dec(23,2) )
               end )               as PriceDifference,

      sum(
        case
                   when TransactionTypeDetermination = 'JRS'
                   then
                       case
                           when DebitCreditCode = 'S'
                           then cast( DebitAmountInTransCrcy as abap.dec(23,2) )
                           else - cast( CreditAmountInTransCrcy as abap.dec(23,2) )
                       end
                   else cast( 0 as abap.dec(23,2) )
               end )               as SGSTRevAmt,

      sum(
        case
                   when TransactionTypeDetermination = 'JRC'
                   then
                       case
                           when DebitCreditCode = 'S'
                           then cast( DebitAmountInTransCrcy as abap.dec(23,2) )
                           else - cast( CreditAmountInTransCrcy as abap.dec(23,2) )
                       end
                   else cast( 0 as abap.dec(23,2) )
               end )               as CGSTRevAmt,

      sum(
        case
                   when TransactionTypeDetermination = 'JRI'
                   then
                       case
                           when DebitCreditCode = 'S'
                           then cast( DebitAmountInTransCrcy as abap.dec(23,2) )
                           else - cast( CreditAmountInTransCrcy as abap.dec(23,2) )
                       end
                   else cast( 0 as abap.dec(23,2) )
               end )               as IGSTRevAmt,

      sum(
        case
                   when TransactionTypeDetermination = 'JIM'
                   then
                       case
                           when DebitCreditCode = 'S'
                           then cast( DebitAmountInTransCrcy as abap.dec(23,2) )
                           else - cast( CreditAmountInTransCrcy as abap.dec(23,2) )
                       end
                   else cast( 0 as abap.dec(23,2) )
               end )               as ImpGSTDedAmt,
               
      sum(
        case
                   when TransactionTypeDetermination = 'JTI'
                   then
                       case
                           when DebitCreditCode = 'S'
                           then cast( DebitAmountInTransCrcy as abap.dec(23,2) )
                           else - cast( CreditAmountInTransCrcy as abap.dec(23,2) )
                       end
                   else cast( 0 as abap.dec(23,2) )
               end )               as TCS,

      FixedAsset,
      AccountingDocumentHeaderText,

      case
        when sum(cast(DebitAmountInTransCrcy as abap.dec(23,2))) > 0
             and sum(cast(CreditAmountInTransCrcy as abap.dec(23,2))) = 0
        then 'S'

        when sum(cast(CreditAmountInTransCrcy as abap.dec(23,2))) < 0
             and sum(cast(DebitAmountInTransCrcy as abap.dec(23,2))) = 0
        then 'H'

        else ' '
      end                          as DebitCreditCode,

      DocumentReferenceID,
      IsReversal

}
where
       Ledger                       =    '0L'

  and(
       TransactionTypeDetermination like 'JI%'
    or TransactionTypeDetermination like 'JC%'
    or TransactionTypeDetermination like 'JR%'
    or TransactionTypeDetermination like 'JT%'
    or TransactionTypeDetermination =    'PRD'
  )
group by
  ReferenceDocument,
  FiscalYear,
  AccountingDocument,
  PostingDate,
  CompanyCode,
  TransactionCurrency,
  FixedAsset,
  AccountingDocumentHeaderText,
  DocumentReferenceID,
  InvoiceReference,
  IsReversal
