rodents <- MATSS::get_portal_rodents()

rodents <- reformat_matss_data(rodents)

c_rodents <- LDATS:::conform_data(rodents, control = LDA_control())

lda_set_rodents_old <- LDATS::LDA(c_rodents, topics = 2:3, replicates = 2)
lda_set_rodents_onetopic <- LDATS::LDA(c_rodents, topics = 1:2, replicates = 2)
lda_set_rodents_gibbs <- LDATS::LDA(c_rodents, topics = 2:3, replicates = 2, control = LDA_control(model_args = list(method = "Gibbs")))
