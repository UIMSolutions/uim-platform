/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.overview;
// import uim.platform.logging.application.usecases.get_overview;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

class OverviewController : HttpController {
  protected GetOverviewUseCase usecase;

  this(GetOverviewUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/overview", &handleOverview);
  }

  protected Json overviewHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto summary = usecase.getSummary(tenantId);

    auto response = Json.emptyObject
      .set("totalLogEntries", summary.totalLogEntries)
      .set("totalSpans", summary.totalSpans)
      .set("totalStreams", summary.totalStreams)
      .set("totalDashboards", summary.totalDashboards)
      .set("totalAlerts", summary.totalAlerts)
      .set("openAlerts", summary.openAlerts)
      .set("criticalAlerts", summary.criticalAlerts)
      .set("totalPipelines", summary.totalPipelines)
      .set("activePipelines", summary.activePipelines)
      .set("totalChannels", summary.totalChannels);

    return successResponse("Overview retrieved successfully", 200, response);
  }

  mixin(HandleTemplate!("handleOverview", "overviewHandler"));
}
///
unittest {
  import uim.platform.service.tests;

  @safe class OverviewControllerTest : ControllerTestBase {
    void runTests() {
      auto logRepo = new MemoryLogEntryRepository();
      auto spanRepo = new MemorySpanRepository();
      auto streamRepo = new MemoryLogStreamRepository();
      auto dashboardRepo = new MemoryDashboardRepository();
      auto alertRepo = new MemoryAlertRepository();
      auto pipelineRepo = new MemoryPipelineRepository();
      auto channelRepo = new MemoryNotificationChannelRepository();

      auto usecase = new GetOverviewUseCase(
        logRepo,
        spanRepo,
        streamRepo,
        dashboardRepo,
        alertRepo,
        pipelineRepo,
        channelRepo
      );
      auto controller = new OverviewController(usecase);
      auto tenantId = TenantId("test-tenant");

      // Seed a log entry
      LogEntry log;
      log.tenantId = tenantId;
      logRepo.save(log);

      auto request = createMockRequest("GET", "/api/v1/overview", tenantId);
      auto response = controller.overviewHandler(request);

      assert(response.getString("status") == "success");
      assert(response["data"]["totalLogEntries"].get!int == 1);
    }
  }

  (new OverviewControllerTest).runTests();
}
