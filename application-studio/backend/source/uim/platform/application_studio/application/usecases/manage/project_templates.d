/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.project_templates;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Interactor: project templates (generators).
class ManageProjectTemplatesUseCase
  : ResourceUseCase!(ProjectTemplate, ProjectTemplateId, CreateProjectTemplateRequest, UpdateProjectTemplateRequest),
  IManageProjectTemplatesUseCase {

  this(StudioRepositories repos, IStudioEventPublisher publisher) {
    super(repos, repos.projectTemplates, publisher, "Project template", "studio.project-template");
  }

  override protected ProjectTemplate build(CreateProjectTemplateRequest r) {
    auto t = ProjectTemplate(r.tenantId);
    assignMatching(t, r.spec);
    t.name = t.name.strip;
    check(t);
    ensureUnique(repos.projectTemplates.findByName(r.tenantId, t.name), t, "the catalogue");
    return t;
  }

  override protected void apply(ref ProjectTemplate t, ProjectTemplateSpec spec) {
    assignMatching(t, spec, ["name"]);
    check(t);
  }

  protected void check(ref ProjectTemplate t) {
    validateCatalogName("Template", t.name);
    if (t.title.strip.length == 0)
      t.title = t.name;
    validateDisplayName("Template title", t.title);
    validateSemVer("Template", t.version_);
    t.requiredExtensions = normalizedNames(t.requiredExtensions);
    requireExtensions(t.tenantId, t.requiredExtensions, false);
    t.scaffoldFiles = normalizedNames(t.scaffoldFiles);
    foreach (f; t.scaffoldFiles)
      validate(!f.startsWith("/") && !f.split("/").canFind(".."), "Scaffold file '" ~ f ~ "' must be a relative path inside the project");
    string[] keys;
    foreach (p; t.parameters) {
      validate(p.key.strip.length > 0, "Template parameters need a name");
      validate(!keys.canFind(p.key), "Template parameter '" ~ p.key ~ "' is defined twice");
      keys ~= p.key;
    }
  }

  override protected void beforeRemove(ProjectTemplate t) {
    auto users = repos.projects.findByTemplate(t.tenantId, t.id);
    ensureState(users.length == 0, "Project template '" ~ t.name ~ "' is used by project(s) "
        ~ users.map!(p => p.name).join(", "));
  }
}
