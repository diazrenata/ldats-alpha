reformat_matss_data <- function(matss_data) {
  matss_data <- matss_data[c("abundance", "covariates")]
  names(matss_data) <- c("document_term_table", "document_covariate_table")
  return(matss_data)
}
