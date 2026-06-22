# Atlas — Client Reporting Toolkit

Everything Atlas (the analytics/reporting PM agent) needs to turn a client's Google data into a plain-language monthly website-performance report. The agent doc lives at [`../agents/atlas.md`](../agents/atlas.md); this folder holds the **report artifact** he fills.

## What's here

| File | What it is |
|---|---|
| `report-template.html` | The reusable master report. Self-contained (inline CSS + vanilla JS, no CDN/fonts), renders offline, prints clean to PDF. Designed by Morpheus. |
| `sample-report.html` | The template filled with a worked example (Blue Ridge Family Dentistry) so you can see the finished product. Open it in any browser. |

Both are **single self-contained HTML files** — open by double-clicking, email as one attachment, or host as a link. The client **PDF** is generated with Chrome — see [Exporting the PDF](#exporting-the-pdf).

## How a monthly report gets made

1. **Drop the data** into the client's intake folder (see convention below) — CSV exports are best, but PDF or screenshots work too.
2. **Tell Atlas:** *"Atlas, build June's report for [client] — exports are in [path], plan is Premium Growth."*
3. Atlas delegates three scans (one each for GBP, GSC, GA4), verifies the numbers, builds the funnel, writes the story, fills the template, and hands back `report.html`.
4. **Atlas exports the PDF with Chrome** — `./render-pdf.sh <client>/reports/2026-06/report.html` produces the print-perfect, page-mapped PDF. He checks it renders; you do the final read and send it.

## Exporting the PDF

The client deliverable is a PDF, and it's **always generated with Chrome** via `render-pdf.sh`:

```
./render-pdf.sh <client>/reports/2026-06/report.html
```

**Why Chrome, not Safari?** The report is a full-bleed, page-mapped document. Chrome's print engine renders it exactly as designed — 8 clean pages, dark to every trim edge, crisp badge dot. Safari's "Save as PDF" imposes its own print margins even when the CSS says `margin: 0`, which inserts blank pages and leaves white strips. So Atlas exports the PDF with Chrome automatically. The HTML still **views** perfectly in Safari (or any browser) — only the PDF export uses Chrome.

## Intake folder convention

Keep each client's data in one predictable place so the data's always where Atlas expects it:

```
<client>/reports/
  _intake/
    manifest.yaml # this client's plan + add-ons — Atlas reads it FIRST to set scope
    ga4/          # Google Analytics 4 exports — CSV / PDF / screenshots
    gsc/          # Search Console exports
    gbp/          # Business Profile insights — exports or screenshots
    local-rank/   # Local Falcon exports — only for geo-grid / AI-visibility / competitor add-ons
    notes.md      # context that explains the numbers: campaigns, site changes, a new service, a holiday
  2026-06/
    report.html   # the generated report for that month
```

`notes.md` matters more than it looks — "we ran a Facebook promo the last week of June" turns a confusing spike into a clear story.

## Where the data comes from (quick export guide)

- **GA4 (Google Analytics):** Reports → choose the date range → export. Or build an Exploration and export to CSV. Useful reports: Acquisition (traffic sources), Engagement → Pages and screens (top pages), Tech → device category, and your key events (form submissions, calls).
- **GSC (Search Console):** Performance → set the date range → Export. Grab Queries (top searches) and Pages. For the 6-month trend, export with the date range set to the last ~6 months.
- **GBP (Business Profile):** In the profile's Performance view, note searches/views, calls, direction requests, website clicks, and the review count + rating. Screenshots are fine here — Atlas's scanner reads images.

Compare **this month vs last month** so every number has a direction.

## The data contract

The top of `report-template.html` is a single `const REPORT_DATA = { ... }` object. **That object is the entire report** — Atlas edits only it (never the CSS or JS). Its shape is the contract between the scanner sub-agents and the template: each scanner returns JSON keyed to a section of `REPORT_DATA` (`visibility`, `onSite`, `funnel`, …) so the merge is clean. The full, worked shape is visible in both HTML files.

## Report scope by care plan

Scope is **data-driven**: the client's `_intake/manifest.yaml` declares their `plan` + `addons`, and Atlas resolves the exact section list from [`plan-modules.yaml`](plan-modules.yaml) (structure only — **no prices**; pricing lives on the STRIX care-plans page). Atlas runs only the scanners those sections need.

| Plan | Report |
|---|---|
| **Premium Growth** | The full report — GBP + GSC + GA4, all nine sections, the complete lead-leak funnel, plus the AI-referral panel. The flagship. |
| **Essential Care** | Lighter: Search Console visibility + top searches + a short on-site summary + any health flags. No deep GBP/GA4 funnel unless access is wired up. |
| **Managed Hosting / On-Demand** | No recurring report; a one-off basic health snapshot only if asked. |
| **Add-ons** (sold on Premium Growth) | Geo-Grid map · AI-Visibility panel · Competitor panel — each from the Local Falcon export in `_intake/local-rank/`. *(Report sections pending a Morpheus build.)* |

## Phase 2 — live API automation (a Neo build, when you want it)

Today the workflow is **manual export → Atlas reads it**. That works with zero setup and no Google Cloud credentials. When the volume justifies going hands-off, the upgrade is a Neo project:

- **APIs:** GA4 Data API (`runReport`), Search Console API (`searchanalytics.query`), and the Business Profile Performance API.
- **Auth:** a Google Cloud service account (or OAuth) with each client's properties shared to it — the trickiest part, and why it's phase 2.
- **Shape:** the puller outputs JSON matching the `REPORT_DATA` schema, so it drops straight into the template — Atlas's job doesn't change, only where the numbers come from.
- **Cadence:** a scheduled monthly run that fills `_intake/` (or the data object directly) automatically.

When you're ready: *"Atlas, scope the API automation with Neo."*

## Privacy

Reports describe **aggregate** behavior (how many people, from where, doing what) — never individual visitors. Keep client analytics access and credentials out of the repo and out of reports. One client's data never appears in another's report.
