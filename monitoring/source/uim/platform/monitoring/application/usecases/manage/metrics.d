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
// 
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Application service for metric retrieval, push, and custom metric definitions.
class ManageMetricsUseCase { // TODO: UIMUseCase {
  private MetricRepository metricRepo;
  private MetricDefinitionRepository definitions;

  this(MetricRepository metricRepo, MetricDefinitionRepository definitions) {
    this.metricRepo = metricRepo;
    this.definitions = definitions;
  }

  // --- Metric Definitions ---

  CommandResult createDefinition(CreateMetricDefinitionRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Metric name is required");

    if (definitions.existsByName(req.tenantId, req.name))
      return CommandResult(false, "", "Metric definition '" ~ req.name ~ "' already exists");

    MetricDefinition definition;
    definition.initEntity(req.tenantId, req.createdBy);

    definition.name = req.name;
    definition.displayName = req.displayName.length > 0 ? req.displayName : req.name;
    definition.description = req.description;
    definition.category = toMetricCategory(req.category);
    definition.unit = toMetricUnit(req.unit);
    definition.aggregation = toAggregationMethod(req.aggregation);
    definition.isCustom = true;
    definition.isEnabled = true;

    definitions.save(definition);
    return CommandResult(true, definition.id.value, "");
  }

  CommandResult updateDefinition(UpdateMetricDefinitionRequest req) {
    auto def = definitions.findById(req.tenantId, req.id);
    if (def.isNull)
      return CommandResult(false, "", "Metric definition not found");

    if (req.displayName.length > 0)
      def.displayName = req.displayName;
    if (req.description.length > 0)
      def.description = req.description;
    if (req.aggregation.length > 0)
      def.aggregation = toAggregationMethod(req.aggregation);
    def.isEnabled = req.isEnabled;

    definitions.update(def);
    return CommandResult(true, def.id.value, "");
  }

  MetricDefinition getDefinition(TenantId tenantId, MetricDefinitionId id) {
    return definitions.findById(tenantId, id);
  }

  MetricDefinition[] listDefinitions(TenantId tenantId) {
    return definitions.findByTenant(tenantId);
  }

  CommandResult deleteMetricDefinition(TenantId tenantId, MetricDefinitionId id) {
    auto definition = definitions.findById(tenantId, id);
    if (definition.isNull)
      return CommandResult(false, "", "Metric definition not found");

    definitions.remove(definition);
    return CommandResult(true, definition.id.value, "");
  }

  // --- Metric Data Points ---
  CommandResult pushMetric(PushMetricRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Metric name is required");

    if (req.resourceId.isEmpty)
      return CommandResult(false, "", "Resource ID is required");

    Metric m;
    m.initEntity(req.tenantId);

    m.resourceId = req.resourceId;
    m.name = req.name;
    m.value_ = req.value_;
    m.unit = toMetricUnit(req.unit);
    m.category = toMetricCategory(req.category);
    m.labels = req.labels;
    m.timestamp = m.createdAt; // use server time for consistency

    metricRepo.save(m);
    return CommandResult(true, m.id.value, "");
  }

  CommandResult pushMetricBatch(PushMetricBatchRequest req) {
    Metric[] metrics;
    foreach (r; req.metrics) {
      Metric m;
      m.initEntity(req.tenantId);

      m.resourceId = r.resourceId;
      m.name = r.name;
      m.value_ = r.value_;
      m.unit = toMetricUnit(r.unit);
      m.category = toMetricCategory(r.category);
      m.labels = r.labels;
      m.timestamp = clockSeconds();
      metrics ~= m;
    }

    metricRepo.saveAll(metrics);
    return CommandResult(true, "", "");
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
      return metricRepo.findByTenant(req.tenantId).filter!(m => m.name == req.metricName).array;
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
}
