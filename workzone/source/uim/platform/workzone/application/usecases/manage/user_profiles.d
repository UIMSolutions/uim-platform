/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.user_profiles;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.user_profile;
// import uim.platform.workzone.domain.ports.repositories.user_profiles;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageUserProfilesUseCase { // TODO: UIMUseCase {
  private UserProfileRepository repo;

  this(UserProfileRepository repo) {
    this.repo = repo;
  }

  CommandResult createUserProfile(CreateUserProfileRequest req) {
    if (req.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");

    auto now = Clock.currStdTime();
    auto p = UserProfile();
    p.id = randomUUID();
    p.userId = req.userId;
    p.tenantId = req.tenantId;
    p.displayName = req.displayName;
    p.email = req.email;
    p.firstName = req.firstName;
    p.lastName = req.lastName;
    p.jobTitle = req.jobTitle;
    p.department = req.department;
    p.timezone = req.timezone;
    p.language = req.language;
    p.active = true;
    p.createdAt = now;
    p.updatedAt = now;

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  UserProfile getUserProfile(TenantId tenantId, UserProfileId id) {
    return repo.findById(tenantId, id);
  }

  UserProfile getUserProfileByUserId(TenantId tenantId, UserId id) {
    return repo.findByUserId(tenantId, id);
  }

  UserProfile[] listProfiles(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateUserProfile(UpdateUserProfileRequest req) {
    auto p = repo.findById(req.tenantId, req.id);
    if (p.isNull)
      return CommandResult(false, "", "User profile not found");

    if (req.displayName.length > 0)
      p.displayName = req.displayName;
    if (req.email.length > 0)
      p.email = req.email;
    if (req.jobTitle.length > 0)
      p.jobTitle = req.jobTitle;
    if (req.avatarUrl.length > 0)
      p.avatarUrl = req.avatarUrl;
    p.updatedAt = Clock.currStdTime();

    repo.update(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult deleteUserProfile(TenantId tenantId, UserProfileId id) {
    auto p = repo.findById(tenantId, id);
    if (p.isNull)
      return CommandResult(false, "", "User profile not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
