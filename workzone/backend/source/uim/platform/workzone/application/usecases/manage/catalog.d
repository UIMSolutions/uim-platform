/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.catalog;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: themes. One default per tenant; predefined, default and used
/// themes cannot be deleted.
class ManageThemesUseCase : ResourceUseCase!(Theme, ThemeId, CreateThemeRequest, UpdateThemeRequest), IManageThemesUseCase {
  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.themes, publisher, "Theme", "workzone.theme");
  }

  override protected Theme build(CreateThemeRequest r) {
    auto t = Theme(r.tenantId);
    assignMatching(t, r.spec);
    check(t);
    return t;
  }

  override protected void apply(ref Theme t, ThemeSpec spec) {
    assignMatching(t, spec);
    check(t);
  }

  protected void check(ref Theme t) {
    t.name = t.name.strip;
    validateDisplayName("Theme name", t.name, 80);
    ensureUnique(repos.themes.findByName(t.tenantId, t.name), t);
    validateOptionalColor("Primary colour", t.primaryColor);
    validateOptionalColor("Secondary colour", t.secondaryColor);
    validateOptionalColor("Background colour", t.backgroundColor);
    validateOptionalColor("Header colour", t.headerColor);
    validateOptionalColor("Text colour", t.textColor);
    validateOptionalColor("Link colour", t.linkColor);
    validateOptionalColor("Accent colour", t.accentColor);
    validate(t.logoUrl.length == 0 || isLaunchTarget(t.logoUrl), "Logo '" ~ t.logoUrl ~ "' is not a valid URL");
    validate(!t.customCss.canFind("<"), "Custom CSS must not contain markup");
    validate(t.customCss.length <= 20_000, "Custom CSS is limited to 20000 characters");
  }

  override protected void afterCreate(Theme t, UserId actor) {
    if (t.isDefault)
      exclusiveDefault(repos.themes, t);
  }

  override UsecaseResult update(UpdateThemeRequest request) {
    auto result = super.update(request);
    if (result.isSuccess) {
      auto t = repo.findById(request.tenantId, request.id);
      if (t.isDefault)
        exclusiveDefault(repos.themes, t);
    }
    return result;
  }

  override protected void beforeRemove(Theme t) {
    ensureState(!t.predefined, "Theme '" ~ t.name ~ "' is predefined");
    ensureState(!t.isDefault, "Theme '" ~ t.name ~ "' is the default theme — make another theme default first");
    auto id = t.id;
    auto sites = repos.sites.findMatching(t.tenantId, (const Site s) => s.themeId == id);
    ensureState(sites.length == 0, "Theme '" ~ t.name ~ "' is used by site(s) " ~ sites.map!(s => s.name).join(", "));
  }

  UsecaseResult makeDefault(TenantId tenantId, ThemeId id, UserId actor) {
    auto result = transition(tenantId, id, actor, "set as default", (ref Theme t) { t.isDefault = true; });
    if (result.isSuccess)
      exclusiveDefault(repos.themes, repos.themes.findById(tenantId, id));
    return result;
  }
}

/// Clear `isDefault` on every other aggregate of the tenant.
void exclusiveDefault(TEntity, TId)(IWorkzoneRepository!(TEntity, TId) repo, const TEntity keep) {
  auto keepId = keep.id;
  foreach (other; repo.findMatching(keep.tenantId, (const TEntity o) => o.isDefault && o.id != keepId)) {
    other.isDefault = false;
    repo.update(other);
  }
}

