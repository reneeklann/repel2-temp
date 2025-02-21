p <- 0.25 # 25% probability predicted by the model
lambda <- -log(1-p) # translates to frequency of introduction/year 0.288

n_years <- 20 
n_years_country <- n_years * 150 
n_years_country_disease <- n_years_country * 50

n_simulations = 1000

# Simple simulation of Poisson distribution
rpois(n = n_simulations, lambda = lambda)

# binomial confidence
binom::binom.confint(x = p*n_years_country_disease, n = n_years_country_disease)

# binomial simulation
instances <- rbinom(n = n_simulations, size = n_years, p)
ggdist::hdci(instances/n_years) # rate per year

# could cluster the training set - binning 
