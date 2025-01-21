`nix-build` action
==================

This `nix-build` action is an opinionated all-inclusive action that will

 - Checkout your code
 - Install a Nix language interpreter and daemon
 - Setup artifacts caching
 - Automatically run `nix-build` with *heuristics* applied

* * *

Usage
-----

Here's a simple sample to get you started:

```yaml
name: "CI"

on:
  pull_request:
  push:

jobs:
  build:
    name: Build (${{ matrix.os }})
    strategy:
      fail-fast: false
      matrix:
        os:
          - ubuntu-24.04
          - macos-13 # most recent x86_64
          - macos-15 # most recent aarch64
    runs-on: ${{ matrix.os }}
    steps:
      - uses: samueldr/nix-build-action@latest
```

> [!NOTE]
> Prefer pinning to a released version, rather than following the latest branch.
>
> This applies to all actions.

This sample will effectively run `nix-build ./release.nix` or `nix-build ./default.nix` at the root of your repository.

By default the artifacts will be sent to the cache, allowing future builds to resume from existing transitive builds (if relevant).


* * *

`nix-build` heuristics
----------------------

Heuristics is a big word for basically a small few options.

The first of the following files found will be `nix-build`'t:

 - `release.nix`
 - `default.nix`

> *This mirrors an older, yet still relevant, convention with Nix projects, where
> the `default.nix` may expose a more involved API, and the `release.nix` expression
> is used as a well-known way to build the expected outputs.


* * *

Configuring the action
----------------------

There are a couple inputs you can provide to this action.

Be mindful about interactions between some inputs. Read [the script](do-nix-build) and [the action](action.yml) to better understand how they interact.

<!-- ACTION.YML INPUTS START -->

### `expression-file`

The expression file to build.

When missing, it will try in order: `[ ./release.nix ./default.nix ]`.


### `attributes`

Attributes to build from the expression.

When missing, it will follow the default Nix semantics around build outputs.


### `nix-expression`

When provided, `nix-build` will pass the given value to the standard input, and build that instead of `expression-file`.


### `nix-build-extra-arguments`

When provided, the call to `nix-build` will use these appended extra arguments.

> [!WARNING]
> Beware of string splitting semantics!


### `nix-path`

When provided, `NIX_PATH` will be set to this value.


### `checkout-repo`

*Default: `true`*

Whether the repository will be checked-out automatically with the actions/checkout action.

Use `false` to bring your own checkout action alternative.


### `installer-action`

*Default: `lix-gha-installer-action`*

Installer action to use.

Supports the following: `[ "lix-gha-installer-action" "none" ]`.

Use `none` to bring your own.


### `cache-action`

*Default: `DeterminateSystems/magic-nix-cache`*

Cache action to use.

Supports the following: `[ "DeterminateSystems/magic-nix-cache" "none" ]`.

Use `none` to disable or bring your own.


<!-- ACTION.YML INPUTS END -->

* * *

FAQ
---

### Can I use the `___` action instead?

Maybe!

As of right now, all steps (except building) are conditional.

If you don't want to use the `actions/checkout` to checkout your repo, set `checkout-repo` to `false`.

Similarly, all other actions are implemented as if they were an enum type, with the `none` value available to disable the step entirely.

*Contributions welcome for alternative steps.*


### I want to upload the build to a binary cache

It is not supported at this moment, though a desired feature.

*Contributions welcome to add support.*


### I want upload outputs to a release

This is not a desired feature, as it involves knowing too much about the intended use-case.

Instead, you can safely add additional steps to upload artifacts to releases, just like you would otherwise.


### My `release.nix` is big and OOMs at eval

Try making a [*matrix*](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/running-variations-of-jobs-in-a-workflow) out of it,
and use the `attributes` input to build one attribute at a time.

This will also provide some parallelism, but unless done carefully, will not manage dependencies between attributes.


### What about Flakes?

Currently unsupported, as I'm not using them myself.
I don't think I could properly support the nuances of Flakes since I don't know them.

*Contributions welcome to support Flakes appropriately.*
