Exploring subsetting functions
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

    ##   timestep
    ## 1        1
    ## 2        2
    ## 3        3
    ## 4        4
    ## 5        5
    ## 6        6

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

Playing with `conform_data` to generate subsets…

#### Systematic leave one out

``` r
dat_systematic_loo <- conform_data(dat, control = list(nsubsets = 30, rule = systematic_loo))

names(dat_systematic_loo)
```

    ##  [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10" "11" "12" "13" "14" "15"
    ## [16] "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"

``` r
str(dat_systematic_loo[[1]])
```

    ## List of 2
    ##  $ test :List of 2
    ##   ..$ document_term_table     :'data.frame': 1 obs. of  7 variables:
    ##   .. ..$ V1: int 3
    ##   .. ..$ V2: int 0
    ##   .. ..$ V3: int 2
    ##   .. ..$ V4: int 3
    ##   .. ..$ V5: int 3
    ##   .. ..$ V6: int 6
    ##   .. ..$ V7: int 28
    ##   ..$ document_covariate_table:'data.frame': 1 obs. of  1 variable:
    ##   .. ..$ timestep: int 1
    ##  $ train:List of 2
    ##   ..$ document_term_table     :'data.frame': 29 obs. of  7 variables:
    ##   .. ..$ V1: int [1:29] 6 8 10 10 18 17 20 25 27 31 ...
    ##   .. ..$ V2: int [1:29] 0 0 0 0 0 0 0 0 0 0 ...
    ##   .. ..$ V3: int [1:29] 4 7 7 9 11 16 13 17 22 17 ...
    ##   .. ..$ V4: int [1:29] 1 0 0 0 0 0 0 0 0 0 ...
    ##   .. ..$ V5: int [1:29] 3 2 2 3 2 2 1 1 2 1 ...
    ##   .. ..$ V6: int [1:29] 6 7 5 8 6 6 9 9 8 10 ...
    ##   .. ..$ V7: int [1:29] 25 16 18 16 12 15 12 12 7 7 ...
    ##   ..$ document_covariate_table:'data.frame': 29 obs. of  1 variable:
    ##   .. ..$ timestep: int [1:29] 2 3 4 5 6 7 8 9 10 11 ...

``` r
dat_systematic_loo <- conform_data(dat, control = list(nsubsets = 10, rule = systematic_loo))

names(dat_systematic_loo)
```

    ##  [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10"

``` r
str(dat_systematic_loo[[10]])
```

    ## List of 2
    ##  $ test :List of 2
    ##   ..$ document_term_table     :'data.frame': 1 obs. of  7 variables:
    ##   .. ..$ V1: int 27
    ##   .. ..$ V2: int 0
    ##   .. ..$ V3: int 22
    ##   .. ..$ V4: int 0
    ##   .. ..$ V5: int 2
    ##   .. ..$ V6: int 8
    ##   .. ..$ V7: int 7
    ##   ..$ document_covariate_table:'data.frame': 1 obs. of  1 variable:
    ##   .. ..$ timestep: int 10
    ##  $ train:List of 2
    ##   ..$ document_term_table     :'data.frame': 29 obs. of  7 variables:
    ##   .. ..$ V1: int [1:29] 3 6 8 10 10 18 17 20 25 31 ...
    ##   .. ..$ V2: int [1:29] 0 0 0 0 0 0 0 0 0 0 ...
    ##   .. ..$ V3: int [1:29] 2 4 7 7 9 11 16 13 17 17 ...
    ##   .. ..$ V4: int [1:29] 3 1 0 0 0 0 0 0 0 0 ...
    ##   .. ..$ V5: int [1:29] 3 3 2 2 3 2 2 1 1 1 ...
    ##   .. ..$ V6: int [1:29] 6 6 7 5 8 6 6 9 9 10 ...
    ##   .. ..$ V7: int [1:29] 28 25 16 18 16 12 15 12 12 7 ...
    ##   ..$ document_covariate_table:'data.frame': 29 obs. of  1 variable:
    ##   .. ..$ timestep: int [1:29] 1 2 3 4 5 6 7 8 9 11 ...

Systematically removing each year works. If you have nsubsets \<
ntimesteps, you get the first nsubsets timesteps removed.

#### Random LOO

``` r
dat_random_loo <- conform_data(dat, control = list(nsubsets = 30, rule = random_loo))

names(dat_random_loo)
```

    ##  [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10" "11" "12" "13" "14" "15"
    ## [16] "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"

