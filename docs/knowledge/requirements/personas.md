# User Personas

> Personas define who the product serves. The requirements agent uses these to assess whether a new feature serves a real user need and to write acceptance criteria from the user's perspective.
>
> **Update this file** whenever a new user type is identified through research, user interviews, or feedback.

---

## Persona 1 — Alex, the Solo Developer

**Role**: Independent developer / freelancer  
**Team size**: 1 (themselves)  
**GitHub Copilot plan**: Pro or Pro+  
**Technical level**: Senior engineer  

### Context
Alex builds side projects and client work solo. They use GitHub Copilot extensively for code completion but struggle with the planning and process side of development. They often skip requirements analysis and jump straight to coding, which leads to rework.

### Goals
- Build features faster without sacrificing quality
- Have a structured process without the overhead of a full team
- Catch security and edge-case issues before they reach production

### Pain Points
- Requirements are in their head — not written down, often incomplete
- No one to review architecture or security
- Testing is the first thing skipped when under deadline pressure
- Documentation is always out of date

### How They Use the Orchestrator
- Assigns GitHub issues directly to the orchestrator agent
- Reviews and approves requirements/planning outputs quickly (high trust)
- Values the security agent most — it catches what they would miss alone

### Quote
> "I know what I want to build. I just need someone to make sure I build it right."

---

## Persona 2 — Jordan, the Engineering Lead

**Role**: Engineering lead / tech lead at a startup  
**Team size**: 3–8 engineers  
**GitHub Copilot plan**: Business  
**Technical level**: Staff engineer  

### Context
Jordan manages a small team and is responsible for technical quality. They want to delegate implementation to Copilot agents while retaining control over architecture decisions and security reviews. They are the bottleneck for requirements reviews.

### Goals
- Reduce time spent reviewing PRs that don't meet requirements
- Ensure all features go through a consistent quality process
- Delegate routine implementation work while staying in control of design and architecture

### Pain Points
- Engineers often implement before requirements are clear
- Security reviews are skipped due to time pressure
- Test coverage is inconsistent across the team
- Documentation is a constant battle

### How They Use the Orchestrator
- Uses the orchestrator for greenfield features and significant changes
- Always reviews and approves planning options carefully
- Reviews security agent output before approving
- Trusts coding and testing agents to execute after approval

### Quote
> "I need to be the approver, not the implementer. But I need to know it's done right."

---

## Persona 3 — Morgan, the Product Manager

**Role**: Product manager at a growth-stage company  
**Team size**: Cross-functional team of 5–15  
**GitHub Copilot plan**: Business (via engineering team)  
**Technical level**: Non-technical to intermediate  

### Context
Morgan writes GitHub issues and feature requests. They understand product and user needs deeply but cannot write code. They want their issues to be implemented faithfully without constant back-and-forth with engineers.

### Goals
- Have their GitHub issues translated into working features without specification rework
- Understand the technical tradeoffs without needing to read code
- Be notified of decisions that affect user experience

### Pain Points
- Issues they write are vague from a technical standpoint, but they don't know what's missing
- Engineers interpret requirements differently
- Security and technical constraints are invisible to them until it's too late

### How They Use the Orchestrator
- Writes issues in plain product language; the requirements agent identifies gaps
- Reviews requirements options and selects the one that matches their intent
- Does not review planning/security/coding outputs (engineering team does)
- Reviews the final PR description for feature accuracy

### Quote
> "I write the issue. I shouldn't have to write a 10-page spec for it to be built right."

---

## Persona 4 — Sam, the Open Source Maintainer

**Role**: Open source project maintainer  
**Team size**: 1–3 core maintainers + community contributors  
**GitHub Copilot plan**: Pro (free tier or paid)  
**Technical level**: Senior to staff engineer  

### Context
Sam maintains a popular open source library. They receive contributions and feature requests from the community but have limited bandwidth to review and implement everything. They want to scale their ability to ship features without burning out.

### Goals
- Implement community-requested features consistently
- Ensure contributed code meets the project's quality standards
- Keep documentation and changelogs accurate

### Pain Points
- Community issues are often underspecified
- Reviewing and merging contributions takes enormous time
- Docs drift from the actual implementation
- Security issues go unnoticed in community contributions

### How They Use the Orchestrator
- Uses the orchestrator to triage and implement community feature requests
- The requirements agent's gap analysis is critical for underspecified community issues
- Relies on the documentation agent to keep changelogs and API docs accurate

### Quote
> "I love contributions, but every PR I merge is an hour of my life. I need to scale this."

---

## Adding New Personas

When a new user type is identified:

```markdown
## Persona N — [Name], the [Role Title]

**Role**: ...
**Team size**: ...
**GitHub Copilot plan**: ...
**Technical level**: ...

### Context
...

### Goals
- ...

### Pain Points
- ...

### How They Use the Orchestrator
- ...

### Quote
> "..."
```
