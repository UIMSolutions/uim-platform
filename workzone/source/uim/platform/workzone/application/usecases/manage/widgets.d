/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.widgets;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.widget;
// import uim.platform.workzone.domain.ports.repositories.widgets;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class ManageWidgetsUseCase { // TODO: UIMUseCase {
  private WidgetRepository repo;

  this(WidgetRepository repo) {
    this.repo = repo;
  }

  CommandResult createWidget(CreateWidgetRequest req) {
    auto now = currentTimestamp();
    Widget w;
    w.initEntity(req.tenantId);
    
    w.pageId = req.pageId;
    w.title = req.title;
    w.cardId = req.cardId;
    w.appId = req.appId;
    w.size = req.size;
    w.row = req.row;
    w.col = req.col;
    w.sortOrder = req.sortOrder;
    w.config = req.config;

    repo.save(w);
    return CommandResult(true, w.id.value, "");
  }

  Widget getWidget(TenantId tenantId, WidgetId id) {
    return repo.findById(tenantId, id);
  }

  Widget[] listWidgets(TenantId tenantId, WorkpageId pageId) {
    Widget[] result;
    foreach (w; repo.find(tenantId)) {
      if (w.pageId == pageId)
        result ~= w;
    }
    return result;
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
    w.updatedAt = currentTimestamp();

    repo.update(w);
    return CommandResult(true, w.id.value, "");
  }

  CommandResult deleteWidget(TenantId tenantId, WidgetId id) {
    auto w = repo.findById(tenantId, id);
    if (w.isNull)
      return CommandResult(false, "", "Widget not found");

    repo.remove(w);
    return CommandResult(true, w.id.value, "");
  }
}
