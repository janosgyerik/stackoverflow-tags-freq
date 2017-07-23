function(input, output, session) {

  # qStream is a reactive expression that represents a stream of
  # new questions; up to once in 10 seconds it may return a
  # data frame of new questions since the last update.
  qStream <- questionStream(session)

  # Max age of data (5 minutes)
  maxAgeSecs <- 60 * 5

  # pkgData is a reactive expression that accumulates previous
  # values of qStream, discarding any that are older than
  # maxAgeSecs.
  pkgData <- packageData(qStream, maxAgeSecs)

  # qCount is a reactive expression that keeps track of the total
  # number of questions that have ever appeared through qStream.
  qCount <- questionCount(qStream)

  # tTagCount is a reactive expression that keeps track of the total
  # number of tags that have ever appeared through qStream.
  tTagCount <- totalTagCount(qStream)

  # uTagCount is a reactive expression that keeps a
  # count of all of the unique tags that have been seen since the
  # app started.
  uTagCount <- uniqueTagCount(qStream)

  # Record the time that the session started.
  startTime <- as.numeric(Sys.time())

  output$rate <- renderValueBox({
    # The downloadRate is the number of rows in pkgData since
    # either startTime or maxAgeSecs ago, whichever is later.
    elapsed <- as.numeric(Sys.time()) - startTime
    downloadRate <- nrow(pkgData()) / min(maxAgeSecs, elapsed) * 60

    valueBox(
      value = formatC(downloadRate, digits = 1, format = "f"),
      subtitle = "Questions / min",
      icon = icon("bar-chart"),
      color = "aqua"
    )
  })

  output$totalQuestions <- renderValueBox({
    valueBox(
      value = qCount(),
      subtitle = "Total questions",
      icon = icon("question-circle-o")
    )
  })
  
  output$totalTags <- renderValueBox({
    valueBox(
      value = tTagCount(),
      subtitle = "Total tags",
      icon = icon("tags")
    )
  })
  
  output$uniqueTags <- renderValueBox({
    valueBox(
      value  = uTagCount(),
      subtitle = "Unique tags",
      icon = icon("tag")
    )
  })

  output$tagPlot <- renderBubbles({
    if (nrow(pkgData()) == 0)
      return()

    tags <- pkgData()$tags %>%
      strsplit(',') %>%
      unlist

    df <- data.frame(tag=tags) %>%
      group_by(tag) %>%
      tally %>%
      arrange(desc(n), tolower(tag)) %>%
      head(60)

    bubbles(df$n, df$tag, key = df$tag)
  })

  output$tagTable <- renderTable({
    tags <- pkgData()$tags %>%
      strsplit(',') %>%
      unlist

    data.frame(tag=tags) %>%
      group_by(tag) %>%
      tally %>%
      arrange(desc(n), tolower(tag)) %>%
      mutate(percentage=n / nrow(pkgData()) * 100) %>%
      select("Tag" = tag, "%" = percentage) %>%
      as.data.frame() %>%
      head(15)
  }, digits = 1)

  output$downloadCsv <- downloadHandler(
    filename = "cranlog.csv",
    content = function(file) {
      write.csv(pkgData(), file)
    },
    contentType = "text/csv"
  )

  output$rawtable <- renderPrint({
    orig <- options(width = 1000)
    print(tail(pkgData(), input$maxrows))
    options(orig)
  })
}


