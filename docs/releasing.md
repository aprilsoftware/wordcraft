# Releasing April Writer

April Writer source and binary releases are coordinated through April Office. This source
repository validates April Writer changes and identifies accepted source commits; it does not
assemble or publish standalone binary releases.

The April integration line intentionally has no release-publication workflow. In particular,
April Writer must not delegate builds or publication to Storytold release automation or follow a
moving upstream workflow reference.

The clean upstream `main` branch may retain inherited workflow files so that it remains an exact
upstream line. Those files are not approved April release machinery and `main` is never an April
build input. While that branch remains the repository default, administrators must keep the
inherited release workflow disabled and keep publication credentials inaccessible to it. Changing
remote repository settings is a separate administrative action.

## Repository roles

| Repository or ref | Responsibility |
|---|---|
| `april/main` | Integrated April Writer source line |
| `aprilwriter-vX.Y.Z` | Immutable, preferably signed tag for an accepted April Writer source commit |
| `apriloffice` manifest | Selects the exact April Software source commit accepted for integration |
| April Office qualification | Rebuilds pinned sources, tests packages, and records checksums and provenance |
| Protected April Office release workflow | Eventually signs and publishes approved experimental, testing, or stable artifacts |

The clean `main` branch and Storytold tags are provenance and import inputs, not April build
aliases. Never move an April release tag, rewind a published integration branch, or silently build
a later upstream branch.

## Source acceptance

Before April Office selects a Writer commit:

1. merge the reviewed source change into `april/main` without rewriting published history;
2. run the applicable source tests, native builds, WebAssembly checks, and packaging checks;
3. record checks that require Windows or macOS runners as external qualification rather than
   treating an unavailable local toolchain as success;
4. create `aprilwriter-vX.Y.Z` only for a deliberately accepted source commit, when a source tag is
   required;
5. update the April Office manifest to the exact commit through a separate reviewed change.

The primary Linux source gate, packaging lint, native printing/browser compatibility, Windows
ARM64 package qualification, and FreeBSD x86-64 qualification workflows are maintained in this
repository for `april/main`. No mutable Storytold workflow delegates remain on the April integration
line.

April Writer currently has no Nix flake or approved Nix package. Nix enablement would require a
separate packaging design and qualification increment; a workflow that merely skips because no
flake exists is not qualification.

April Writer also has no approved SonarCloud project. Enabling hosted analysis requires an
April-owned organization and project, a narrowly scoped token, privacy review, and separate
approval. April source and coverage must not be submitted under the inherited Storytold project.

## Local package qualification

These commands exercise repository packaging locally where their platform tools are available:

```text
packaging/linux/package.sh
packaging/linux/flatpak-bundle.sh
packaging/freebsd/package.sh
packaging/macos/package.sh --arch universal
packaging/windows/package.ps1
packaging/web/package.sh
```

Their outputs are test artifacts unless April Office accepts the exact commit and records the
result. A local package is not a release merely because it has a versioned filename.

Platform-specific signing and validation remain mandatory where applicable. Windows installer
compilation and installation require Windows; universal app assembly, signing, Gatekeeper checks,
DMG verification, and notarization require macOS. Signing credentials stay outside Git and are
available only to protected release environments.

## Release record

An approved April Office release record must include:

- April product version, channel, and source tag when one exists;
- exact April Software source commit and original WordCraft base tag and commit;
- locked dependencies and toolchain information;
- artifact checksums, notices, source offer, SBOM, and provenance;
- native, WebAssembly, package-installation, and platform-signing results that apply;
- known limitations and rollback information.

Publication is a separate authorized action. Source acceptance must not publish a GitHub release,
move a channel, or expose signing credentials automatically.

## Update channel

April Writer update checks remain disabled. Publishing packages does not enable an update channel.
A signed April-controlled metadata service, rollback policy, and channel design require separate
review before the application may advertise or consume updates.