``` r
str(dat_random_loo[[1]])
```

    ## List of 2
    ##  $ test :List of 2
    ##   ..$ document_term_table     :'data.frame': 1 obs. of  7 variables:
    ##   .. ..$ V1: int 34
    ##   .. ..$ V2: int 0
    ##   .. ..$ V3: int 24
    ##   .. ..$ V4: int 0
    ##   .. ..$ V5: int 0
    ##   .. ..$ V6: int 9
    ##   .. ..$ V7: int 1
    ##   ..$ document_covariate_table:'data.frame': 1 obs. of  1 variable:
    ##   .. ..$ timestep: int 14
    ##  $ train:List of 2
    ##   ..$ document_term_table     :'data.frame': 29 obs. of  7 variables:
    ##   .. ..$ V1: int [1:29] 3 6 8 10 10 18 17 20 25 27 ...
    ##   .. ..$ V2: int [1:29] 0 0 0 0 0 0 0 0 0 0 ...
    ##   .. ..$ V3: int [1:29] 2 4 7 7 9 11 16 13 17 22 ...
    ##   .. ..$ V4: int [1:29] 3 1 0 0 0 0 0 0 0 0 ...
    ##   .. ..$ V5: int [1:29] 3 3 2 2 3 2 2 1 1 2 ...
    ##   .. ..$ V6: int [1:29] 6 6 7 5 8 6 6 9 9 8 ...
    ##   .. ..$ V7: int [1:29] 28 25 16 18 16 12 15 12 12 7 ...
    ##   ..$ document_covariate_table:'data.frame': 29 obs. of  1 variable:
    ##   .. ..$ timestep: int [1:29] 1 2 3 4 5 6 7 8 9 10 ...

``` r
dat_random_loo <- conform_data(dat, control = list(nsubsets = 10, rule = random_loo))

names(dat_random_loo)
```

    ##  [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10"

``` r
str(dat_random_loo[[10]])
```

    ## List of 2
    ##  $ test :List of 2
    ##   ..$ document_term_table     :'data.frame': 1 obs. of  7 variables:
    ##   .. ..$ V1: int 35
    ##   .. ..$ V2: int 0
    ##   .. ..$ V3: int 28
    ##   .. ..$ V4: int 0
    ##   .. ..$ V5: int 0
    ##   .. ..$ V6: int 10
    ##   .. ..$ V7: int 0
    ##   ..$ document_covariate_table:'data.frame': 1 obs. of  1 variable:
    ##   .. ..$ timestep: int 18
    ##  $ train:List of 2
    ##   ..$ document_term_table     :'data.frame': 29 obs. of  7 variables:
    ##   .. ..$ V1: int [1:29] 3 6 8 10 10 18 17 20 25 27 ...
    ##   .. ..$ V2: int [1:29] 0 0 0 0 0 0 0 0 0 0 ...
    ##   .. ..$ V3: int [1:29] 2 4 7 7 9 11 16 13 17 22 ...
    ##   .. ..$ V4: int [1:29] 3 1 0 0 0 0 0 0 0 0 ...
    ##   .. ..$ V5: int [1:29] 3 3 2 2 3 2 2 1 1 2 ...
    ##   .. ..$ V6: int [1:29] 6 6 7 5 8 6 6 9 9 8 ...
    ##   .. ..$ V7: int [1:29] 28 25 16 18 16 12 15 12 12 7 ...
    ##   ..$ document_covariate_table:'data.frame': 29 obs. of  1 variable:
    ##   .. ..$ timestep: int [1:29] 1 2 3 4 5 6 7 8 9 10 ...

#### Leave p out

``` r
dat_p <- conform_data(dat, control = list(nsubsets = 30, rule = leave_p_out))
```

The above fails:

``` r
# Error in (function (data, p = 1, pre = 0, post = 0, random = TRUE, locations = NULL)  : unused argument (iteration = 1)
```

I don’t see how to pass the relevant arguments to `leave_p_out` via
`conform_data`. It looks like the args that get passed to whatever the
`rule` function is get specified at line 126 of `data_preparation.R` in
LDATS, and are currently fixed (see chunk below). I think the `unused
argument (iteration = 1)` message is because `conform_data` is set up to
run whatever `rule` is with the following:

``` r
        args <- list(data = dtt, iteration = i)
        test_train <- do.call(what = rule, args = args)
```

which works if `rule` is `systematic_loo` or `random_loo` because those
use `iteration`, but doesn’t work if `rule` is `leave_p_out`.

So maybe this points to a control list (within a list within a list………it
works\!\!) to feed the appropriate arguments to rule?

``` r
dat_p <- conform_data(dat, control = list(nsubsets = 30, rule = leave_p_out, rule_args = list(p = 1, pre = 1, post = 1, random = T)))
```

Or the option to supply a function with arguments specified as `rule`:

``` r
dat_p <- conform_data(dat, control = list(nsubsets = 30, rule = leave_p_out(p = 1, pre = 1, post = 1, random = T)))


# Fails with
# Error in NROW(data) : argument "data" is missing, with no default
```
