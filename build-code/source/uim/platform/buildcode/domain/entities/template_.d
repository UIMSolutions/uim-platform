/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.entities.template_;

import uim.platform.buildcode;


mixin(ShowModule!());

@safe:

/// A project scaffolding template (CAP, Fiori, SAPUI5, Mobile, …)
struct ProjectTemplate {
  mixin TenantEntity!(TemplateId);

  string       name;
  string       displayName;
  string       description;
  string       category;
  ProjectType  projectType;
  TechStack    techStack;
  string       version_;
  string       author;
  bool         isBuiltIn;
  string[]     parameters;

  Json toJson() const {
    auto j = entityToJson();
    j["name"]        = Json(name);
    j["displayName"] = Json(displayName);
    j["description"] = Json(description);
    j["category"]    = Json(category);
    j["projectType"] = Json(projectType.to!string);
    j["techStack"]   = Json(techStack.to!string);
    j["version"]     = Json(version_);
    j["author"]      = Json(author);
    j["isBuiltIn"]   = Json(isBuiltIn);
    auto arr = Json.emptyArray;
    foreach (p; parameters) arr ~= Json(p);
    j["parameters"] = arr;
    return j;
  }
}
