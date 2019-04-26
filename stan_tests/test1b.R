mar_mediator_dag = dagitty("
  M  1 @1,0
  O  U @0,1
  E  1 @-1,0
  O* O @1,2
  R_O 1 @2,1
  
  M O R_O
  E O M
  O O*
  R_O O*
")

mar_dag = gsub("^R_O -> \\\"O\\*\\\"","R_O -> \\\"O\\*\\\" [beta = .75]", mar_dag)
mar_dag = gsub("O -> \\\"O\\*\\\"","O -> \\\"O\\*\\\" [beta = .75]", mar_dag)


drawdag(mar_mediator_dag)

dag = mar_dag

my_latents = latents(dag)
latents(dag) = ""

N = 1000
E  = rnorm(N)
M = E + rnorm(N)
O = E + M + rnorm(N)
R_O = M + rnorm(N)
`O*` = O
`O*`[R_O < 0] = NA

lm(`O*` ~  E + M)
lm(`O*` ~  E)
lm(O ~  E)
library(lavaan)
model <- '
# Regression model 
Ox ~ E

# Variances
Ox ~~ M
E ~~ M
'
ldata = data.frame(E = E,
                   M = M,
                   Ox = `O*`)

fit <- sem(model, ldata, missing='fiml', meanstructure=TRUE, 
           fixed.x=FALSE)

ifit = lm(`O*` ~ E + M)
imputed = predict(ifit,newdata = data.frame(E = E[R_O < 0],M = M[R_O < 0]))
Oxx = O
Oxx[R_O < 0] = imputed
lm(Oxx ~ E)
lm(O ~ E)

library(brms)
bform = bf(Ox | mi() ~ E) 
fit_imp2 <- brm(bform, data = ldata)