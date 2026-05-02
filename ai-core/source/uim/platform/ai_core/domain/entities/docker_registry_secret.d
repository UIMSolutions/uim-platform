/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.docker_registry_secret;

// import uim.platform.ai_core.domain.types;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
struct DockerRegistrySecret {
  mixin TenantEntity!(DockerRegistrySecretId);

  ResourceGroupId resourceGroupId;
  string name;
  string server;
  string username;

  Json toJson() const {
    return entityToJson
      .set("resourceGroupId", resourceGroupId)
      .set("name", name)
      .set("server", server)
      .set("username", username);
  }
}
