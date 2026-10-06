@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tax Rate Sum'
@Metadata.allowExtensions: true
define view entity ZI_TAX_RATE_SUM
  as select from I_TaxCodeRate
{
  key TaxCode,

      /* ==========================================================
         1. BASE POSITIVE RATES ("P" Columns)
         Always fetches the base condition rate ratio.
         ========================================================== */
      max( case when VATConditionType = 'JIIG'
                then cast(ConditionRateRatio as abap.dec(5,2))
                else cast(0 as abap.dec(5,2)) end ) as IGSTRateP,

      max( case when VATConditionType = 'JICG'
                then cast(ConditionRateRatio as abap.dec(5,2))
                else cast(0 as abap.dec(5,2)) end ) as CGSTRateP,

      max( case when VATConditionType = 'JISG'
                then cast(ConditionRateRatio as abap.dec(5,2))
                else cast(0 as abap.dec(5,2)) end ) as SGSTRateP,

      /* ==========================================================
         2. PAYABLE RATES (0 if RCM condition exists, else Base Rate)
         ========================================================== */
      case when max( case when VATConditionType = 'JIIR' then 1 else 0 end ) > 0
           then cast( 0 as abap.dec(5,2) )
           else max( case when VATConditionType = 'JIIG'
                          then cast(ConditionRateRatio as abap.dec(5,2))
                          else cast(0 as abap.dec(5,2)) end )
      end                                           as IGSTRate,

      case when max( case when VATConditionType = 'JICR' then 1 else 0 end ) > 0
           then cast( 0 as abap.dec(5,2) )
           else max( case when VATConditionType = 'JICG'
                          then cast(ConditionRateRatio as abap.dec(5,2))
                          else cast(0 as abap.dec(5,2)) end )
      end                                           as CGSTRate,

      case when max( case when VATConditionType = 'JISR' then 1 else 0 end ) > 0
           then cast( 0 as abap.dec(5,2) )
           else max( case when VATConditionType = 'JISG'
                          then cast(ConditionRateRatio as abap.dec(5,2))
                          else cast(0 as abap.dec(5,2)) end )
      end                                           as SGSTRate,

      /* ==========================================================
         3. REVERSE RATES (Negative of Base Rate if RCM exists, else 0)
         ========================================================== */
      case when max( case when VATConditionType = 'JIIR' then 1 else 0 end ) > 0 
           then max( case when VATConditionType = 'JIIG'
                          then cast(ConditionRateRatio as abap.dec(5,2))
                          else cast(0 as abap.dec(5,2)) end ) * -1
           else cast( 0 as abap.dec(5,2) )
      end as IGSTRevRate,

      case when max( case when VATConditionType = 'JICR' then 1 else 0 end ) > 0 
           then max( case when VATConditionType = 'JICG'
                          then cast(ConditionRateRatio as abap.dec(5,2))
                          else cast(0 as abap.dec(5,2)) end ) * -1
           else cast( 0 as abap.dec(5,2) )
      end as CGSTRevRate,

      case when max( case when VATConditionType = 'JISR' then 1 else 0 end ) > 0 
           then max( case when VATConditionType = 'JISG'
                          then cast(ConditionRateRatio as abap.dec(5,2))
                          else cast(0 as abap.dec(5,2)) end ) * -1
           else cast( 0 as abap.dec(5,2) )
      end as SGSTRevRate,

      /* ==========================================================
         4. OTHER RATES
         ========================================================== */
      -- TCS Rate
      max( case when VATConditionType = 'JITC'
                then cast(ConditionRateRatio as abap.dec(5,2))
                else cast(0 as abap.dec(5,2)) end ) as TCSRate,

      -- Import Deduction Rate
      max( case when VATConditionType = 'JIMD'
                then cast(ConditionRateRatio as abap.dec(5,2))
                else cast(0 as abap.dec(5,2)) end ) as ImpGSTDedRate
}
group by
  TaxCode
