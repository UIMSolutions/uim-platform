/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.persistence.repositories.repositories;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Repository of a tenant-wide aggregate with a unique name.
class NamedRepository(TEntity, TId) : StudioRepository!(TEntity, TId) {
  this() {
    super();
  }

  this(ITenantStore!(TEntity, TId) store) {
    super(store);
  }

  TEntity findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }
}

/// Repository of an aggregate that lives inside one dev space.
class DevSpaceScopedRepository(TEntity, TId) : StudioRepository!(TEntity, TId) {
  this() {
    super();
  }

  this(ITenantStore!(TEntity, TId) store) {
    super(store);
  }

  TEntity findByName(TenantId tenantId, DevSpaceId devSpaceId, string name) {
    return first(tenantId, (e) => devSpaceOf(e) == devSpaceId && e.name == name);
  }

  TEntity[] findByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
    return where(tenantId, (e) => devSpaceOf(e) == devSpaceId);
  }
}

/// Repository of an aggregate that lives inside one project.
class ProjectScopedRepository(TEntity, TId) : DevSpaceScopedRepository!(TEntity, TId) {
  this() {
    super();
  }

  this(ITenantStore!(TEntity, TId) store) {
    super(store);
  }

  TEntity findByProjectAndName(TenantId tenantId, ProjectId projectId, string name) {
    return first(tenantId, (e) => projectOf(e) == projectId && e.name == name);
  }

  TEntity[] findByProject(TenantId tenantId, ProjectId projectId) {
    return where(tenantId, (e) => projectOf(e) == projectId);
  }
}

/// Declares `<Name>Repository : <Base>!(<Name>, <Name>Id), I<Name>Repository`.
private string repository(string base, string name, string id, string extra = "") {
  return "class " ~ name ~ "Repository : " ~ base ~ "!(" ~ name ~ ", " ~ id ~ "), I" ~ name ~ "Repository {\n"
    ~ "  this() { super(); }\n"
    ~ "  this(ITenantStore!(" ~ name ~ ", " ~ id ~ ") store) { super(store); }\n"
    ~ extra ~ "}\n";
}

mixin(repository("NamedRepository", "DevSpaceType", "DevSpaceTypeId"));
mixin(repository("NamedRepository", "Extension", "ExtensionId"));
mixin(repository("NamedRepository", "ProjectTemplate", "ProjectTemplateId"));
mixin(repository("NamedRepository", "DevSpace", "DevSpaceId", q{
  DevSpace[] findByType(TenantId tenantId, DevSpaceTypeId typeId) {
    return where(tenantId, (e) => e.devSpaceTypeId == typeId);
  }

  DevSpace[] findByExtension(TenantId tenantId, string extension) {
    return where(tenantId, (e) => e.extensions.canFind(extension));
  }
}));
mixin(repository("DevSpaceScopedRepository", "Project", "ProjectId", q{
  Project[] findByTemplate(TenantId tenantId, ProjectTemplateId templateId) {
    return where(tenantId, (e) => e.templateId == templateId);
  }
}));
mixin(repository("DevSpaceScopedRepository", "ServiceBinding", "ServiceBindingId"));
mixin(repository("ProjectScopedRepository", "RunConfiguration", "RunConfigurationId"));
mixin(repository("ProjectScopedRepository", "BuildConfiguration", "BuildConfigurationId"));

///
unittest {
  mixin(ShowTest!("Repositories"));

  assert(tenantRepositoryTest(new DevSpaceRepository()));
  assert(tenantRepositoryTest(new ExtensionRepository()));
  assert(tenantRepositoryTest(new ProjectRepository()));
  assert(tenantRepositoryTest(new RunConfigurationRepository()));

  auto t = TenantId("t1");
  auto ds = DevSpaceId("d1");
  auto runs = new RunConfigurationRepository();
  auto r = RunConfiguration(t);
  r.devSpaceId = ds;
  r.projectId = ProjectId("p1");
  r.name = "Run travel";
  runs.save(r);
  assert(!runs.findByProjectAndName(t, ProjectId("p1"), "Run travel").isNull);
  assert(runs.findByProjectAndName(t, ProjectId("p2"), "Run travel").isNull);
  assert(runs.findByDevSpace(t, ds).length == 1 && runs.findByProject(t, ProjectId("p1")).length == 1);

  auto spaces = new DevSpaceRepository();
  auto d = DevSpace(t);
  d.name = "FioriDev";
  d.extensions = ["sap.kyma-tools"];
  d.devSpaceTypeId = DevSpaceTypeId("fiori");
  spaces.save(d);
  assert(!spaces.findByName(t, "FioriDev").isNull);
  assert(spaces.findByExtension(t, "sap.kyma-tools").length == 1 && spaces.findByType(t, DevSpaceTypeId("fiori")).length == 1);
}
