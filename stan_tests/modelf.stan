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

corr_matrix[2] Omega[3];
vector<lower=0>[4] tau;
vector[4] mus;

} 

model { 
  vector[N] Yl = Y;
  vector[N] mu = temp_Intercept + Xc * b;
  
  Ymi ~ normal(0,6);
  mus ~ normal(0,5);
  target += student_t_lpdf(tau | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10); 
  for (k in 1:3)
    Omega[k] ~ lkj_corr(2.0);
  

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
    target += multi_normal_lpdf(to_vector({Yl[i],M[i]})  | mus[{1,2}], quad_form_diag(Omega[1],tau[{1,2}]))*100; 
    target += multi_normal_lpdf(to_vector({Yl[i],iEL[i]})| mus[{1,3}], quad_form_diag(Omega[2],tau[{1,3}]))*100; 
    target += multi_normal_lpdf(to_vector({E[i],M[i]})   | mus[{4,2}], quad_form_diag(Omega[3],tau[{4,2}]))*100;
  }
} 
generated quantities { 
  // actual population-level intercept 
  real b_Intercept = temp_Intercept - dot_product(means_X, b); 
  matrix[2,2] S1 = quad_form_diag(Omega[1],tau[{1,2}]);
  matrix[2,2] S2 = quad_form_diag(Omega[2],tau[{1,3}]);
  matrix[2,2] S3 = quad_form_diag(Omega[3],tau[{4,2}]);
} 
