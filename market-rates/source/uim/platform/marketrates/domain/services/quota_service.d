/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.domain.services.quota_service;
import uim.platform.marketrates;

mixin(ShowModule!());

@safe:

// Enforces the SAP MRM BYOR quota limits:
//   - Max 1,500 records per request
//   - Max 300,000 records per global account
//   - Max 6,000 upload OR download requests per month
struct QuotaService {
  enum size_t MAX_RECORDS_PER_REQUEST    = 1_500;
  enum size_t MAX_RECORDS_PER_ACCOUNT    = 300_000;
  enum size_t MAX_REQUESTS_PER_MONTH     = 6_000;

  static string checkBatchSize(size_t count) {
    if (count > MAX_RECORDS_PER_REQUEST)
      return "Batch size exceeds the maximum of 1,500 records per request";
    return "";
  }

  static string checkAccountQuota(size_t current, size_t toAdd) {
    if ((current + toAdd) > MAX_RECORDS_PER_ACCOUNT)
      return "Account record quota of 300,000 would be exceeded";
    return "";
  }

  static string checkRequestQuota(size_t monthlyRequests) {
    if (monthlyRequests >= MAX_REQUESTS_PER_MONTH)
      return "Monthly request quota of 6,000 has been reached";
    return "";
  }
}
