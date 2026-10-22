# Learn R in an Afternoon

A hands-on introduction to R for complete beginners, built around 32 classic cars. The tutorial is a single [Quarto](https://quarto.org) document that takes you from using R as a calculator to fitting a model and checking that your code works, in roughly two to three hours.

It uses `mtcars`, a dataset that ships with R, so there is nothing to download and no packages to install. Everything is base R.

## What you'll learn

- Doing math, creating vectors, and filtering values without loops
- Loading, inspecting, and tidying a data frame
- Asking questions of data: sorting, filtering, and grouped averages
- Making two charts: a scatter plot and a bar chart
- Writing your own function
- Fitting a simple linear model (does heavier mean thirstier?)
- Checking your code against simulated data where you already know the answer

## Tutorial outline

| Section | Topic | Time |
|---|---|---|
| 1 | R as a calculator | ~5 min |
| 2 | Vectors | ~10 min |
| 3 | Meet the data | ~15 min |
| 4 | Ask questions of your data | ~20 min |
| 5 | Make it a chart | ~20 min |
| 6 | Write a function | ~15 min |
| 7 | A first model | ~20 min |
| 8 | How do we know the code is right? | ~15 min |

The tutorial ends with a recap, four challenges to try on your own, and pointers for where to go next.

## Project structure

```
.
├── learn-r.qmd            # The tutorial (Quarto document)
├── R/
│   └── helpers.R          # Reusable functions the tutorial calls
└── tests/
    └── test_tutorial.R    # Automated checks for the helper functions
```

The helper functions are kept in their own file so the tutorial stays readable and each piece can be tested on its own:

| Function | What it does |
|---|---|
| `load_cars()` | Loads `mtcars` and tidies it: car names become a column, cylinders and transmission become labeled factors, and km per liter and weight in pounds are added |
| `mpg_label()` | Buckets fuel efficiency into `thirsty` (under 18 mpg), `average` (18 up to 25), and `efficient` (25+) |
| `summarize_by()` | Averages any numeric column by any grouping column, with group counts |
| `fit_mpg_model()` | Fits `mpg ~ weight_lbs` with `lm()` |
| `predict_mpg()` | Predicts mpg for one or more car weights |
| `simulate_cars()` | Generates fake cars with a known slope plus random noise, for testing the model |

## Getting started

### Requirements

- [R](https://www.r-project.org/)
- [Quarto](https://quarto.org/docs/get-started/) (only needed to render the tutorial)

You can also open `learn-r.qmd` in [RStudio](https://posit.co/download/rstudio-desktop/) and run the code chunks one at a time, which is the best way to learn from it.

### Render the tutorial

From the project folder:

```bash
quarto render learn-r.qmd
```

This produces a self-contained `learn-r.html` with a table of contents and code-tools menu.

### Run the tests

From the project folder:

```bash
Rscript tests/test_tutorial.R
```

The tests use only base R and print a `PASS` or `FAIL` line for each check, followed by a summary. The script exits with a non-zero status if anything fails. Together they cover:

- **Data loading:** dimensions, column names, factor levels, no missing values, unit conversions, and that the original `mtcars` is left untouched
- **Edge cases:** the exact boundaries of the efficiency buckets (18 and 25 mpg)
- **Grouped averages:** checked against the real data and against a tiny toy example you can verify by hand, plus an error on bad column names
- **The model:** sign and size of the slope, R-squared range, and sensible predictions
- **Simulation:** the model recovers a planted slope, results are reproducible with a seed, and more noise means more spread but not bias, across 200 repeated runs

## Challenges

Once you've finished the tutorial, try these:

1. Find the 3 cars with the best horsepower per pound.
2. Make a bar chart of average `hp` by transmission type.
3. Rerun the simulation with `noise_sd = 6`. What happens to the slope estimate, and why?
4. Swap `mtcars` for `iris` or `airquality` and repeat sections 3 to 5.

## Where to go next

- [R for Data Science](https://r4ds.hadley.nz), a free book
- [`ggplot2`](https://ggplot2.tidyverse.org) for prettier charts
- [Posit Cloud](https://posit.cloud) to run R in your browser

## Author

Leher Harlalka
