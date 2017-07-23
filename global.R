library(shiny)
library(shinySignals)
library(dplyr)
library(shinydashboard)
library(bubbles)
library(plyr)
library(stackr)

# dummy data for testing
load('questions.dev.RData')

# An empty prototype of the data frame we want to create
prototype <- head(questions, n=0) %>% mutate(received = numeric())

# Periodically fetches latest questions from Stack Overflow,
# returns a reactive expression that serves up the cumulative
# results as a data frame
questionStream <- function(session) {
  qno <- 1
  newQuestions.dev <- reactive({
    invalidateLater(1000, session)
    qno <<- qno + 1
    if (qno > nrow(questions)) qno <<- 1
    questions[qno,]
  })

  lastSeenTs <- NULL
  newQuestions.prod <- reactive({
    invalidateLater(10000, session)

    questions <- stack_questions(
      site = "stackoverflow",
      sort = "creation",
      order = "desc",
      fromdate = lastSeenTs
    )

    if (nrow(questions) > 0) {
      lastSeenTs <<- strftime(questions$creation_date[1], "%s")
    }
    questions
  })

  newQuestions <- newQuestions.prod

  # Parses newLines() into data frame
  reactive({
    if (nrow(newQuestions()) == 0) prototype
    else newQuestions() %>% mutate(received = as.numeric(Sys.time()))
  })
}

# Accumulates qStream rows over time; throws out any older than timeWindow
# (assuming the presence of a "received" field)
packageData <- function(qStream, timeWindow) {
  shinySignals::reducePast(qStream, function(memo, value) {
    rbind.fill(memo, value) %>%
      filter(received > as.numeric(Sys.time()) - timeWindow)
  }, prototype)
}

# Count the total nrows of qStream
questionCount <- function(qStream) {
  shinySignals::reducePast(qStream, function(memo, df) {
    if (is.null(df))
      return(memo)
    memo + nrow(df)
  }, 0)
}

# Count the total tags of qStream
totalTagCount <- function(qStream) {
  shinySignals::reducePast(qStream, function(memo, df) {
    if (is.null(df))
      return(memo)
    memo + length(df$tags %>% strsplit(",") %>% unlist)
  }, 0)
}

# Count the unique tags of qStream
uniqueTagCount <- function(qStream) {
  seen <- c()
  reactive({
    df <- qStream()
    if (!is.null(df) && nrow(df) > 0) {
      seen <<- unique(c(seen, unique(df$tags %>% strsplit(",") %>% unlist)))
    }
    length(seen)
  })
}
