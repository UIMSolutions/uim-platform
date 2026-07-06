/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.values.types;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:

/// Strongly-typed identifier for a Dashboard aggregate root.
mixin(IdTemplate!"Dashboard");

/// Strongly-typed identifier for a Page within a Dashboard.
mixin(IdTemplate!"Page");

/// Strongly-typed identifier for a Story aggregate root.
mixin(IdTemplate!"Story");

/// Strongly-typed identifier for a Section within a Story.
mixin(IdTemplate!"Section");

/// Strongly-typed identifier for a Widget aggregate root.
mixin(IdTemplate!"Widget");

/// Strongly-typed identifier for a DataSource aggregate root.
mixin(IdTemplate!"DataSource");

/// Strongly-typed identifier for a Dataset aggregate root.
mixin(IdTemplate!"Dataset");

/// Strongly-typed identifier for a PlanningModel aggregate root.
mixin(IdTemplate!"PlanningModel");

/// Strongly-typed identifier for a Prediction aggregate root.
mixin(IdTemplate!"Prediction");

/// Strongly-typed identifier for a resource group (SAP BTP resource group concept).
mixin(IdTemplate!"ResourceGroup");
