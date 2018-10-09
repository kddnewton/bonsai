# Grow a bonsai, not a shrub

Scaling a codebase with coherence and structure.

## `ext`

Various examples of extracting logical patterns, including:

* `Ext::ArelTables` - generate functions that access arel tables
* `Ext::DelegateScope` - delegate scopes to associated classes
* `Ext::Factory` - extract functionality into helper objects
* `Ext::Query` - generate scopes from query objects
* `Ext::StripAttributes` - automatically strip attributes before they hit the DB
* `Ext::TouchAll` - bust associated caches downward instead of just upward

## `reflection`

Reflection tests enforcing certain code style, including:

* `AssociationsTest` - enforce various things about associations, including having a specified `inverse_of` or an automatic one, having the expected columns, and not overriding association methods
* `ControllerActionsTest` - enforce only having the expected controller action names within your app's controllers
* `DefTest` - enforce not having method definitions in model files
* `UpgradeTest` - refuse to pass the build if the version is upgraded and the code that depends on a specific version is not checked

## `support`

Tools for trimming your application code, including:

* `MacroTracking` - hook into `delegate` and `scope` to make sure that they don't go stale -- reports out at the end of the test suite which were called and which weren't

