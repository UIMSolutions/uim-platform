/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.housekeeping;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Use case: time driven transitions of a tenant (run by the background worker,
/// the CLI "housekeeping" command, the GUI and the OData action "RunHousekeeping").
class HousekeepingUseCase : IHousekeepingUseCase {
  protected WorkzoneRepositories repos;
  protected IContentProviderGateway gateway;
  protected IWorkzoneEventPublisher publisher;
  protected long delegate() @safe clock;

  this(WorkzoneRepositories repos, IContentProviderGateway gateway, IWorkzoneEventPublisher publisher,
      long delegate() @safe clock = null) {
    this.repos = repos;
    this.gateway = gateway;
    this.publisher = publisher;
    this.clock = clock is null ? () => nowStdTime() : clock;
  }

  HousekeepingReport run(TenantId tenantId) {
    HousekeepingReport report;
    report.tenantId = tenantId;
    auto now = clock();

    void changed(string text) {
      report.changed++;
      report.changes ~= text;
    }

    foreach (t; repos.tasks.findByTenant(tenantId)) {
      report.examined++;
      if (isOverdue(t, now)) {
        t.status = TaskStatus.overdue;
        repos.tasks.update(t);
        changed("task '" ~ t.title ~ "' is overdue");
      }
    }
    foreach (e; repos.events.findByTenant(tenantId)) {
      report.examined++;
      auto next = eventStatusAt(e, now);
      if (next != e.status) {
        e.status = next;
        repos.events.update(e);
        changed("event '" ~ e.title ~ "' is " ~ enumText(next));
      }
    }
    foreach (s; repos.surveys.findByTenant(tenantId)) {
      report.examined++;
      if (isExpired(s, now)) {
        s.status = SurveyStatus.closed;
        repos.surveys.update(s);
        changed("survey '" ~ s.title ~ "' closed (end date reached)");
      }
    }
    foreach (n; repos.notifications.findByTenant(tenantId)) {
      report.examined++;
      if (isExpired(n, now)) {
        n.status = NotificationStatus.dismissed;
        repos.notifications.update(n);
        changed("notification '" ~ n.title ~ "' expired");
      }
    }
    foreach (p; repos.contentProviders.findByTenant(tenantId)) {
      report.examined++;
      if (isDueForSync(p, now)) {
        applySync(p, gateway.sync(p), now);
        repos.contentProviders.update(p);
        changed("content provider '" ~ p.name ~ "' " ~ (p.status == ProviderStatus.error
            ? "failed: " ~ p.statusMessage : "synchronised (" ~ p.itemCount.to!string ~ " items)"));
      }
    }

    if (report.changed > 0) {
      auto payload = Json.emptyObject;
      payload["tenantId"] = tenantId.value;
      payload["changed"] = report.changed;
      publisher.publish("workzone.housekeeping.completed", payload);
    }
    return report;
  }
}
