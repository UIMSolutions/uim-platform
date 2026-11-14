/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.business_roles;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Interactor: business roles. Restricted roles need restriction types,
/// unrestricted roles have none; roles in use cannot be deleted.
class ManageBusinessRolesUseCase
  : ResourceUseCase!(BusinessRole, BusinessRoleId, CreateBusinessRoleRequest, UpdateBusinessRoleRequest),
  IManageBusinessRolesUseCase {

  this(AbapRepositories repos, IAbapEventPublisher publisher) {
    super(repos, repos.businessRoles, publisher, "Business role", "abap.business-role");
  }

  override protected BusinessRole build(CreateBusinessRoleRequest r) {
    auto system = requireSystem(r.tenantId, r.parentId);
    auto role = BusinessRole(r.tenantId);
    role.systemInstanceId = system.id;
    role.systemName = system.name;
    assignMatching(role, r.spec);
    role.name = role.name.strip.toUpper;
    check(role);
    ensureUnique(repos.businessRoles.findByName(r.tenantId, system.id, role.name), role, "system '" ~ system.name ~ "'");
    return role;
  }

  override protected void apply(ref BusinessRole role, BusinessRoleSpec spec) {
    assignMatching(role, spec, ["name"]);
    check(role);
  }

  protected static void check(ref BusinessRole role) {
    validateAbapName("Business role", role.name, 40);
    role.businessCatalogs = role.businessCatalogs.map!(c => c.strip.toUpper).filter!(c => c.length > 0).array.sort.uniq.array;
    foreach (c; role.businessCatalogs)
      validateAbapName("Business catalog", c, 40);
    final switch (role.roleType) {
    case RoleType.restricted:
      validate(role.restrictionTypes.length > 0, "A restricted role needs at least one restriction type");
      break;
    case RoleType.unrestricted:
      validate(role.restrictionTypes.length == 0, "An unrestricted role cannot have restriction types");
      break;
    case RoleType.custom:
      break;
    }
  }

  override protected void beforeRemove(BusinessRole role) {
    auto users = repos.businessUsers.findByRole(role.tenantId, role.id);
    ensureState(users.length == 0, "Business role '" ~ role.name ~ "' is assigned to " ~ users.length.to!string
        ~ " user(s): " ~ users.map!(u => u.name).join(", "));
  }

  size_t userCount(TenantId tenantId, BusinessRoleId id) {
    return repos.businessUsers.findByRole(tenantId, id).length;
  }

  UsecaseResult addCatalog(TenantId tenantId, BusinessRoleId id, string catalog, UserId actor) {
    return transition(tenantId, id, actor, "updated", (ref BusinessRole role) {
      auto c = catalog.strip.toUpper;
      validateAbapName("Business catalog", c, 40);
      ensureState(!role.businessCatalogs.canFind(c), "Business role '" ~ role.name ~ "' already contains " ~ c);
      role.businessCatalogs ~= c;
      check(role);
    });
  }

  UsecaseResult removeCatalog(TenantId tenantId, BusinessRoleId id, string catalog, UserId actor) {
    return transition(tenantId, id, actor, "updated", (ref BusinessRole role) {
      auto c = catalog.strip.toUpper;
      if (!role.businessCatalogs.canFind(c))
        throw new AbapNotFoundException("Business role '" ~ role.name ~ "' does not contain " ~ c);
      role.businessCatalogs = role.businessCatalogs.filter!(x => x != c).array;
    });
  }
}
