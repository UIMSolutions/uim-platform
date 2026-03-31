module uim.platform.analytics.domain.entities.dashboard;

import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
/// A Dashboard is a collection of pages, each containing analytical widgets.
/// Corresponds to an "Analytic Application" in SAP Analytics Cloud.
class Dashboard {
  EntityId id;
  string name;
  string description;
  EntityId ownerId;
  Visibility visibility;
  ArtifactStatus status;
  Page[] pages;
  AuditInfo audit;
  string[] tags;

  this() {
  }

  static Dashboard create(string name, string description, string ownerId) {
    auto d = new Dashboard();
    d.id = EntityId.generate();
    d.name = name;
    d.description = description;
    d.ownerId = EntityId(ownerId);
    d.visibility = Visibility.Private;
    d.status = ArtifactStatus.Draft;
    d.pages = [];
    d.tags = [];
    d.audit = AuditInfo.create(ownerId);
    return d;
  }

  void addPage(string title) {
    pages ~= Page(EntityId.generate(), title, []);
  }

  void publish() {
    status = ArtifactStatus.Published;
  }

  void archive() {
    status = ArtifactStatus.Archived;
  }

  Json toJson() {
    auto jPages = pages.map!(p => Json.emptyObject
        .set("id", p.id.toJson)
        .set("title", p.title)
        .set("widgetIds", p.widgetIds.map!(wid => wid).array)
    ).array;

    return Json.emptyObject
      .set("id", id.toJson)
      .set("name", name)
      .set("description", description)
      .set("ownerId", ownerId.toString)
      .set("visibility", visibility.toString)
      .set("status", status.toString)
      .set("pages", jPages)
      .set("audit", Json.emptyObject
          .set("createdBy", audit.createdBy)
          .set("createdAt", audit.createdAt)
          .set("updatedBy", audit.updatedBy)
          .set("updatedAt", audit.updatedAt)
      )
      .set("tags", tags);
  }
}

/// A page / tab within a dashboard.
struct Page {
  EntityId id;
  string title;
  EntityId[] widgetIds;
}
