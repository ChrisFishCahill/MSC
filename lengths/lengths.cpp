#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  DATA_VECTOR(y_obs);       // observed data
  DATA_INTEGER(n_pond);      
  DATA_IVECTOR(pond);       // integer vector indicating pond
  
  PARAMETER(ln_mu);         // average length among lakes
  PARAMETER(ln_sd_among);   // sd among ponds
  PARAMETER(ln_sd_within);  // sd within ponds
  PARAMETER_VECTOR(eps);    // random effects - deviations from mu
  
  int n_obs = y_obs.size();
  Type mu = exp(ln_mu); 
  Type sd_among = exp(ln_sd_among);
  Type sd_within = exp(ln_sd_within);
  
  Type jnll = 0.0; 
  
  // Pr(random coefficients)
  for(int i = 0; i < n_pond; i++){
    jnll -= dnorm(eps(i), Type(0.0), sd_among, true);   
  }
  
  // Pr(data conditional on fixed and random effect values)
  for(int i = 0; i < n_obs; i++){
    jnll -= dnorm(y_obs(i), mu + eps(pond(i)), sd_within, true); 
  }
  
  return jnll;
}
