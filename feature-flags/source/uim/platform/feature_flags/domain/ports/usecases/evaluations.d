/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.ports.usecases.evaluations;

import uim.platform.feature_flags;

mixin(ShowModule!());

@safe:

interface IEvaluateFlagsUseCase {

    /// Evaluate a single named flag.
    EvaluationResult evaluate(EvaluationRequest req);

    /// Evaluate all flags in an instance (bulk SDK call).
    EvaluationResult[] evaluateAll(BulkEvaluationRequest req);

}
