library(LDATS)
source(here::here("fxns", "fxns.R"))

dat = load_toy_data("static")
dat = conform_data(dat, control = LDA_control())
dat_lda = LDATS::LDA(data = dat,topics = 4, replicates = 2)

# classic works
classic =  LDATS::TS(LDAs = dat_lda, formulas = ~1, nchangepoints = 0:1,
                     timename = "timestep",
                     control = list(response = multinom_TS, 
                                    method_args = 
                                      list(control = ldats_classic_control(nit = 100))))

# alr, ilr work
simplex_alr = LDATS:: TS(LDAs = dat_lda, formulas = ~ 1, nchangepoints = 0:1, 
                     timename = "timestep",
                     control = list(response = simplex_TS,
                                    method_args = 
                                      list(control = ldats_classic_control(nit = 100)),
                                    response_args = list(control = simplex_TS_control(transformation = rlang::expr(alr)))))

simplex_ilr = LDATS:: TS(LDAs = dat_lda, formulas = ~ 1, nchangepoints = 0:1, 
                     timename = "timestep",
                     control = list(response = simplex_TS,
                                    method_args = 
                                      list(control = ldats_classic_control(nit = 100)),
                                    response_args = list(control = simplex_TS_control(transformation = rlang::expr(ilr)))))

# clr errors
simplex = LDATS:: TS(LDAs = dat_lda, formulas = ~ 1, nchangepoints = 0:1, 
                     timename = "timestep",
                     control = list(response = simplex_TS,
                                    method_args = 
                                      list(control = ldats_classic_control(nit = 100)),
                                    response_args = list(control = simplex_TS_control(transformation = rlang::expr(clr)))))

# Error message: 
#----- Time Series Analyses -----
# - data subset 1, 4 topics, replicate 2, gamma ~ 1, 0 change points
# - estimating regressor distribution
# Error in TSs[[i]] : subscript out of bounds 

# Traceback
# 5.
# paste0("  - data subset ", TS$data_subset) at TS.R#259
# 4.
# TS_msg(TS = TS) at TS.R#246
# 3.
# TS_call(TS = TSs[[i]]) at TS.R#235
# 2.
# run_TS(TSs = TSs) at TS.R#208
# 1.
# LDATS::TS(LDAs = dat_lda, formulas = ~1, nchangepoints = 0:1, 
#           timename = "timestep", control = list(response = simplex_TS, 
#                                                 method_args = list(control = ldats_classic_control(nit = 100)), 
#                                                 response_args = list(control = simplex_TS_control(transformation = rlang::expr(clr)))))

# Troubleshooting in LDATS functions:

LDAs = dat_lda
formulas = ~1
nchangepoints = 0:1
timename = "timestep"
control = list(response = simplex_TS, 
               method_args = list(control = ldats_classic_control(nit = 100)), 
               response_args = list(control = simplex_TS_control(transformation = rlang::expr(ilr))))
weights = NULL

# from LDATS::TS
TSs <- prepare_TS(LDAs = LDAs, formulas = formulas,
                  nchangepoints = nchangepoints, timename = timename,
                  weights = weights, control = control)
#TSs <- run_TS(TSs = TSs)

# from LDATS::run_TS
nTS <- length(TSs)
nTS

TSs[[1]]
TSs[[2]]

for (i in 1:nTS){
  TSs[[i]] <- TS_call(TS = TSs[[i]])
}

# breaks when i = 2  
# looks like TSs gets converted to a list of 1 element after one trip through the for loop.

TS_call(TS = TSs[[1]])
# - data subset 1, 4 topics, replicate 2, gamma ~ 1, 0 change points
# - estimating regressor distribution
# NULL

TS_call(TS = TSs[[2]])
# - data subset 1, 4 topics, replicate 2, gamma ~ 1, 1 change point
# - estimating change point distribution
# $error
# [1] "argument is of length zero"


# Are those expected outcomes for TS_call? Trying with classic:

LDAs = dat_lda
formulas = ~1
nchangepoints = 0:1
timename = "timestep"
control = list(response = multinom_TS, 
               method_args = list(control = ldats_classic_control(nit = 100)))
weights = NULL

# from LDATS::TS
TSs <- prepare_TS(LDAs = LDAs, formulas = formulas,
                  nchangepoints = nchangepoints, timename = timename,
                  weights = weights, control = control)

# from LDATS::run_TS
nTS <- length(TSs)
nTS

TS_call(TS = TSs[[1]])
# - data subset 1, 4 topics, replicate 2, gamma ~ 1, 0 change points
# - estimating regressor distribution
# $data_subset
# [1] "1"
# 
# $formula
# gamma ~ 1
# <environment: 0x0000020669900700>
#   
#   $nchangepoints
# [1] 0
# 
# $timename
# [1] "timestep"
# 
# $topics
# [1] 4
# 
# $replicate
# [1] 2
# 
# $eta_summary
# Mean Median Lower_95% Upper_95%     SD MCMCerr    AC10 ESS
# 1_2:(Intercept) 0.1945 0.2403   -0.7935    0.9792 0.4997  0.0500 -0.0022 100
# 1_3:(Intercept) 0.3316 0.3282   -0.5546    1.1239 0.4768  0.0477  0.0531 100
# 1_4:(Intercept) 0.4800 0.4924   -0.4092    1.4211 0.4859  0.0486 -0.0008 100
# 
# $logLik
# [1] -41.28933
# 
# $nparams
# [1] 3

TS_call(TS = TSs[[2]])
# - data subset 1, 4 topics, replicate 2, gamma ~ 1, 1 change point
# - estimating change point distribution
# - estimating regressor distribution                     
# $data_subset                                                
# [1] "1"
# 
# $formula
# gamma ~ 1
# <environment: 0x000002066b073cf8>
#   
#   $nchangepoints
# [1] 1
# 
# $timename
# [1] "timestep"
# 
# $topics
# [1] 4
# 
# $replicate
# [1] 2
# 
# $rho_summary
# Mean Median Mode Lower_95% Upper_95%   SD MCMCerr   AC10      ESS
# Changepoint_1 15.81   16.5   20         2        27 7.22   0.722 0.1869 40.92401
# 
# $eta_summary
# Mean Median Lower_95% Upper_95%     SD MCMCerr    AC10      ESS
# 1_2:(Intercept) 0.0719 0.1270   -1.6330    1.3322 0.8545  0.0854 -0.0681 100.0000
# 1_3:(Intercept) 0.0971 0.0314   -2.4302    1.7634 0.9763  0.0976  0.0177 100.0000
# 1_4:(Intercept) 0.2769 0.3751   -2.0626    1.8562 0.9948  0.0995 -0.0727 142.2556
# 2_2:(Intercept) 0.2122 0.2716   -2.2289    1.8870 1.2307  0.1231 -0.0870 100.0000
# 2_3:(Intercept) 0.4296 0.4343   -1.6918    2.1567 0.9599  0.0960  0.1825 100.0000
# 2_4:(Intercept) 0.6906 0.6483   -0.7531    2.6349 0.8953  0.0895 -0.1167 100.0000
# 
# $logLik
# [1] -41.15909
# 
# $nparams
# [1] 7
