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

// ---------------------------------------------------------------------------
// Quota / plan type
// ---------------------------------------------------------------------------
enum PlanType {
  free,
  default_,
}

// ---------------------------------------------------------------------------
// Price quotation direction
// ---------------------------------------------------------------------------
enum PriceQuotation {
  direct,
  indirect,
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
