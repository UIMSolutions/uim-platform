/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.enumerations.integration;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// UI integration card type (sap.card manifest type).
enum CardType {
  list,
  table_,
  object_,
  analytical,
  timeline,
  calendar,
  adaptive,
  component,
}

/// Source of a workspace channel.
enum ChannelType {
  activity,
  notification,
  custom,
  external,
}

/// Lifecycle of a registered business app.
enum AppStatus {
  active,
  inactive,
  deprecated_,
}

/// Platforms an app supports.
enum AppPlatform {
  web,
  mobile,
  desktop,
}

/// Size of a widget on a workpage.
enum WidgetSize {
  small,
  medium,
  large,
  fullWidth,
}

/// Grid columns a widget occupies.
int columnsOf(WidgetSize s) pure nothrow {
  final switch (s) {
  case WidgetSize.small:
    return 1;
  case WidgetSize.medium:
    return 2;
  case WidgetSize.large:
    return 3;
  case WidgetSize.fullWidth:
    return 4;
  }
}

/// Protocol of an external content provider.
enum ProviderType {
  rest,
  odata,
  graphql,
  sapBtp,
  custom,
}

/// Connection state of an external content provider.
enum ProviderStatus {
  disconnected,
  connected,
  error,
}

/// Lifecycle of a shell plugin.
enum PluginStatus {
  inactive,
  active,
  error,
}

/// Extension points of the launchpad shell.
enum HookPoint {
  header,
  footer,
  sidebar,
  shellBar,
}

///
unittest {
  assert(WidgetSize.fullWidth.columnsOf == 4);
  assert(enumText(CardType.table_) == "table");
  assert(parseEnum!AppStatus("deprecated", AppStatus.active) == AppStatus.deprecated_);
}
