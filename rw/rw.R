# simulate a random walk

# set leading parameters
years <- 1:43
lam0 <- 10 # initial value
sd_rw <- 1 # stdev of process
sd_obs <- 0.8 # stdev of observations
lams <- rep(NA, length(years)) # true lambdas
y_obs <- rep(NA, length(years)) # observed data
set.seed(1) # ensure "random" data are same

lams[1] <- rnorm(1, lam0, sd_rw) # initialize the stochastic process

# do the random walk, add in process error:
for (i in 2:length(years)) {
  lams[i] <- rnorm(1, lams[i - 1], sd_rw)
}

# add observation error to true (latent) process:
y_obs <- rnorm(length(lams), lams, sd_obs)

library(TMB)
compile("rw/rw.cpp")
dyn.load(dynlib("rw/rw"))
data <- list(y_obs = y_obs)

parameters <- list(
  ln_sd_rw = 0,
  ln_sd_obs = 0,
  lam0 = 0,
  lams = rep(0, length(data$y_obs))
)
obj <- MakeADFun(data, parameters, random = "lams", DLL = "rw")
obj$fn()
obj$gr()

opt <- nlminb(obj$par, obj$fn, obj$gr)
sdr <- sdreport(obj)

sdr

# check gradients and make sure pdHess
final_gradient = obj$gr(opt$par)
if (any(abs(final_gradient) > 0.001) || sdr$pdHess == FALSE) {
  message("Model did not converge: check results")
} else {
  message("Model diagnostics consistent with convergence")
}

par(mar = c(5, 6, 4, 1) + .1)
plot(y_obs,
  type = "p", xlab = "year",
  ylab = "value",
  cex = 0.75, pch = 3, cex.lab = 1.5,
  cex.main = 1.7, ylim = c(8, 16),
  main = expression(lambda[true] ~ (points) ~ vs. ~ y[obs] ~ ("x's") ~ vs. ~ lambda[est] ~ (black))
)
points(lams,
  type = "b", col = "steelblue",
  pch = 16, cex = 0.75
)

points(sdr$par.random,
  type = "l", col = "black",
  pch = 16, cex = 2, lwd = 2
)
upper = sdr$par.random + 1.96 * sqrt(sdr$diag.cov.random)
lower = sdr$par.random + -1.96 * sqrt(sdr$diag.cov.random)
points(upper,
  type = "l", col = "black",
  pch = 16, lwd = 1.5, lty = 2
)
points(lower,
  type = "l", col = "black",
  pch = 16, lwd = 1.5, lty = 2
)

# profile model
prof <- tmbprofile(obj, name = c("ln_sd_rw"))
plot(prof)
