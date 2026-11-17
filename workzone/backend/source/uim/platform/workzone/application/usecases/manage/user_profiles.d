/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.user_profiles;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: user profiles. One profile per user; roles and groups must
/// exist; default roles are assigned to new profiles.
class ManageUserProfilesUseCase
  : ResourceUseCase!(UserProfile, UserProfileId, CreateUserProfileRequest, UpdateUserProfileRequest),
  IManageUserProfilesUseCase {

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.userProfiles, publisher, "User profile", "workzone.user-profile");
  }

  override protected UserProfile build(CreateUserProfileRequest r) {
    auto p = UserProfile(r.tenantId);
    assignMatching(p, r.spec);
    if (p.roles.length == 0)
      p.roles = repos.roles.findMatching(r.tenantId, (const Role x) => x.isDefault).map!(x => x.name).array;
    check(p);
    return p;
  }

  override protected void apply(ref UserProfile p, UserProfileSpec spec) {
    auto user = p.userId;
    assignMatching(p, spec, ["userId"]);
    p.userId = user;
    check(p);
  }

  protected void check(ref UserProfile p) {
    validate(!p.userId.isEmpty, "userId is required");
    auto user = p.userId;
    auto id = p.id;
    ensureState(repos.userProfiles.findMatching(p.tenantId, (const UserProfile o) => o.userId == user && o.id != id).length == 0,
      "User '" ~ p.userId.value ~ "' already has a profile");
    if (p.displayName.strip.length == 0)
      p.displayName = (p.firstName ~ " " ~ p.lastName).strip;
    if (p.displayName.length == 0)
      p.displayName = p.userId.value;
    validateDisplayName("Display name", p.displayName, 120);
    validate(p.email.length == 0 || isEmail(p.email), "E-mail '" ~ p.email ~ "' is invalid");
    validateOptionalUrl("Avatar URL", p.avatarUrl);
    p.roles = requireRoles(p.tenantId, p.roles);
    p.groups = normalizedNames(p.groups);
    foreach (g; p.groups)
      ensureFound(!repos.groups.findByName(p.tenantId, g).isNull, "Group '" ~ g ~ "' not found");
  }

  UsecaseResult activate(TenantId tenantId, UserProfileId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref UserProfile p) {
      ensureState(!p.active, "User '" ~ p.displayName ~ "' is already active");
      p.active = true;
    });
  }

  UsecaseResult deactivate(TenantId tenantId, UserProfileId id, UserId actor) {
    return transition(tenantId, id, actor, "deactivated", (ref UserProfile p) {
      ensureState(p.active, "User '" ~ p.displayName ~ "' is already inactive");
      p.active = false;
    });
  }

  UsecaseResult recordLogin(TenantId tenantId, UserProfileId id, UserId actor) {
    return transition(tenantId, id, actor, "logged in", (ref UserProfile p) {
      ensureState(p.active, "User '" ~ p.displayName ~ "' is inactive");
      p.lastLoginAt = nowStdTime();
    });
  }
}
