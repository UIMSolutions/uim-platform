/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.ports.gateways.key_management;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Driven port: the key management service of the hyperscaler (AWS KMS,
/// Azure Key Vault, Google Cloud KMS) that holds customer managed keys.
interface IKeyManagementGateway {
  /// "" if the key can be used for buckets of `provider`, else the reason.
  string checkKey(TenantId tenantId, IaasProvider provider, string keyId);
}
