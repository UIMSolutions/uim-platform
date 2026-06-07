/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.application.usecases.manage.evaluations;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

class EvaluateFlagsUseCase {
    private FeatureFlagRepository repo;
    private FlagEvaluator         evaluator;

    this(FeatureFlagRepository repo) {
        this.repo      = repo;
        this.evaluator = new FlagEvaluator();
    }

    /// Evaluate a single named flag.
    EvaluationResult evaluate(EvaluationRequest req) {
        auto ctx = EvaluationContext(req.tenantId, req.userId, req.attributes);
        auto flag_ = repo.findByName(req.tenantId, ServiceInstanceId(req.instanceId), req.flagName);
        return evaluator.evaluate(flag_, ctx);
    }

    /// Evaluate all flags in an instance (bulk SDK call).
    EvaluationResult[] evaluateAll(BulkEvaluationRequest req) {
        auto ctx   = EvaluationContext(req.tenantId, req.userId, req.attributes);
        auto flags = repo.findByInstance(req.tenantId, ServiceInstanceId(req.instanceId));
        EvaluationResult[] results;
        foreach (flag_; flags)
            results ~= evaluator.evaluate(flag_, ctx);
        return results;
    }
}
