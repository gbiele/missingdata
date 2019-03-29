coefplot2 = function(fit1,fit2) {
  confint1 = confint(fit1,level = .9)
  confint2 = confint(fit2,level = .9)
  par (mar=c(3,5,.1,1), mgp=c(2,.7,0), tck=-.01)
  ylim = c(.75,2.75)
  plot(0,type = "n",
       xlim = range(cbind(confint2,
                          confint1)),
       ylim = ylim,
       yaxt = "n", ylab = "",
       xlab = "standardized effect")
  axis(2,at = .125+1:2,
       labels = names(coef(fit_mar)),
       las = 2)
  rect(xleft = -.1,ybottom = 0,xright = .1,ytop = 5,
       col = adjustcolor("green4",alpha = .3), border = NA)
  abline(v = 0)
  points(coef(fit1),1:2, pch = 16,cex = 2)
  segments(x0 = confint1[,1],
           x1 = confint1[,2],
           y0 = 1:2)
  points(coef(fit2),.25+1:2, pch = 16,cex = 2, col = "red")
  segments(x0 = confint2[,1],
           x1 = confint2[,2],
           y0 = .25+1:2,
           col = "red")
  legend("topright",
         bty = "n",
         pch = 16,
         col = c("black","red"),
         legend = c("MCAR","MAR"),
         ncol = 2, cex = 1.5)
}


sim_mDAG = function(dag, b.default = .5, N = 1000) {
  my_latents = latents(dag)
  latents(dag) = ""
  d = simulateSEM(dag,b.default = b.default, N = N,standardized = F)

  for (v in my_latents) {
    d[,paste0(v,"*")] = d[,v]
    if (paste0("R_",v) %in% names(d)) {
      d[,paste0("R_",v)] = d[,paste0("R_",v)] > -1
      d[!d[,paste0("R_",v)],paste0(v,"*")] = NA  
    }
    
  }
  
  return(d)
}