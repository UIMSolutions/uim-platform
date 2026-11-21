/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the administration API (resource groups, secrets).
module uim.platform.ai_core.ports.usecases.administration;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

interface IManageResourceGroups {
  ResourceGroup createResourceGroup(CreateResourceGroupRequest r);
  ResourceGroup updateResourceGroup(UpdateResourceGroupRequest r);
  ResourceGroup getResourceGroup(TenantId t, ResourceGroupId id);
  ResourceGroup[] listResourceGroups(TenantId t);
  /// Deletes the group and everything in it; refused while executions or
  /// deployments are active. Returns the number of removed child resources.
  size_t deleteResourceGroup(TenantId t, ResourceGroupId id);
  /// Throws notFound / ruleViolation unless the group exists and is provisioned.
  ResourceGroup requireUsableGroup(TenantId t, ResourceGroupId id);
}

interface IManageSecrets {
  DockerRegistrySecret createDockerRegistrySecret(CreateDockerRegistrySecretRequest r);
  DockerRegistrySecret updateDockerRegistrySecret(UpdateDockerRegistrySecretRequest r);
  DockerRegistrySecret getDockerRegistrySecret(TenantId t, DockerRegistrySecretId id);
  DockerRegistrySecret[] listDockerRegistrySecrets(TenantId t);
  void deleteDockerRegistrySecret(TenantId t, DockerRegistrySecretId id);

  ObjectStoreSecret createObjectStoreSecret(CreateObjectStoreSecretRequest r);
  ObjectStoreSecret updateObjectStoreSecret(UpdateObjectStoreSecretRequest r);
  ObjectStoreSecret getObjectStoreSecret(TenantId t, ResourceGroupId rg, ObjectStoreSecretId id);
  /// rg empty = all groups
  ObjectStoreSecret[] listObjectStoreSecrets(TenantId t, ResourceGroupId rg);
  void deleteObjectStoreSecret(TenantId t, ResourceGroupId rg, ObjectStoreSecretId id);
}
