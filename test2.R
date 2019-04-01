

mar_dag = dagitty("
E E @0,0
A U @1,0
B U @2,0
C U @3,0
R_A 1 @.5,-1
R_B 1 @1.5,-1
R_C 1 @2.5,-1
R_O 1 @3,1
O U @1.5,1
O* O @1.5,2
A* 1 @1,-2
B* 1 @2,-2
C* 1 @3,-2

A R_B A* E O
B R_C B* R_O
C R_A C* R_O
E R_A R_B R_C O
R_A A*
R_B B*
R_C C*
O O*
R_O O*
")


drawdag(mar_dag)

fiml_model = "
# Regression model 
O ~ b1*E + b2*A + b3*B + b3*C

# Variances
E ~~ E
A ~~ A
B ~~ B
C ~~ C

# Covariance/correlation
E ~~ A
E ~~ B
E ~~ C
A ~~ B
A ~~ C
B ~~ C
"
d = sim_mDAG(mar_dag)
dm = d
dm$A = d$`A*`
dm$B = d$`B*`
dm$C = d$`C*`
dm$O = d$`O*`
fit <- sem(fiml_model, dm, missing='fiml', meanstructure=TRUE, 
           fixed.x=FALSE)
bidx = grep("^b",fit@ParTable$label)
bs = fit@ParTable$est[bidx]
names(bs) = fit@ParTable$label[bidx]
bs
coef(lm(O ~ E + A + B + C, d))[-1]
coef(lm(`O*` ~ E + `A*` + `B*` + `C*`, d))[-1]
