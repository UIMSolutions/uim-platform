/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.user_profiles;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.user_profile;
import uim.platform.workzone.domain.ports.repositories.user_profiles;
import uim.platform.workzone.application.dto;

class ManageUserProfilesUseCase : UIMUseCase {
  private UserProfileRepository repo;

  this(UserProfileRepository repo) {
    this.repo = repo;
  }

  CommandResult createUserProfile(CreateUserProfileRequest req) {
    if (req.displayName.length == 0)
      return CommandResult("", "Display name is required");

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
    return CommandResult(p.id, "");
  }

  UserProfile* getUserProfile(UserProfileId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  UserProfile* getUserProfileByUserId(UserId userId, TenantId tenantId) {
    return repo.findByUserId(userId, tenantId);
  }

  UserProfile[] listProfiles(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateUserProfile(UpdateUserProfileRequest req) {
    auto p = repo.findById(req.id, req.tenantId);
    if (p is null)
      return CommandResult("", "User profile not found");

    if (req.displayName.length > 0)
      p.displayName = req.displayName;
    if (req.email.length > 0)
      p.email = req.email;
    if (req.jobTitle.length > 0)
      p.jobTitle = req.jobTitle;
    if (req.avatarUrl.length > 0)
      p.avatarUrl = req.avatarUrl;
    p.updatedAt = Clock.currStdTime();

    repo.update(*p);
    return CommandResult(p.id, "");
  }

  CommandResult deleteUserProfile(UserProfileId id, TenantId tenantId) {
    auto p = repo.findById(id, tenantId);
    if (p is null)
      return CommandResult("", "User profile not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
