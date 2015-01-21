library(shiny)
shinyUI(fluidPage(
  titlePanel("Central Limit Theorem"),
  sidebarLayout(
    # Sidebar with explanatory text, radiobutton and slider inputs
	sidebarPanel(width=4,
		h4("Simulation parameters:"),
		radioButtons("dist", "Parent distribution:",
			list("Uniform" = "runif",
				"Normal" = "rnorm",
				"Log-normal" = "rlnorm",
				"Exponential" = "rexp",
				"Binomial distribution (n=30, p=.25)" = "rbinom",
				"Poisson" = "rpois",
				"Cauchy (pathological)" = "rcauchy")),
		br(),

		sliderInput("n", 
			"Number of observations in each sample from the population:", 
				value = 30,
				min = 2, 
				max = 500),
		br(),

		sliderInput("N", 
			"Number of samples taken from the population:", 
				value = 100,
				min = 2, 
				max = 500),
		br(),
    wellPanel(
		p("Use the controls above to select a different parent distribution for a random variable and see the distribution of its sample means."),
		p("Observe that the distribution of sample means tends to be Normal/Gaussian (except for samples from a Cauchy-distributed population)."),
		p("Observe how the distribution of sample means gets narrower if you increase the size of each sample.")	    
#     helpText(a(href="https://github.com/xjlc/climit", target="_blank", "View code"))
	)), # sidebarPanel
	mainPanel(width=8,
	          wellPanel(p("This simulation demonstrates the central limit theorem. Have you ever wondered why the Normal distribution is so important in statistical theory?"), 
                      p("Consider a random variable X that has a certain distribution in the population, and a number of N samples taken from that variable, each of size n. If you record the mean of each of these samples, you will get a new distribution consisting of the N sample means. This is a sample from the population of sample means, which is also a random variable. The central limit theorem basically states that regardless of the distribution of a random variable in the population, the mean (or sum) obtained by repeatedly sampling the population  will be normally distributed."),
                      p("The mild assumption is that the random variable follows a distribution with clearly defined moments. A well-known exception is the Cauchy distribution, for which the mean and variance are not defined. For a strong pamphlet against using the Gaussian indiscriminately, see the book 'The Black Swan: The Impact of the Highly Improbable' by Nassim Nicholas Taleb.")), 
            br(),
            plotOutput("plot", height="650px"),
            em("Figure 1"), "The upper left panel shows one sample of the chosen distribution. The upper right panel shows all samples, represented by density estimations (note that these are off at the boundaries for distributions such as the exponential, lognormal, Poisson or uniform which are not defined over the whole range of numbers). Red lines indicate the means of the individual samples.", "The lower panel show the distribution of sample means as a histogram (with added density, lower left) and as Normal Q-Q-Plot (lower right)"
    ) # main panel
)))
