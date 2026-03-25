# Default Repo Notice Template

Use this block in future repositories as a default disclaimer.

## Long form (README / docs)

```md
## Project Notice

This project is primarily built with **OpenAI Codex**, with manual edits, decisions, and testing by the repository owner.

I started using Linux in **December 2025** and I am actively learning while building this setup.
This repository reflects a specific personal vision and system target.

This project is provided as-is. I do not guarantee ongoing maintenance, immediate fixes, or broad compatibility support.

Questions are welcome. If you need context for design decisions, please ask and I will provide it when possible.
```

## Short form (for small repos)

```md
Built primarily with OpenAI Codex + manual edits by the owner.
Learning-focused project (Linux since Dec 2025), tailored to a personal setup.
Best-effort maintenance only. Questions and context requests are welcome.
```

## Commit footer (optional)

```text
Co-developed with: OpenAI Codex
Maintainer model: Best-effort / no guaranteed upkeep
```

## Environment assumptions block (optional)

Use this when the repo is intentionally tied to one stack:

```md
### Environment Assumptions

- Target distro/session: <distro + WM/DE + display stack>
- Primary shell: <bash/fish/zsh>
- Hardware-specific behavior may exist (GPU/audio/network/monitor layout)
- Behavior outside this environment may require adaptation
```

## Module change checklist (optional)

Use this checklist when adding a new module so future maintenance stays clean:

```md
### Module Added Checklist

- [ ] Module wiring added in config (`modules-left/center/right` + module block)
- [ ] Dependencies documented (`documentation/DEPENDENCIES.md`)
- [ ] Troubleshooting notes updated (`documentation/SUPPORT.md`)
- [ ] Matching module/script docs added (`documentation/modules/` or `documentation/scripts/`)
- [ ] Click actions/keybinds documented (if interactive)
```
