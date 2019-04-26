// generated with brms 2.5.0
functions { 
} 
data { 
  int<lower=1> N;  // total number of observations 
  vector[N] Y;  // response variable 
  int<lower=0> Nmi;  // number of missings 
  int<lower=1> Jmi[Nmi];  // positions of missings 
  int<lower=1> K;  // number of population-level effects 
  matrix[N, K] X;  // population-level design matrix 
  int prior_only;  // should the likelihood be ignored? 
  vector[500] E;
  vector[500] M;
  vector[500] L;
  vector[500] iEL;
} 
transformed data { 
  int Kc = K - 1; 
  matrix[N, K - 1] Xc;  // centered version of X 
  vector[K - 1] means_X;  // column means of X before centering 
  for (i in 2:K) { 
    means_X[i - 1] = mean(X[, i]); 
    Xc[, i - 1] = X[, i] - means_X[i - 1]; 
  } 
} 
parameters { 
  vector[Nmi] Ymi;  // estimated missings
  vector[Kc] b;  // population-level effects 
  real temp_Intercept;  // temporary intercept 
  real<lower=0> sigma;  // residual SD 

corr_matrix[4] Omega;
vector<lower=0>[4] tau;
vector[4] mus;

corr_matrix[2] xOmega;
real<lower=0> xtau;
real xmu;

} 
transformed parameters {
  cov_matrix[4] Sigma = quad_form_diag(Omega,tau);
  cov_matrix[2] xSigma = quad_form_diag(xOmega,to_vector({tau[2],xtau}));
  //Sigma[2,4] = 1;
  //Sigma[4,2] = 1;
} 
model { 
  vector[N] Yl = Y;
  vector[N] mu = temp_Intercept + Xc * b;

  mus ~ normal(0,2);
  tau ~ normal(0,2);
  Omega ~ lkj_corr(2.0);
  xmu ~ normal(0,2);
  xtau ~ normal(0,2);
  xOmega ~ lkj_corr(2.0);
  

  Yl[Jmi] = Ymi;
  // priors including all constants 
  target += student_t_lpdf(temp_Intercept | 3, 0, 10); 
  target += student_t_lpdf(sigma | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10); 
  // likelihood including all constants 
  if (!prior_only) { 
    target += normal_lpdf(Yl | mu, sigma);
  } 
  
  for (i in 1:N) {
  target += multi_normal_lpdf(to_vector({Yl[i],M[i],iEL[i],L[i]}) | 
                              mus,
                              Sigma);
  target += multi_normal_lpdf(to_vector({M[i],E[i]}) | 
                              to_vector({mus[2],xmu}),
                              xSigma);
  }
} 
generated quantities { 
  // actual population-level intercept 
  real b_Intercept = temp_Intercept - dot_product(means_X, b); 
} 
