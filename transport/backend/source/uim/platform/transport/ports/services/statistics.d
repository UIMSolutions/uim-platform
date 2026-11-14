/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.services.statistics;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driving port: key figures for dashboards (Fiori KPI header, CLI, GUI).
interface ITransportStatisticsService {
  TransportStatistics statistics(TenantId tenantId);
}

/// Driving port: read model of the landscape topology.
interface ITransportLandscapeService {
  TransportLandscape landscape(TenantId tenantId);
}
