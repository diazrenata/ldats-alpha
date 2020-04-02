ldats_wrapper <- function(data_list, nseed, ntopics, ncpts, formulas) {
  
  data_list$document_covariate_table <- as.data.frame(data_list$document_covariate_table)
  
  thislda <- LDATS::LDA_set(data_list$document_term_table, topics = ntopics, nseeds = nseed)
  
  
  if(formulas == "time") {
    
    thists <-  LDATS::TS_on_LDA(LDA_models = thislda, document_covariate_table = data_list$covariates, nchangepoints = ncpts, formulas = c(~ timestep), weights =LDATS::document_weights(data_list$document_term_table), timename = "timestep")
    
  } else (
    
    thists <-  LDATS::TS_on_LDA(LDA_models = thislda, document_covariate_table = data_list$document_covariate_table, nchangepoints = ncpts, formulas = c(~ 1), weights =LDATS::document_weights(data_list$document_term_table), timename = "timestep")
    
  )

  return(list(data = data_list,
              lda = thislda,
              ts = thists))
  
}
