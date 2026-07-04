/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.application.dto;
import uim.platform.marketrates;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Upload
// ---------------------------------------------------------------------------

// A single record in an upload request payload
struct UploadRateRecord {
  string providerCode;
  string dataSource;
  string category;         // e.g. "01"
  string key1;
  string key2;
  string marketDataProperty;
  string effectiveDate;    // YYYYMMDD
  string effectiveTime;    // HHMMSS
  double marketDataValue;
  string securityCurrency;
  int    fromFactor;
  int    toFactor;
  string priceQuotation;
  string additionalKey;
}

struct UploadRatesRequest {
  TenantId         tenantId;
  string           requestedBy;
  UploadRateRecord[] records;
}

struct UploadRatesResponse {
  OperationStatus status;
  int             acceptedCount;
  int             rejectedCount;
  string[]        errors;
}

// ---------------------------------------------------------------------------
// Download
// ---------------------------------------------------------------------------

// Request instrument identifiers for a download call.
// Format: key1~key2:category  (or key1:category when no key2)
struct DownloadInstrument {
  string key1;
  string key2;
  string category;
}

struct DownloadRatesRequest {
  TenantId             tenantId;
  string               requestedBy;
  string               providerCode;
  DownloadInstrument[] instruments;
  string               fromDate;    // optional, YYYYMMDD
  string               toDate;      // optional, YYYYMMDD
  bool                 latestOnly;
}

struct DownloadRatesResponse {
  OperationStatus status;
  MarketRate[]    rates;
  int             totalCount;
}

// ---------------------------------------------------------------------------
// Provider CRUD
// ---------------------------------------------------------------------------

struct CreateProviderRequest {
  TenantId tenantId;
  string   requestedBy;
  string   code;
  string   name;
  string   description;
  string   contactEmail;
}

struct UpdateProviderRequest {
  TenantId   tenantId;
  ProviderId providerId;
  string     name;
  string     description;
  string     contactEmail;
  bool       isActive;
}

// ---------------------------------------------------------------------------
// Query / Delete
// ---------------------------------------------------------------------------

struct QueryRatesRequest {
  TenantId tenantId;
  string   providerCode;
  string   category;
  string   fromDate;
  string   toDate;
  string   key1;
  string   key2;
}

struct DeleteRatesRequest {
  TenantId tenantId;
  string   requestedBy;
  string   providerCode;
  string   category;
  string   fromDate;
  string   toDate;
}
