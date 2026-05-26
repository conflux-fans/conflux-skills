# Repository Guidance

This repository contains reusable Codex skills for Conflux-related development workflows. Treat each top-level skill directory as an independently installable skill.

## Skill Scope

- Keep each skill focused on one workflow or closely related family of workflows.
- Put trigger guidance in the `description` field of `SKILL.md` frontmatter. Make it clear when the skill should be used, including common user phrases or contexts.
- Keep `SKILL.md` concise enough to load directly. If details grow large, move them into targeted reference files and link to the specific file from `SKILL.md`.
- Keep `SKILL_LIST.md` as the central index of all skills, including each skill's GitHub URL and install command.
- When a skill references another skill, mention the skill by name and point readers to `SKILL_LIST.md` from the `Related skills` section instead of relying on relative paths.
- When a skill has variants by tool, framework, network, or workflow, organize details by variant so an agent can load only the relevant reference.
- Prefer reusable scripts for deterministic or repetitive work instead of asking future agents to reimplement the same procedure.

## Writing Rules

- Write instructions in direct imperative form.
- Explain why important constraints exist instead of relying only on rigid wording.
- Be explicit about safety boundaries. For example, read-only inspection skills should say that they do not use private keys, sign transactions, or send transactions.
- Do not invent external URLs, RPC endpoints, chain IDs, explorer behavior, or API parameters. Prefer official Conflux documentation or checked reference files.
- Keep examples realistic and copy-pasteable where useful.

## Review Checklist

Before adding or updating a skill, check:

- The frontmatter includes `name` and a useful `description`.
- The description is specific enough to trigger for the intended tasks without capturing unrelated work.
- The `SKILL.md` body states the workflow, scope, safety limits, and related skills where relevant.
- Large details are moved to `references/` with clear links from `SKILL.md`.
- `SKILL_LIST.md` includes every skill, with its GitHub URL and install command.
- Cross-skill references point readers to `SKILL_LIST.md` from the `Related skills` section.
- Any scripts or assets are documented from `SKILL.md` and have a clear reason to exist.
- The README and `SKILL_LIST.md` skill lists are updated when a skill is added, renamed, or removed.
- Examples, commands, RPC URLs, chain IDs, and explorer links are current.
