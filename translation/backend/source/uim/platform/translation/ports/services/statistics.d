/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.ports.services.statistics;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Aggregated figures of a tenant (KPI header, overview tiles, `stats` command).
interface ITranslationStatisticsService {
  TranslationStatistics statistics(TenantId tenantId);
}
