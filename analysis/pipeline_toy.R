library(drake)
library(MATSS)
library(LDATS)
source(here::here("fxns", "fxns.R"))


toy_names <- list.files(here::here("data")) 
toy_names <- unlist(strsplit(toy_names, split = ".csv"))

pipeline <- drake_plan(
  dat = target(load_toy_data(toy_path = toy_name),
               transform = map(toy_name = !!toy_names)),
  conf = target(conform_data(data = dat, control = LDA_control()),
                transform = map(dat)),
  lda = target(LDATS::LDA(data = conf,topics = 2:5, replicates = 2),
               transform = map(conf)),
  classic =  target(LDATS::TS(LDAs = lda, formulas = ~1, nchangepoints = 0:1, 
                              control = list(response = multinom_TS,
                                                   method_args = list(control = ldats_classic_control(nit = 1000))), 
                              timename = "timestep"),
                    transform = map(lda))#,
  # simplex_alr = target(LDATS::TS(LDAs = lda, formulas = ~1, nchangepoints = 0:1, 
  #                        control = list(response = simplex_TS,
  #                                             method_args = list(control = ldats_classic_control(nit = 100)),
  #                                             response_args = list(control = simplex_TS_control(transformation = rlang::expr(alr)))), 
  #                        timename = "timestep"),
  #              transform = map(lda)),
  # simplex_ilr = target(LDATS::TS(LDAs = lda, formulas = ~1, nchangepoints = 0:1, 
  #                        control = list(response = simplex_TS,
  #                                             method_args = list(control = ldats_classic_control(nit = 100)),
  #                                             response_args = list(control = simplex_TS_control(transformation = rlang::expr(ilr)))), 
  #                        timename = "timestep"),
  #              transform = map(lda))
)



## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("drake", "drake-cache-toy.sqlite"))
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
       cache_log_file = here::here("drake", "cache_log_toy.txt"),
       verbose = 2,
       parallelism = "future",
       jobs = 4,
       caching = "master") # Important for DBI caches!
} else {
  # Run the pipeline on a single local core
  system.time(make(pipeline, cache = cache, cache_log_file = here::here("drake", "cache_log_toy.txt")))
}
