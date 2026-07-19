/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.dto.buildpack;
import uim.platform.foundry;
mixin(ShowModule!());
@safe:

struct CreateBuildpackRequest {
  TenantId tenantId;
  BuildpackId packId;
  UserId createdBy;

  string name;
  string type_;
  int position;
  string stack;
  string filename;
}

struct UpdateBuildpackRequest {
  TenantId tenantId;
  BuildpackId packId;
  
  string name;
  int position;
  string stack;
  string filename;
  bool enabled;
  bool locked;
}
