library(brms)
options(mc.cores = 4)

bform <- bf(Ox | mi() ~ E) 

parameters_code = "
corr_matrix[4] Omega;
vector<lower=0>[4] tau;
vector[4] mus;
"


model_code = "
mus ~ normal(0,2);
tau ~ normal(0,2);
Omega ~ lkj_corr(2.0);


for (i in 1:N) {
  target += multi_normal_lpdf(to_vector({M[i],iEL[i],Yl[i]}) | 
                              mus,
                              quad_form_diag(Omega,tau));
}
"

stanvars = 
  stanvar(x = as.vector(mar_interaction_data$E),
          name = "E") +
  stanvar(x = as.vector(mar_interaction_data$M),
          name = "M") +
  stanvar(x = as.vector(mar_interaction_data$E*scale(as.numeric(mar_interaction_data$L))),
          name = "iEL") +
  stanvar(x = as.vector(scale(as.numeric(mar_interaction_data$L))),
          name = "L") +
  stanvar(block = "parameters",
          scode = parameters_code) +
  stanvar(block = "model",
          scode = model_code) 

fit_imp2 <- brm(bform,
                data = mar_interaction_data,
                stanvars = stanvars,
                chains = 1)

standata = make_standata(bform, data = mar_interaction_data, stanvars = stanvars)