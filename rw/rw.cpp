#include <TMB.hpp>

template<class Type>
bool is_NA(Type x){
  return R_IsNA(asDouble(x));
}
template<class Type>
Type objective_function<Type>::operator() ()
{
  DATA_VECTOR(y_obs);       // observed data

  PARAMETER(ln_sd_rw);     // log(sd) process
  PARAMETER(ln_sd_obs);    // log(sd) observation
  PARAMETER(lam0);         // initial state
  PARAMETER_VECTOR(lams);  // random effects
  
  int n_year = y_obs.size();
  Type sd_rw = exp(ln_sd_rw);
  Type sd_obs = exp(ln_sd_obs);
  
  Type jnll =- dnorm(lams(0), lam0, sd_rw, true);      // pr(inital state)
  
  for(int i=1; i<n_year; i++){
    jnll +=- dnorm(lams(i), lams(i-1), sd_rw, true);   // pr(subsequent states)
  }
  
  for(int i=0; i<n_year; i++){
    if(!is_NA(y_obs(i))){
      jnll +=- dnorm(y_obs(i), lams(i), sd_obs, true); // pr(observations)--> "likelihood"  
    }
  }
  
  return jnll;
}
