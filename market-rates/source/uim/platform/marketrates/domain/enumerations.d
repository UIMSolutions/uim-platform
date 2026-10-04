/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.domain.enumerations;

import uim.platform.marketrates;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Market data type codes (SAP MRM BYOR standard)
// ---------------------------------------------------------------------------
enum MarketDataCategory : string {
  exchangeRates         = "01",
  securities            = "02",
  interestRates         = "03",
  indexes               = "04",
  basisSpread           = "09",
  creditSpread          = "10",
  forexSwapRates        = "21",
  generalVolatilities   = "30",
  exchangeRateVola      = "31",
  securityPriceVola     = "32",
  interestRateVola      = "33",
  indexVolatilities     = "34",
}

string toString(MarketDataCategory c) {
      mixin(EnumSwitch("MarketDataCategory", "exchangeRates"));
}

string[] toString(MarketDataCategory[] values) {
    return values.map!toString.array;
}

MarketDataCategory toMarketDataCategory(string value) {
    mixin(EnumSwitch("MarketDataCategory", "exchangeRates"));
}

MarketDataCategory[] toMarketDataCategories(string[] values) {
    return values.map!toMarketDataCategory.array;
}

// ---------------------------------------------------------------------------
// Upload / download request status
// ---------------------------------------------------------------------------
enum OperationStatus {
  pending,
  processing,
  success,
  warning,
  failed,
}

OperationStatus toOperationStatus(string value) {
    mixin(EnumSwitch("OperationStatus", "pending"));
}

OperationStatus[] toOperationStatuses(string[] values) {
    return values.map!toOperationStatus.array;
}

string toString(OperationStatus c) {
    return c.to!string;
}

string[] toString(OperationStatus[] values) {
    return values.map!toString.array;
}

// ---------------------------------------------------------------------------
// Quota / plan type
// ---------------------------------------------------------------------------
enum PlanType {
  free,
  default_,
}

PlanType toPlanType(string value) {
    mixin(EnumSwitch("PlanType", "free"));
}

PlanType[] toPlanTypes(string[] values) {
    return values.map!toPlanType.array;
}

string toString(PlanType c) {
    return c.to!string;
}

string[] toString(PlanType[] values) {
    return values.map!toString.array;
}

// ---------------------------------------------------------------------------
// Price quotation direction
// ---------------------------------------------------------------------------
enum PriceQuotation {
  direct,
  indirect,
}

PriceQuotation toPriceQuotation(string value) {
    mixin(EnumSwitch("PriceQuotation", "direct"));
}

PriceQuotation[] toPriceQuotations(string[] values) {
    return values.map!toPriceQuotation.array;
}

string toString(PriceQuotation c) {
    return c.to!string;
}

string[] toString(PriceQuotation[] values) {
    return values.map!toString.array;
}

// ---------------------------------------------------------------------------
// Audit log operation types
// ---------------------------------------------------------------------------
enum AuditOperation {
  upload,
  download,
  delete_,
  query,
}

AuditOperation toAuditOperation(string value) {
    mixin(EnumSwitch("AuditOperation", "upload"));
}

AuditOperation[] toAuditOperations(string[] values) {
    return values.map!toAuditOperation.array;
}

string toString(AuditOperation c) {
    return c.to!string;
}

string[] toString(AuditOperation[] values) {
    return values.map!toString.array;
}
