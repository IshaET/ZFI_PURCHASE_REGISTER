@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Operational Acc Doc Item'
@Metadata.allowExtensions: true

define view entity ZI_OPRNTNLACCDOCITM
  as select distinct from I_JournalEntryItem as a

    left outer join I_JournalEntry as b
      on  a.CompanyCode        = b.CompanyCode
      and a.AccountingDocument = b.AccountingDocument
      and a.FiscalYear         = b.FiscalYear
             

{
      key a.AccountingDocument,
      key a.AccountingDocumentItem,
      key a.FiscalYear,
      key a.CompanyCode,

          a.ReferenceDocument,
          a.ReferenceDocumentItem,
          a.AssignmentReference,
//          a.MasterFixedAsset as FixedAsset,
          a.ReversalReferenceDocument,

          b.DocumentReferenceID as DocumentReferenceID,
          b.PostingDate,
          b.DocumentDate as JournalEntryDate,
          substring( b.AccountingDocumentHeaderText, 6, 10 ) 
          as AccountingDocumentHeaderText

} 
where a.Ledger = '0L'