/// Interactor: page templates. Sections need unique ids and 1..4 columns.
class ManagePageTemplatesUseCase
  : ResourceUseCase!(PageTemplate, PageTemplateId, CreatePageTemplateRequest, UpdatePageTemplateRequest),
  IManagePageTemplatesUseCase {

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.pageTemplates, publisher, "Page template", "workzone.page-template");
  }

  override protected PageTemplate build(CreatePageTemplateRequest r) {
    auto t = PageTemplate(r.tenantId);
    assignMatching(t, r.spec);
    check(t);
    return t;
  }

  override protected void apply(ref PageTemplate t, PageTemplateSpec spec) {
    assignMatching(t, spec);
    check(t);
  }

  protected void check(ref PageTemplate t) {
    t.name = t.name.strip;
    validateDisplayName("Template name", t.name, 80);
    ensureUnique(repos.pageTemplates.findByName(t.tenantId, t.name), t);
    if (t.sections.length == 0)
      t.sections = [TemplateSection("main", "Content", 4)];
    string[] ids;
    foreach (i, ref s; t.sections) {
      if (s.sectionId.strip.length == 0)
        s.sectionId = "section" ~ (i + 1).to!string;
      validate(!ids.canFind(s.sectionId), "Section ID '" ~ s.sectionId ~ "' is used twice");
      ids ~= s.sectionId;
      validate(s.columns >= 1 && s.columns <= 4, "Section '" ~ s.sectionId ~ "' must have 1 to 4 columns");
      validate(["grid", "list", "tabs"].canFind(s.layoutType), "Layout of section '" ~ s.sectionId ~ "' must be grid, list or tabs");
    }
  }

  override protected void afterCreate(PageTemplate t, UserId actor) {
    if (t.isDefault)
      exclusiveDefault(repos.pageTemplates, t);
  }

  override UsecaseResult update(UpdatePageTemplateRequest request) {
    auto result = super.update(request);
    if (result.isSuccess) {
      auto t = repo.findById(request.tenantId, request.id);
      if (t.isDefault)
        exclusiveDefault(repos.pageTemplates, t);
    }
    return result;
  }

  override protected void beforeRemove(PageTemplate t) {
    ensureState(!t.predefined, "Page template '" ~ t.name ~ "' is predefined");
    auto id = t.id;
    auto pages = repos.workpages.findMatching(t.tenantId, (const Workpage p) => p.templateId == id);
    ensureState(pages.length == 0, "Page template '" ~ t.name ~ "' is used by workpage(s) " ~ pages.map!(p => p.title).join(", "));
  }

  UsecaseResult makeDefault(TenantId tenantId, PageTemplateId id, UserId actor) {
    auto result = transition(tenantId, id, actor, "set as default", (ref PageTemplate t) { t.isDefault = true; });
    if (result.isSuccess)
      exclusiveDefault(repos.pageTemplates, repos.pageTemplates.findById(tenantId, id));
    return result;
  }
}

/// Interactor: roles. Permissions look like "verb:object"; predefined roles and
/// roles referenced by groups, profiles, pages, cards, apps or sites cannot be deleted.
class ManageRolesUseCase : ResourceUseCase!(Role, RoleId, CreateRoleRequest, UpdateRoleRequest), IManageRolesUseCase {
  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.roles, publisher, "Role", "workzone.role");
  }

  override protected Role build(CreateRoleRequest r) {
    auto role = Role(r.tenantId);
    assignMatching(role, r.spec);
    check(role);
    return role;
  }

  override protected void apply(ref Role role, RoleSpec spec) {
    auto name = role.name;
    assignMatching(role, spec, ["name"]);
    role.name = name; // role names are referenced by name
    check(role);
  }

  protected void check(ref Role role) {
    role.name = role.name.strip;
    validateDisplayName("Role name", role.name, 80);
    ensureUnique(repos.roles.findByName(role.tenantId, role.name), role);
    role.permissions = normalizedNames(role.permissions);
    foreach (p; role.permissions)
      validate(isPermission(p), "Permission '" ~ p ~ "' must look like verb:object (e.g. read:workspace)");
  }

  override protected void beforeRemove(Role role) {
    ensureState(!role.predefined, "Role '" ~ role.name ~ "' is predefined");
    auto n = role.name;
    string[] users;
    foreach (g; repos.groups.findMatching(role.tenantId, (const UserGroup g) => g.roles.canFind(n)))
      users ~= "group " ~ g.name;
    foreach (p; repos.userProfiles.findMatching(role.tenantId, (const UserProfile p) => p.roles.canFind(n)))
      users ~= "user " ~ p.displayName;
    foreach (p; repos.workpages.findMatching(role.tenantId, (const Workpage p) => p.allowedRoles.canFind(n)))
      users ~= "workpage " ~ p.title;
    foreach (s; repos.sites.findMatching(role.tenantId, (const Site s) => s.allowedRoles.canFind(n)))
      users ~= "site " ~ s.name;
    foreach (a; repos.apps.findMatching(role.tenantId, (const AppRegistration a) => a.allowedRoles.canFind(n)))
      users ~= "app " ~ a.name;
    foreach (c; repos.cards.findMatching(role.tenantId, (const Card c) => c.allowedRoles.canFind(n)))
      users ~= "card " ~ c.title;
    ensureState(users.length == 0, "Role '" ~ role.name ~ "' is assigned to " ~ users.join(", "));
  }
}

