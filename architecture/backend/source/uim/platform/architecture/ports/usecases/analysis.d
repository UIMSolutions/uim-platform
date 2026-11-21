/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports: analysis, export and demo content.
module uim.platform.architecture.ports.usecases.analysis;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IAnalyzeArchitecture {
  ArchitectureStatistics statistics(TenantId t);
  /// ABBs without a realizing SBB.
  BuildingBlock[] gaps(TenantId t);
  BuildingBlock[] orphans(TenantId t);
  PhaseOutRisk[] phaseOutRisks(TenantId t);
  /// What is affected by a change of the block (404 if it does not exist).
  ImpactAnalysis impact(TenantId t, BuildingBlockId id);
}

interface IExportArchitecture {
  /// The repository as ArchiMate Model Exchange File (Open Group, XML).
  string exportArchiMate(TenantId t, string modelName = "");
}

interface ISeedDemoData {
  /// Create the demo landscape in an empty tenant (conflict otherwise).
  SeedResult seed(TenantId t, UserId actor);
}
