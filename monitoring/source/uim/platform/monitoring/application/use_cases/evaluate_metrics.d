module uim.platform.xyz.application.usecases.evaluate_metrics;

import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.alert_rule;
import uim.platform.xyz.domain.entities.metric;
import uim.platform.xyz.domain.ports.alert_rule_repository;
import uim.platform.xyz.domain.ports.metric_repository;
import uim.platform.xyz.domain.services.threshold_evaluator;
import uim.platform.xyz.domain.types;

import uim.platform.xyz.application.usecases.manage_alerts;

/// Application service: evaluates metrics against alert rules and triggers alerts.
class EvaluateMetricsUseCase
{
    private AlertRuleRepository ruleRepo;
    private MetricRepository metricRepo;
    private ManageAlertsUseCase alertsUseCase;

    this(AlertRuleRepository ruleRepo, MetricRepository metricRepo, ManageAlertsUseCase alertsUseCase)
    {
        this.ruleRepo = ruleRepo;
        this.metricRepo = metricRepo;
        this.alertsUseCase = alertsUseCase;
    }

    /// Evaluate all enabled alert rules for a tenant. Returns number of alerts triggered.
    int evaluateAll(TenantId tenantId)
    {
        auto rules = ruleRepo.findEnabled(tenantId);
        int triggered = 0;

        foreach (ref rule; rules)
        {
            auto now = clockSeconds();
            auto windowStart = now - rule.evaluationPeriodSeconds;

            auto metrics = metricRepo.findInTimeRange(
                tenantId, rule.resourceId, rule.metricName, windowStart, now);

            if (metrics.length == 0)
                continue;

            auto avg = ThresholdEvaluator.computeAverage(metrics);
            auto result = ThresholdEvaluator.evaluate(avg, rule);

            if (result.breached)
            {
                alertsUseCase.triggerAlert(
                    tenantId, rule.id, rule.resourceId,
                    rule.name, rule.metricName,
                    result.currentValue, result.thresholdValue,
                    rule.operator_, result.severity, result.message);
                triggered++;
            }
        }

        return triggered;
    }

    /// Evaluate a single rule by ID. Returns whether an alert was triggered.
    bool evaluateRule(TenantId tenantId, AlertRuleId ruleId)
    {
        auto rule = ruleRepo.findById(ruleId);
        if (rule.id.length == 0 || !rule.isEnabled)
            return false;

        auto now = clockSeconds();
        auto windowStart = now - rule.evaluationPeriodSeconds;

        auto metrics = metricRepo.findInTimeRange(
            tenantId, rule.resourceId, rule.metricName, windowStart, now);

        if (metrics.length == 0)
            return false;

        auto avg = ThresholdEvaluator.computeAverage(metrics);
        auto result = ThresholdEvaluator.evaluate(avg, rule);

        if (result.breached)
        {
            alertsUseCase.triggerAlert(
                tenantId, rule.id, rule.resourceId,
                rule.name, rule.metricName,
                result.currentValue, result.thresholdValue,
                rule.operator_, result.severity, result.message);
            return true;
        }

        return false;
    }

    private static long clockSeconds()
    {
        import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }
}
