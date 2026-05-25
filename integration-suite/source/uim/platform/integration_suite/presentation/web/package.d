module uim.platform.integration_suite.presentation.web;

/**
 * Web Presentation Layer — Model-View-Controller pattern (vibe.d Diet templates)
 *
 * Model      : Application use cases providing data to views.
 * View       : Diet HTML templates rendered server-side (views/*.dt).
 * Controller : WebController classes handling HTTP GET/POST for browser-facing UIs.
 *
 * Planned routes (browser UI):
 *   GET  /ui/packages              — list integration packages
 *   GET  /ui/packages/:id          — package detail + flows
 *   GET  /ui/flows                 — list integration flows
 *   GET  /ui/flows/:id             — flow detail + deployment status
 *   GET  /ui/apimanagement         — API Management overview
 *   GET  /ui/apimanagement/proxies — API Proxy list
 *   GET  /ui/eventmesh             — Event Mesh overview
 *   GET  /ui/b2b/partners          — B2B Trading Partner list
 */
