norm.z.quantile <- function(z, quant.int = seq(0.2, 1, 0.02)) {
    z[which(is.infinite(z))] = NA  ## Remove infinite values
    non.na.i = which(!is.na(z) & z != 0)
    z.non.na = z[non.na.i]
    sigma.est = sapply(quant.int, function(qi) fdrtool::censored.fit(z.non.na, stats::quantile(abs(z.non.na), 
        probs = qi, na.rm = TRUE))[5])
    sigma.est = sigma.est[which.min(abs(diff(sigma.est)))]
    return(z/sigma.est)
} 
