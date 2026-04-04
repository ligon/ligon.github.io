# ligon.github.io — Agent Guide

Personal academic website for Ethan Ligon, built with Hugo + PaperMod theme.
Content is authored in `content-org/website.org` (ox-hugo) and exported to Hugo.

## Site Structure

```
config.yml              # Hugo config (PaperMod theme)
content-org/website.org # All content in one org file, ox-hugo exports to Hugo
static/images/          # Cover images for papers (referenced via Hugo front matter)
layouts/                # Template overrides
themes/                 # PaperMod (git submodule)
```

## Paper Cover Images

Each paper entry uses a PaperMod cover image set in org properties:

```org
:EXPORT_HUGO_CUSTOM_FRONT_MATTER+: :cover '((image . "images/FILENAME.png") (alt . "ALT TEXT") (relative . t))
```

Images live in `static/images/` and are referenced with `relative . t`.

### Image Spec

| Property   | Value        |
|------------|--------------|
| Dimensions | 1536 × 1024 |
| Format     | PNG (RGB)    |
| File size  | ~100–200 KB  |
| Aspect     | 3:2          |

### Visual Style

All cover images share a consistent aesthetic:

- **Background colour:** cream `#e8dcc8` / `rgb(232, 220, 200)`
- **Ink/accent colour:** dark navy `#1a2744` / `rgb(26, 39, 68)`
- **Warm accent:** amber/burnt sienna `#b5651d` / `rgb(181, 101, 29)`
- **Font:** EB Garamond 12 Bold (`/usr/share/fonts/truetype/ebgaramond/EBGaramond12-Bold.ttf`), all-caps
- **Feel:** Woodcut/linocut inspired — high contrast, limited palette

### Hero Image Recipe (for data-driven papers)

When a paper has a distinctive data visualisation (heatmap, network,
time series, etc.), compose a cover image as follows:

1. **Render the visualisation** at high resolution using matplotlib.
   - Use the custom diverging colourmap: navy → mid-blue `#3a5a8c` → cream → peach `#d4956a` → amber.
   - No axis labels, ticks, or chrome — the vis is pure texture.
   - Save as a lossless intermediate (PNG, ≥2000 px on the short side).

2. **Composite with Pillow** (not matplotlib) for the final hero:
   - Canvas: 1536 × 1024, cream fill.
   - Scale the visualisation to overfill the canvas (~105%).
   - Apply an alpha mask: full opacity at edges/corners, fading to
     ~25% opacity in a central ellipse where the title sits (vis is
     strongest in the corners; title stays legible).
   - Slight edge vignette (~3% border fade to cream).

3. **Overlay the paper title** in EB Garamond 12 Bold, all-caps, navy.
   - Typically 3–4 lines: smaller font for prepositions/conjunctions,
     a larger font for the key phrase.
   - Cream halo (radius ~3 px, alpha ~220) behind each glyph for
     legibility over the background visualisation.

4. **Save** as PNG (RGB, no embedded DPI needed) to `static/images/`.

### Colour Constants (copy-paste)

```python
# Pillow (RGB tuples)
navy  = (26, 39, 68)
cream = (232, 220, 200)
amber = (181, 101, 29)

# Matplotlib (hex)
navy_hex  = '#1a2744'
cream_hex = '#e8dcc8'
amber_hex = '#b5651d'
mid_blue  = '#3a5a8c'
peach     = '#d4956a'

# Diverging colourmap
from matplotlib.colors import LinearSegmentedColormap
cmap = LinearSegmentedColormap.from_list(
    'ligon_diverge',
    [navy_hex, mid_blue, cream_hex, peach, amber_hex],
    N=256,
)
```

### Example: Substitution Heatmap (K-Aggregators paper)

The cover for "Consumer Demand with Price Aggregators and Low-Rank
Cross-Price Effects" was generated from the estimated 45×45 cross-price
elasticity matrix:

- Products reordered by Ward hierarchical clustering (correlation
  distance) to place substitutes near the diagonal and complements
  in off-diagonal blocks.
- Diagonal masked (set to NaN → cream via `cmap.set_bad()`).
- Generation script lives in the K-Aggregators repo.

## Adding a Paper

New papers go under `* Papers` in `website.org`, newest first.
Use this template (generate a fresh UUID for `:ID:`):

