/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.usecases.manage.projects;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Interactor: translation projects. Names are unique per tenant and fixed
/// after creation; archived projects are read-only; deleting a project
/// deletes its texts.
class ManageProjectsUseCase
  : ResourceUseCase!(TranslationProject, TranslationProjectId, CreateProjectRequest, UpdateProjectRequest),
  IManageProjectsUseCase {

  protected ProjectTranslationService service;

  this(TranslationRepositories repos, EventRecorder events, ProjectTranslationService service) {
    super(repos, repos.projects, events, "Translation project", "translation.project");
    this.service = service;
  }

  override protected TranslationProject build(CreateProjectRequest r) {
    auto p = TranslationProject(r.tenantId);
    assignMatching(p, r.spec);
    p.name = p.name.strip;
    validateDisplayName("Project", p.name);
    check(p);
    ensureUnique(repos.projects.findByName(r.tenantId, p.name), p, "this tenant");
    p.status = ProjectStatus.draft;
    return p;
  }

  override protected void apply(ref TranslationProject p, ProjectSpec spec) {
    ensureWritable(p);
    auto sourceBefore = p.sourceLanguage;
    assignMatching(p, spec, ["name"]);
    check(p);
    ensureState(p.sourceLanguage == sourceBefore || p.textCount == 0,
      "The source language of '" ~ p.name ~ "' cannot change while it has texts");
  }

  override protected void afterUpdate(TranslationProject before, TranslationProject after, UserId actor) {
    if (before.targetLanguages != after.targetLanguages) {
      service.restatus(after);
      service.refresh(after.tenantId, after.id);
    }
  }

  protected void check(ref TranslationProject p) {
    p.sourceLanguage = requireLanguage("Source language", p.sourceLanguage);
    p.targetLanguages = requireTargetLanguages(p.sourceLanguage, p.targetLanguages);
    p.domainName = requireDomain(p.domainName);
    final switch (p.projectType) {
    case ProjectType.git:
      validate(isRepositoryUrl(p.repositoryUrl), "Git projects need a repository URL (https://… or git@…)");
      if (p.baseBranch.strip.length == 0)
        p.baseBranch = "main";
      break;
    case ProjectType.abap:
      validate(p.abapSystemId.strip.length > 0, "ABAP projects need an ABAP system ID");
      break;
    case ProjectType.file, ProjectType.api:
      break;
    }
  }

  override protected void beforeRemove(TranslationProject p) {
    foreach (j; repos.jobs.findByProject(p.tenantId, p.id))
      ensureState(j.status != JobStatus.pending && j.status != JobStatus.processing,
        "Translation project '" ~ p.name ~ "' has an open job (" ~ j.name ~ ")");
  }

  override protected void afterRemove(TranslationProject p, UserId actor) {
    foreach (t; repos.texts.findByProject(p.tenantId, p.id))
      repos.texts.remove(t);
  }

  TranslationProject findByName(TenantId tenantId, string name) {
    return repos.projects.findByName(tenantId, name);
  }

  UsecaseResult activate(TenantId tenantId, TranslationProjectId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref p) {
      ensureState(p.status == ProjectStatus.draft, "Translation project '" ~ p.name ~ "' is already " ~ enumText(p.status));
      p.status = progressStatus(ProjectStatus.active, p.completionPercent, p.textCount);
    });
  }

  UsecaseResult archive(TenantId tenantId, TranslationProjectId id, UserId actor) {
    return transition(tenantId, id, actor, "archived", (ref p) {
      ensureState(p.status != ProjectStatus.archived, "Translation project '" ~ p.name ~ "' is already archived");
      p.status = ProjectStatus.archived;
    });
  }

  UsecaseResult reopen(TenantId tenantId, TranslationProjectId id, UserId actor) {
    return transition(tenantId, id, actor, "reopened", (ref p) {
      ensureState(p.status == ProjectStatus.archived, "Only archived projects can be reopened");
      p.status = progressStatus(ProjectStatus.active, p.completionPercent, p.textCount);
    });
  }

  UsecaseResult translate(TenantId tenantId, TranslationProjectId id, bool force, UserId actor) {
    return guarded(() {
      auto p = require(tenantId, id);
      ensureWritable(p);
      auto run = service.translateProject(p, null, force, actor);
      p = require(tenantId, id);
      publish(p, "translated");
      return succeeded(p.id.value, "Translation project '%s': %d translation(s) for %d text(s), %d%% complete"
          .format(p.name, run.translations, run.texts, p.completionPercent));
    });
  }
}
