/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.project;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// A project inside a dev space, optionally generated from a template.
struct Project {
  mixin TenantEntity!ProjectId;

  DevSpaceId devSpaceId;
  string devSpaceName;
  string name; /// unique per dev space: lowercase letters, digits, "-", "_", "."
  string description;
  ProjectType projectType = ProjectType.basic;
  ProjectStatus status = ProjectStatus.active;
  string statusMessage;

  ProjectTemplateId templateId;
  string templateName;
  string rootPath; /// derived: /home/user/projects/<name>
  string namespace_; /// "namespace", e.g. "com.acme.travel"
  string gitRepositoryUrl;
  string gitBranch = "main";
  string[] files; /// scaffolded files
}
