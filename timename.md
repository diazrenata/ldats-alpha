Timename
================

``` r
library(MATSS)
library(LDATS)
source(here::here("fxns", "fxns.R"))

dat <- load_toy_data("directional")
names(dat)
```

    ## [1] "document_term_table"      "document_covariate_table"

``` r
head(dat$document_covariate_table)
```

    ##   timestep
    ## 1        1
    ## 2        2
    ## 3        3
    ## 4        4
    ## 5        5
    ## 6        6

``` r
head(dat$document_term_table)
```

    ##   V1 V2 V3 V4 V5 V6 V7
    ## 1  3  0  2  3  3  6 28
    ## 2  6  0  4  1  3  6 25
    ## 3  8  0  7  0  2  7 16
    ## 4 10  0  7  0  2  5 18
    ## 5 10  0  9  0  3  8 16
    ## 6 18  0 11  0  2  6 12

``` r
cdat <- conform_data(dat, control = LDA_TS_control())
names(cdat[[1]]$train)
```

    ## [1] "document_term_table"      "document_covariate_table"

``` r
head(cdat[[1]]$train$document_covariate_table)
```

    ## [1] 1 2 3 4 5 6

``` r
head(cdat[[1]]$train$document_term_table)
```

    ##   V1 V2 V3 V4 V5 V6 V7
    ## 1  3  0  2  3  3  6 28
    ## 2  6  0  4  1  3  6 25
    ## 3  8  0  7  0  2  7 16
    ## 4 10  0  7  0  2  5 18
    ## 5 10  0  9  0  3  8 16
    ## 6 18  0 11  0  2  6 12

``` r
lda_cdat <- LDA(cdat, topics = c(2:3))
```

    ## ----- Linguistic Decomposition Analyses -----

    ##   - data subset 1, 2 topics, replicate 1

    ##   - data subset 1, 3 topics, replicate 1

The following fail:

``` r
ts_cdat <- TS(lda_cdat, formulas = ~1, nchangepoints = 0, timename = "timestep")

# Error in check_timename(LDAs = LDAs, timename = timename) : 
#  timename not present in document covariate table

ts_cdat <- TS(lda_cdat, formulas = ~1, nchangepoints = 0, timename = "time")

# Error in check_timename(LDAs = LDAs, timename = timename) : 
#  timename not present in document covariate table

ts_cdat <- TS(lda_cdat, formulas = ~1, nchangepoints = 0, timename = "")

# Error in check_timename(LDAs = LDAs, timename = timename) : 
#  timename not present in document covariate table
```
