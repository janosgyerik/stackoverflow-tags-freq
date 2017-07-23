# tagfreq

Demo of dashboard with streaming updates, using [Shiny](http://shiny.rstudio.com).

The streaming data is question tags from Stack Overflow,
requested at a frequency of 10 seconds due to polling rate limitations.

The source code is based on the Streaming CRAN data example ("crandash") by Joe Cheng.

## Installation

```r
install.packages(c("shiny", "dplyr", "htmlwidgets", "digest", "bit"))
devtools::install_github("rstudio/shinydashboard")
devtools::install_github("jcheng5/bubbles")
devtools::install_github("hadley/shinySignals")
```

