/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.templates;

import uim.platform.buildcode;


// mixin(ShowModule!());

@safe:

class ManageTemplatesUseCase {
  private TemplateRepository _repo;

  this(TemplateRepository repo) { _repo = repo; }

  CommandResult create(TenantId tenantId, CreateTemplateRequest req) {
    ProjectType ptype  = ProjectType.other;
    TechStack   tstack = TechStack.other;
    static foreach (member; __traits(allMembers, ProjectType)) {
      if (req.projectType == mixin("ProjectType." ~ member ~ ".to!string"))
        ptype = mixin("ProjectType." ~ member);
    }
    static foreach (member; __traits(allMembers, TechStack)) {
      if (req.techStack == mixin("TechStack." ~ member ~ ".to!string"))
        tstack = mixin("TechStack." ~ member);
    }

    auto t = ProjectTemplate(tenantId);
    t.name        = req.name;
    t.displayName = req.displayName;
    t.description = req.description;
    t.category    = req.category;
    t.projectType = ptype;
    t.techStack   = tstack;
    t.version_    = req.version_;
    t.author      = req.author;
    t.isBuiltIn   = req.isBuiltIn;
    t.parameters  = req.parameters;

    _repo.save(t);
    return CommandResult(true, t.id.value, "");
  }

  ProjectTemplate getById(TenantId tenantId, string id) {
    return _repo.findById(tenantId, TemplateId(id));
  }

  ProjectTemplate[] list(TenantId tenantId) {
    return _repo.findByTenant(tenantId);
  }

  ProjectTemplate[] listByProjectType(TenantId tenantId, string typeStr) {
    ProjectType ptype = ProjectType.other;
    static foreach (member; __traits(allMembers, ProjectType)) {
      if (typeStr == mixin("ProjectType." ~ member ~ ".to!string"))
        ptype = mixin("ProjectType." ~ member);
    }
    return _repo.findByProjectType(tenantId, ptype);
  }

  ProjectTemplate[] listBuiltIn(TenantId tenantId) {
    return _repo.findBuiltIn(tenantId);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto t = _repo.findById(tenantId, TemplateId(id));
    if (t.isNull) return CommandResult(false, "", "Template not found");
    _repo.remove(tenantId, TemplateId(id));
    return CommandResult(true, id, "");
  }
}
