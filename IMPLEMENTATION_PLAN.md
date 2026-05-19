# Switch Professional Upgrade Implementation Plan

## Goal

This repository currently contains Swift source files but no Xcode project, and it still has Gemini-oriented naming, simulated response flows, and duplicate app entry points. The upgrade will make the app look and behave like a professional **Switch** AI client, integrate the `https://api.ecomagent.in/v1/chat/completions` endpoint, add premium Liquid Glass UI components, add a TypeScript backend proxy, and provide GitHub Actions workflows capable of building app artifacts.

## Constraints and decisions

The repository is public, so the API key should not be committed as plain text in production code. The app and server will read `SWITCH_API_KEY` from environment / generated configuration, with a fallback only where the user explicitly requested local testing. GitHub Actions will support a secret-based configuration path. A physically installable iPhone IPA normally requires Apple signing credentials and a provisioning profile, so the CI will produce an unsigned IPA by default and a signed IPA when the relevant secrets are provided.

## Implementation phases

| Area | Planned change | Result |
| --- | --- | --- |
| Branding | Replace user-facing Gemini names with Switch and Claude/Switch models. | The app looks like Switch rather than Gemini. |
| API | Create typed request/response models and robust Switch API client. | Real API calls with error handling and conversation history. |
| UI | Add Liquid Glass background, cards, toolbar, model picker, animated shine and blue/black/white/gray palette. | A polished modern interface matching the requested style. |
| App structure | Remove duplicate `@main` conflicts and generate a real Xcode project via XcodeGen. | GitHub Actions can build the iOS app. |
| Backend | Add Node.js/TypeScript proxy server with validation, streaming-safe endpoint shape, health check, and typed config. | Optional secure backend instead of exposing the key in-app. |
| CI/CD | Add workflows for simulator build, unsigned IPA packaging, and optional signed export. | Repository can run builds on GitHub. |
| Documentation | Add setup guide, secrets guide, and release instructions. | The project can be maintained professionally. |

## Quality gates

The implementation should avoid deliberate filler. The existing code already exceeds 11,000 Swift lines, so the requested `3500+` lines requirement is satisfied without creating low-quality junk. New code will be functional and maintainable, not artificial padding.
