##' Following targeted normalization, some Quality Control graphs are produced to see if some bins were problematic. Several graphs will be created. First the distribution of each normalization statistic: correlation distance with the last supporting bin; average normalized coverage; number of outlier samples removed. Then pairwise comparison of these metrics are displayed.
##' @title QC graphs for Targeted Normalization
##' @param norm.stats the name of the file with the normalization statistics ('norm.stats' in 'tn.norm' function) or directly a 'norm.stats' data.frame.
##' @param out.pdf the name of the PDF file to create.
##' @param bin.size Should the metrics be compared to the bin size. Default is FALSE. Useful if the bins are not of equal size.
##' @return the name of the created PDF file.
##' @author Jean Monlong
##' @export
tn.norm.qc <- function(norm.stats, out.pdf = "normStats-QC.pdf", bin.size = FALSE) {
  ## load norm statistics
  if (is.character(norm.stats) & length(norm.stats) == 1) {
    headers = utils::read.table(norm.stats, nrows = 1, as.is = TRUE)
    colC = rep("NULL", length(headers))
    names(colC) = headers
    colC[c("chr", "start", "end", "d.max", "m", "sd", "nb.remove")] = c("character", 
                                                                        rep("integer", 2), rep("numeric", 4))
    res.df = utils::read.table(norm.stats, header = TRUE, colClasses = colC)
  } else {
    res.df = norm.stats[, c("chr", "start", "end", "d.max", "m", "sd", "nb.remove")]
    rm(norm.stats)
  }
  res.df = res.df[which(res.df$d.max != -1 & !is.na(res.df$d.max)), ]

  d.max = m = nb.remove = ..count.. = NULL  ## Uglily appease R checks
  grDevices::pdf(out.pdf, 8, 6)
  print(ggplot2::ggplot(res.df, ggplot2::aes(x = d.max)) + ggplot2::geom_histogram() + 
        ggplot2::theme_bw() + ggplot2::xlab("correlation distance to last supporting bin") + 
        ggplot2::ylab("number of bins"))
  print(ggplot2::ggplot(res.df, ggplot2::aes(x = m)) + ggplot2::geom_histogram() + 
        ggplot2::theme_bw() + ggplot2::xlab("average normalized coverage") + ggplot2::ylab("number of bins"))
  print(ggplot2::ggplot(res.df, ggplot2::aes(x = m + 1)) + ggplot2::geom_histogram() + 
        ggplot2::theme_bw() + ggplot2::scale_x_log10() + ggplot2::xlab("average normalized coverage") + 
        ggplot2::ylab("number of bins"))
  print(ggplot2::ggplot(res.df, ggplot2::aes(x = nb.remove)) + ggplot2::geom_histogram() + 
        ggplot2::theme_bw() + ggplot2::xlab("number of outlier samples removed") + 
        ggplot2::ylab("number of bins"))
  if (bin.size) {
    print(ggplot2::ggplot(res.df, ggplot2::aes(x = end - start)) + ggplot2::geom_histogram() + 
          ggplot2::theme_bw() + ggplot2::xlab("bin size (bp)") + ggplot2::ylab("number of bins"))
  }
  ## Pairwise graphs
  print(ggplot2::ggplot(res.df, ggplot2::aes(x = d.max, y = m + 1, fill = log10(..count..))) + 
        ggplot2::stat_bin2d() + ggplot2::theme_bw() + ggplot2::xlab("correlation distance to last supporting bin") + 
        ggplot2::ylab("average normalized coverage") + ggplot2::scale_y_log10() + 
        ggplot2::scale_fill_gradient(name = "log10(nb bins)", low = "white", high = "red"))
  print(ggplot2::ggplot(res.df, ggplot2::aes(x = d.max, y = nb.remove, fill = log10(..count..))) + 
        ggplot2::stat_bin2d() + ggplot2::theme_bw() + ggplot2::xlab("correlation distance to last supporting bin") + 
        ggplot2::ylab("number of outlier samples removed") + ggplot2::scale_fill_gradient(name = "log10(nb bins)", 
                                                                                          low = "white", high = "red"))
  print(ggplot2::ggplot(res.df, ggplot2::aes(x = m + 1, y = nb.remove, fill = log10(..count..))) + 
        ggplot2::stat_bin2d() + ggplot2::theme_bw() + ggplot2::xlab("average normalized coverage") + 
        ggplot2::ylab("number of outlier samples removed") + ggplot2::scale_fill_gradient(name = "log10(nb bins)", 
                                                                                          low = "white", high = "red") + ggplot2::scale_x_log10())
  if (bin.size) {
    print(ggplot2::ggplot(res.df, ggplot2::aes(x = d.max, y = end - start, fill = log10(..count..))) + 
          ggplot2::stat_bin2d() + ggplot2::theme_bw() + ggplot2::xlab("correlation distance to last supporting bin") + 
          ggplot2::ylab("bin size (bp)") + ggplot2::scale_fill_gradient(name = "log10(nb bins)", 
                                                                        low = "white", high = "red"))
    print(ggplot2::ggplot(res.df, ggplot2::aes(x = nb.remove, y = end - start, 
                                               fill = log10(..count..))) + ggplot2::stat_bin2d() + ggplot2::theme_bw() + 
          ggplot2::xlab("number of outlier samples removed") + ggplot2::ylab("bin size (bp)") + 
          ggplot2::scale_fill_gradient(name = "log10(nb bins)", low = "white", 
                                       high = "red"))
  }
  grDevices::dev.off()
  
  return(out.pdf)
} 
