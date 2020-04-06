library(LDATS)
source(here::here("fxns", "fxns.R"))

dat = load_toy_data("directional")
dat = conform_data(dat, control = LDA_control())
dat_lda = LDATS::LDA(data = dat,topics = 2:5, replicates = 2)

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
# ----- Time Series Analyses -----
#   - data subset 1, 2 topics, replicate 1, gamma ~ 1, 0 change points
# - estimating regressor distribution
# - data subset 1, 2 topics, replicate 1, gamma ~ 1, 1 change point
# Error: orig_list must be a list