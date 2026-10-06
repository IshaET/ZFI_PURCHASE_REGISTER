@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OffSetting Amount'
@Metadata.allowExtensions: true
define view entity ZI_OFFSETTING
  as select distinct from I_AccountingDocumentJournal(P_Language : 'E')
{
  key CompanyCode,
  key AccountingDocument,
  key AccountingDocumentItem,
  key FiscalYear,
  key LedgerGLLineItem,
      ReferenceDocument,
      ReferenceDocumentItem,
      PurchasingDocument,
      PurchasingDocumentItem,

      case when TransactionTypeDetermination = 'EKG'
                 then case when DebitCreditCode = 'S'
                           then cast(DebitAmountInTransCrcy as abap.dec(23,2))
                           else cast(CreditAmountInTransCrcy as abap.dec(23,2))
                      end
                 else cast(0 as abap.dec(23,2)) end as PurchaseOffsettingAmt

}
where
      Ledger                       = '0L'
  and TransactionTypeDetermination = 'EKG'
