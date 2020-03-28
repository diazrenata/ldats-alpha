library(drake)
library(MATSS)
library(LDATS)
source(here::here("fxns", "fxns.R"))

dat_plan <- MATSS::build_datasets_plan(include_retriever_data = F)

dat_targets <- rlang::syms(dat_plan$target)
  
lda_plan <- drake_plan(
  t = target(reformat_matss_data(matss_data = dat),
                transform = map(dat = !!dat_targets)),
  c = target(conform_data(data = t, control = LDA_control()),
             transform = map(t)),
  plain = target(LDATS::LDA(data = c,topics = 2:3, replicates = 2),
                 transform = map(c)),
  one = target(LDATS::LDA(data = c,topics = 1:2, replicates = 2),
                 transform = map(c)),
  gibbs = target(LDATS::LDA(data = c,topics = 2:3, replicates = 2, control = LDA_control(model_args = list(method = "Gibbs"))),
                 transform = map(c)),
  all_plain = target(list(plain),
                     transform = combine(plain)),
  all_one = target(list(one),
                   transform = combine(one)),
  all_gibbs = target(list(gibbs),
                     transform = combine(gibbs))
)

pipeline <- dplyr::bind_rows(dat_plan, lda_plan)

## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("drake", "drake-cache-MATSS.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)


## View the graph of the plan
if (interactive())
{
  config <- drake_config(pipeline, cache = cache)
  sankey_drake_graph(config, build_times = "none")  # requires "networkD3" package
  vis_drake_graph(config, build_times = "none")     # requires "visNetwork" package
}


## Run the pipeline
nodename <- Sys.info()["nodename"]
if(grepl("ufhpc", nodename)) {
  library(future.batchtools)
  print("I know I am on SLURM!")
  ## Run the pipeline parallelized for HiPerGator
  future::plan(batchtools_slurm, template = "slurm_batchtools.tmpl")
  make(pipeline,
       force = TRUE,
       cache = cache,
       cache_log_file = here::here("drake", "cache_log_MATSS.txt"),
       verbose = 2,
       parallelism = "future",
       jobs = 128,
       caching = "master") # Important for DBI caches!
} else {
  # Run the pipeline on a single local core
  system.time(make(pipeline, cache = cache, cache_log_file = here::here("drake", "cache_log_MATSS.txt")))
}
