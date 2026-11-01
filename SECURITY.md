# Security policy

## Reporting a vulnerability

Please report security problems privately through GitHub:
**[Report a vulnerability](https://github.com/aprilsoftware/wordcraft/security/advisories/new)**
(Security tab › Advisories › Report a vulnerability).

Don't open a public issue or pull request for a vulnerability until a fix is released.

Useful to include:
- the April Writer version or commit, and the platform (macOS, Windows, Linux, BSD, web);
- what an attacker can do, and what they need (a crafted document, MCP or control-channel access, a local account…);
- steps or a sample file that reproduce it.

We'll acknowledge the report, keep you updated while we work on a fix, and credit you in the advisory unless you'd rather not be named.

## Supported versions

Fixes go into `april/main` and ship in the next April Office-qualified release. Older releases don't get backported fixes.

## Scope

In scope: anything that lets a document, file, command, MCP or control-channel request, or network response read or write files it shouldn't, run code, leak data, or crash April Writer and lose the user's work.

Crashes from hostile input count, because April Writer treats every panic as a bug (see [Never crash](AGENTS.md)).
