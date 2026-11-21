/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Interactor: statistics, gap, orphan, phase-out and impact analysis.
module uim.platform.architecture.application.usecases.analyze;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class AnalyzeArchitectureUseCase : ArchitectureInteractor, IAnalyzeArchitecture {
  this(ArchitectureRepositories repos, IClock clock) {
    super(repos, clock, null);
  }

  ArchitectureStatistics statistics(TenantId t) {
    requireTenant(t);
    return computeStatistics(repos.blocks.findAll(t), repos.relationships.findAll(t), clock.now);
  }

  BuildingBlock[] gaps(TenantId t) {
    requireTenant(t);
    return findGaps(repos.blocks.findAll(t), repos.relationships.findAll(t));
  }

  BuildingBlock[] orphans(TenantId t) {
    requireTenant(t);
    return findOrphans(repos.blocks.findAll(t), repos.relationships.findAll(t));
  }

  PhaseOutRisk[] phaseOutRisks(TenantId t) {
    requireTenant(t);
    return findPhaseOutRisks(repos.blocks.findAll(t), repos.relationships.findAll(t));
  }

  ImpactAnalysis impact(TenantId t, BuildingBlockId id) {
    requireTenant(t);
    loadBlock(t, id);
    return analyzeImpact(id, repos.blocks.findAll(t), repos.relationships.findAll(t));
  }
}
