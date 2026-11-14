/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.persistence.storages.json_file;

import std.file : exists, mkdirRecurse, readText, rename, timeLastModified, write;
import std.path : buildPath;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Snapshot storage that keeps one JSON file per collection in a data directory:
/// <dataDir>/<collection>.json. Writes go to a temp file first and are renamed
/// atomically, so readers in other processes (CLI, GUI, server) never see half a file.
class JsonFileSnapshotStorage : ISnapshotStorage {
  protected string _dataDir;

  this(string dataDir) {
    _dataDir = dataDir;
    if (!_dataDir.exists)
      (() @trusted => mkdirRecurse(_dataDir))();
  }

  string dataDir() const {
    return _dataDir;
  }

  string pathOf(string collection) const {
    return buildPath(_dataDir, collection ~ ".json");
  }

  Json load(string collection) {
    auto path = pathOf(collection);
    if (!path.exists)
      return Json.emptyArray;
    try {
      auto text = (() @trusted => readText(path))();
      return text.length == 0 ? Json.emptyArray : parseJsonString(text);
    } catch (Exception e) {
      logError("connectivity: cannot read snapshot %s: %s", path, e.msg);
      return Json.emptyArray;
    }
  }

  void store(string collection, Json snapshot) {
    auto path = pathOf(collection);
    auto tmp = path ~ ".tmp";
    () @trusted {
      write(tmp, snapshot.toPrettyString);
      rename(tmp, path);
    }();
  }

  long revision(string collection) {
    auto path = pathOf(collection);
    if (!path.exists)
      return 0;
    return (() @trusted => timeLastModified(path).stdTime)();
  }
}
