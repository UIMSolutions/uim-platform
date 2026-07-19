/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.services.quota_service;

import uim.platform.buildcode;
mixin(ShowModule!());

@safe:

/// Hard quotas for Build Code tenant usage
struct QuotaService {
  enum MAX_PROJECTS_PER_TENANT    = 100;
  enum MAX_DEVSPACES_PER_PROJECT  = 5;
  enum MAX_PIPELINES_PER_PROJECT  = 20;
  enum MAX_AI_REQUESTS_PER_DAY    = 200;
  enum MAX_BUILD_JOBS_STORED      = 1_000;

  string checkProjectQuota(size_t current) {
    if (current >= MAX_PROJECTS_PER_TENANT)
      return "Project quota exceeded: maximum " ~ MAX_PROJECTS_PER_TENANT.to!string ~ " projects per tenant";
    return null;
  }

  string checkDevSpaceQuota(size_t current) {
    if (current >= MAX_DEVSPACES_PER_PROJECT)
      return "Dev space quota exceeded: maximum " ~ MAX_DEVSPACES_PER_PROJECT.to!string ~ " dev spaces per project";
    return null;
  }

  string checkPipelineQuota(size_t current) {
    if (current >= MAX_PIPELINES_PER_PROJECT)
      return "Pipeline quota exceeded: maximum " ~ MAX_PIPELINES_PER_PROJECT.to!string ~ " pipelines per project";
    return null;
  }

  string checkAIRequestQuota(size_t todayCount) {
    if (todayCount >= MAX_AI_REQUESTS_PER_DAY)
      return "AI request quota exceeded: maximum " ~ MAX_AI_REQUESTS_PER_DAY.to!string ~ " requests per day";
    return null;
  }
}
