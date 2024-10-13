# Load necessary libraries
library(readxl)
library(knitr)
library(xtable)
library(bbmle)

# Function to estimate parameters for Negative Binomial Distribution using MLE
EstNB1 <- function(X) {
  
  # Negative log-likelihood function for NBD
  minuslogl2 <- function(size, x) {
    -sum(dnbinom(x = x, size = size, prob = size / (size + mean(x)), log = TRUE))
  }
  
  # Initialize starting values
  k0 <- VarG(X)  # Initial guess for 'size' parameter (k)
  M <- mean(X)   # Mean of the data
  
  # Fit the model using MLE
  m <- mle2(
    minuslogl = minuslogl2,
    start = list(size = k0),
    data = list(x = X),
    method = "L-BFGS-B",
    lower = list(size = 1e-4),
    upper = list(size = 1e+5)
  )
  
  # Extract estimated parameters
  k <- coef(m)[1]
  p <- k / (k + M)
  
  # Return parameters in a vector
  V <- c(p = p, k = k)
  return(V)
}

# Variance function used as an initial guess for 'k' parameter
VarG <- function(X) {
  M <- mean(X)
  p <- M / var(X)
  return(p / (1 - p) * M)
}

# Plotting function to visualize the fitted distribution
Graph <- function(X, res) {
  y <- table(X)  # Frequency table of X
  
  # Compare actual vs estimated probabilities
  test <- cbind(y / sum(y),
                sapply(as.numeric(names(y)), function(j) dnbinom(j, prob = res[1], size = res[2])))
  
  # Plot observed vs estimated probabilities
  plot(as.numeric(row.names(test)), test[,1], type = "p", xlab = "j", ylab = "Pj")
  lines(as.numeric(row.names(test)), test[,2], type = "b", col = 2, pch = 20)
  
  # Add title with estimated parameters
  p. <- res[1]
  k. <- res[2]
  a1 <- paste(paste("p=", round(p., 3), sep = ""), paste("k=", round(k., 3), sep = ""), sep = ", ")
  title(sub = a1)
}

# Read input data from CSV
input_file <- "input_file.csv"
data <- read.csv(input_file, header = TRUE)

# Extract the single column of values
X <- as.numeric(data[[1]])

# Estimate parameters and plot the results
res1 <- EstNB1(X)
Graph(X, res1)

