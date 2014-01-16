
#  Copyright 2013, INSEAD
#  by T. Evgeniou 
#  Dual licensed under the MIT or GPL Version 2 licenses.

shinyUI(pageWithSidebar(
  
  ##########################################
  # STEP 1: The name of the application
  ##########################################
  
  headerPanel("Segmentation Web App"),
  
  ##########################################
  # STEP 2: The left menu, which reads the data as
  # well as all the inputs exactly like the inputs in RunStudy.R
  
  sidebarPanel(
    
    HTML("Please reload the web page any time the app crashes. <strong> When it crashes the screen turns into grey.</strong> If it only stops reacting it may be because of 
       heavy computation or traffic on the server, in which case you should simply wait. This is a test version.</center>"),    
    HTML("<hr>"),    
    
    ###########################################################    
    # STEP 2.1: read the data
    
    HTML("<center><h4>Choose a data file:<h4>"),    
    selectInput('datafile_name_coded', '',
                c("Boats","MBAadmin"),multiple = FALSE),
    
    ###########################################################
    # STEP 2.2: read the INPUTS. 
    # THESE ARE THE *SAME* AS THE NECESSARY INPUT PARAMETERS IN RunStudy.R
    
    HTML("<hr>"),
    HTML("<h4>Factor Analysis Variables<h4>"),
    
    HTML("<h5>Select the variables to use for Factor Analysis</h5>"),
    HTML("(<strong>Press 'ctrl' or 'shift'</strong> to select multiple  variables)"),
    HTML("<br>"),
    HTML("<br>"),
    selectInput("factor_attributes_used","Variables used for Factor Analysis",  choices=c("attributes used"),selected=NULL, multiple=TRUE),
    HTML("<br>"),
    selectInput("rotation_used", "Select rotation method:", 
                choices = c("varimax", "quatimax","promax","oblimin","simplimax","cluster")),
    numericInput("MIN_VALUE", "Select the threshold below which numbers in the factors tables do not appear in the report:", 0.5),
    numericInput("manual_numb_factors_used", "Select Number of Factors to use in the Reports:", 2),
    
    HTML("<hr>"),
    HTML("<h4>Cluster Analysis Variables<h4>"),
    
    HTML("<h5>Select the variables to use for Cluster  Analysis</h5>"),
    HTML("<br>"),
    HTML("(<strong>Press 'ctrl' or 'shift'</strong> to select multiple  variables)"),
    HTML("<br>"),
    HTML("<br>"),
    selectInput("segmentation_attributes_used","Segmentation variables used",  choices=c("Segmentation Variables"),selected=NULL, multiple=TRUE),
    HTML("<br>"),
    selectInput("profile_attributes_used","Profiling variables used",  choices = c("Profiling Variables"), selected=NULL, multiple=TRUE),
    HTML("<hr>"),
    numericInput("numb_clusters_used", "Select Number of clusters to find):", 2),
    HTML("<br>"),
    HTML("<br>"),
    selectInput("hclust_method", "Select the Hierarchical Clustering method to use:", 
                choices = c("ward", "single", "complete", "average", "mcquitty", "median", "centroid"), selected="ward", multiple=FALSE),    
    HTML("<br>"),
    HTML("<br>"),
    selectInput("distance_used", "Select the distance metric to use for Hclust:", 
                choices = c("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski"), selected="euclidean", multiple=FALSE),
    HTML("<br>"),
    HTML("<br>"),
    selectInput("kmeans_method", "Select the K-means Clustering method to use:", 
                choices = c("Hartigan-Wong", "Lloyd", "Forgy", "MacQueen"), selected="Lloyd", multiple=FALSE),    
    HTML("<br>"),
    HTML("<br>"),
    
    ###########################################################
    # STEP 2.3: buttons to download the new report and new slides 
    
    HTML("<hr>"),
    HTML("<h4>Download the new HTML report </h4>"),
    HTML("<br>"),
    HTML("<br>"),
    downloadButton('report', label = "Download"),
    HTML("<br>"),
    HTML("<br>"),
    HTML("<h4>Download the new HTML5 slides </h4>"),
    HTML("<br>"),
    HTML("(Only for small Data (not Boats!). Slides are not visible otherwise!)"),
    HTML("<br>"),
    HTML("<br>"),
    downloadButton('slide', label = "Download"),
    HTML("<hr></center>")
  ),
  
  ###########################################################
  # STEP 3: The output tabs (these follow more or less the 
  # order of the Rchunks in the report and slides)
  mainPanel(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    
    # Now these are the taps one by one. 
    # NOTE: each tab has a name that appears in the web app, as well as a
    # "variable" which has exactly the same name as the variables in the 
    # output$ part of code in the server.R file 
    # (e.g. tableOutput('parameters') corresponds to output$parameters in server.r)
    
    tabsetPanel(
      tabPanel("Parameters", 
               div(class="span12",tableOutput('parameters'))), 
      tabPanel("Summary", 
               div(class="span12",tableOutput('summary'))), 
      tabPanel("Histograms", 
               numericInput("var_chosen", "Select the attribute to see the Histogram for:", 1),
               div(class="span12",plotOutput('histograms'))), 
      tabPanel("Correlations",
               selectInput("show_colnames", "Show column names? (0 or 1):", choices=c("0","1"),selected=1, multiple=FALSE),               
               tableOutput('correlation')),
      tabPanel("Variance Explained",tableOutput('Variance_Explained_Table')),
      tabPanel("Scree Plot", htmlOutput("scree")), 
      tabPanel("Unrotated Factors",
               numericInput("unrot_number", "Select the the number of factors to see:",3),
               selectInput("show_colnames_unrotate", "Show variable names? (0 or 1):", choices=c("0","1"),selected=1, multiple=FALSE),               
               tableOutput('Unrotated_Factors')),
      tabPanel("Rotated Factors",
               selectInput("show_colnames_rotate", "Show variable names? (0 or 1):", choices=c("0","1"),selected=1, multiple=FALSE),               
               div(class="span12",h5("Showing Factors for the number of factors you selected in the right pane")),
               tableOutput('Rotated_Factors')),
      tabPanel("Factors Visualization", 
               numericInput("factor1", "Select the the x-axis factors to use:",1),
               numericInput("factor2", "Select the the y-axis factors to use:",2),             
               plotOutput("NEW_ProjectData")),
      tabPanel("Parameters Cluster", 
               div(class="span12",tableOutput('parameters_cluster'))), 
      tabPanel("Summary Cluster", 
               div(class="span12",tableOutput('summary_cluster'))), 
      tabPanel("Histograms Cluster", 
               numericInput("var_chosen", "Select the attribute to see the Histogram for:", 1),
               div(class="span12",plotOutput('histograms_cluster'))), 
      tabPanel("Pairwise Distances",
               selectInput("dist_chosen", "Select the distance metric:",  c("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski"),selected="euclidean"),
               numericInput("obs_shown", "How many observations to show? First:", 5),
               div(class="span12",h4("Histogram of Pairwise Distances")),
               div(class="span12",plotOutput('dist_histogram')), 
               div(class="span12",tableOutput('pairwise_dist'))), 
      tabPanel("The Dendrogram", 
               div(class="span12",plotOutput('dendrogram'))), 
      tabPanel("The Dendrogram Heights Plot", 
               div(class="span12",plotOutput('dendrogram_heights'))), 
      tabPanel("Hclust Membership", 
               numericInput("hclust_obs_chosen", "Select the observation to see the Hclust cluster membership for:", 1),
               div(class="span12",tableOutput('hclust_membership'))), 
      tabPanel("Kmeans Membership", 
               numericInput("kmeans_obs_chosen", "Select the observation to see the Kmeans cluster membership for:", 1),
               div(class="span12",tableOutput('kmeans_membership'))), 
      tabPanel("Kmeans Profiling",
               div(class="span12",tableOutput('kmeans_profiling'))), 
      tabPanel("Snake Plots", 
               selectInput("clust_method_used", "Select cluster method (kmeans or hclust):", 
                           choices = c("kmeans","hclust"), selected = "kmeans", multiple=FALSE),
               div(class="span12",plotOutput('snake_plot')))
      
    )
    
  )
))

