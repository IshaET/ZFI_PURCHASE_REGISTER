@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Register'
@Metadata.allowExtensions: true
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [ #ANALYTICAL_QUERY ]
@Analytics.query: true
define view entity ZC_PUR_REGISTER
  as select from ZI_PURCHASE_REGISTER
{
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchaseOrderAPI01', element: 'PurchaseOrder' } }]
  key PurchaseOrder,
      @AnalyticsDetails.query.axis: #ROWS
  key PurchaseOrderItem,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_MaterialDocumentHeader_2', element: 'MaterialDocument' } }]
  key MaterialDocument,
      @AnalyticsDetails.query.axis: #ROWS
  key MaterialDocumentItem,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SupplierInvoiceAPI01', element: 'SupplierInvoice' } }]
  key SupplierInvoice,
      @AnalyticsDetails.query.axis: #ROWS
  key SupplierInvoiceItem,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: true }
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }]
      CompanyCode,
      PurchaseOrderDate,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Supplier', element: 'Supplier' } }]
      Supplier,
      PurchasingGroup,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      PurchaseOrderType,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Plant', element: 'Plant' } }]
      Plant,
      MaterialGroup,
      NetPriceAmount,
      NetAmount,
      NetAmount_INR,
      CurrencyNetAmt,
      TaxBaseAmt,
      POAmount,
      POCurrency,
      DocumentCurrency,
      OrderQuantity,
      PurchaseOrderQuantityUnit,
      QuantityInEntryUnit,
      EntryUnit,
      QtyInPurchaseOrderPriceUnit,
      PurchaseOrderPriceUnit,
      GoodsReceiptIsExpected,
      IsCompletelyDelivered,
      InvoiceIsExpected,
      IsFinallyInvoiced,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      TaxCode,
      ValuationCategory,
      ValuationType,
      ConsumptionTaxCtrlCode,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      PurchaseOrderItemMaterial,
      GoodsMovementType,
      IsAutomaticallyCreated,
      SupplierName,
      CityName,
      Region,
      Country,
      GSTIN,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.axis: #ROWS
      FiscalYear,
      IsSubsequentDebitCredit,
      IsInvoice,
      IsReversal,
      DocumentTypeCode,
      DocumentTypeText,
      SupplierPostingLineItemText,
      AccountingDocumentType,
      SupplierInvoiceStatus,
      @EndUserText.label: 'Invoice No.'
      MIRORef,
      PaymentTerms,
      ExchangeRate,
      BusinessPlace,
      DocumentReferenceID,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.axis: #ROWS
      AccountingDocument,
      DebitCreditCode,
      @Consumption.filter: {
      selectionType: #INTERVAL,
      multipleSelections: true,
      mandatory: false
      }
      @AnalyticsDetails.query.axis: #ROWS
      PostingDate,
      @Consumption.filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.axis: #ROWS
      JournalEntryDate,
      FixedAsset,
      CGSTAmount,
      SGSTAmount,
      IGSTAmount,
      PriceDifference,
      CGSTRevAmt,
      SGSTRevAmt,
      IGSTRevAmt,
      ImpGSTDedAmt,
      ImpGSTDedAmt_INR,
      TCS,
      AccountingDocumentHeaderText,
      ExternalProductGroup,
      ExternalProductGroupName,
      ProductDescription,
      WhldgTaxAmtInCoCodeCrcy,
      CompanyCodeCurrency,
      AccountAssignmentCategory,
      ReversalReferenceDocument,
      ProfitCenter,
      CostCenter,
      DeliveryNote,
      OtherCharges,
      LandCharges,
      FreightCharges,
      CVDAmt,
      CustomDuty,
      SWSCharges,
      InsuranceCharges,
      ImportFreight,
      FreightLocal,
      FreightDuty,
      CHACharges,
      CHASupplier,
      FreightSupplierName,
      FreightSupGST,
      CGSTRate,
      SGSTRate,
      IGSTRate,
      CGSTRevRate,
      SGSTRevRate,
      IGSTRevRate,
      ImpGSTDedRate,
      TCSRate,
      GRNOffset,
      PurchaseOffsettingAmt,
      TotalAmount,
      TotalAmount_INR,
      CurrencyTotAmt
}
