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
  matrix[N, 4] mi_X;
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

  real mi_Intercept;
  vector[4] mi_b;
  real<lower=0> mi_sigma;

} 

model { 
  vector[N] Yl = Y;
  vector[N] mu = temp_Intercept + Xc * b;
  
  target += student_t_lpdf(mi_Intercept | 3, 0, 10); 
  target += student_t_lpdf(mi_sigma | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10); 

  Yl[Jmi] = Ymi;
  // priors including all constants 
  target += student_t_lpdf(temp_Intercept | 3, 0, 10); 
  target += student_t_lpdf(sigma | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10); 
  // likelihood including all constants 
  if (!prior_only) { 
    target += normal_lpdf(Yl | mu, sigma);
    target += normal_lpdf(Yl | mi_Intercept + mi_X * mi_b, mi_sigma)*100;
  } 
  
  
  
} 
generated quantities { 
  // actual population-level intercept 
  real b_Intercept = temp_Intercept - dot_product(means_X, b); 
} 
