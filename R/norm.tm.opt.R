##' Optimized version of the trimmed-mean normalization for bin counts.
##' @title Trimmed-Mean normalization optimized
##' @param df a data.frame with the bin counts (bin x sample).
##' @param ref.col the column to be used as baseline for the pairwise normalization.
##' All columns are normalized on this sepcified column.
##' @param lm.min.prop the minimum height proportion in the density curve to define a
##' local maximum.
##' @param bc.mean.norm the average coverage in the reference sample. To be used to
##' help normalize tumor samples.
##' @param chrs the chromosomes of the bins used. The diversity of the chromosome is
##' useful to differentiate misleading coefficient from a few aberrant chromosomes.
##' @return a vector with the normalization coefficients for each column (sample).
##' @author Jean Monlong
##' @keywords internal
norm.tm.opt <- function(df, ref.col, lm.min.prop = 0.1, bc.mean.norm = NULL, chrs = NULL) {
    trimmed.mean.TN.best <- function(a, b, lm.min.prop = 0.1, bc.mean.norm = NULL) {
        if (sum(a != 0 & b != 0) > 10 & any(a!=b)) {
            r = log(a/b)[a != 0 & b != 0]
            if (!is.null(bc.mean.norm) & !is.null(chrs)) {
                chrs = chrs[a != 0 & b != 0]
                lM.o = localMax(r, lm.min.prop)
                r.mean.norm = ifelse(b[1] == 0 | bc.mean.norm == 0, max(r), log(bc.mean.norm/b[1]))
                s.mn = 1 - abs(lM.o$lM - r.mean.norm)/max(abs(r - r.mean.norm), na.rm = TRUE)  ## Score for distance to average in normals
                s.h = lM.o$h/max(lM.o$h)
                s.c = sapply(lM.o$lM, function(rr) max(table(chrs[order(abs(rr - 
                  r))[1:100]])))
                s.c = 1 - s.c/max(s.c)
                ## return(lM.o$lM[which.max(s.mn+s.h+s.c)])
                return(lM.o$lM[which.max(s.mn + s.h)])
            } else {
                return(stats::median(r, na.rm = TRUE))
            }
        } else {
            return(0)
        }
    }
    tm.all = apply(df, 2, function(c) trimmed.mean.TN.best(ref.col, c, lm.min.prop, 
        bc.mean.norm = bc.mean.norm))
    return(exp(tm.all))
} 
