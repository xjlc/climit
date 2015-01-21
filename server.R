# illustration of the CLT
# based on a github gist by https://github.com/tgouhier/climit

library(shiny)

shinyServer(function(input, output) {
    
	# one simulation run: generate random numbers
	simdata <- function(input, n) {
	    if (input$dist=="rpois") {
	      vals <-  do.call(input$dist, list(n=input$n, lambda=1))
	    } else if (input$dist=="rbinom") {
	      vals <-  do.call(input$dist, list(n=input$n, size=30, p=.25))
	    } else {
	      vals <-  do.call(input$dist, list(n=input$n))
	    }
	}
  
  data <- reactive({      
	  vals <- simdata(input, n)
	  return (list(fun=input$dist, vals=vals))
  })
  
  output$plot <- renderPlot({
	  # generate plot title based on user-chosen distribution
    distname <- switch(input$dist,
						runif = "Uniform distribution", # (n = ",
						rnorm = "Normal distribution", # (n = ",
						rlnorm = "Log-normal distribution", # (n = ",
						rexp = "Exponential distribution", # (n = ",
						rbinom = "Binomial distribution (n=30, p=.25)",
						rpois = "Poisson distribution",
						rcauchy = "Cauchy distribution") # (n = ")

	# extract parameters from user input
    n <- input$n
    N <- input$N
    pdist <- data()$vals
	# generate N samples
	x <- replicate(N, simdata(input, n))
	# extract means of samples 
	# note: this was rowMeans in the original code, but I think that was a mistake
    ndist <- colMeans(x)
	# expected values from the literature/formulary
    expect <- switch(input$dist,
                     rexp = c(1^-1, 1^-2),
                     rnorm = c(0, 1),
                     rlnorm = c(exp(0+(1/2)*1^2), exp(0 + 1^2)*(exp(1^2)-1)),
                     runif = c(0.5, (1/12)*1),
					           rbinom = c(30*.25, 30*.25*.75),
                     rpois =c(1, 1),
                     rcauchy = rep(NA, 2))
    obs <- data.frame(pdist=c(mean(pdist), var(pdist)), ndist=c(mean(ndist), var(ndist)))

# TODO: better visualization, ggplot?, add means, samples, etc.

  nbreaks <- 10
	par(mfrow=c(2,2))
	# first panel: a single simulation
    pdens <- density(pdist)
    phist <- hist(pdist, plot=FALSE)
    hist(pdist, main=paste("A single sample of", n, "observations\nfrom the", distname), 
         xlab="Values (X)", freq=FALSE, ylim=c(0, max(pdens$y, phist$density)), breaks=nbreaks)
    lines(pdens, col="black", lwd=2)
    abline(v=obs$pdist[1], col="blue", lwd=2, lty=2)
    abline(v=expect[1], col="red", lwd=2, lty=2)
    legend(x="topright", col=c("black", "red"), lwd=2, lty=2,
          legend=c("Observed", "Expected"))
    box()

	# second panel: add a plot showing the individual distributions
	# densities <- apply(x, 2, density, bw="SJ", adjust=2)
  
	if (input$dist=="rexp" | input$dist=="rlnorm" | input$dist=="rpois") { 
		xl <- c(0, max(as.vector(x)))
		densities <- apply(x, 2, density, from=0.05)
	} else if (input$dist=="runif") {
		xl <- c(0, 1)
		densities <- apply(x, 2, density, n=512, from=0.02, to=.98)
	} else {
		xl <- range(as.vector(x))
		densities <- apply(x, 2, density)
	}
	plot(densities[[1]], type="l", lwd=.5, xlim=xl, ylim=c(0, max(sapply(densities, "[[", "y"))), main="Individual samples (smoothed)\nwith sample means in red", xlab="Value")
	sapply(densities, lines, lwd=.5)
	abline(v=ndist, col="red", lty=1, lwd=.25)
    
	# third panel: histogram of sample means
	ndens <- density(ndist)
    nhist <- hist(ndist, plot=FALSE)
    hist(ndist, main=paste("Distribution of mean values from ", N, 
                           " random samples each\nconsisting of ", n, 
                           " observations from the ", distname, sep=""), col="red",
         xlab=expression(paste("Sample means (", bar(X), ")")), 
         freq=FALSE, ylim=c(0, max(ndens$y, nhist$density)), breaks=nbreaks, xlim=range(phist$breaks))
    lines(ndens, col="black", lwd=3)
    abline(v=obs$ndist[1], col="blue", lwd=2, lty=2)
    abline(v=expect[1], col="red",  lwd=2, lty=2)
    legend(x="topright", col=c("blue", "red"), lwd=2, lty=2,
          legend=c("Observed", "Expected"))
    box()
	
	# fourth panel: compare sample means to normal distribution
	qqnorm(ndist, main=paste("Distribution of sample means\n from the", distname, "against Normal"))
	qqline(ndist)  
  })
})
