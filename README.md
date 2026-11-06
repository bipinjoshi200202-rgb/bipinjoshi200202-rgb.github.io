# Bipin Joshi — Portfolio Website

Professional portfolio covering economic analysis, quantitative modelling and policy research.
Built with [Quarto](https://quarto.org) and published free with GitHub Pages at
**https://bipinjoshi200202-rgb.github.io**.

## Structure

```
_quarto.yml               Site settings: navigation, theme, footer
index.qmd                 Home page
about.qmd                 About
skills.qmd                Skills
cv.qmd                    CV & Contact
projects/
  index.qmd               Projects overview (cards are generated automatically)
  econometrics/           One folder per econometrics project
  policy-research/        One folder per presentation / policy case study
_templates/               Copy-and-fill templates for new projects (not published)
  econometrics/index.qmd
  policy-research/index.qmd
  project-cards.ejs       Design of the project cards
assets/
  styles.scss             Colours, fonts and layout
  favicon.svg
.github/workflows/publish.yml   Builds and publishes the site on every push
```

## Adding a new project

1. Copy the matching template folder from `_templates/` into the right category, under a short name:
   - `_templates/econometrics/` → `projects/econometrics/my-project-name/`
   - `_templates/policy-research/` → `projects/policy-research/my-project-name/`
2. Open `index.qmd` in the new folder and fill in the header (title, description, question, tools, date, image)
   and the sections. Delete any section that doesn't apply. **Only use real content from your own work.**
3. Put supporting files in the same folder:
   - `figures/`: charts and selected slides (PNG); `figures/thumbnail.png` becomes the card image
   - `scripts/`: R scripts
   - `files/`: PDFs you are allowed to share
4. Commit and push. The project appears on the Projects page automatically.

### Projects with R code

If a project's `index.qmd` runs R code, render it on your own computer first
(`quarto render projects/econometrics/my-project-name/index.qmd` in RStudio's terminal). Then commit the
`_freeze/` folder that Quarto creates. GitHub publishes the stored results without re-running R.

## Adding a new category later (e.g. GAMS, data management)

1. Create `projects/<category-name>/`.
2. In `projects/index.qmd`, add a listing block with a new `id` and a matching heading and `::: {#id}` div.
3. Add a template folder in `_templates/`.

## Preview locally

```bash
quarto preview
```

## Integrity rules for content

- No invented data, results, model outputs or recommendations.
- Group work is always labelled as group work, and personal contributions are stated separately.
- No restricted university material or copyrighted data without permission.
