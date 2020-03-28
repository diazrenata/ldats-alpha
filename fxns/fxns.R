reformat_matss_data <- function(matss_data) {
  matss_data <- matss_data[c("abundance", "covariates")]
  names(matss_data) <- c("document_term_table", "document_covariate_table")
  return(matss_data)
}

load_toy_data <- function(toy_path) {
  toy_data <- list()
  toy_data$document_term_table <- read.csv(here::here("data", paste0(toy_path, ".csv")), stringsAsFactors = F)
  toy_data$document_covariate_table <- data.frame(
    timestep = 1:nrow(toy_data$document_term_table)
  )
  
  return(toy_data)
  
}

  