# helpers.R
# The small, reusable functions behind the tutorial.
# Keeping them in their own file means the tutorial stays readable
# and the tests can check each piece on its own.

# ---- 1. Load and tidy the data ---------------------------------------------
# mtcars ships with R, so there is nothing to download or install.
# We make it friendlier: car names become a real column, cylinders and
# transmission become labeled categories, and we add km-per-liter
# for anyone who doesn't think in miles per gallon.
load_cars <- function() {
  cars <- mtcars
  cars$model <- rownames(mtcars)
  rownames(cars) <- NULL

  cars$cyl <- factor(cars$cyl)
  cars$transmission <- factor(
    ifelse(cars$am == 1, "manual", "automatic"),
    levels = c("automatic", "manual")
  )
  cars$kpl <- round(cars$mpg * 0.425144, 1)  # 1 mpg = 0.425144 km per liter
  cars$weight_lbs <- cars$wt * 1000          # wt is recorded in 1000s of lbs

  cars[, c("model", "mpg", "kpl", "cyl", "hp", "weight_lbs", "transmission")]
}

# ---- 2. Label a car by fuel efficiency ---------------------------------------
# Under 18 mpg = "thirsty", 18 up to (not including) 25 = "average",
# 25 and above = "efficient".
mpg_label <- function(mpg) {
  cut(
    mpg,
    breaks = c(-Inf, 18, 25, Inf),
    labels = c("thirsty", "average", "efficient"),
    right = FALSE
  )
}

# ---- 3. Average a number by group --------------------------------------------
# "What's the average mpg for each cylinder count?" is the classic
# first question you ask of a dataset. This function answers it for
# any numeric column and any grouping column.
summarize_by <- function(data, group, value) {
  stopifnot(group %in% names(data), value %in% names(data))
  out <- aggregate(data[[value]], by = list(group = data[[group]]), FUN = mean)
  names(out)[2] <- paste0("avg_", value)
  out[[2]] <- round(out[[2]], 2)
  out$n <- as.vector(table(data[[group]])[as.character(out$group)])
  out
}

# ---- 4. A simple model: does heavier mean thirstier? -------------------------
fit_mpg_model <- function(data) {
  lm(mpg ~ weight_lbs, data = data)
}

predict_mpg <- function(model, weight_lbs) {
  round(as.numeric(predict(model, newdata = data.frame(weight_lbs = weight_lbs))), 1)
}

# ---- 5. Make-believe cars ----------------------------------------------------
# Simulation lets us check our code against a world where we KNOW the
# answer. Here every extra pound costs exactly `slope` mpg, plus some
# random noise. If our model can't find that slope, something is wrong.
simulate_cars <- function(n = 500, intercept = 37, slope = -0.006,
                          noise_sd = 2, seed = 42) {
  set.seed(seed)
  weight_lbs <- runif(n, min = 1500, max = 5500)
  mpg <- intercept + slope * weight_lbs + rnorm(n, mean = 0, sd = noise_sd)
  data.frame(mpg = mpg, weight_lbs = weight_lbs)
}
