#' An algorithm for determining the smallest values for Lasso and Group Lasso tuning parameters that yield all zeros.
#'
#' \code{maxLGlasso} identify the minimum value for Lasso and Group Lasso tuning parameters that
#' lead to an estimated P matrix with all of its elements equal 0. This minimum value is thus the maximum value (the boundary) that users
#' should consider for Lasso and Group Lasso. Note that the algorithm is based on the "component" method; see sparseSCA.R
#'
#' @param DATA The concatenated data block, with rows representing subjects.
#' @param Jk A vector. Each element of this vector is the number of columns of a data block.
#' @param R The number of components.
#'
#' @return
#' \item{Glasso}{The maximum value for Group Lasso tuning parameter.}
#' \item{Lasso}{The maximum value for Lasso tuning parameter.}
#'
#' @examples
#' \dontrun{
#' DATA1 <- matrix(rnorm(50), nrow=5)
#' DATA2 <- matrix(rnorm(100), nrow=5)
#' DATA <- cbind(DATA1, DATA2)
#' Jk <- c(10, 20) 
#' results <- maxLGlasso(DATA, Jk, R=5)
#' maxGLasso <- results$Glasso
#' maxLasso <- results$Lasso
#' }
#' @references 
#' Hastie, T., Tibshirani, R., & Wainwright, M. (2015). \emph{Statistical learning with sparsity}. CRC press.
#' @note The description of how to obtain the maximum value for Lasso tuning parameter can be found in page 17 of Hastie, Tibshirani, and Wainwright (2015). We are not aware of 
#' any literature that mentions how to obtain the maximum value for Group Lasso, but this value can easily be derived from the algorithm. 
#'@export
maxLGlasso <- function(DATA, Jk, R){

  DATA <- data.matrix(DATA)
  I_Data <- dim(DATA)[1]
  sumJk <- dim(DATA)[2]
  eps <- 10^(-12)

  LASSO = 0
  GROUPLASSO = 0
  
  #initialize P
  P <- matrix(stats::rnorm(sumJk * R), nrow = sumJk, ncol = R)
  Pt <- t(P)
    
  residual <- sum(DATA ^ 2)
  Lossc <- residual 
    
  conv <- 0
  iter <- 1
  Lossvec <- array()
    
  max_Glasso <- 0
  max_lasso <- 0
    
  #update Tmat, note that Tmax refers to T matrix
    
  SVD_DATA <- svd(DATA, R, R)
  Tmat <- SVD_DATA$u
    
  #update P
    
  L <- 1
  for (i in 1:length(Jk)){ #iterate over groups
      
    U <- L + Jk[i] - 1
    Pt_1 <- Pt[ ,c(L:U)]
    data <- DATA[ ,c(L:U)]
      
    sum_abs_theta <- sum(abs(Pt_1))
    if (sum_abs_theta != 0){
    # to test whether the entire Pk should be zeros, i.e., ||Sj||2 <=1
        
      Xk_r <- matrix(NA, R, Jk[i])
      soft_Xkr <- matrix(NA, R, Jk[i])
        
      for (j in 1:Jk[i]){
        for (r in 1:R){
           xkr <- t(Tmat[, r]) %*% data[, j]
           Xk_r[r, j] <- xkr
           soft_Xkr[r, j] <- sign(xkr)*max((abs(xkr) - LASSO), 0)
         }
       }
        
      Vec_Xkr <- as.vector(Xk_r)
      Vec_soft_Xkr <- as.vector(soft_Xkr)
        
      l2_soft_Xkr <- sqrt(sum(Vec_soft_Xkr^2))
        
      #if (l2_soft_Xkr/(Jk[i]*GROUPLASSO^2) <= 1){
      #  Pt[ ,c(L:U)] <- 0}  Note that this tells us the max Glasso
        
      Pt[ ,c(L:U)] <- max((l2_soft_Xkr - GROUPLASSO*sqrt(Jk[i])), 0) * soft_Xkr / l2_soft_Xkr
        
    }
    L <- U + 1
      
    max_Glasso <- max(max_Glasso, sqrt(l2_soft_Xkr/Jk[i]))
  }
  P <- t(Pt)
    
  max_lasso <- max(Pt)
    
  ################################################################
  # to make sure that estimated P = 0
  flag <- 0
  while(flag == 0){
    results <- sparseSCA(DATA, Jk, R, max_lasso, max_Glasso, MaxIter = 400, NRSTARTS = 2, method = "component")
    if(sum(results$Pmatrix==0)){
      flag <- 1
    }else{
      max_lasso <- max_lasso + max(results$Pmatrix)
    }
      
  }
    
  
  return_tuning <- list()
  return_tuning$Glasso <- max_Glasso
  return_tuning$Lasso <- max_lasso
  return(return_tuning)


}
