mar_milk = dagitty(
"
M 1 @1,0
U U @2,0
B U @3,0
K O @2,1
R_B 1 @2,-1
B* E @3,-1

M R_B K
R_B B*
U M B
B B* K
"
)

drawdag(mar_milk)

U = rnorm(N)
M = U + rnorm(N)
B = -U + rnorm(N)
K = M + B + rnorm(N)
R_B = M + rnorm(N)
`B*` = B
`B*`[R_B > 0] = NA 

No bias in MAR?
U = rnorm(N)
M = U + rnorm(N)
B = -U + rnorm(N)
K = M + B + rnorm(N)
R_B = M + rnorm(N)
Bobs = B 
Bobs[R_B > 0] = NA
lm(K ~ B + M)
lm(K ~ Bobs + M)
Why don't I see bias in the estimate of the 2md model?