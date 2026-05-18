/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.entities.project;

import uim.platform.buildcode;
import std.conv : to;

mixin(ShowModule!());

@safe:

/// A Build Code project (top-level dev workspace)
struct Project {
  mixin TenantEntity!(ProjectId);

  string          name;
  string          description;
  ProjectType     type;
  TechStack       techStack;
  ProjectStatus   status;
  string          ownerEmail;
  string          repositoryUrl;
  string          defaultBranch;
  string[]        tags;

  Json toJson() const {
    auto j = entityToJson();
    j["name"]          = Json(name);
    j["description"]   = Json(description);
    j["type"]          = Json(type.to!string);
    j["techStack"]     = Json(techStack.to!string);
    j["status"]        = Json(status.to!string);
    j["ownerEmail"]    = Json(ownerEmail);
    j["repositoryUrl"] = Json(repositoryUrl);
    j["defaultBranch"] = Json(defaultBranch);
    auto arr = Json.emptyArray;
    foreach (t; tags) arr ~= Json(t);
    j["tags"] = arr;
    return j;
  }
}
