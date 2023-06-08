# cahill coding up jrb's example from memory
n_pond = 8
n_fish = 10
mu = 150 # assume average size among ponds is 150 mm
sd_among = 50 # among lake (shared) sd
sd_within = 10 # within lake sd
pond = rep(1:n_pond, each = n_fish)
print(pond)

# step 1, calculate pond mean lengths from hyperprior:
set.seed(31)
mu_pond = rnorm(n_pond, mu, sd_among) # average length in each lake
plot(mu_pond,
  xlab = "lake", ylab = "length (mm)", pch = 4,
  main = "Random length intercepts for each pond"
)

# step 2, calculate fish lengths | on mu_pond:
y_obs = rep(NA, n_pond * n_fish)

for (i in 1:length(y_obs)) {
  y_obs[i] = rnorm(1, mu_pond[pond[i]], sd_within)
}

boxplot(y_obs ~ pond, ylab = "length (mm)", main = "distribution of lengths")

#-------------------------------------------------------------------------------
library(TMB)
compile("lengths/lengths.cpp")
dyn.load(dynlib("lengths/lengths"))

data = list(
  y_obs = y_obs,
  n_pond = n_pond,
  pond = pond - 1 # look here, this is important
)

parameters = list(
  ln_mu = log(150),
  ln_sd_among = log(50),
  ln_sd_within = log(50),
  eps = rep(0, n_pond)
)

obj = MakeADFun(data, parameters, random = "eps", DLL = "lengths")
obj$fn()
obj$gr()

opt <- nlminb(obj$par, obj$fn, obj$gr)
sdr <- sdreport(obj)
sdr

# check gradients and make sure pdHess
opt$convergence # 0 is good 
final_gradient <- obj$gr(opt$par)
if (any(abs(final_gradient) > 0.001) || sdr$pdHess == FALSE) {
  message("Model did not converge: check results")
} else {
  message("Model diagnostics consistent with convergence")
}

# ------------------------------------------------------------------------------
# plot it 
boxplot(y_obs ~ pond, ylab = "length (mm)", 
        main = "distribution of lengths")

# extract the best estimates of mean length for each pond:
mles = exp(sdr$par.fixed["ln_mu"]) + sdr$par.random
abline(a = exp(sdr$par.fixed["ln_mu"]), b = 0, 
       lty = 3, lwd = 3)
points(mles, pch = 16, col = "steelblue")

