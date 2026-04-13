/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.manage.metrics;

// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.metric;
// import uim.platform.monitoring.domain.entities.metric_definition;
// import uim.platform.monitoring.domain.ports.repositories.metrics;
// import uim.platform.monitoring.domain.ports.repositories.metric_definitions;
// import uim.platform.monitoring.domain.types;

// // import std.conv : to;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Application service for metric retrieval, push, and custom metric definitions.
class ManageMetricsUseCase : UIMUseCase {
  private MetricRepository metricRepo;
  private MetricDefinitionRepository definitionRepo;

  this(MetricRepository metricRepo, MetricDefinitionRepository definitionRepo) {
    this.metricRepo = metricRepo;
    this.definitionRepo = definitionRepo;
  }

  // --- Metric Definitions ---

  CommandResult createDefinition(CreateMetricDefinitionRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Metric name is required");

    if (definitionRepo.existsByName(req.tenantId, req.name))
      return CommandResult(false, "", "Metric definition '" ~ req.name ~ "' already exists");

    MetricDefinition definition;
    definition.id = randomUUID();
    definition.tenantId = req.tenantId;
    definition.name = req.name;
    definition.displayName = req.displayName.length > 0 ? req.displayName : req.name;
    definition.description = req.description;
    definition.category = parseCategory(req.category);
    definition.unit = parseUnit(req.unit);
    definition.aggregation = parseAggregation(req.aggregation);
    definition.isCustom = true;
    definition.isEnabled = true;
    definition.createdBy = req.createdBy;
    definition.createdAt = clockSeconds();

    definitionRepo.save(definition);
    return CommandResult(true, definition.id.toString, "");
  }

  CommandResult updateDefinition(MetricDefinitionId id, UpdateMetricDefinitionRequest req) {
    if (!definitionRepo.existsById(id))
      return CommandResult(false, "", "Metric definition not found");

    auto def = definitionRepo.findById(id);
    if (req.displayName.length > 0)
      def.displayName = req.displayName;
    if (req.description.length > 0)
      def.description = req.description;
    if (req.aggregation.length > 0)
      def.aggregation = parseAggregation(req.aggregation);
    def.isEnabled = req.isEnabled;

    definitionRepo.update(def);
    return CommandResult(true, id.toString(), "");
  }

  MetricDefinition getDefinition(MetricDefinitionId id) {
    return definitionRepo.findById(id);
  }

  MetricDefinition[] listDefinitions(TenantId tenantId) {
    return definitionRepo.findByTenant(tenantId);
  }

  CommandResult removeDefinition(MetricDefinitionId id) {
    if (!definitionRepo.existsById(id))
      return CommandResult(false, "", "Metric definition not found");

    definitionRepo.remove(id);
    return CommandResult(true, id.toString(), "");
  }

  // --- Metric Data Points ---

  CommandResult pushMetric(PushMetricRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Metric name is required");

    if (req.resourceId.isEmpty)
      return CommandResult(false, "", "Resource ID is required");

    Metric m;
    m.id = randomUUID();
    m.tenantId = req.tenantId;
    m.resourceId = req.resourceId;
    m.name = req.name;
    m.value_ = req.value_;
    m.unit = parseUnit(req.unit);
    m.category = parseCategory(req.category);
    m.labels = req.labels;
    m.timestamp = clockSeconds();

    metricRepo.save(m);
    return CommandResult(true, m.id.toString(), "");
  }

  CommandResult pushMetricBatch(PushMetricBatchRequest req) {
    Metric[] metrics;
    foreach (r; req.metrics) {
      // import std.uuid : randomUUID;
      Metric m;
      m.id = randomUUID();
      m.tenantId = req.tenantId;
      m.resourceId = r.resourceId;
      m.name = r.name;
      m.value_ = r.value_;
      m.unit = parseUnit(r.unit);
      m.category = parseCategory(r.category);
      m.labels = r.labels;
      m.timestamp = clockSeconds();
      metrics ~= m;
    }

    metricRepo.saveAll(metrics);
    return CommandResult(true, "", "");
  }

  Metric[] getMetrics(string tenantId, string resourceId) {
    return getMetrics(TenantId(tenantId), MonitoredResourceId(resourceId));
  }

  Metric[] getMetrics(TenantId tenantId, MonitoredResourceId resourceId) {
    return metricRepo.findByResource(tenantId, resourceId);
  }

  Metric[] queryMetrics(QueryMetricsRequest req) {
    if (req.startTime > 0 && req.endTime > 0)
      return metricRepo.findInTimeRange(req.tenantId, req.resourceId,
        req.metricName, req.startTime, req.endTime);
    if (req.metricName.length > 0 && req.resourceId.value.length > 0)
      return metricRepo.findByResourceAndName(req.tenantId, req.resourceId, req.metricName);
    if (req.metricName.length > 0)
      return metricRepo.findByName(req.tenantId, req.metricName);
    return metricRepo.findByResource(req.tenantId, req.resourceId);
  }

  MetricSummary computeSummary(TenantId tenantId, MonitoredResourceId resourceId,
    string metricName, long startTime, long endTime) {
    auto metrics = metricRepo.findInTimeRange(tenantId, resourceId,
      metricName, startTime, endTime);
    MetricSummary s;
    s.name = metricName;
    s.resourceId = resourceId;
    s.windowStartTime = startTime;
    s.windowEndTime = endTime;
    s.dataPointCount = metrics.length;

    if (metrics.length == 0)
      return s;

    s.minValue = metrics[0].value_;
    s.maxValue = metrics[0].value_;
    double sum = 0;
    foreach (m; metrics) {
      if (m.value_ < s.minValue)
        s.minValue = m.value_;
      if (m.value_ > s.maxValue)
        s.maxValue = m.value_;
      sum += m.value_;
    }
    s.sumValue = sum;
    s.avgValue = sum / cast(double)metrics.length;
    return s;
  }

  private static MetricCategory parseCategory(string s) {
    switch (s) {
    case "cpu":
      return MetricCategory.cpu;
    case "memory":
      return MetricCategory.memory;
    case "disk":
      return MetricCategory.disk;
    case "network":
      return MetricCategory.network;
    case "requests":
      return MetricCategory.requests;
    case "responseTime":
      return MetricCategory.responseTime;
    case "availability":
      return MetricCategory.availability;
    case "jmx":
      return MetricCategory.jmx;
    case "database":
      return MetricCategory.database;
    case "certificate":
      return MetricCategory.certificate;
    default:
      return MetricCategory.custom;
    }
  }

  private static MetricUnit parseUnit(string unit) {
    switch (unit) {
    case "percent":
      return MetricUnit.percent;
    case "bytes":
      return MetricUnit.bytes_;
    case "kilobytes":
      return MetricUnit.kilobytes;
    case "megabytes":
      return MetricUnit.megabytes;
    case "gigabytes":
      return MetricUnit.gigabytes;
    case "milliseconds":
      return MetricUnit.milliseconds;
    case "seconds":
      return MetricUnit.seconds;
    case "count":
      return MetricUnit.count;
    case "countPerSecond":
      return MetricUnit.countPerSecond;
    case "boolean":
      return MetricUnit.boolean_;
    default:
      return MetricUnit.none;
    }
  }

  private static AggregationMethod parseAggregation(string method) {
    switch (method) {
    case "sum":
      return AggregationMethod.sum;
    case "min":
      return AggregationMethod.min;
    case "max":
      return AggregationMethod.max;
    case "last":
      return AggregationMethod.last;
    case "count":
      return AggregationMethod.count;
    default:
      return AggregationMethod.average;
    }
  }
}
