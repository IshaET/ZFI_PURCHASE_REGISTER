@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Purchase Register'
@Metadata.allowExtensions: true
@Analytics.dataCategory: #CUBE

define view entity ZI_PURCHASE_REGISTER
  as select distinct from ZC_INV_SUM                     as f

    left outer join       I_PurchaseOrderAPI01           as a    on f.PurchaseOrder = a.PurchaseOrder

    left outer join       I_PurchaseOrderItemAPI01       as b    on  f.PurchaseOrder     = b.PurchaseOrder
                                                                 and f.PurchaseOrderItem = b.PurchaseOrderItem

    left outer join       I_ProductPlantBasic            as c    on  b.Material = c.Product
                                                                 and b.Plant    = c.Plant

    left outer join       ZI_GR_FIRST                    as d    on  f.PurchaseOrder     = d.PurchaseOrder
                                                                 and f.PurchaseOrderItem = d.PurchaseOrderItem
                                                                 and f.ReferenceDocument = d.MaterialDocument

    left outer join       I_SupplierInvoiceAPI01         as g    on  f.SupplierInvoice = g.SupplierInvoice
                                                                 and f.FiscalYear      = g.FiscalYear

    left outer join       I_Supplier                     as e    on g.InvoicingParty = e.Supplier

    left outer join       ZI_TAX_RATE_SUM                as h    on f.TaxCode = h.TaxCode

    left outer join       I_Product                      as j    on b.Material = j.Product

    left outer join       I_ExtProdGrpText               as k    on j.ExternalProductGroup = k.ExternalProductGroup

    left outer join       I_ProductDescription           as l    on j.Product = l.Product

  //    left outer join       I_ProductValuationBasic              as m    on  b.Material      = m.Product
  //                                                                       and b.ValuationType = m.ValuationType
  //
  //    left outer join       I_Prodvaluationclasstxt              as n    on m.ValuationClass = n.ValuationClass

    left outer join       I_PurOrdAccountAssignmentAPI01 as p    on  b.PurchaseOrder     = p.PurchaseOrder
                                                                 and b.PurchaseOrderItem = p.PurchaseOrderItem

    left outer join       ZC_PO_PRICING_SUM              as q    on  b.PurchaseOrder     = q.PurchaseOrder
                                                                 and b.PurchaseOrderItem = q.PurchaseOrderItem

    left outer join       ZI_FRT_SUP                     as fsup on  b.PurchaseOrder     = fsup.PurchaseOrder
                                                                 and b.PurchaseOrderItem = fsup.PurchaseOrderItem

    left outer join       I_Supplier                     as fs   on fs.Supplier = fsup.FreightSupplier

    left outer join       ZI_OPRNTNLACCDOCITM            as r    on  f.FiscalYear          = r.FiscalYear
                                                                 and f.SupplierInvoice     = r.ReferenceDocument
                                                                 and f.SupplierInvoiceItem = r.ReferenceDocumentItem

    left outer join       ZI_JOURNALENTRY                as jo   on  r.AccountingDocument = jo.AccountingDocument
                                                                 and f.FiscalYear         = jo.FiscalYear
                                                                 and a.CompanyCode        = jo.CompanyCode
                                                                 and f.TaxCode            = jo.TaxCode
                                                                 and f.InvoiceAmount      = jo.TaxBaseAmount

    left outer join       ZI_OFFSETTING                  as of   on  r.AccountingDocument     = of.AccountingDocument
                                                                 and r.AccountingDocumentItem = of.AccountingDocumentItem
                                                                 and f.FiscalYear             = of.FiscalYear
                                                                 and a.CompanyCode            = of.CompanyCode

    left outer join       ZI_OFFSETTING                  as grn  on  f.ReferenceDocument = grn.ReferenceDocument
                                                                 and f.PurchaseOrder     = grn.PurchasingDocument
                                                                 and f.PurchaseOrderItem = grn.PurchasingDocumentItem
                                                                 and f.FiscalYear        = grn.FiscalYear
                                                                 and a.CompanyCode       = grn.CompanyCode

    left outer join       ZI_INV_FI_SUMMARY              as i    on  f.SupplierInvoice = i.ReferenceDocument
                                                                 and f.FiscalYear      = i.FiscalYear
                                                                 and a.CompanyCode     = i.CompanyCode

    left outer join       I_Withholdingtaxitem           as o    on  i.AccountingDocument = o.AccountingDocument
                                                                 and f.FiscalYear         = o.FiscalYear
                                                                 and a.CompanyCode        = o.CompanyCode

    left outer join       ZI_TAX                         as ta   on  a.CompanyCode         = ta.CompanyCode
                                                                 and f.FiscalYear          = ta.FiscalYear
                                                                 and r.AccountingDocument  = ta.AccountingDocument
                                                                 and f.TaxCode             = ta.TaxCode
                                                                 and f.SupplierInvoiceItem = ta.TaxItemAcctgDocItemRef

    left outer join       I_OperationalAcctgDocItem      as tax  on  a.CompanyCode         = tax.CompanyCode
                                                                 and f.FiscalYear          = tax.FiscalYear
                                                                 and r.AccountingDocument  = tax.AccountingDocument
                                                                 and f.TaxCode             = tax.TaxCode
                                                                 and f.SupplierInvoiceItem = tax.TaxItemAcctgDocItemRef
{
  key f.PurchaseOrder,
  key f.PurchaseOrderItem,
  key f.ReferenceDocument                                                                                                                  as MaterialDocument,
  key f.ReferenceDocumentItem                                                                                                              as MaterialDocumentItem,
  key f.SupplierInvoice,
  key f.SupplierInvoiceItem,

      a.CompanyCode,
      a.PurchaseOrderDate,
      g.InvoicingParty                                                                                                                     as Supplier,
      a.PurchasingGroup,
      a.PurchaseOrderType,

      f.Plant,

      b.MaterialGroup,

      @Semantics.amount.currencyCode: 'POCurrency'
      @Aggregation.default: #SUM
      max( b.NetPriceAmount )                                                                                                              as NetPriceAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      @Aggregation.default: #SUM
      max( cast( f.InvoiceAmount as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )               as NetAmount,

      @Semantics.amount.currencyCode: 'CurrencyNetAmt'
      @Aggregation.default: #SUM
      max( coalesce( cast( cast( f.InvoiceAmount as abap.dec(23,2) ) * g.ExchangeRate as abap.dec(23,2) ), 0 )
           * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                                                         as NetAmount_INR,

      cast( 'INR' as abap.cuky )                                                                                                           as CurrencyNetAmt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      @Aggregation.default: #SUM
      max( cast( f.InvoiceAmount as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )               as TaxBaseAmt,

      @Semantics.amount.currencyCode: 'POCurrency'
      @Aggregation.default: #SUM
      max( cast( b.NetAmount as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                   as POAmount,

      b.DocumentCurrency                                                                                                                   as POCurrency,
      f.DocumentCurrency,

      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      b.OrderQuantity,
      b.PurchaseOrderQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      max( cast( d.QuantityInEntryUnit as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )         as QuantityInEntryUnit,
      d.EntryUnit,

      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderPriceUnit'
      max( cast( f.QtyInPurchaseOrderPriceUnit as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end ) as QtyInPurchaseOrderPriceUnit,
      f.PurchaseOrderPriceUnit,

      b.GoodsReceiptIsExpected,
      b.IsCompletelyDelivered,
      b.InvoiceIsExpected,
      b.IsFinallyInvoiced,
      f.TaxCode,
      b.ValuationCategory,
      b.ValuationType,
      b.BR_NCM                                                                                                                             as ConsumptionTaxCtrlCode,

      f.PurchaseOrderItemMaterial,

      d.GoodsMovementType,
      d.IsAutomaticallyCreated,

      e.SupplierName,
      e.CityName,
      e.Region,
      e.Country,
      e.TaxNumber3                                                                                                                         as GSTIN,

      f.FiscalYear,
      f.IsSubsequentDebitCredit,
      g.IsInvoice,
      i.IsReversal,

      case
        when g.IsInvoice = ''  and f.IsSubsequentDebitCredit = ''  then '2'
        when g.IsInvoice = ''  and f.IsSubsequentDebitCredit = 'X' then '4'
        when g.IsInvoice = 'X' and f.IsSubsequentDebitCredit = ''  then '1'
        when g.IsInvoice = 'X' and f.IsSubsequentDebitCredit = 'X' then '3'
        else ''
      end                                                                                                                                  as DocumentTypeCode,

      case
        when g.IsInvoice = ''  and f.IsSubsequentDebitCredit = ''  then 'Credit Memo'
        when g.IsInvoice = ''  and f.IsSubsequentDebitCredit = 'X' then 'Subsequent Credit'
        when g.IsInvoice = 'X' and f.IsSubsequentDebitCredit = ''  then 'Invoice'
        when g.IsInvoice = 'X' and f.IsSubsequentDebitCredit = 'X' then 'Subsequent Debit'
        else ''
      end                                                                                                                                  as DocumentTypeText,

      g.SupplierPostingLineItemText,
      g.AccountingDocumentType,
      g.SupplierInvoiceStatus,
      g.SupplierInvoiceIDByInvcgParty                                                                                                      as MIRORef,

      a.PaymentTerms,

      cast( g.ExchangeRate as abap.dec(9,5) )                                                                                              as ExchangeRate,

      g.BusinessPlace,

      i.DocumentReferenceID,
      r.AccountingDocument,
      f.DebitCreditCode,
      r.PostingDate,
      r.JournalEntryDate,
      r.ReversalReferenceDocument,
      i.FixedAsset,

      @Aggregation.default: #SUM
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      max( cast( jo.CGSTAmount as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                 as CGSTAmount,

      @Aggregation.default: #SUM
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      max( cast( jo.SGSTAmount as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                 as SGSTAmount,

      @Aggregation.default: #SUM
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      max( cast( jo.IGSTAmount as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                 as IGSTAmount,

      @Aggregation.default: #SUM
      max( i.PriceDifference )                                                                                                             as PriceDifference,

      @Aggregation.default: #SUM
      max( ( case when f.TaxCode = 'J1' or f.TaxCode = 'J2' or f.TaxCode = 'P5' or
                       f.TaxCode = 'P6' or f.TaxCode = 'P7' or f.TaxCode = 'P8' or
                       f.TaxCode = 'PB' or f.TaxCode = 'PC'
                  then cast( division( cast(f.InvoiceAmount as abap.dec(23,2)) * h.CGSTRevRate, 100, 2 ) as abap.dec(23,2) )
             end ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end
         )                                                                                                                                 as CGSTRevAmt,

      @Aggregation.default: #SUM
      max( ( case when f.TaxCode = 'J1' or f.TaxCode = 'J2' or f.TaxCode = 'P5' or
                       f.TaxCode = 'P6' or f.TaxCode = 'P7' or f.TaxCode = 'P8' or
                       f.TaxCode = 'PB' or f.TaxCode = 'PC'
                  then cast( division( cast(f.InvoiceAmount as abap.dec(23,2)) * h.SGSTRevRate, 100, 2 ) as abap.dec(23,2) )
             end ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end
         )                                                                                                                                 as SGSTRevAmt,

      @Aggregation.default: #SUM
      max( ( case when f.TaxCode = 'J1' or f.TaxCode = 'J2' or f.TaxCode = 'P5' or
                       f.TaxCode = 'P6' or f.TaxCode = 'P7' or f.TaxCode = 'P8' or
                       f.TaxCode = 'PB' or f.TaxCode = 'PC'
                  then cast( division( cast(f.InvoiceAmount as abap.dec(23,2)) * h.IGSTRevRate, 100, 2 ) as abap.dec(23,2) )
             end ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end
         )                                                                                                                                 as IGSTRevAmt,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      max(case
          when tax.TransactionTypeDetermination = 'JIM'
               then cast( tax.AmountInCompanyCodeCurrency as abap.dec(23,2) )

          else cast(
                  division(
                      cast(jo.TaxBaseAmountInTransCrcy as abap.dec(23,2)) * h.ImpGSTDedRate,
                      100,
                      2
                  ) as abap.dec(23,2)
               )
      end )                                                                                                                                as ImpGSTDedAmt,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @DefaultAggregation: #SUM
      max(case
          when tax.TransactionTypeDetermination = 'JIM'
               then cast( tax.AmountInCompanyCodeCurrency as abap.dec(23,2) )

          else cast(
                  division(
                      cast(jo.TaxBaseAmountInTransCrcy as abap.dec(23,2)) * h.ImpGSTDedRate,
                      100,
                      2
                  ) as abap.dec(23,2)
               )
      end )                                                                                                                                as ImpGSTDedAmt_INR,

      @Aggregation.default: #SUM
      max( i.TCS )                                                                                                                         as TCS,

      i.AccountingDocumentHeaderText,

      j.ExternalProductGroup,
      k.ExternalProductGroupName,
      l.ProductDescription,

      //      m.ValuationClass,
      //      n.ValuationClassDescription,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @Aggregation.default: #SUM
      o.WhldgTaxAmtInCoCodeCrcy,

      o.CompanyCodeCurrency,

      b.AccountAssignmentCategory,
      b.ProfitCenter,
      p.CostCenter,

      d.ReferenceDocument                                                                                                                  as DeliveryNote,

      @Aggregation.default: #SUM
      max( cast( q.OtherCharges as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                as OtherCharges,

      @Aggregation.default: #SUM
      max( cast( q.LandCharges as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                 as LandCharges,

      @Aggregation.default: #SUM
      max( cast( q.FreightCharges as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )              as FreightCharges,

      @Aggregation.default: #SUM
      max( cast( q.CVDAmt as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                      as CVDAmt,

      @Aggregation.default: #SUM
      max( cast( q.BasicCustoms as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                as CustomDuty,

      @Aggregation.default: #SUM
      max( cast( q.SWSCharges as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                  as SWSCharges,

      @Aggregation.default: #SUM
      max( cast( q.InsuranceCharges as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )            as InsuranceCharges,

      @Aggregation.default: #SUM
      max( cast( q.OverheadFreight as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )             as ImportFreight,

      @Aggregation.default: #SUM
      max( cast( q.FreightLocal as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                as FreightLocal,

      @Aggregation.default: #SUM
      max( cast( q.FreightDuty as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                 as FreightDuty,

      @Aggregation.default: #SUM
      max( cast( q.CHACharges as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end )                  as CHACharges,

      fsup.FreightSupplier                                                                                                                 as CHASupplier,
      fs.SupplierName                                                                                                                      as FreightSupplierName,
      fs.TaxNumber3                                                                                                                        as FreightSupGST,

      @Aggregation.default: #SUM
      max(h.CGSTRate)                                                                                                                      as CGSTRate,

      @Aggregation.default: #SUM
      max(h.SGSTRate)                                                                                                                      as SGSTRate,

      @Aggregation.default: #SUM
      max(h.IGSTRate)                                                                                                                      as IGSTRate,

      @Aggregation.default: #SUM
      max(h.CGSTRevRate)                                                                                                                   as CGSTRevRate,

      @Aggregation.default: #SUM
      max(h.SGSTRevRate)                                                                                                                   as SGSTRevRate,

      @Aggregation.default: #SUM
      max(h.IGSTRevRate)                                                                                                                   as IGSTRevRate,

      @Aggregation.default: #SUM
      max(h.ImpGSTDedRate)                                                                                                                 as ImpGSTDedRate,

      @Aggregation.default: #SUM
      max(h.TCSRate)                                                                                                                       as TCSRate,

      @Aggregation.default: #SUM
      max(grn.PurchaseOffsettingAmt)                                                                                                       as GRNOffset,

      @Aggregation.default: #SUM
      max(of.PurchaseOffsettingAmt)                                                                                                        as PurchaseOffsettingAmt,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      @Aggregation.default: #SUM
      max(
      /* 1. Base - MM Field (Needs Dynamic Sign) */
        ( coalesce(cast( cast( f.InvoiceAmount as abap.dec(23,2) ) * g.ExchangeRate as abap.dec(23,2) ), 0)
          * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end ) +

      /* 2. FI Adjustments (Already Signed Natively in FI except new calculated ones) */
      coalesce( cast( ( cast( jo.CGSTAmount as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end ) as abap.dec(23,2) ), 0 ) +
      coalesce( cast( ( cast( jo.SGSTAmount as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end ) as abap.dec(23,2) ), 0 ) +
      coalesce( cast( ( cast( jo.IGSTAmount as abap.dec(13,3) ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end ) as abap.dec(23,2) ), 0 )    +
        coalesce(cast( i.PriceDifference as abap.dec(23,2) ), 0) +

      /* 3. Reverse GSTs Calculated Inline (MM Base requires Dynamic Sign) */
        coalesce(
          ( case when f.TaxCode = 'J1' or f.TaxCode = 'J2' or f.TaxCode = 'P5' or f.TaxCode = 'P6' or f.TaxCode = 'P7' or f.TaxCode = 'P8' or f.TaxCode = 'PB' or f.TaxCode = 'PC'
                 then cast( division( cast(f.InvoiceAmount as abap.dec(23,2)) * h.CGSTRevRate, 100, 2 ) as abap.dec(23,2) )
                 else cast( 0 as abap.dec(23,2) )
            end ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end, 0
        ) +
        coalesce(
          ( case when f.TaxCode = 'J1' or f.TaxCode = 'J2' or f.TaxCode = 'P5' or f.TaxCode = 'P6' or f.TaxCode = 'P7' or f.TaxCode = 'P8' or f.TaxCode = 'PB' or f.TaxCode = 'PC'
                 then cast( division( cast(f.InvoiceAmount as abap.dec(23,2)) * h.SGSTRevRate, 100, 2 ) as abap.dec(23,2) )
                 else cast( 0 as abap.dec(23,2) )
            end ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end, 0
        ) +
        coalesce(
          ( case when f.TaxCode = 'J1' or f.TaxCode = 'J2' or f.TaxCode = 'P5' or f.TaxCode = 'P6' or f.TaxCode = 'P7' or f.TaxCode = 'P8' or f.TaxCode = 'PB' or f.TaxCode = 'PC'
                 then cast( division( cast(f.InvoiceAmount as abap.dec(23,2)) * h.IGSTRevRate, 100, 2 ) as abap.dec(23,2) )
                 else cast( 0 as abap.dec(23,2) )
            end ) * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end, 0
        ) +

      /* 4. ImpGSTDedAmt Calculated Inline (FI Base is already signed) */
        coalesce(
          case when tax.TransactionTypeDetermination = 'JIM'
               then cast( tax.AmountInCompanyCodeCurrency as abap.dec(23,2) )
               else cast( division( cast(jo.TaxBaseAmountInTransCrcy as abap.dec(23,2)) * h.ImpGSTDedRate, 100, 2 ) as abap.dec(23,2) )
          end, 0
        ) +

      /* 5. Withholding Tax Amount */
        coalesce( cast( o.WhldgTaxAmtInCoCodeCrcy as abap.dec(23,2) ), 0 )
      )                                                                                                                                    as TotalAmount,

      @Semantics.amount.currencyCode: 'CurrencyTotAmt'
      @Aggregation.default: #SUM
      max(
      /* 1. Base - MM Field (Needs Dynamic Sign) */
        ( coalesce(cast( cast( f.InvoiceAmount as abap.dec(23,2) ) * g.ExchangeRate as abap.dec(23,2) ), 0)
          * case when g.IsInvoice = '' or i.IsReversal = 'X' then -1 else 1 end ) +

      /* 2. FI Adjustments (Already Signed Natively) */
        coalesce(cast( i.PriceDifference as abap.dec(23,2) ), 0) +

      /* 3. ImpGSTDedAmt Calculated Inline (FI Base is already signed) */
        coalesce(
          case when tax.TransactionTypeDetermination = 'JIM'
               then cast( tax.AmountInCompanyCodeCurrency as abap.dec(23,2) )
               else cast( division( cast(jo.TaxBaseAmountInTransCrcy as abap.dec(23,2)) * h.ImpGSTDedRate, 100, 2 ) as abap.dec(23,2) )
          end, 0
        ) +

      /* 4. Withholding Tax Amount */
        coalesce( cast( o.WhldgTaxAmtInCoCodeCrcy as abap.dec(23,2) ), 0 )

      )                                                                                                                                    as TotalAmount_INR,

      cast( 'INR' as abap.cuky )                                                                                                           as CurrencyTotAmt
}
where
       f.PurchaseOrder                  <> ''
  and(
       d.IsAutomaticallyCreated         <> 'X'
    or d.IsAutomaticallyCreated         is null
  )
  and  b.PurchasingDocumentDeletionCode is initial

group by
  f.PurchaseOrder,
  f.PurchaseOrderItem,
  f.ReferenceDocument,
  f.ReferenceDocumentItem,
  f.SupplierInvoice,
  f.SupplierInvoiceItem,

  a.CompanyCode,
  a.PurchaseOrderDate,
  g.InvoicingParty,
  a.PurchasingGroup,
  a.PurchaseOrderType,

  f.Plant,

  b.MaterialGroup,
  f.DocumentCurrency,
  b.DocumentCurrency,
  b.OrderQuantity,
  b.PurchaseOrderQuantityUnit,

  d.MaterialDocument,
  d.QuantityInEntryUnit,
  d.EntryUnit,
  d.GoodsMovementType,
  d.IsAutomaticallyCreated,

  b.GoodsReceiptIsExpected,
  b.IsCompletelyDelivered,
  b.InvoiceIsExpected,
  b.IsFinallyInvoiced,
  f.TaxCode,
  b.ValuationCategory,
  b.ValuationType,
  b.BR_NCM,
  r.ReversalReferenceDocument,

  f.PurchaseOrderItemMaterial,

  e.SupplierName,
  e.CityName,
  e.Region,
  e.Country,
  e.TaxNumber3,

  f.FiscalYear,
  f.IsSubsequentDebitCredit,

  g.IsInvoice,
  b.PurchasingDocumentDeletionCode,
  g.SupplierPostingLineItemText,
  g.AccountingDocumentType,
  g.SupplierInvoiceStatus,
  g.SupplierInvoiceIDByInvcgParty,
  g.ExchangeRate,
  g.BusinessPlace,

  a.PaymentTerms,

  i.DocumentReferenceID,
  r.AccountingDocument,
  f.DebitCreditCode,
  r.PostingDate,
  r.JournalEntryDate,
  i.FixedAsset,
  i.AccountingDocumentHeaderText,
  d.ReferenceDocument,

  j.ExternalProductGroup,
  k.ExternalProductGroupName,
  l.ProductDescription,

  //  m.ValuationClass,
  //  n.ValuationClassDescription,

  o.WhldgTaxAmtInCoCodeCrcy,
  o.CompanyCodeCurrency,

  b.AccountAssignmentCategory,
  b.ProfitCenter,
  p.CostCenter,

  fsup.FreightSupplier,
  fs.SupplierName,
  fs.TaxNumber3,

  f.QtyInPurchaseOrderPriceUnit,
  f.PurchaseOrderPriceUnit,
  i.IsReversal
