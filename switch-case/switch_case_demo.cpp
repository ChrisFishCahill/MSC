#include <TMB.hpp>
/*
 *          switch-case demonstration
 *            cahill QFC june 2023
 */
template <class Type>
Type objective_function<Type>::operator()()
{
  DATA_INTEGER(selmode); // selectivity indicator variable
  PARAMETER(b0);         // not real, just a filler 
  Type a = 100; Type b = 200; Type c = 300; 
  switch(selmode){
    case 0:
      REPORT(a);
      break;
      
    case 1:
      REPORT(b);
      break;
      
    case 2:
      REPORT(c);
      break;
      
    default:
      std::cout<<"selmode not yet implemented."<<std::endl;
    exit(EXIT_FAILURE);
    break;
  }
  return(0);
}
