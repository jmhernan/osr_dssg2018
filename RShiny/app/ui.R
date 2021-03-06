# User Interface for OSR Shiny App

library(shiny)
library(leaflet)

# Source needed data and functions for ui and server
source('../source_file.R', chdir = TRUE)  # temp changes working dir to same as source_file.R
source('helpers.R')

# UI options for filtering by demographics
demog_names <- list("None selected",
                    "Median household income ($)", 
                    "Less than high school degree (% over 25 years)",
                    "College graduates (% over 25 years)",
                    HTML("Language other than English spoken (%)<br><br>
                                                                    <i>Race/Ethnicity Variables</i>"),
                    "Hispanic population (%)", 
                    "Black population (%)",
                    "White population (%)",
                    "Majority + breakdown"
                    )

# internal values for options for filtering by demographics
demog_values <- list("None selected", 
                     "Median household income ($)", 
                     "Less than high school degree (%)",
                     "College graduates (%)",
                     "Non-English speakers (%)",
                     "Hispanic population (%)", 
                     "Black population (%)",
                     "White population (%)",
                     "All races"
                     )


shinyUI(
  
  fluidPage(
  
  includeCSS("style.css"),
  
  navbarPage("Denver Out-of-School Resources",
                   
                   ## RESCHOOL PROGRAMS TAB
                   tabPanel("B4S Programs",
                            fluidPage(
                              
                              # includeCSS("style.css"),
                              
                              sidebarLayout(
                              
                              # Sidebar panel for making selections about reschool programs
                              sidebarPanel(
                                checkboxGroupInput("program", "Select one or more program types:", 
                                                   choices = c("Academic" = 13, "Arts" = 14, 
                                                               "Cooking" = 15, "Dance" = 16, 
                                                               "Drama" = 17, "Music" = 18, 
                                                               "Nature" = 19, "Sports" = 20, 
                                                               "STEM" = 21), 
                                                   selected = 13,
                                                   inline = TRUE
                                                   ),
                                #br(),
                                sliderInput("slider", "Select a range for program cost:", 
                                            min = minprice_reschoolprograms, 
                                            max = maxprice_reschoolprograms , 
                                            value = c(minprice_reschoolprograms, 
                                                      maxprice_reschoolprograms),
                                            pre = "$"
                                ),
                                #br(),
                                radioButtons("demographics", 
                                             "Select a demographics variable to visualize:", 
                                             choiceNames = demog_names,
                                             choiceValues = demog_values,
                                             selected = "None selected"
                                             ),
                                br(),
                                selectInput("neighborhoods", "Restrict to one neighborhood:", 
                                            choices = c("No neighborhood selected", 
                                                        sort(neighborhoods_reshoolprograms))
                                ),
                                width = 4
                              ),
                              
                              # Main panel for reschool programs: map tab + data tab + analysis tab
                              mainPanel(
                                tabsetPanel(type = "tab",
                                            tabPanel("Map",
                                                     leafletOutput("mymap", height = 520)
                                                     ),
                                            tabPanel("Data",
                                                     DT::dataTableOutput("datatable")
                                                     ),
                                            tabPanel("Summary analysis",
                                                     uiOutput("summary_title"),
                                                     fluidRow(
                                                       column(6, plotOutput("program_type_summary")),
                                                       column(6, plotOutput("program_cost_summary"))
                                                     ),
                                                     uiOutput("program_special_cats"),
                                                     DT::dataTableOutput("nbhd_summary")
                                                     )
                                            )
                                ) 
                              ))
                            ),
                   
                   
                   ## OPEN DATA TAB - Parks, Libraries, etc.
                   tabPanel("Other Resources",
                            fluidPage(sidebarLayout(
                              
                              sidebarPanel(
                                checkboxGroupInput("program_other", 
                                                   "Select one or more resource types:", 
                                                   choices = c("Parks", "Playgrounds", 
                                                               "Rec Centers", "Libraries", 
                                                               "Museums", "Fields"), 
                                                   selected = "Parks", 
                                                   inline = TRUE
                                                   ),
                                br(),
                                radioButtons("demographics_other", 
                                             "Select a demographics variable to visualize:", 
                                             choiceNames = demog_names,
                                             choiceValues = demog_values,
                                             selected = "None selected"
                                ),
                                br(),
                                selectInput("neighborhoods_other", 
                                            "Restrict to one neighborhood:", 
                                            choices = c("No neighborhood selected", 
                                                        sort(neighborhoods_other)
                                                        )
                                ),
                                br()
                              ),
                              
                              mainPanel(
                                tabsetPanel(type = "tab",
                                            tabPanel("Map",
                                                     leafletOutput("mymap_other", height = 520)),
                                            tabPanel("Data",
                                                     uiOutput("dt")),
                                            tabPanel("Summary analysis")
                                )
                              )
                            )
                          )
                   ),

                   ## RESCHOOL SEARCH DATA TAB
             tabPanel("ReSchool Program Searches",
                      
                      fluidPage(sidebarLayout(
                        
                        sidebarPanel(
                          selectInput("minprice_search", "Select Min Price:", 
                                      choices = c("No min price selected", 
                                                  sort(unique(google_analytics$mincost)))
                          ),
                          selectInput("maxprice_search", "Select Max Price:", 
                                      choices = c("No max price selected", 
                                                  sort(unique(google_analytics$maxcost)))
                          ),
                          br(),
                          selectInput("zipcode_searchprog", "Restrict to one zipcode:", 
                                      choices = c("No zipcode selected", 
                                                  sort(zipcode_searchdata))),
                          br(),
                          selectInput("sessiontimes_searchprog", "Restrict to one session time:", 
                                      choices = c("No session time selected", 
                                                  sort(unique(google_analytics$sessiontimes)))
                          ), br(),
                          checkboxGroupInput("program_search", 
                                             "Select one or more program type:", 
                                             choices = sort(unique(google_analytics$category)), 
                                             selected = "academic", 
                                             inline = TRUE
                          )),
                        
                        mainPanel(
                          tabsetPanel(type = "tab",
                                      tabPanel("Summary",
                                               
                                               fluidRow(

                                                 column(6, uiOutput("totalsearches", 
                                                                    style = "background-color:yellow; 
                                                                    height:120px; padding:20px;
                                                                    border:solid", align = "center")),
                                                 column(6, uiOutput("percentagesearches", style = "background-color:yellow; 
                                                                    height:120px; padding:20px;
                                                                    border:solid", align = "center")),
                                                 
                                                 DT::dataTableOutput("datatable_search")
                                               )
                                      ),
                                      tabPanel("Visualization")
                          )
                        )
                      ))
                      
                      
             ),
                   
                   ## ACCESS INDEX TAB
                   tabPanel("Access Index",
                            fluidPage(sidebarLayout(
                              
                              sidebarPanel(
                                checkboxGroupInput("type_access", 
                                                   "Select one or more program types:", 
                                                   choiceNames = c("Academic", "Arts", "Athletic", "Nature"),
                                                   choiceValues = list("academic","art","sports","nature"),
                                                   inline = TRUE,
                                                   selected = c("academic","art","sports","nature")
                                                   ),
                                br(),
                                radioButtons("cost_access", 
                                             "Select a cost range for programs:", 
                                             choiceNames = list("Free", "Free to Low Cost", "All Programs"),
                                             choiceValues = list("free", "low", "any"),
                                             selected = "any"
                                             ),
                                br(),
                                radioButtons("drive_or_transit",
                                             "Drive or transit?",
                                             choiceNames = list("Drive", "Transit"),
                                             choiceValues = list("drive", "transit"),
                                             selected = "drive"
                                             ),
                                br()
                              ),  # end sidebarPanel for access index
                              
                              mainPanel(
                                
                                textOutput("test"),
                                tabsetPanel(type = "tab",
                                            tabPanel("Map",
                                                     leafletOutput("mymap_access", height = 520))
                                            # tabPanel("Data",
                                            #          uiOutput("dt")),
                                            # tabPanel("Summary analysis")
                                )
                              )  # end main panel for access index
                              
                            ))  # end sidebar layrout and access index fluidPage
                  )  # end access index tab
             
             )  # end navbarPage 
  
  ))  # end fluidPage for whole UI, and shinyUI
