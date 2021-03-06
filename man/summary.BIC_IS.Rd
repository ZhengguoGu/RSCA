% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary.BIC_IS.R
\name{summary.BIC_IS}
\alias{summary.BIC_IS}
\title{Display a summary of the results of \code{BIC_IS()}.}
\usage{
\method{summary}{BIC_IS}(object, disp, ...)
}
\arguments{
\item{object}{Object of class inheriting from 'BIC_IS'.}

\item{disp}{The default is \code{"tuning"}; in this case, the recommended tuning 
parameter values based on Index of Sparseness are presented. 
If \code{"tuning_BIC"}, then the recommended tuning 
parameter values based on BIC are presented
If \code{"full"}, then recommended tuning parameter values based on Index 
of Sparseness and BIC are presented.}

\item{...}{Argument to be passed to or from other methods.}
}
\description{
Display a summary of the results of \code{BIC_IS()}.
}
\examples{
\dontrun{
## S3 method for class 'BIC_IS'
summary(object, disp="tuning")
}

}
