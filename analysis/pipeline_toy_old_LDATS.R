library(drake)
library(MATSS)
library(LDATS)
source(here::here("fxns", "fxns.R"))

remotes::install_github("weecology/LDATS@master")


toy_names <- list.files(here::here("data")) 
toy_names <- unlist(strsplit(toy_names, split = ".csv"))

pipeline <- drake_plan(
  dat = target(load_toy_data(toy_path = toy_name),
               transform = map(toy_name = !!toy_names)),
  conf = target(conform_data(data = dat, control = LDA_control()),
             transform = map(dat)),
  lda = target(LDATS::LDA(data = conf,topics = 2:5, replicates = 2),
                                transform = map(conf)),
  classic =  target(LDATS::TS(LDAs = lda, formulas = ~1, nchangepoints = c(0, 1), control = TS_control(response = multinom_TS), timename = "timestep"),
                    transform = map(lda))#,
  # alr = target(new_TS(lda = lda, response = "alr"),
  #              transform = map(lda)),
  # ilr = target(new_TS(lda = lda, response = "ilr"),
  #              transform = map(lda)),
  # clr = target(new_TS(lda = lda, response = "clr"),
  #              transform = map(lda))
)



#   
# lda_plan <- drake_plan(
#   t = target(reformat_matss_data(matss_data = dat),
#                 transform = map(dat = !!dat_targets)),
#   c = target(conform_data(data = t, control = LDA_control()),
#              transform = map(t)),
#   plain = target(LDATS::LDA(data = c,topics = 2:3, replicates = 2),
#                  transform = map(c)),
#   one = target(LDATS::LDA(data = c,topics = 1:2, replicates = 2),
#                  transform = map(c)),
#   gibbs = target(LDATS::LDA(data = c,topics = 2:3, replicates = 2, control = LDA_control(model_args = list(method = "Gibbs"))),
#                  transform = map(c)),
#   all_plain = target(list(plain),
#                      transform = combine(plain)),
#   all_one = target(list(one),
#                    transform = combine(one)),
#   all_gibbs = target(list(gibbs),
#                      transform = combine(gibbs))
# )


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
       jobs = 128,
       caching = "master") # Important for DBI caches!
} else {
  # Run the pipeline on a single local core
  system.time(make(pipeline, cache = cache, cache_log_file = here::here("drake", "cache_log_toy.txt")))
}
