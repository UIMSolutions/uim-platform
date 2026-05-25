module uim.platform.integration_suite.presentation.cli;

/**
 * CLI Presentation Layer — Model-View-Controller pattern
 *
 * Model   : Uses application use cases / domain entities directly.
 * View    : Terminal output formatting (tables, JSON, progress indicators).
 * Controller: CLI command dispatcher — parses argv and delegates to use cases.
 *
 * Entry point: `uim-integration-suite-platform-service --cli <command> [options]`
 *
 * Planned commands:
 *   packages list|get|create|update|delete
 *   flows    list|get|create|update|delete|deploy
 *   proxies  list|get|create|update|delete|publish
 *   products list|get|create|update|delete|publish
 *   queues   list|get|create|update|delete
 *   subs     list|get|create|update|delete
 *   partners list|get|create|update|delete
 *   mappings list|get|create|update|delete
 *   users    list|get
 *   health
 */
