library(TMB)
compile("switch-case/switch_case_demo.cpp")
dyn.load(dynlib("switch-case/switch_case_demo"))
data = list(selmode = 0L) # can be 0, 1, 2
parameters = list(b0 = 1) # fake value

data
obj <- MakeADFun(data, parameters, DLL = "switch_case_demo")
obj$report()

data$selmode = 1
obj <- MakeADFun(data, parameters, DLL = "switch_case_demo")
obj$report()

data$selmode = 2
obj <- MakeADFun(data, parameters, DLL = "switch_case_demo")
obj$report()

data$selmode = 4
obj <- MakeADFun(data, parameters, DLL = "switch_case_demo")
obj$report()


