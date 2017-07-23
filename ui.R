dashboardPage(
  dashboardHeader(title = "cran.rstudio.com"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard"),
      menuItem("Raw data", tabName = "rawdata")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem("dashboard",
        fluidRow(
          valueBoxOutput("rate", width = 3),
          valueBoxOutput("totalQuestions", width = 3),
          valueBoxOutput("totalTags", width = 3),
          valueBoxOutput("uniqueTags", width = 3)
        ),
        fluidRow(
          box(
            width = 8, status = "info", solidHeader = TRUE,
            title = "Popularity by tag (last 5 min)",
            bubblesOutput("tagPlot", width = "100%", height = 600)
          ),
          box(
            width = 4, status = "info",
            title = "Top tags (last 5 min)",
            tableOutput("tagTable")
          )
        )
      ),
      tabItem("rawdata",
        numericInput("maxrows", "Rows to show", 25),
        verbatimTextOutput("rawtable"),
        downloadButton("downloadCsv", "Download as CSV")
      )
    )
  )
)

