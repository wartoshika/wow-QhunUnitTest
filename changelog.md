# QhunUnitTest - Changelog

I use [Semantic Versioning](https://semver.org/) for version numbers (MAJOR, MINOR, PATCH).

**TL; DR:** PATCH and MINOR changes are allways compatible. MAJOR releases can beak the existing API!

Every PATCH version contains Bugfixes or general stuff like refactoring or comment changes. Every MINOR version contains features that are always backwards compatible. Every MAJOR version contains API changes, features that are not backwards compatible.

## 1.1.0
- [Feature] `QhunUnitTest.Base.new()` has a new constructor parameter for specifying the order of test methods.

## 1.0.1
- [Bugfix] `assertTableSimilar` does not increase the assert count.
- [Bugfix] `QhunUnitTest.Base:assertError` throws error if no arguments given.
- [Bugfix] `QhunUnitTest.Wrapper:__index` throw error when calling `__unittest_getMethodCallAmount` without existing calls stored in `_calledFunctions`
- [General] Added tests for `base.lua`, `suite.lua` and `wrapper.lua`

## 1.0.0 Release
- Lots of features added to the first public release!