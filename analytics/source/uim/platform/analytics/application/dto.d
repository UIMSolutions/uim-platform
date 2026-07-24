/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.application.dto;

import uim.platform.analytics.domain.types;

struct CreateAssetRequest {
  TenantId tenantId;
  string name;
  string kind;
  string sourceSystem;
  string[] dimensions;
  string[] measures;
}

struct UpdateAssetRequest {
  TenantId tenantId;
  AssetId id;
  string name;
  string kind;
  string sourceSystem;
  string[] dimensions;
  string[] measures;
}
