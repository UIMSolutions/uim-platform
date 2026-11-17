/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.services.seed;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Installs the predefined content of a tenant: standard roles, SAP themes,
/// page templates and tags. Idempotent: existing names are kept.
class WorkzoneSeedService : IWorkzoneSeedService {
  protected WorkzoneRepositories repos;
  protected IWorkzoneEventPublisher publisher;

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    this.repos = repos;
    this.publisher = publisher;
  }

  SeedReport seed(TenantId tenantId, UserId actor) {
    SeedReport report;
    report.tenantId = tenantId;

    void add(TEntity, TId)(IWorkzoneRepository!(TEntity, TId) repo, TEntity entity, string kind) {
      if (!repo.findByName(tenantId, nameOf(entity)).isNull) {
        report.skipped++;
        return;
      }
      entity.createdBy = actor;
      entity.updatedBy = actor;
      repo.save(entity);
      report.created++;
      report.items ~= kind ~ " " ~ nameOf(entity);
    }

    // ── roles ──────────────────────────────────────────────────────────────
    Role role(string name, string description, string[] permissions, bool isDefault = false) {
      auto r = Role(tenantId);
      r.name = name;
      r.description = description;
      r.permissions = permissions;
      r.isDefault = isDefault;
      r.predefined = true;
      return r;
    }

    add(repos.roles, role("Viewer", "Read workspaces, pages and content",
        ["read:workspace", "read:content", "read:site"], true), "role");
    add(repos.roles, role("Contributor", "Create and edit content in workspaces",
        ["read:workspace", "read:content", "write:content", "write:forum", "read:site"]), "role");
    add(repos.roles, role("Workspace Administrator", "Manage workspaces, members, pages and widgets",
        ["read:workspace", "admin:workspace", "write:content", "admin:content", "read:site"]), "role");
    add(repos.roles, role("Content Manager", "Manage cards, apps, channels and content providers",
        ["read:workspace", "admin:card", "admin:app", "admin:channel", "admin:provider"]), "role");
    add(repos.roles, role("Site Administrator", "Manage sites, navigation, themes and shell plugins",
        ["admin:site", "admin:theme", "admin:plugin", "read:workspace"]), "role");
    add(repos.roles, role("Tenant Administrator", "Full access", ["*:*"]), "role");

    // ── themes ─────────────────────────────────────────────────────────────
    Theme theme(string name, BaseTheme base, string primary, string background, bool isDefault = false) {
      auto t = Theme(tenantId);
      t.name = name;
      t.description = "SAP " ~ enumText(base) ~ " based theme";
      t.baseTheme = base;
      t.primaryColor = primary;
      t.backgroundColor = background;
      t.isDefault = isDefault;
      t.predefined = true;
      return t;
    }

    auto hasDefaultTheme = repos.themes.findMatching(tenantId, (const Theme t) => t.isDefault).length > 0;
    add(repos.themes, theme("Morning Horizon", BaseTheme.sapHorizon, "#0070F2", "#F5F6F7", !hasDefaultTheme), "theme");
    add(repos.themes, theme("Evening Horizon", BaseTheme.sapHorizonDark, "#4DB1FF", "#12171C"), "theme");
    add(repos.themes, theme("High Contrast Black", BaseTheme.sapHorizonHcb, "#FFFFFF", "#000000"), "theme");
    add(repos.themes, theme("Quartz Light", BaseTheme.sapFiori3, "#0A6ED1", "#F7F7F7"), "theme");

    // ── page templates ─────────────────────────────────────────────────────
    PageTemplate tpl(string name, string description, TemplateSection[] sections, bool isDefault = false) {
      auto t = PageTemplate(tenantId);
      t.name = name;
      t.description = description;
      t.sections = sections;
      t.isDefault = isDefault;
      t.predefined = true;
      return t;
    }

    with (WidgetSize) {
      auto hasDefaultTemplate = repos.pageTemplates.findMatching(tenantId, (const PageTemplate t) => t.isDefault).length > 0;
      add(repos.pageTemplates, tpl("Standard", "One flexible grid section",
          [TemplateSection("main", "Content", 4, "grid", 0, [small, medium, large, fullWidth])], !hasDefaultTemplate), "template");
      add(repos.pageTemplates, tpl("Two Columns", "Main area and side bar",
          [TemplateSection("main", "Main", 3, "grid", 0, [medium, large]),
           TemplateSection("side", "Side Bar", 1, "list", 1, [small])]), "template");
      add(repos.pageTemplates, tpl("Dashboard", "KPI header, cards and a full width table",
          [TemplateSection("kpis", "Key Figures", 4, "grid", 0, [small]),
           TemplateSection("cards", "Cards", 4, "grid", 1, [medium, large]),
           TemplateSection("details", "Details", 4, "list", 2, [fullWidth])]), "template");
      add(repos.pageTemplates, tpl("Tabs", "Content organised in tabs",
          [TemplateSection("tabs", "Tabs", 4, "tabs", 0, [medium, large, fullWidth])]), "template");
    }

    // ── tags ───────────────────────────────────────────────────────────────
    Tag tag(string name, string color, string parent = "") {
      auto t = Tag(tenantId);
      t.name = name;
      t.color = color;
      t.parentTag = parent;
      return t;
    }

    add(repos.tags, tag("General", "#0A6ED1"), "tag");
    add(repos.tags, tag("Announcement", "#E9730C"), "tag");
    add(repos.tags, tag("HR", "#107E3E"), "tag");
    add(repos.tags, tag("Onboarding", "#107E3E", "HR"), "tag");
    add(repos.tags, tag("IT", "#5D36FF"), "tag");
    add(repos.tags, tag("Sales", "#BB0000"), "tag");

    auto payload = Json.emptyObject;
    payload["tenantId"] = tenantId.value;
    payload["created"] = report.created;
    publisher.publish("workzone.seed.completed", payload);
    return report;
  }
}
