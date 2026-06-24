/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.domain.entities.market_rate;
import uim.platform.marketrates;

// mixin(ShowModule!());

@safe:

// A single market rate record – the core domain entity.
// Maps directly to one entry in an upload/download payload.
struct MarketRate {
  mixin TenantEntity!MarketRateId;

  // Identifies where the data comes from
  string providerCode;   // e.g. "ECB", "TR"
  string dataSource;     // e.g. "NYSE", "ECB"

  // Category code as per SAP MRM BYOR spec (e.g. "01" = Exchange Rates)
  MarketDataCategory category;

  // Key pair; combined must be <= 15 chars for S/4HANA download
  string key1;           // e.g. "EUR"
  string key2;           // e.g. "USD" (empty for interest rates)

  // Market data property (e.g. "CMID" for midday value)
  string marketDataProperty;

  // Temporal validity
  string effectiveDate;  // YYYYMMDD
  string effectiveTime;  // HHMMSS

  // The actual numeric value
  double marketDataValue;

  // Optional fields
  string securityCurrency; // For securities
  int fromFactor;           // Translation ratio – from currency
  int toFactor;             // Translation ratio – to currency
  PriceQuotation priceQuotation;
  string additionalKey;     // e.g. number of days for volatilities

  Json toJson() const {
    return entityToJson
      .set("providerCode",       providerCode)
      .set("dataSource",         dataSource)
      .set("category",           category)
      .set("key1",               key1)
      .set("key2",               key2)
      .set("marketDataProperty", marketDataProperty)
      .set("effectiveDate",      effectiveDate)
      .set("effectiveTime",      effectiveTime)
      .set("marketDataValue",    marketDataValue)
      .set("securityCurrency",   securityCurrency)
      .set("fromFactor",         fromFactor)
      .set("toFactor",           toFactor)
      .set("priceQuotation",     priceQuotation.to!string)
      .set("additionalKey",      additionalKey);
  }
}