```org
** Paper Title Here :Tag_One:Tag_Two:
:PROPERTIES:
:export_hugo_bundle: papers/authorkey-YY
:EXPORT_FILE_NAME: index
:ID:       <fresh-uuid>
:EXPORT_DATE: <YYYY-MM-DD Day>
:EXPORT_HUGO_CUSTOM_FRONT_MATTER+: :cover '((image . "images/COVER.png") (alt . "ALT TEXT") (relative . t))
:END:

#+begin_description
One-sentence description for HTML meta / list pages.
#+end_description

[[/images/COVER.png]]

#+begin_summary
Two-sentence plain-language summary for the card on the home page.
#+end_summary

*** Download
- [[https://escholarship.org/uc/item/XXXX][Paper]]
*** Abstract
Full abstract here.
*** BibTeX

#+begin_src bibtex
@Unpublished{  authorkey-YY,
  ...
}
#+end_src
```

### Checklist (common pitfalls)

- [ ] `:ID:` is unique (don't reuse one from another entry)
- [ ] No duplicate tags in the headline
- [ ] Bundle path (`papers/authorkey-YY`) matches BibTeX key and year
- [ ] Cover image exists in `static/images/` and matches the spec above
- [ ] Inline image uses `/images/COVER.png` (not `./static/images/...` which breaks in page bundles)
- [ ] Abstract is the current version from eScholarship

## Content Workflow

1. Edit `content-org/website.org` in Emacs.
2. Export with `ox-hugo` (`C-c C-e H A` exports all subtrees).
3. Preview with `hugo server` from the repo root.
4. Push to `master`; GitHub Pages deploys automatically.

### Local build (CLI)

ox-hugo and its dependencies live in `~coder/.emacs.d/.local/straight/repos/`.
Hugo is not installed system-wide; fetch the arm64 binary to `/tmp`:

```sh
# 1. Export org to markdown
emacs --batch \
  --eval '(dolist (d (quote ("ox-hugo" "tomelr" "s"))) (add-to-list (quote load-path) (concat "/home/coder/.emacs.d/.local/straight/repos/" d "/")))' \
  --eval '(require (quote org))' \
  --eval '(require (quote ox-hugo))' \
  --find-file content-org/website.org \
  --eval '(org-hugo-export-wim-to-md :all-subtrees)'

# 2. Build (downloads hugo 0.148.2 once)
[ -x /tmp/hugo ] || curl -sL https://github.com/gohugoio/hugo/releases/download/v0.148.2/hugo_extended_0.148.2_linux-arm64.tar.gz | tar xz -C /tmp hugo
/tmp/hugo --minify

# 3. Inspect output
# e.g. grep 'src=.*images' public/papers/fally-ligon26/index.html
```

The `content/` directory is generated by ox-hugo and not checked in.

## Adding a Software Project

Software projects live under `* Software` in `website.org`, parallel
to `* Papers`.  Three pieces are needed:

1. **List page** (`** software` under `* General`):
   ```org
   ** software
   :PROPERTIES:
   :export_hugo_bundle: software
   :EXPORT_FILE_NAME: _index
   :END:
   #+begin_description
   Open-source software projects by Ethan Ligon.
   #+end_description
   ```

2. **Individual entries** (under `* Software`):
   ```org
   ** Project Name :Tag_One:Tag_Two:
   :PROPERTIES:
   :export_hugo_bundle: software/project-slug
   :EXPORT_FILE_NAME: index
   :ID:       <fresh-uuid>
   :EXPORT_DATE: <YYYY-MM-DD Day>
   :EXPORT_HUGO_CUSTOM_FRONT_MATTER+: :cover '((image . "images/COVER.png") (alt . "ALT TEXT") (relative . t))
   :END:

   #+begin_description
   One-sentence description.
   #+end_description

   [[/images/COVER.png]]

   #+begin_summary
   Two-sentence summary for the home-page card.
   #+end_summary

   *** Links
   - [[https://github.com/ligon/REPO][GitHub Repository]]
   *** Overview
   Prose description of the project.
   *** Citation
   #+begin_src bibtex
   ...
   #+end_src
   ```

3. **Config** (`config.yml`): the section name must appear in
   `MainSections` and as a profile button:
   ```yaml
   MainSections: ["papers", "software"]
   ...
   buttons:
     - name: Software
       url: software/
   ```

The pattern mirrors Papers exactly --- same cover-image spec, same
ox-hugo export, same PaperMod card layout.

## Notes

- The theme is PaperMod, pinned as a git submodule under `themes/`.
- `config.yml` sets `MainSections: ["papers", "software"]` so papers and software projects appear on the home page.
- Profile image is `ligon.jpg` (320 x 160 display size).
- Older paper metadata lives in `~ligon/bibtex/*.bib` (`selected_working_papers.bib` is the curated subset; `main.bib` has everything).
- eScholarship abstracts can be fetched programmatically via OAI-PMH: `https://escholarship.org/oai?verb=GetRecord&identifier=oai:escholarship.org:ark:/13030/qtXXXXXXXX&metadataPrefix=oai_dc` (the main pages are behind AWS WAF).
