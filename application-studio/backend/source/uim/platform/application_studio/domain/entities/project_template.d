/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.project_template;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// A project template (generator): scaffolds files and needs extensions.
struct ProjectTemplate {
  mixin TenantEntity!ProjectTemplateId;

  string name; /// unique per tenant, e.g. "fiori-list-report"
  string title;
  string description;
  TemplateCategory category = TemplateCategory.general;
  ProjectType targetProjectType = ProjectType.basic;
  string version_ = "1.0.0"; /// "version"
  string[] requiredExtensions; /// extension names the dev space must have
  string[] scaffoldFiles; /// relative paths created in the project
  KeyValue[] parameters; /// generator defaults, e.g. odataVersion=4
  string iconUrl;
}
