/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests and results of cleansing jobs and address cleansing.
module uim.platform.data_quality.application.dtos.cleansing;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct CreateCleansingJobRequest {
  TenantId tenantId;
  UserId actor;
  DatasetId datasetId;
  string[] ruleIds; /// empty = all active rules matching the dataset
  bool dryRun;
  bool revalidate = true;
}

struct JobRunSummary {
  size_t started;
  size_t completed;
  size_t failed;

  void add(JobRunSummary o) {
    started += o.started;
    completed += o.completed;
    failed += o.failed;
  }
}

struct CleanseAddressRequest {
  TenantId tenantId;
  UserId actor;
  string sourceRecordId;
  AddressInput input;
  bool persist = true;
}
