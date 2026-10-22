# Learn R in an Afternoon

A beginner-friendly R tutorial built around 32 classic cars. No packages to install, no data to download. You go from using R as a calculator to making charts, writing a function, fitting a model, and testing your own code, in about two hours.

**Read it:** (add your GitHub Pages link here)
**Watch the walkthrough:** (add your Loom link here)

## What you'll learn

Vectors, data frames, filtering, grouped summaries, base R charts, writing functions, a simple linear model, and how to check your work against simulated data where you know the right answer.

## Run it yourself

1. Install [R](https://cran.r-project.org/) (and optionally [Quarto](https://quarto.org/) plus RStudio).
2. Clone this repo.
3. Render the tutorial: `quarto render learn-r.qmd` (or open it in RStudio and click Render).
4. Run the tests from the project folder: `Rscript tests/test_tutorial.R`

Expected test result: `44 passed, 0 failed`.

## Project layout

```
learn-r.qmd            the tutorial
R/helpers.R            small reusable functions used by the tutorial
tests/test_tutorial.R  tests and simulations (base R only)
```

## How I built this with AI

(Fill this in honestly. Suggested outline:)

- **Tools used:** which AI assistant(s), and for what (outline, code, tests, editing).
- **Example prompts:** two or three real ones.
- **What the AI got wrong:** for example, a test expectation that didn't match the real data, and how you caught it.
- **What I changed by hand:** wording, examples, challenges.
