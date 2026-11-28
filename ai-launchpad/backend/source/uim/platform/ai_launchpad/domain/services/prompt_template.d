/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Prompt templates: {{name}} placeholders (names of [A-Za-z0-9_]),
/// extraction, validation and rendering.
module uim.platform.ai_launchpad.domain.services.prompt_template;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

private bool isNameChar(dchar c) pure {
  return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_';
}

/// The distinct placeholder names, in order of appearance.
string[] placeholders(string text) pure {
  string[] names;
  size_t i;
  while (i + 1 < text.length) {
    auto open = text[i .. $].indexOf("{{");
    if (open < 0)
      break;
    auto start = i + open + 2;
    auto close = text[start .. $].indexOf("}}");
    if (close < 0)
      break;
    auto name = text[start .. start + close].strip;
    if (name.length && name.all!isNameChar && !names.canFind(name))
      names ~= name;
    i = start + close + 2;
  }
  return names;
}

/// Unbalanced or malformed placeholders are refused ("{{ }}", "{{a-b}}").
void requirePlaceholders(string text) {
  size_t i;
  while (i < text.length) {
    auto open = text[i .. $].indexOf("{{");
    if (open < 0)
      return;
    auto start = i + open + 2;
    auto close = text[start .. $].indexOf("}}");
    if (close < 0)
      throw AilpException.invalid("Unclosed placeholder '{{' in the prompt template");
    auto name = text[start .. start + close].strip;
    if (name.length == 0 || !name.all!isNameChar)
      throw AilpException.invalid("Invalid placeholder '{{" ~ text[start .. start + close]
          ~ "}}' (letters, digits and '_' only)");
    i = start + close + 2;
  }
}

/// Replace the placeholders by the inputs; every placeholder needs a value.
string renderTemplate(string text, const string[string] inputs) {
  foreach (name; placeholders(text))
    if (name !in inputs)
      throw AilpException.invalid("Input '" ~ name ~ "' is required");
  string result;
  size_t i;
  while (i < text.length) {
    auto open = text[i .. $].indexOf("{{");
    if (open < 0) {
      result ~= text[i .. $];
      break;
    }
    auto start = i + open + 2;
    auto close = text[start .. $].indexOf("}}");
    if (close < 0) {
      result ~= text[i .. $];
      break;
    }
    result ~= text[i .. i + open];
    auto name = text[start .. start + close].strip;
    auto v = name in inputs;
    result ~= v ? *v : text[i + open .. start + close + 2];
    i = start + close + 2;
  }
  return result;
}

///
unittest {
  assert(placeholders("Hi {{ name }}, {{name}} in {{lang}}") == ["name", "lang"]);
  assert(renderTemplate("Hi {{name}} ({{lang}})", ["name": "Ada", "lang": "en"]) == "Hi Ada (en)");
  assert(failsWith(AilpErrorKind.invalid, () { renderTemplate("{{x}}", null); }));
  assert(failsWith(AilpErrorKind.invalid, () { requirePlaceholders("{{a-b}}"); }));
  assert(failsWith(AilpErrorKind.invalid, () { requirePlaceholders("text {{open"); }));
  requirePlaceholders("plain text, {single} braces");
}
