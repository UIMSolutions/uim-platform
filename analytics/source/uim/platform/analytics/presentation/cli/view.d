module uim.platform.analytics.presentation.cli.view;

import std.array : appender;
import std.format : format;
import uim.platform.analytics.presentation.cli.model;

struct CliView {
  string renderAssetList(CliAssetListModel model) const {
    auto buffer = appender!string();
    buffer.put(format("Tenant: %s\n", model.tenantId));
    buffer.put(format("Assets: %s\n", model.count));
    foreach (name; model.assetNames) {
      buffer.put(" - " ~ name ~ "\n");
    }
    return buffer.data;
  }
}
