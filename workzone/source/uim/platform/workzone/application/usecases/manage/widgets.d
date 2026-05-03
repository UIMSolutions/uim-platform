/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.widgets;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.widget;
// import uim.platform.workzone.domain.ports.repositories.widgets;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageWidgetsUseCase { // TODO: UIMUseCase {
  private WidgetRepository repo;

  this(WidgetRepository repo) {
    this.repo = repo;
  }

  CommandResult createWidget(CreateWidgetRequest req) {
    auto now = Clock.currStdTime();
    auto w = Widget();
    w.id = randomUUID();
    w.pageId = req.pageId;
    w.tenantId = req.tenantId;
    w.title = req.title;
    w.cardId = req.cardId;
    w.appId = req.appId;
    w.size = req.size;
    w.row = req.row;
    w.col = req.col;
    w.sortOrder = req.sortOrder;
    w.config = req.config;
    w.createdAt = now;
    w.updatedAt = now;

    repo.save(w);
    return CommandResult(w.id, "");
  }

  Widget getWidget(TenantId tenantId, WidgetId id) {
    return repo.findById(tenantId, id);
  }

  Widget[] listByPage(TenantId tenantId, WorkpageId pageId) {
    return repo.findByPage(tenantId, pageId);
  }

  CommandResult updateWidget(UpdateWidgetRequest req) {
    auto w = repo.findById(req.tenantId, req.id);
    if (w.isNull)
      return CommandResult(false, "", "Widget not found");

    if (req.title.length > 0)
      w.title = req.title;
    w.size = req.size;
    w.row = req.row;
    w.col = req.col;
    w.sortOrder = req.sortOrder;
    w.visible = req.visible;
    w.config = req.config;
    w.updatedAt = Clock.currStdTime();

    repo.update(w);
    return CommandResult(w.id, "");
  }

  void deleteWidget(TenantId tenantId, WidgetId id) {
    repo.removeById(tenantId, id);
  }
}
