/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// All driving ports as one bundle (wired in the container).
module uim.platform.architecture.ports.usecases.driving;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct ArchitecturePorts {
  IManageBuildingBlocks blocks;
  IManageRelationships relationships;
  IAnalyzeArchitecture analysis;
  IExportArchitecture exporter;
  ISeedDemoData seeder;
}
