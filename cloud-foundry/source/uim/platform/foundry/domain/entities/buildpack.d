/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.buildpack;

// import uim.platform.foundry.domain.types;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// A buildpack — provides the runtime detection, compilation, and start
/// scripts for staging applications (e.g. Java, Node.js, Go, Python).
struct Buildpack {
  mixin TenantEntity!BuildpackId;
  
  string name; // e.g. "java_buildpack", "nodejs_buildpack"
  BuildpackType type_ = BuildpackType.system;
  int position = 0; // detection order priority
  string stack = "cflinuxfs4";
  string filename; // archive filename for custom buildpacks
  bool enabled = true;
  bool locked = false;

    Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("type", type_.to!string)
      .set("position", position)
      .set("stack", stack)
      .set("filename", filename)
      .set("enabled", enabled)
      .set("locked", locked);
  }

}
