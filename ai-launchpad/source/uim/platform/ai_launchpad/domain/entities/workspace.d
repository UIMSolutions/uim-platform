/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.workspace;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Workspace {
  mixin TenantEntity!(WorkspaceId);

  string name;
  string description;
  WorkspaceStatus status;
  int connectionCount;
  
  Json toJson() const {
    auto j = entityToJson
      .set("name", name)
      .set("description", description)
      .set("status", status)
      .set("connectionCount", connectionCount);

    return j;
  }
}
