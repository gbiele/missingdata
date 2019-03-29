mar_dag = dagitty(
  "
  E  E @1,0
  O  U @0,1
  A  E @-1,0
  O* O @1,2
  R_O A @2,1
  
  A O
  E R_O
  E O
  O O*
  R_O O*
  "
)

mar_dag = gsub("^R_O -> \\\"O\\*\\\"","R_O -> \\\"O\\*\\\" [beta = .75]", mar_dag)
mar_dag = gsub("O -> \\\"O\\*\\\"","O -> \\\"O\\*\\\" [beta = .75]", mar_dag)


drawdag(mar_dag)

dag = mar_dag

my_latents = latents(dag)
latents(dag) = ""
d = simulateSEM(dag,b.default = b.default, N = N)

d = sim_mDAG(mar_dag, b.default = .5)
lm(`O*` ~  E, d)
lm(O ~  E, d)