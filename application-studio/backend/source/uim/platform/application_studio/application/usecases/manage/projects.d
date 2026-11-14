/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Root folder of the projects of a dev space.
enum string projectsRoot = "/home/user/projects/";

/// Interactor: projects. Generated from a template inside a running dev space;
/// the template's extensions must be installed and the dev space type must
/// support the project type.
class ManageProjectsUseCase
  : ResourceUseCase!(Project, ProjectId, CreateProjectRequest, UpdateProjectRequest),
  IManageProjectsUseCase {

  protected CascadeDeleter cascade;

  this(StudioRepositories repos, CascadeDeleter cascade, IStudioEventPublisher publisher) {
    super(repos, repos.projects, publisher, "Project", "studio.project");
    this.cascade = cascade;
  }

  override protected Project build(CreateProjectRequest r) {
    auto ds = requireDevSpace(r.tenantId, r.parentId);
    requireRunning(ds, "create projects");
    auto p = Project(r.tenantId);
    p.devSpaceId = ds.id;
    p.devSpaceName = ds.name;
    assignMatching(p, r.spec);
    p.name = p.name.strip;
    validateProjectName(p.name);
    ensureUnique(repos.projects.findByName(r.tenantId, ds.id, p.name), p, "dev space " ~ ds.name);

    auto type = requireType(r.tenantId, ds.devSpaceTypeId);
    if (!p.templateId.isEmpty) {
      auto t = repos.projectTemplates.findById(r.tenantId, p.templateId);
      if (t.isNull)
        throw new StudioNotFoundException("Project template '" ~ p.templateId.value ~ "' not found");
      if (p.projectType == ProjectType.basic)
        p.projectType = t.targetProjectType;
      validate(p.projectType == t.targetProjectType, "Template " ~ t.name ~ " creates "
          ~ enumText(t.targetProjectType) ~ " projects, not " ~ enumText(p.projectType));
      auto missing = missingNames(t.requiredExtensions, effectiveExtensions(type, ds));
      ensureState(missing.length == 0, "Dev space '" ~ ds.name ~ "' lacks extension(s) required by template "
          ~ t.name ~ ": " ~ missing.join(", "));
      p.templateName = t.name;
      p.files = t.scaffoldFiles.dup;
    }
    ensureState(supportsProjectType(type, p.projectType), "Dev space type " ~ type.name ~ " does not support "
        ~ enumText(p.projectType) ~ " projects");
    if (p.files.length == 0)
      p.files = ["README.md"];
    p.rootPath = projectsRoot ~ p.name;
    check(p);
    p.status = ProjectStatus.active;
    return p;
  }

  /// Name, dev space, template and type are fixed after the generation.
  override protected void apply(ref Project p, ProjectSpec spec) {
    ensureState(p.status != ProjectStatus.archived, "Project '" ~ p.name ~ "' is archived — restore it first");
    assignMatching(p, spec, ["name", "projectType", "templateId"]);
    check(p);
  }

  protected static void check(ref Project p) {
    validate(p.gitRepositoryUrl.length == 0 || isGitUrl(p.gitRepositoryUrl),
      "Git repository '" ~ p.gitRepositoryUrl ~ "' must be an http(s) or git@host:path URL");
    p.gitBranch = p.gitBranch.strip;
    if (p.gitBranch.length == 0)
      p.gitBranch = "main";
    validate(!p.gitBranch.canFind(" ") && !p.gitBranch.canFind(".."), "Invalid git branch '" ~ p.gitBranch ~ "'");
    foreach (part; p.namespace_.length ? p.namespace_.split(".") : null)
      validate(part.length > 0 && part.all!(c => (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')),
        "Namespace '" ~ p.namespace_ ~ "' must look like com.acme.travel");
  }

  protected void requireIdle(const Project p, string what) {
    auto live = repos.runConfigurations.findByProject(p.tenantId, p.id).filter!(r => r.status.isLive).array;
    ensureState(live.length == 0, "Stop the running configuration(s) " ~ live.map!(r => r.name).join(", ")
        ~ " of project '" ~ p.name ~ "' before it can be " ~ what);
    auto busy = repos.buildConfigurations.findByProject(p.tenantId, p.id).filter!(b => b.status.isBusy).array;
    ensureState(busy.length == 0, "Project '" ~ p.name ~ "' has builds in progress: " ~ busy.map!(b => b.name).join(", "));
  }

  override protected void beforeRemove(Project p) {
    requireIdle(p, "deleted");
  }

  override protected void afterRemove(Project p) {
    cascade.clearProject(p.tenantId, p.id);
  }

  UsecaseResult archive(TenantId tenantId, ProjectId id, UserId actor) {
    return transition(tenantId, id, actor, "archived", (ref Project p) {
      ensureState(p.status != ProjectStatus.archived, "Project '" ~ p.name ~ "' is already archived");
      requireIdle(p, "archived");
      p.status = ProjectStatus.archived;
      p.statusMessage = "";
    });
  }

  UsecaseResult restore(TenantId tenantId, ProjectId id, UserId actor) {
    return transition(tenantId, id, actor, "restored", (ref Project p) {
      ensureState(p.status == ProjectStatus.archived, "Project '" ~ p.name ~ "' is not archived");
      requireDevSpace(tenantId, p.devSpaceId);
      p.status = ProjectStatus.active;
    });
  }
}
