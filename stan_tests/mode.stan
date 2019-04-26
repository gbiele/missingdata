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
  vector[N] E;
  vector[N] M;
  vector[N] iEL;
} 
transformed data { 
  int Kc = K - 1; 
  matrix[N, K - 1] Xc;  // centered version of X 
  vector[K - 1] means_X;  // column means of X before centering 
  vector[2] cov_data1[N] = {M, E};
  vector[2] cov_data2[N] = {M, iEL};
  vector[2] cov_data3[N] = {E, iEL};

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
  cov_matrix[2] covs[5];
  real muM;
  real muE;
  real muiEL;
  real muY;
} 
transformed parameters { 
} 
model { 
  vector[N] Yl = Y;
  vector[N] mu = temp_Intercept + Xc * b;
  Yl[Jmi] = Ymi;
  // priors including all constants 
  target += student_t_lpdf(temp_Intercept | 3, 0, 10); 
  target += student_t_lpdf(sigma | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10); 
  // likelihood including all constants 
  if (!prior_only) { 
    target += normal_lpdf(Yl | mu, sigma);
  } 
  target += multi_normal_lpdf(cov_data1 | to_vector({muM, muE}), covs[1]);
  target += multi_normal_lpdf(cov_data2 | to_vector({muM, muiEL}), covs[2]);
  target += multi_normal_lpdf(cov_data3 | to_vector({muE, muiEL}), covs[3]);
  for (i in 1:N) {
    target += multi_normal_lpdf(to_vector({Yl[i],M[i]}) | to_vector({muY, muM}), covs[4]);
    target += multi_normal_lpdf(to_vector({Yl[i],iEL[i]}) | to_vector({muY, muiEL}), covs[5]);
  }
  
} 
generated quantities { 
  // actual population-level intercept 
  real b_Intercept = temp_Intercept - dot_product(means_X, b); 
} 
