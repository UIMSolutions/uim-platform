/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of modeling and governance: views, data flows, data access
/// controls and the catalog.
module uim.platform.datasphere.ports.usecases.modeling;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

interface IManageViews : IManageResource!(DataView, DataViewId, ViewInput) {
  /// Check the sources and activate the view.
  DataView deploy(TenantId t, DataViewId id, UserId actor);
  /// Materialise the view now (logged as a view persistence run).
  TaskRun persist(TenantId t, DataViewId id, UserId actor);
  /// Drop the materialised copy.
  DataView removePersistence(TenantId t, DataViewId id, UserId actor);
  /// Would the user see the row? (row level security of the data access controls)
  AccessDecision checkAccess(TenantId t, DataViewId id, string user, Json row);
}

interface IManageDataFlows : IManageResource!(DataFlow, DataFlowId, DataFlowInput) {
  DataFlow deploy(TenantId t, DataFlowId id, UserId actor);
  /// Run now (logged as a data flow run).
  TaskRun run(TenantId t, DataFlowId id, UserId actor);
}

interface IManageAccessControls : IManageResource!(DataAccessControl, DataAccessControlId, AccessControlInput) {
}

interface IManageCatalog : IManageResource!(CatalogAsset, CatalogAssetId, CatalogAssetInput) {
  /// Assets matching the text, best first (spaceId "" = all spaces).
  CatalogAsset[] search(TenantId t, string text, SpaceId spaceId);
  /// Count a read of the asset.
  CatalogAsset recordAccess(TenantId t, CatalogAssetId id);
}
