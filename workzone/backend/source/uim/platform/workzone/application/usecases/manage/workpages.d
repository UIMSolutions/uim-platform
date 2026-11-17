/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.workpages;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: workpages. Titles are unique per workspace, one default page per
/// workspace; pages referenced by navigation cannot be deleted.
class ManageWorkpagesUseCase
  : ResourceUseCase!(Workpage, WorkpageId, CreateWorkpageRequest, UpdateWorkpageRequest),
  IManageWorkpagesUseCase {

  protected CascadeDeleter cascade;

  this(WorkzoneRepositories repos, CascadeDeleter cascade, IWorkzoneEventPublisher publisher) {
    super(repos, repos.workpages, publisher, "Workpage", "workzone.workpage");
    this.cascade = cascade;
  }

  override protected Workpage build(CreateWorkpageRequest r) {
    auto ws = requireWorkspace(r.tenantId, r.parentId, "workpages");
    auto p = Workpage(r.tenantId);
    p.workspaceId = ws.id;
    p.workspaceName = ws.name;
    assignMatching(p, r.spec);
    if (p.templateId.isEmpty) {
      auto defaults = repos.pageTemplates.findMatching(r.tenantId, (const PageTemplate t) => t.isDefault);
      if (defaults.length > 0)
        p.templateId = defaults[0].id;
    }
    // the first page of a workspace is its default page
    if (repos.workpages.findByWorkspace(r.tenantId, ws.id).length == 0)
      p.isDefault = true;
    check(p, ws.name);
    return p;
  }

  override protected void apply(ref Workpage p, WorkpageSpec spec) {
    assignMatching(p, spec);
    check(p, p.workspaceName);
  }

  protected void check(ref Workpage p, string workspaceName) {
    p.title = p.title.strip;
    validateDisplayName("Workpage title", p.title, 80);
    ensureUniqueInWorkspace(p, workspaceName);
    p.templateName = "";
    if (!p.templateId.isEmpty) {
      auto t = repos.pageTemplates.findById(p.tenantId, p.templateId);
      ensureFound(!t.isNull, "Page template '" ~ p.templateId.value ~ "' not found");
      p.templateName = t.name;
    }
    p.allowedRoles = requireRoles(p.tenantId, p.allowedRoles);
    validate(p.sortOrder >= 0, "Sort order must not be negative");
  }

  /// Keep a single default page per workspace.
  override protected void afterCreate(Workpage p, UserId actor) {
    if (p.isDefault)
      clearOtherDefaults(p);
  }

  override UsecaseResult update(UpdateWorkpageRequest request) {
    auto result = super.update(request);
    if (result.isSuccess) {
      auto p = repo.findById(request.tenantId, request.id);
      if (p.isDefault)
        clearOtherDefaults(p);
    }
    return result;
  }

  protected void clearOtherDefaults(const Workpage keep) {
    auto keepId = keep.id;
    auto wsId = keep.workspaceId;
    foreach (other; repos.workpages.findMatching(keep.tenantId,
        (const Workpage o) => o.workspaceId == wsId && o.id != keepId && o.isDefault)) {
      other.isDefault = false;
      repos.workpages.update(other);
    }
  }

  override protected void beforeRemove(Workpage p) {
    auto id = p.id;
    auto refs = repos.navigationItems.findMatching(p.tenantId, (const NavigationItem n) => n.targetWorkpageId == id);
    ensureState(refs.length == 0, "Workpage '" ~ p.title ~ "' is used by navigation item(s) "
        ~ refs.map!(n => n.title).join(", "));
  }

  override protected void afterRemove(Workpage p) {
    cascade.clearWorkpage(p.tenantId, p.id);
  }

  UsecaseResult makeDefault(TenantId tenantId, WorkpageId id, UserId actor) {
    auto result = transition(tenantId, id, actor, "set as default", (ref Workpage p) {
      ensureState(p.visible, "A hidden workpage cannot be the default page");
      p.isDefault = true;
    });
    if (result.isSuccess)
      clearOtherDefaults(repo.findById(tenantId, id));
    return result;
  }
}

/// Interactor: widgets. A widget shows exactly one active card or active app
/// and must fit into the 4 column grid.
class ManageWidgetsUseCase
  : ResourceUseCase!(PageWidget, WidgetId, CreateWidgetRequest, UpdateWidgetRequest),
  IManageWidgetsUseCase {

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.widgets, publisher, "Widget", "workzone.widget");
  }

  override protected PageWidget build(CreateWidgetRequest r) {
    validate(!r.parentId.isEmpty, "workpageId is required");
    auto page = repos.workpages.findById(r.tenantId, r.parentId);
    ensureFound(!page.isNull, "Workpage '" ~ r.parentId.value ~ "' not found");
    requireWorkspace(r.tenantId, page.workspaceId, "widgets");
    auto w = PageWidget(r.tenantId);
    w.workpageId = page.id;
    w.workpageTitle = page.title;
    w.workspaceId = page.workspaceId;
    assignMatching(w, r.spec);
    check(w);
    return w;
  }

  override protected void apply(ref PageWidget w, WidgetSpec spec) {
    assignMatching(w, spec);
    check(w);
  }

  protected void check(ref PageWidget w) {
    validate(w.cardId.isEmpty != w.appId.isEmpty, "A widget shows exactly one card (cardId) or one app (appId)");
    if (!w.cardId.isEmpty) {
      auto c = repos.cards.findById(w.tenantId, w.cardId);
      ensureFound(!c.isNull, "Card '" ~ w.cardId.value ~ "' not found");
      ensureState(c.active, "Card '" ~ c.title ~ "' is inactive");
      if (w.title.strip.length == 0)
        w.title = c.title;
    } else {
      auto a = repos.apps.findById(w.tenantId, w.appId);
      ensureFound(!a.isNull, "App '" ~ w.appId.value ~ "' not found");
      ensureState(a.status == AppStatus.active, "App '" ~ a.name ~ "' is " ~ enumText(a.status));
      if (w.title.strip.length == 0)
        w.title = a.name;
    }
    validatePlacement(w);
    validate(w.maxItems >= 0 && w.maxItems <= 100, "Max items must be between 0 and 100");
    validate(w.refreshIntervalSec == 0 || w.refreshIntervalSec >= 30, "Refresh interval must be 0 (off) or at least 30 seconds");
    string[] keys;
    foreach (p; w.parameters) {
      validate(p.key.strip.length > 0, "Widget parameters need a name");
      validate(!keys.canFind(p.key), "Widget parameter '" ~ p.key ~ "' is defined twice");
      keys ~= p.key;
    }
  }

  protected static void validatePlacement(const PageWidget w) {
    validate(w.row >= 0 && w.col >= 0, "Row and column must not be negative");
    validate(w.col + w.size.columnsOf <= 4, "A " ~ enumText(w.size) ~ " widget does not fit into column " ~ w.col.to!string
        ~ " of the 4 column grid");
  }

  UsecaseResult move(TenantId tenantId, WidgetId id, int row, int col, UserId actor) {
    return transition(tenantId, id, actor, "moved", (ref PageWidget w) {
      w.row = row;
      w.col = col;
      validatePlacement(w);
    });
  }
}
