/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.enumerations.node;

@safe:

/// Runtime environment of a transport node.
enum NodeType {
  cloudFoundry,
  abap,
  neo,
  kyma,
  other
}

/// Operational status of a transport node.
enum NodeStatus {
  enabled,
  disabled
}
