/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.persistence.repositories.repositories;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

class SystemInstanceRepository : AbapRepository!(SystemInstance, SystemInstanceId), ISystemInstanceRepository {
  this() {
    super();
  }

  this(ITenantStore!(SystemInstance, SystemInstanceId) store) {
    super(store);
  }

  SystemInstance findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }

  SystemInstance findBySid(TenantId tenantId, string sapSystemId) {
    return first(tenantId, (e) => e.sapSystemId == sapSystemId);
  }
}

/// Repository of an aggregate that lives inside one system.
class SystemScopedRepository(TEntity, TId) : AbapRepository!(TEntity, TId) {
  this() {
    super();
  }

  this(ITenantStore!(TEntity, TId) store) {
    super(store);
  }

  TEntity findByName(TenantId tenantId, SystemInstanceId systemId, string name) {
    return first(tenantId, (e) => systemOf(e) == systemId && e.name == name);
  }

  TEntity[] findBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return where(tenantId, (e) => systemOf(e) == systemId);
  }
}

/// Declares `<Name>Repository : SystemScopedRepository!(TEntity, TId), I<Name>Repository`.
private string scopedRepository(string name, string entity, string id, string extra = "") {
  return "class " ~ name ~ "Repository : SystemScopedRepository!(" ~ entity ~ ", " ~ id ~ "), I" ~ name ~ "Repository {\n"
    ~ "  this() { super(); }\n"
    ~ "  this(ITenantStore!(" ~ entity ~ ", " ~ id ~ ") store) { super(store); }\n"
    ~ extra ~ "}\n";
}

mixin(scopedRepository("SoftwareComponent", "SoftwareComponent", "SoftwareComponentId"));
mixin(scopedRepository("CommunicationArrangement", "CommunicationArrangement", "CommunicationArrangementId"));
mixin(scopedRepository("ServiceBinding", "ServiceBinding", "ServiceBindingId"));
mixin(scopedRepository("BusinessRole", "BusinessRole", "BusinessRoleId"));
mixin(scopedRepository("ApplicationJob", "ApplicationJob", "ApplicationJobId"));

mixin(scopedRepository("BusinessUser", "BusinessUser", "BusinessUserId", q{
  BusinessUser findByEmail(TenantId tenantId, SystemInstanceId systemId, string email) {
    auto wanted = email.toLower;
    return first(tenantId, (e) => e.systemInstanceId == systemId && e.email.toLower == wanted);
  }

  BusinessUser[] findByRole(TenantId tenantId, BusinessRoleId roleId) {
    return where(tenantId, (e) => e.roleAssignments.any!(a => a.roleId == roleId));
  }
}));

mixin(scopedRepository("TransportRequest", "TransportRequest", "TransportRequestId", q{
  TransportRequest[] findByTarget(TenantId tenantId, SystemInstanceId systemId) {
    return where(tenantId, (e) => e.targetSystemId == systemId);
  }
}));

///
unittest {
  mixin(ShowTest!("Repositories"));

  assert(tenantRepositoryTest(new SystemInstanceRepository()));
  assert(tenantRepositoryTest(new SoftwareComponentRepository()));
  assert(tenantRepositoryTest(new BusinessUserRepository()));
  assert(tenantRepositoryTest(new TransportRequestRepository()));

  auto t = TenantId("t1");
  auto system = SystemInstanceId("s1");
  auto repo = new BusinessUserRepository();
  auto u = BusinessUser(t);
  u.systemInstanceId = system;
  u.name = "JANE";
  u.email = "Jane@Example.com";
  u.roleAssignments = [RoleAssignment(BusinessRoleId("r1"), "Z_BR", 1)];
  repo.save(u);
  assert(!repo.findByName(t, system, "JANE").isNull);
  assert(repo.findByName(t, SystemInstanceId("other"), "JANE").isNull);
  assert(!repo.findByEmail(t, system, "jane@example.com").isNull);
  assert(repo.findByRole(t, BusinessRoleId("r1")).length == 1);
  assert(repo.findBySystem(t, system).length == 1);
}
