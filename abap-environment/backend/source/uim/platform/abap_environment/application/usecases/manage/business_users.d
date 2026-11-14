/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.business_users;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Interactor: business users. Names and e-mail addresses are unique per
/// system; roles are resolved by id or name within the same system.
class ManageBusinessUsersUseCase
  : ResourceUseCase!(BusinessUser, BusinessUserId, CreateBusinessUserRequest, UpdateBusinessUserRequest),
  IManageBusinessUsersUseCase {

  this(AbapRepositories repos, IAbapEventPublisher publisher) {
    super(repos, repos.businessUsers, publisher, "Business user", "abap.business-user");
  }

  override protected BusinessUser build(CreateBusinessUserRequest r) {
    auto system = requireActiveSystem(r.tenantId, r.parentId, "maintain business users");
    auto user = BusinessUser(r.tenantId);
    user.systemInstanceId = system.id;
    user.systemName = system.name;
    assignMatching(user, r.spec, ["roles"]);
    user.name = user.name.strip;
    validateUserName(user.name);
    ensureUnique(repos.businessUsers.findByName(r.tenantId, system.id, user.name), user, "system '" ~ system.name ~ "'");
    check(user);
    assignRoles(user, r.spec.roles);
    user.status = UserStatus.active;
    user.passwordChangeRequired = true;
    return user;
  }

  override protected void apply(ref BusinessUser user, BusinessUserSpec spec) {
    assignMatching(user, spec, ["name", "roles"]);
    check(user);
    assignRoles(user, spec.roles);
  }

  protected void check(ref BusinessUser user) {
    user.email = user.email.strip.toLower;
    validateEmail("E-mail", user.email);
    auto other = repos.businessUsers.findByEmail(user.tenantId, user.systemInstanceId, user.email);
    ensureState(other.isNull || other.id == user.id, "E-mail '" ~ user.email ~ "' is already used by '" ~ other.name ~ "'");
  }

  /// Resolve a role by id or (case-insensitive) name within the user's system.
  protected BusinessRole resolveRole(const ref BusinessUser user, string role) {
    auto key = role.strip;
    validate(key.length > 0, "Role is required");
    auto byId = repos.businessRoles.findById(user.tenantId, BusinessRoleId(key));
    if (!byId.isNull && byId.systemInstanceId == user.systemInstanceId)
      return byId;
    auto byName = repos.businessRoles.findByName(user.tenantId, user.systemInstanceId, key.toUpper);
    if (byName.isNull)
      throw new AbapNotFoundException("Business role '" ~ key ~ "' not found in system '" ~ user.systemName ~ "'");
    return byName;
  }

  /// Replace the assignments; unchanged roles keep their assignment date.
  protected void assignRoles(ref BusinessUser user, const string[] roles) {
    RoleAssignment[] result;
    foreach (r; roles) {
      auto role = resolveRole(user, r);
      if (result.any!(a => a.roleId == role.id))
        continue;
      auto previous = user.roleAssignments.filter!(a => a.roleId == role.id);
      result ~= RoleAssignment(role.id, role.name, previous.empty ? nowStdTime() : previous.front.assignedAt);
    }
    user.roleAssignments = result;
    user.roles = result.map!(a => a.roleName).array;
  }

  UsecaseResult lock(TenantId tenantId, BusinessUserId id, UserId actor) {
    return transition(tenantId, id, actor, "locked", (ref BusinessUser u) {
      ensureState(u.status != UserStatus.locked, "Business user '" ~ u.name ~ "' is already locked");
      u.status = UserStatus.locked;
      u.lockedAt = nowStdTime();
    });
  }

  UsecaseResult unlock(TenantId tenantId, BusinessUserId id, UserId actor) {
    return transition(tenantId, id, actor, "unlocked", (ref BusinessUser u) {
      ensureState(u.status == UserStatus.locked, "Business user '" ~ u.name ~ "' is not locked");
      u.status = UserStatus.active;
      u.lockedAt = 0;
      u.failedLoginAttempts = 0;
    });
  }

  UsecaseResult resetPassword(TenantId tenantId, BusinessUserId id, UserId actor) {
    return transition(tenantId, id, actor, "password reset", (ref BusinessUser u) {
      u.passwordChangeRequired = true;
      u.failedLoginAttempts = 0;
    });
  }

  UsecaseResult assignRole(TenantId tenantId, BusinessUserId id, string role, UserId actor) {
    return transition(tenantId, id, actor, "updated", (ref BusinessUser u) {
      auto r = resolveRole(u, role);
      ensureState(!u.roleAssignments.any!(a => a.roleId == r.id), "Business user '" ~ u.name ~ "' already has role " ~ r.name);
      assignRoles(u, u.roles ~ r.name);
    });
  }

  UsecaseResult unassignRole(TenantId tenantId, BusinessUserId id, string role, UserId actor) {
    return transition(tenantId, id, actor, "updated", (ref BusinessUser u) {
      auto r = resolveRole(u, role);
      if (!u.roleAssignments.any!(a => a.roleId == r.id))
        throw new AbapNotFoundException("Business user '" ~ u.name ~ "' does not have role " ~ r.name);
      assignRoles(u, u.roles.filter!(n => n != r.name).array);
    });
  }
}
