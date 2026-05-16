/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.application.usecases.manage.custom_metrics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class ManageCustomMetricsUseCase {
  private CustomMetricRepository repo;

  this(CustomMetricRepository repo) {
    this.repo = repo;
  }

  CommandResult submit(SubmitCustomMetricRequest r) {
    import core.time : MonoTime;
    import std.conv : to;
    import std.random : uniform;

    if (r.metricName.length == 0)
      return CommandResult(false, "", "metricName is required");
    if (r.appId.length == 0)
      return CommandResult(false, "", "appId is required");

    auto id  = "cm-" ~ currentTimestamp.to!string ~ "-" ~ uniform(1000, 9999).to!string;
    auto now = r.timestamp > 0 ? r.timestamp : currentTimestamp;

    CustomMetricEntity m;
    m.id         = id;
    m.appId      = r.appId;
    m.metricName = r.metricName;
    m.value      = r.value;
    m.unit       = r.unit;
    m.timestamp  = now;

    repo.save(m);
    return CommandResult(true, id, "");
  }

  CustomMetricEntity[] getMetrics(AppBindingId appId, string metricName = "") {
    if (metricName.length > 0)
      return repo.findByAppIdAndName(appId, metricName);
    return repo.findByAppId(appId);
  }

  /// Latest value for a named custom metric (used by scaling engine)
  double latestValue(AppBindingId appId, string metricName) @safe {
    auto entries = repo.findByAppIdAndName(appId, metricName);
    if (entries.length == 0) return 0.0;
    // Return most recent
    auto latest = entries[0];
    foreach (e; entries[1..$])
      if (e.timestamp > latest.timestamp) latest = e;
    return latest.value;
  }
}