/// Interactor: user groups. Roles must exist; members are user ids.
class ManageGroupsUseCase : ResourceUseCase!(UserGroup, GroupId, CreateGroupRequest, UpdateGroupRequest), IManageGroupsUseCase {
  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.groups, publisher, "Group", "workzone.group");
  }

  override protected UserGroup build(CreateGroupRequest r) {
    auto g = UserGroup(r.tenantId);
    assignMatching(g, r.spec);
    check(g);
    return g;
  }

  override protected void apply(ref UserGroup g, GroupSpec spec) {
    auto name = g.name;
    assignMatching(g, spec, ["name"]);
    g.name = name; // group names are referenced by name
    check(g);
  }

  protected void check(ref UserGroup g) {
    g.name = g.name.strip;
    validateDisplayName("Group name", g.name, 80);
    ensureUnique(repos.groups.findByName(g.tenantId, g.name), g);
    g.memberIds = normalizedNames(g.memberIds);
    g.roles = requireRoles(g.tenantId, g.roles);
    validate(g.groupType != GroupType.dynamic || g.memberIds.length == 0, "Dynamic groups derive their members — do not list them");
  }

  override protected void beforeRemove(UserGroup g) {
    auto n = g.name;
    auto users = repos.userProfiles.findMatching(g.tenantId, (const UserProfile p) => p.groups.canFind(n));
    ensureState(users.length == 0, "Group '" ~ g.name ~ "' is assigned to user(s) " ~ users.map!(u => u.displayName).join(", "));
  }

  UsecaseResult addMember(TenantId tenantId, GroupId id, string userId, UserId actor) {
    return transition(tenantId, id, actor, "member added", (ref UserGroup g) {
      validate(userId.strip.length > 0, "userId is required");
      ensureState(g.groupType != GroupType.dynamic, "Members of dynamic group '" ~ g.name ~ "' are derived");
      ensureState(!g.memberIds.canFind(userId), "'" ~ userId ~ "' is already a member of " ~ g.name);
      g.memberIds ~= userId.strip;
    });
  }

  UsecaseResult removeMember(TenantId tenantId, GroupId id, string userId, UserId actor) {
    return transition(tenantId, id, actor, "member removed", (ref UserGroup g) {
      ensureFound(g.memberIds.canFind(userId), "'" ~ userId ~ "' is not a member of " ~ g.name);
      g.memberIds = g.memberIds.filter!(m => m != userId).array;
    });
  }
}

/// Interactor: tags. Parent tags must exist and must not create a cycle; tags
/// used by content or with child tags cannot be deleted.
class ManageTagsUseCase : ResourceUseCase!(Tag, TagId, CreateTagRequest, UpdateTagRequest), IManageTagsUseCase {
  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.tags, publisher, "Tag", "workzone.tag");
  }

  override protected Tag build(CreateTagRequest r) {
    auto t = Tag(r.tenantId);
    assignMatching(t, r.spec);
    check(t);
    return t;
  }

  override protected void apply(ref Tag t, TagSpec spec) {
    auto name = t.name;
    assignMatching(t, spec, ["name"]);
    t.name = name; // tags are referenced by name
    check(t);
  }

  protected void check(ref Tag t) {
    t.name = t.name.strip;
    validateDisplayName("Tag name", t.name, 60);
    validate(!t.name.canFind(","), "Tag names must not contain commas");
    ensureUnique(repos.tags.findByName(t.tenantId, t.name), t);
    validateOptionalColor("Colour", t.color);
    t.parentTag = t.parentTag.strip;
    if (t.parentTag.length > 0) {
      ensureFound(!repos.tags.findByName(t.tenantId, t.parentTag).isNull, "Parent tag '" ~ t.parentTag ~ "' not found");
      validate(!createsTagCycle(repos.tags.findByTenant(t.tenantId), t.name, t.parentTag), "Parent tag '" ~ t.parentTag
          ~ "' would create a cycle");
    }
  }

  override protected void beforeRemove(Tag t) {
    auto n = t.name;
    auto children = repos.tags.findMatching(t.tenantId, (const Tag x) => x.parentTag == n);
    ensureState(children.length == 0, "Tag '" ~ n ~ "' has child tags " ~ children.map!(c => c.name).join(", "));
    auto used = repos.content.findMatching(t.tenantId, (const ContentItem c) => c.tags.canFind(n));
    ensureState(used.length == 0, "Tag '" ~ n ~ "' is used by " ~ used.length.to!string ~ " content item(s)");
  }
}
