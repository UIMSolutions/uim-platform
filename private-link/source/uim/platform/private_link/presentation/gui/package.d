/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.presentation.gui;

// GUI presentation layer for Private Link Service (MVC pattern).
// Desktop or web-component based interface for:
//   - Visual topology: show BTP <-> IaaS private link topology
//   - Status dashboard: real-time endpoint/instance status indicators
//   - Approval workflow: one-click approve/reject private endpoint requests
//   - Binding explorer: view hostname and IP credentials per bound application
//
// Model  -> use cases and domain entities
// View   -> reactive component tree (e.g. GTK-D, WebComponents, or similar)
// Controller -> event handlers wiring view interactions to use cases
