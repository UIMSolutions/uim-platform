/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.ports.usecases.administration;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Sites: draft → published ⇄ maintenance → archived. Removal cascades to navigation.
interface IManageSitesUseCase : IManageResource!(Site, SiteId, CreateSiteRequest, UpdateSiteRequest) {
  UsecaseResult publish(TenantId tenantId, SiteId id, UserId actor);
  UsecaseResult unpublish(TenantId tenantId, SiteId id, UserId actor);
  UsecaseResult startMaintenance(TenantId tenantId, SiteId id, UserId actor);
  UsecaseResult archive(TenantId tenantId, SiteId id, UserId actor);
}

/// Navigation entries of sites.
interface IManageNavigationItemsUseCase : IManageResource!(NavigationItem, NavigationItemId,
    CreateNavigationItemRequest, UpdateNavigationItemRequest) {
}

/// Themes (one default per tenant).
interface IManageThemesUseCase : IManageResource!(Theme, ThemeId, CreateThemeRequest, UpdateThemeRequest) {
  UsecaseResult makeDefault(TenantId tenantId, ThemeId id, UserId actor);
}

/// Page templates (one default per tenant).
interface IManagePageTemplatesUseCase : IManageResource!(PageTemplate, PageTemplateId,
    CreatePageTemplateRequest, UpdatePageTemplateRequest) {
  UsecaseResult makeDefault(TenantId tenantId, PageTemplateId id, UserId actor);
}

/// Roles. Roles in use and predefined roles cannot be deleted.
interface IManageRolesUseCase : IManageResource!(Role, RoleId, CreateRoleRequest, UpdateRoleRequest) {
}

/// User groups.
interface IManageGroupsUseCase : IManageResource!(UserGroup, GroupId, CreateGroupRequest, UpdateGroupRequest) {
  UsecaseResult addMember(TenantId tenantId, GroupId id, string userId, UserId actor);
  UsecaseResult removeMember(TenantId tenantId, GroupId id, string userId, UserId actor);
}

/// Tags (hierarchical).
interface IManageTagsUseCase : IManageResource!(Tag, TagId, CreateTagRequest, UpdateTagRequest) {
}

/// User profiles.
interface IManageUserProfilesUseCase : IManageResource!(UserProfile, UserProfileId,
    CreateUserProfileRequest, UpdateUserProfileRequest) {
  UsecaseResult activate(TenantId tenantId, UserProfileId id, UserId actor);
  UsecaseResult deactivate(TenantId tenantId, UserProfileId id, UserId actor);
  UsecaseResult recordLogin(TenantId tenantId, UserProfileId id, UserId actor);
}
