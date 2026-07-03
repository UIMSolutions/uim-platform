/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.projects;

import uim.platform.buildcode;
import std.conv    : to;
import std.random  : uniform;
import std.format  : format;

// mixin(ShowModule!());

@safe:

class ManageProjectsUseCase {
  private ProjectRepository   _repo;
  private ProjectValidator    _validator;
  private QuotaService        _quota;

  this(ProjectRepository repo) {
    _repo      = repo;
    _validator = ProjectValidator();
    _quota     = QuotaService();
  }

  CommandResult create(TenantId tenantId, CreateProjectRequest req) {
    auto nameErrors = _validator.validateName(req.name);
    if (nameErrors.length > 0)
      return CommandResult(false, "", nameErrors[0]);

    if (_repo.nameExists(tenantId, req.name))
      return CommandResult(false, "", "A project with that name already exists");

    auto existing = _repo.findByTenant(tenantId);
    auto quotaError = _quota.checkProjectQuota(existing.length);
    if (quotaError !is null)
      return CommandResult(false, "", quotaError);

    ProjectType ptype  = ProjectType.other;
    TechStack   tstack = TechStack.other;
    static foreach (member; __traits(allMembers, ProjectType)) {
      if (req.type == mixin("ProjectType." ~ member ~ ".to!string"))
        ptype = mixin("ProjectType." ~ member);
    }
    static foreach (member; __traits(allMembers, TechStack)) {
      if (req.techStack == mixin("TechStack." ~ member ~ ".to!string"))
        tstack = mixin("TechStack." ~ member);
    }

    auto p = Project(tenantId);
    p.name           = req.name;
    p.description    = req.description;
    p.type           = ptype;
    p.techStack      = tstack;
    p.status         = ProjectStatus.active;
    p.ownerEmail     = req.ownerEmail;
    p.repositoryUrl  = req.repositoryUrl;
    p.defaultBranch  = req.defaultBranch.length > 0 ? req.defaultBranch : "main";
    p.tags           = req.tags;

    _repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  Project getById(TenantId tenantId, string id) {
    return _repo.findById(tenantId, ProjectId(id));
  }

  Project[] list(TenantId tenantId) {
    return _repo.findByTenant(tenantId);
  }

  Project[] listByStatus(TenantId tenantId, string statusStr) {
    ProjectStatus st = ProjectStatus.active;
    static foreach (member; __traits(allMembers, ProjectStatus)) {
      if (statusStr == mixin("ProjectStatus." ~ member ~ ".to!string"))
        st = mixin("ProjectStatus." ~ member);
    }
    return _repo.findByStatus(tenantId, st);
  }

  CommandResult update(TenantId tenantId, string id, UpdateProjectRequest req) {
    auto p = _repo.findById(tenantId, ProjectId(id));
    if (p.isNull) return CommandResult(false, "", "Project not found");

    if (req.description.length > 0) p.description   = req.description;
    if (req.ownerEmail.length > 0)  p.ownerEmail     = req.ownerEmail;
    if (req.repositoryUrl.length > 0) p.repositoryUrl = req.repositoryUrl;
    if (req.defaultBranch.length > 0) p.defaultBranch = req.defaultBranch;
    if (req.tags.length > 0)        p.tags           = req.tags;

    static foreach (member; __traits(allMembers, ProjectStatus)) {
      if (req.status == mixin("ProjectStatus." ~ member ~ ".to!string"))
        p.status = mixin("ProjectStatus." ~ member);
    }
    _repo.update(p);
    return CommandResult(true, id, "");
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto p = _repo.findById(tenantId, ProjectId(id));
    if (p.isNull) return CommandResult(false, "", "Project not found");
    _repo.remove(tenantId, ProjectId(id));
    return CommandResult(true, id, "");
  }
}
