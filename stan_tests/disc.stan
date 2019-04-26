data {
  int N;
  int K;
  vector[N] y;
  vector[N] m;
  vector[N] e;
  vector[N] el;
  int nmiss;
  int missidx[nmiss];
}
parameters {
  real intercept;
  real b;
  real<lower=0> sigma;
  corr_matrix[K] Omega;
  vector[K] mu;
  vector<lower=0>[K] tau;
  vector[nmiss] yimp;
}
model {
  // omitting priors to keep this shorter
  vector[N] yl = y;
  matrix[4,4] Sigma = quad_form_diag(Omega,tau); 
  yl[missidx] = yimp;
  
  target += normal_lpdf(yl | intercept + e*b,sigma);
  for (n in 1:N) {
    vector[K] vec = to_vector({yl[n],e[n],el[n],m[n]});
    target += multi_normal_lpdf(vec | mu, Sigma);
  }
}
