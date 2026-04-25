# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Bold parsing now treats only double asterisks as bold (`**text**`); single-asterisk text (`*text*`) remains literal.
- Updated examples and tests to reflect the bold delimiter behavior in `README.md` and `test/telegex/marked_test.exs`.
- Refactored renderer/parser internals for readability and Credo compliance (alias ordering, no-arg defs, `Enum.map_join/3`, and non-match `if` conditions).
- Refreshed development dependency lock entries in `mix.lock`.

### Fixed

- Added explicit range steps in `LinkRule` (`..//1`) to avoid negative-range warnings on newer Elixir versions.
- Eliminated Credo parser/check noise by simplifying the `as_html/2` doctest in `lib/telegex/marked.ex`.

