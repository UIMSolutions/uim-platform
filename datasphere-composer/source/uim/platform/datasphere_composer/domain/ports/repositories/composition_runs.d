/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.ports.repositories.composition_runs;

import uim.platform.datasphere_composer;

@safe:
interface CompositionRunRepository : ITentRepository!(CompositionRun, CompositionRunId) {
  CompositionRun[] findByStatus(TenantId tenantId, CompositionRunStatus status);
  CompositionRun[] findRecent(TenantId tenantId, int limit);
}
