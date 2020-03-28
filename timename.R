library(MATSS)
library(LDATS)
source(here::here("fxns", "fxns.R"))

dat <- load_toy_data("directional")
names(dat)
head(dat$document_covariate_table)
head(dat$document_term_table)

cdat <- conform_data(dat, control = LDA_TS_control())
names(cdat[[1]]$train)
head(cdat[[1]]$train$document_covariate_table)
head(cdat[[1]]$train$document_term_table)

lda_cdat <- LDA(cdat, topics = c(2:3))

ts_cdat <- TS(lda_cdat, formulas = ~1, nchangepoints = 0, timename = "timestep")

ts_cdat <- TS(lda_cdat, formulas = ~1, nchangepoints = 0, timename = "time")

ts_cdat <- TS(lda_cdat, formulas = ~1, nchangepoints = 0, timename = "")
