/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Design-time life cycle of views and data flows, and the disk usage of a
/// space derived from its objects.
module uim.platform.datasphere.domain.services.lifecycle;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// The deployment status after a design-time change.
DeploymentStatus afterChange(DeploymentStatus current) pure {
  return current == DeploymentStatus.deployed ? DeploymentStatus.changesToDeploy : current;
}

/// Disk used by the objects of a space: replicas, persisted views and data
/// flow targets.
long diskUsage(const RemoteTable[] tables, const DataView[] views, const DataFlow[] flows) {
  long used;
  foreach (ref t; tables)
    if (t.holdsData)
      used += t.sizeBytes;
  foreach (ref v; views)
    if (v.persisted)
      used += v.persistedBytes;
  foreach (ref f; flows)
    used += f.targetBytes;
  return used;
}

///
unittest {
  assert(afterChange(DeploymentStatus.deployed) == DeploymentStatus.changesToDeploy);
  assert(afterChange(DeploymentStatus.notDeployed) == DeploymentStatus.notDeployed);
  RemoteTable t;
  t.replicationStatus = ReplicationStatus.replicated;
  t.sizeBytes = 100;
  RemoteTable federated;
  federated.sizeBytes = 999;
  DataView v;
  v.persisted = true;
  v.persistedBytes = 20;
  DataFlow f;
  f.targetBytes = 3;
  assert(diskUsage([t, federated], [v], [f]) == 123);
}
