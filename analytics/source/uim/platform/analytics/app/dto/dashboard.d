/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.dto.dashboard;

// import std.conv : to;
import uim.platform.analytics.domain.entities.dashboard;
import uim.platform.analytics.domain.values.common;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:
struct CreateDashboardRequest {
  string name;
  string description;
  string ownerId;
}

struct DashboardResponse {
  string id;
  string name;
  string description;
  string ownerId;
  string visibility;
  string status;
  PageResponse[] pages;
  string[] tags;

  static DashboardResponse fromEntity(Dashboard d) {
    if (d is null)
      return DashboardResponse.init;

    PageResponse[] pgs;
    foreach (p; d.pages)
      pgs ~= PageResponse(p.id.value, p.title);

    return DashboardResponse(d.id.value, d.name, d.description,
        d.ownerId.value, d.visibility.to!string, d.status.to!string, pgs, d.tags,);
  }
}

struct PageResponse {
  string id;
  string title;
}
