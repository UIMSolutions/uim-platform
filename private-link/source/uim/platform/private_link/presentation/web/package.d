/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.presentation.web;

// Web presentation layer for Private Link Service (MVC pattern).
// Provides HTML views for:
//   - Dashboard: overview of all service instances and their statuses
//   - Instance view: details, endpoint status, bound applications
//   - Endpoint approval workflow: approve/reject incoming connection requests
//   - Binding management: view and delete application bindings
//
// Model  -> DTOs and use case results
// View   -> HTML templates (Diet templates via vibe.d)
// Controller -> HTTP GET/POST handlers serving rendered HTML pages
