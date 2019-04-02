coefplot2 = function(fit1,fit2 = NULL, ttl = "") {
  confint1 = confint(fit1,level = .9)
  if (!is.null(fit2)) {
    confint2 = confint(fit2,level = .9)
    xlim = range(cbind(confint2,
                       confint1))
  } else {
    xlim = range(confint1)
  }
  
  x = 1:length(coef(fit1))
  
  par (mar=c(3,6,1.25,1), mgp=c(2,.7,0), tck=-.01)
  
  ylim = c(min(x)-.25,max(x)+.25)
  
  plot(0,type = "n",
       xlim = xlim,
       ylim = ylim,
       yaxt = "n", ylab = "",
       xlab = "standardized effect")
  axis(2,at = .125+x,
       labels = names(coef(fit1)),
       las = 2)
  rect(xleft = -.1,ybottom = 0,xright = .1,ytop = 5,
       col = adjustcolor("green4",alpha = .3), border = NA)
  abline(v = 0)
  points(coef(fit1),x, pch = 16,cex = 2)
  segments(x0 = confint1[,1],
           x1 = confint1[,2],
           y0 = x)
  if (!is.null(fit2)) {
    points(coef(fit2),.25+x, pch = 16,cex = 2, col = "red")
    segments(x0 = confint2[,1],
             x1 = confint2[,2],
             y0 = .25+x,
             col = "red")
    legend("bottomright",
           bty = "n",
           pch = 16,
           col = c("black","red"),
           legend = c("MCAR","MAR"),
           ncol = 2, cex = 1.5)
    
  }
    mtext(paste0("Model: ",ttl), line = 0)
}


sim_mDAG = function(dag, b.default = .5, N = 1000, seed = 1) {
  set.seed(seed)
  my_latents = latents(dag)
  latents(dag) = ""
  d = simulateSEM(dag,b.default = b.default, N = N,standardized = F)

  for (v in my_latents) {
    d[,paste0(v,"*")] = d[,v]
    if (paste0("R_",v) %in% names(d)) {
      d[,paste0("R_",v)] = d[,paste0("R_",v)] > 0
      d[!d[,paste0("R_",v)],paste0(v,"*")] = NA  
    }
    
  }
  
  return(d)
}

plot_coefs = function(es, clrs = NULL) {
  
  k = nrow(es)
  
  if(is.null(clrs))
    clrs = c("green4",rep("black",k-1))
  
  
  par (mar=c(3,3,2,1), mgp=c(2,.7,0), tck=-.01)
  
  
  plot(es[,1],
       1:k,
       pch = 16,
       xlim = range(es),
       ylim = c(.5,k+.5),
       yaxt = "n", ylab = "",
       xlab = "effect size",
       col = clrs)
  segments(x0 = es[,2],
           x1 = es[,3],
           y0 = 1:k,
           col = clrs)
  text(es[,1],1:k,
       row.names(es),
       pos = 3)
}

get_esci = function(fit) {
  return(cbind(coef(fit),
               confint(fit)))
}
