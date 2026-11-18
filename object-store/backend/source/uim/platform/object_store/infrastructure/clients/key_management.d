/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.clients.key_management;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Offline key management client: checks the key reference format of each
/// hyperscaler instead of calling the KMS. Replace with an HTTP client of
/// AWS KMS / Azure Key Vault / Google Cloud KMS for production use.
///
///   aws      arn:aws:kms:<region>:<account>:key/<id>  or  alias/<name>
///   azure    https://<vault>.vault.azure.net/keys/<name>[/<version>]
///   gcp      projects/<p>/locations/<l>/keyRings/<r>/cryptoKeys/<k>
///   alibaba  acs:kms:<region>:<account>:key/<id>  or  alias/<name>
class SimulatedKeyManagementClient : IKeyManagementGateway {
  string checkKey(TenantId tenantId, IaasProvider provider, string keyId) {
    auto k = keyId.strip;
    final switch (provider) {
    case IaasProvider.aws:
      return (k.startsWith("arn:aws:kms:") && k.canFind(":key/")) || k.startsWith("alias/") ? ""
        : "AWS KMS keys are referenced as arn:aws:kms:<region>:<account>:key/<id> or alias/<name>";
    case IaasProvider.azure:
      return k.startsWith("https://") && k.canFind(".vault.azure.net/keys/") ? ""
        : "Azure Key Vault keys are referenced as https://<vault>.vault.azure.net/keys/<name>";
    case IaasProvider.gcp:
      return k.startsWith("projects/") && k.canFind("/keyRings/") && k.canFind("/cryptoKeys/") ? ""
        : "Cloud KMS keys are referenced as projects/<p>/locations/<l>/keyRings/<r>/cryptoKeys/<k>";
    case IaasProvider.alibaba:
      return (k.startsWith("acs:kms:") && k.canFind(":key/")) || k.startsWith("alias/") ? ""
        : "Alibaba KMS keys are referenced as acs:kms:<region>:<account>:key/<id> or alias/<name>";
    }
  }
}

///
unittest {
  auto kms = new SimulatedKeyManagementClient();
  auto t = TenantId("t");
  assert(kms.checkKey(t, IaasProvider.aws, "arn:aws:kms:eu-central-1:123456789012:key/abcd") == "");
  assert(kms.checkKey(t, IaasProvider.aws, "alias/objects") == "");
  assert(kms.checkKey(t, IaasProvider.aws, "my-key").length > 0);
  assert(kms.checkKey(t, IaasProvider.azure, "https://v1.vault.azure.net/keys/k1") == "");
  assert(kms.checkKey(t, IaasProvider.gcp, "projects/p/locations/l/keyRings/r/cryptoKeys/k") == "");
}
