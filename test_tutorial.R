# test_tutorial.R
# Run from the project folder with:  Rscript tests/test_tutorial.R
# Uses only base R, so there is nothing to install.

source("R/helpers.R")

passed <- 0
failed <- 0

check <- function(description, condition) {
  ok <- isTRUE(condition)
  if (ok) passed <<- passed + 1 else failed <<- failed + 1
  cat(if (ok) "  PASS  " else "  FAIL  ", description, "\n", sep = "")
}

section <- function(title) cat("\n", title, "\n", strrep("-", nchar(title)), "\n", sep = "")

# ---------------------------------------------------------------------------
section("load_cars(): data loads and is tidy")
cars <- load_cars()

check("has 32 rows and 7 columns", all(dim(cars) == c(32, 7)))
check("expected column names, in order",
      identical(names(cars), c("model", "mpg", "kpl", "cyl", "hp", "weight_lbs", "transmission")))
check("car names became a column", "Mazda RX4" %in% cars$model)
check("row names were reset", identical(rownames(cars), as.character(1:32)))
check("cyl is a factor with levels 4, 6, 8", identical(levels(cars$cyl), c("4", "6", "8")))
check("transmission is labeled, not 0/1",
      identical(levels(cars$transmission), c("automatic", "manual")))
check("19 automatics and 13 manuals", all(as.vector(table(cars$transmission)) == c(19, 13)))
check("no missing values anywhere", !anyNA(cars))
check("km per liter conversion is right (Mazda RX4: 21 mpg -> 8.9 kpl)",
      cars$kpl[cars$model == "Mazda RX4"] == 8.9)
check("weight converted to pounds (Mazda RX4: 2620)",
      cars$weight_lbs[cars$model == "Mazda RX4"] == 2620)
check("load_cars() leaves the original mtcars untouched",
      identical(dim(mtcars), c(32L, 11L)) && !is.null(rownames(mtcars)) && "Mazda RX4" %in% rownames(mtcars))

# ---------------------------------------------------------------------------
section("mpg_label(): efficiency buckets, including edge cases")

check("10 mpg is thirsty", mpg_label(10) == "thirsty")
check("17.9 mpg is thirsty", mpg_label(17.9) == "thirsty")
check("18 exactly is average (boundary)", mpg_label(18) == "average")
check("24.9 mpg is average", mpg_label(24.9) == "average")
check("25 exactly is efficient (boundary)", mpg_label(25) == "efficient")
check("very high mpg is efficient", mpg_label(99) == "efficient")
check("works on a whole vector",
      identical(as.character(mpg_label(c(10, 20, 30))), c("thirsty", "average", "efficient")))
check("every real car gets a label", !anyNA(mpg_label(cars$mpg)))
check("bucket counts add up to 32", sum(table(mpg_label(cars$mpg))) == 32)

# ---------------------------------------------------------------------------
section("summarize_by(): grouped averages")

by_cyl <- summarize_by(cars, "cyl", "mpg")
check("one row per cylinder count", nrow(by_cyl) == 3)
check("column is named avg_mpg", "avg_mpg" %in% names(by_cyl))
check("4-cylinder average is 26.66", by_cyl$avg_mpg[by_cyl$group == "4"] == 26.66)
check("6-cylinder average is 19.74", by_cyl$avg_mpg[by_cyl$group == "6"] == 19.74)
check("8-cylinder average is 15.1", by_cyl$avg_mpg[by_cyl$group == "8"] == 15.1)
check("group sizes are 11, 7, 14", identical(by_cyl$n, c(11L, 7L, 14L)))
check("group sizes add up to 32", sum(by_cyl$n) == 32)

by_tx <- summarize_by(cars, "transmission", "mpg")
check("manual beats automatic on average in this data",
      by_tx$avg_mpg[by_tx$group == "manual"] > by_tx$avg_mpg[by_tx$group == "automatic"])

# A tiny hand-checkable example: we can do this math in our heads.
toy <- data.frame(team = c("a", "a", "b", "b", "b"), score = c(2, 4, 10, 20, 30))
toy_out <- summarize_by(toy, "team", "score")
check("toy data: team a averages 3", toy_out$avg_score[toy_out$group == "a"] == 3)
check("toy data: team b averages 20", toy_out$avg_score[toy_out$group == "b"] == 20)

check("bad column name gives an error, not a silent wrong answer",
      inherits(try(summarize_by(cars, "nope", "mpg"), silent = TRUE), "try-error"))

# ---------------------------------------------------------------------------
section("fit_mpg_model(): real data")

model <- fit_mpg_model(cars)
slope <- unname(coef(model)["weight_lbs"])
check("slope is negative (heavier = fewer mpg)", slope < 0)
check("slope is about -0.0053 mpg per lb", abs(slope - (-0.005344)) < 0.0005)
check("model explains roughly 75% of variation (R-squared 0.70-0.80)",
      summary(model)$r.squared > 0.70 && summary(model)$r.squared < 0.80)
check("heavier car predicted to get fewer mpg",
      predict_mpg(model, 4500) < predict_mpg(model, 2500))
check("predict_mpg returns one number per input", length(predict_mpg(model, c(2000, 3000, 4000))) == 3)
check("a 3,000 lb car is predicted in a sensible range (18-26 mpg)",
      predict_mpg(model, 3000) > 18 && predict_mpg(model, 3000) < 26)

# ---------------------------------------------------------------------------
section("simulation: can the model recover a slope we planted?")

true_slope <- -0.006
sim <- simulate_cars(n = 500, slope = true_slope, seed = 1)
sim_slope <- unname(coef(fit_mpg_model(sim))["weight_lbs"])
check("simulated data has 500 rows", nrow(sim) == 500)
check("recovered slope is within 5% of the planted -0.006",
      abs(sim_slope - true_slope) / abs(true_slope) < 0.05)

same_a <- simulate_cars(seed = 7)
same_b <- simulate_cars(seed = 7)
check("same seed gives identical fake data (reproducible)", identical(same_a, same_b))
check("different seeds give different fake data", !identical(simulate_cars(seed = 1), simulate_cars(seed = 2)))

# Run the experiment 200 times. If the code is right, the estimates
# should center on the truth, not drift away from it.
estimates <- sapply(1:200, function(s) {
  unname(coef(fit_mpg_model(simulate_cars(n = 100, slope = true_slope, seed = s)))["weight_lbs"])
})
check("200 repeated simulations average out to the planted slope (within 2%)",
      abs(mean(estimates) - true_slope) / abs(true_slope) < 0.02)

# Noise should make estimates less precise, not biased.
noisy <- sapply(1:200, function(s) {
  unname(coef(fit_mpg_model(simulate_cars(n = 100, slope = true_slope, noise_sd = 6, seed = s)))["weight_lbs"])
})
check("more noise = more spread in estimates", sd(noisy) > sd(estimates))
check("more noise is still centered on the truth (within 5%)",
      abs(mean(noisy) - true_slope) / abs(true_slope) < 0.05)

cat("\nSimulation summary (200 runs, n = 100 cars each)\n")
cat(sprintf("  planted slope:            %.5f\n", true_slope))
cat(sprintf("  mean estimate (noise 2):  %.5f   spread (sd): %.5f\n", mean(estimates), sd(estimates)))
cat(sprintf("  mean estimate (noise 6):  %.5f   spread (sd): %.5f\n", mean(noisy), sd(noisy)))

# ---------------------------------------------------------------------------
cat(sprintf("\nResult: %d passed, %d failed\n", passed, failed))
if (failed > 0) quit(status = 1)
