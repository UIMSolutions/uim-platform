/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage_widgets;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.widget;
import uim.platform.workzone.domain.ports.widget_repository;
import uim.platform.workzone.application.dto;

class ManageWidgetsUseCase
{
  private WidgetRepository repo;

  this(WidgetRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createWidget(CreateWidgetRequest req)
  {
    auto now = Clock.currStdTime();
    auto w = Widget();
    w.id = randomUUID().toString();
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

  Widget* getWidget(WidgetId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  Widget[] listByPage(WorkpageId pageId, TenantId tenantId)
  {
    return repo.findByPage(pageId, tenantId);
  }

  CommandResult updateWidget(UpdateWidgetRequest req)
  {
    auto w = repo.findById(req.id, req.tenantId);
    if (w is null)
      return CommandResult("", "Widget not found");

    if (req.title.length > 0)
      w.title = req.title;
    w.size = req.size;
    w.row = req.row;
    w.col = req.col;
    w.sortOrder = req.sortOrder;
    w.visible = req.visible;
    w.config = req.config;
    w.updatedAt = Clock.currStdTime();

    repo.update(*w);
    return CommandResult(w.id, "");
  }

  void deleteWidget(WidgetId id, TenantId tenantId)
  {
    repo.remove(id, tenantId);
  }
}
