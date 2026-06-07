/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.entities.devspace;

import uim.platform.buildcode;


// mixin(ShowModule!());

@safe:

/// A dev space bound to a project (BAS-style isolated cloud IDE workspace)
struct DevSpace {
  mixin TenantEntity!(DevSpaceId);

  ProjectId       projectId;
  string          name;
  string          displayName;
  DevSpaceStatus  status;
  string          technicalUser;
  string          url;
  ushort          storageGiB;
  ushort          ramGiB;
  string          ideUrl;

  Json toJson() const {
    auto j = entityToJson();
    j["projectId"]     = Json(projectId.value);
    j["name"]          = Json(name);
    j["displayName"]   = Json(displayName);
    j["status"]        = Json(status.to!string);
    j["technicalUser"] = Json(technicalUser);
    j["url"]           = Json(url);
    j["storageGiB"]    = Json(storageGiB);
    j["ramGiB"]        = Json(ramGiB);
    j["ideUrl"]        = Json(ideUrl);
    return j;
  }
}
