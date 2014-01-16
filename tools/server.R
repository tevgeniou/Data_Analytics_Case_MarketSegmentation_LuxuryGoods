
#  Copyright 2013, INSEAD
#  by T. Evgeniou 
#  Dual licensed under the MIT or GPL Version 2 licenses.

if (!exists("local_directory")) {  
  local_directory <- "~/Data_Analytics_Case_MarketSegmentation_LuxuryGoods"
  source(paste(local_directory,"R/library.R",sep="/"))
  source(paste(local_directory,"R/heatmapOutput.R",sep="/"))
} 

# To be able to upload data up to 30MB
options(shiny.maxRequestSize=30*1024^2)
options(rgl.useNULL=TRUE)
options(scipen = 50)

# Please enter the maximum number of observations to show in the report and slides (DEFAULT is 100)
max_data_report = 50 

shinyServer(function(input, output,session) {
  
  ############################################################
  # STEP 1: Read the data 
  read_dataset <- reactive({
    input$datafile_name_coded
    
    # First read the pre-loaded file, and if the user loads another one then replace 
    # ProjectData with the filethe user loads
    ProjectData <- read.csv(paste(paste(local_directory,"data",sep="/"), paste(input$datafile_name_coded, "csv", sep="."), sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData
    ProjectData=data.matrix(ProjectData)
    
    updateSelectInput(session, "factor_attributes_used","Variables used for Factor Analysis",  colnames(ProjectData), selected=colnames(ProjectData)[1])
    updateSelectInput(session, "segmentation_attributes_used","Segmentation variables used",  colnames(ProjectData), selected=colnames(ProjectData)[1])
    updateSelectInput(session, "profile_attributes_used","Profiling variables used",  colnames(ProjectData), selected=colnames(ProjectData)[1])
    
    ProjectData
  })
  
  user_inputs <- reactive({
    input$datafile_name_coded
    input$factor_attributes_used
    input$manual_numb_factors_used
    input$rotation_used
    input$MIN_VALUE
    input$segmentation_attributes_used
    input$profile_attributes_used
    input$numb_clusters_used
    input$distance_used
    input$hclust_method
    input$kmeans_method
        
    ProjectData = read_dataset()
    ProjectDataFactor = as.matrix(ProjectData[,input$factor_attributes_used, drop=F])
    ProjectData_segment=ProjectData[,input$segmentation_attributes_used,drop=F]
    ProjectData_profile=ProjectData[,input$profile_attributes_used,drop=F]
    
    list(ProjectData = read_dataset(), 
         ProjectDataFactor = ProjectDataFactor,
         factor_attributes_used = input$factor_attributes_used, 
         manual_numb_factors_used = max(1,min(input$manual_numb_factors_used,length(input$factor_attributes_used))),
         rotation_used = input$rotation_used,
         MIN_VALUE = input$MIN_VALUE,
         ProjectData_segment = ProjectData_segment,
         ProjectData_profile = ProjectData_profile,
         segmentation_attributes_used = input$segmentation_attributes_used, 
         profile_attributes_used = input$profile_attributes_used,
         numb_clusters_used = input$numb_clusters_used,
         distance_used = input$distance_used,
         hclust_method = input$hclust_method,
         kmeans_method = input$kmeans_method         
    )
  }) 
  
  ############################################################
  # STEP 2: create a "reactive function" as well as an "output" 
  # for each of the R code chunks in the report/slides to use in the web application. 
  # These also correspond to the tabs defined in the ui.R file. 
  
  # The "reactive function" recalculates everything the tab needs whenever any of the inputs 
  # used (in the left pane of the application) for the calculations in that tab is modified by the user 
  # The "output" is then passed to the ui.r file to appear on the application page/
  
  ########## The Parameters Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  the_parameters_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$factor_attributes_used
    input$manual_numb_factors_used
    input$rotation_used
    input$MIN_VALUE
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData 
    ProjectDataFactor = all_inputs$ProjectDataFactor
    factor_attributes_used = all_inputs$factor_attributes_used
    manual_numb_factors_used = all_inputs$manual_numb_factors_used
    rotation_used = all_inputs$rotation_used
    MIN_VALUE = all_inputs$MIN_VALUE
    
    
    allparameters=c(nrow(ProjectData), ncol(ProjectData),
                    ncol(ProjectDataFactor),
                    manual_numb_factors_used, rotation_used,factor_attributes_used
    )
    allparameters<-matrix(allparameters,ncol=1)    
    theparameter_names <- c("Total number of observations", "Total number of attributes", 
                            "Number of attrubutes used",  
                            "Number of factors to get", "Rotation used",
                            paste("Used Attribute:",1:length(factor_attributes_used), sep=" ")
    )
    if (length(allparameters) == length(theparameter_names))
      rownames(allparameters)<- theparameter_names
    colnames(allparameters)<-NULL
    allparameters<-as.data.frame(allparameters)
    
    allparameters
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$parameters<-renderTable({
    the_parameters_tab()
  })
  
  ########## The Summary Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_summary_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData
    ProjectDataFactor = all_inputs$ProjectDataFactor
    factor_attributes_used = all_inputs$factor_attributes_used
    
    my_summary(ProjectDataFactor)
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$summary <- renderTable({        
    the_summary_tab()
  })
  
  
  ########## The hisotgrams Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_histogram_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$var_chosen
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData
    
    var_chosen = max(0,min(input$var_chosen,ncol(ProjectData)))
    ProjectData[,var_chosen,drop=F]
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$histograms <- renderPlot({  
    data_used = unlist(the_histogram_tab())
    numb_of_breaks = ifelse(length(unique(data_used)) < 10, length(unique(data_used)), length(data_used)/5)
    hist(data_used, breaks=numb_of_breaks,main = NULL, xlab=paste("Histogram of Variable: ",colnames(data_used)), ylab="Frequency", cex.lab=1.2, cex.axis=1.2)
  })
  
  ########## The next few tabs use the same "heavy computation" results, so we do these only once
  
  the_computations_fa<-reactive({
    # list the user inputs the tab depends on (easier to read the code)    
    input$datafile_name_coded
    input$factor_attributes_used
    input$manual_numb_factors_used
    input$rotation_used
    input$unrot_number
    input$MIN_VALUE
    input$show_colnames_unrotate    
    input$show_colnames_rotate
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData 
    ProjectDataFactor = all_inputs$ProjectDataFactor
    
    factor_attributes_used = all_inputs$factor_attributes_used
    manual_numb_factors_used = all_inputs$manual_numb_factors_used
    rotation_used = all_inputs$rotation_used
    MIN_VALUE = all_inputs$MIN_VALUE
    
    unrot_number = max(1, min(input$unrot_number, length(factor_attributes_used)))
    
    correl <- cor(ProjectDataFactor)
    
    Unrotated_Results<-principal(ProjectDataFactor, nfactors=ncol(ProjectDataFactor), rotate="none")
    Unrotated_Factors<-Unrotated_Results$loadings[,1:unrot_number,drop=F]
    
    Unrotated_Factors<-as.data.frame(unclass(Unrotated_Factors))
    colnames(Unrotated_Factors)<-paste("Component",1:ncol(Unrotated_Factors),sep=" ")
    rownames(Unrotated_Factors) <- colnames(ProjectDataFactor)
    
    if (input$show_colnames_unrotate==0)
      rownames(Unrotated_Factors)<- NULL
    
    Variance_Explained_Table_results<-PCA(ProjectDataFactor, graph=FALSE)
    Variance_Explained_Table<-Variance_Explained_Table_results$eig
    
    eigenvalues<-Unrotated_Results$values
    
    
    Rotated_Results<-principal(ProjectDataFactor, nfactors=manual_numb_factors_used, rotate=rotation_used,score=TRUE)
    Rotated_Factors<-round(Rotated_Results$loadings,2)
    Rotated_Factors<-as.data.frame(unclass(Rotated_Factors))
    colnames(Rotated_Factors)<-paste("Component",1:ncol(Rotated_Factors),sep=" ")
    
    sorted_rows <- sort(Rotated_Factors[,1], decreasing = TRUE, index.return = TRUE)$ix
    Rotated_Factors <- Rotated_Factors[sorted_rows,]
    
    Rotated_Factors<-as.data.frame(unclass(Rotated_Factors))
    colnames(Rotated_Factors)<-paste("Component",1:ncol(Rotated_Factors),sep=" ")
    rownames(Rotated_Factors) <- colnames(ProjectDataFactor)
    
    if (input$show_colnames_rotate==0)
      rownames(Rotated_Factors)<- NULL
    
    NEW_ProjectData <- Rotated_Results$scores
    colnames(NEW_ProjectData)<-paste("Derived Variable (Factor)",1:ncol(NEW_ProjectData),sep=" ")
    
    list( 
      correl = correl,
      Unrotated_Results = Unrotated_Results,
      Unrotated_Factors = Unrotated_Factors,
      Variance_Explained_Table_results = Variance_Explained_Table_results,
      Variance_Explained_Table = Variance_Explained_Table,
      eigenvalues = eigenvalues,
      Rotated_Results = Rotated_Results,
      Rotated_Factors = Rotated_Factors,
      NEW_ProjectData = NEW_ProjectData
    )
  })
  
  # Now get the rest of the tabs
  
  the_correlation_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)    
    input$datafile_name_coded
    input$factor_attributes_used
    input$show_colnames
    
    data_used = the_computations_fa()    
    the_data = data_used$correl
    if (input$show_colnames == "0"){
      colnames(the_data) <- NULL
      rownames(the_data) <- NULL
    }
    round(the_data,2)
  })
  
  output$correlation <- renderHeatmap({  
    round(the_correlation_tab(),2)   
  })
  
  output$Variance_Explained_Table<-renderTable({
    data_used = the_computations_fa()    
    round(data_used$Variance_Explained_Table,2)
  })
  
  output$Unrotated_Factors<-renderHeatmap({
    
    data_used = the_computations_fa()        
    
    the_data = round(data_used$Unrotated_Factors,2)
    the_data[abs(the_data) < input$MIN_VALUE] <- 0
    the_data
  })
  
  output$Rotated_Factors<-renderHeatmap({
    data_used = the_computations_fa()        
    
    the_data = round(data_used$Rotated_Factors,2)
    the_data[abs(the_data) < input$MIN_VALUE] <- 0
    the_data
  })
  
  output$scree <- renderGvis({      
    data_used = the_computations_fa()
    
    eigenvalues  <- data_used$eigenvalues
    df           <- cbind(as.data.frame(eigenvalues), c(1:length(eigenvalues)), rep(1, length(eigenvalues)))
    colnames(df) <- c("eigenvalues", "components", "abline")
    gvisLineChart(as.data.frame(df), xvar="components", yvar=c("eigenvalues","abline"), options=list(title='Scree plot', legend="right", width=900, height=600, hAxis="{title:'Number of Components', titleTextStyle:{color:'black'}}", vAxes="[{title:'Eigenvalues'}]",  series="[{color:'green',pointSize:12, targetAxisIndex: 0}]"))
  })
  
  output$NEW_ProjectData<-renderPlot({  
    input$factor1
    input$factor
    data_used = the_computations_fa()    
    NEW_ProjectData <- data_used$NEW_ProjectData
    
    factor1 = max(1,min(input$factor1,ncol(NEW_ProjectData)))
    factor2 = max(1,min(input$factor2,ncol(NEW_ProjectData)))
    
    if (ncol(NEW_ProjectData)>=2 ){
      plot(NEW_ProjectData[,factor1],NEW_ProjectData[,factor2], 
           main="Data Visualization Using the Derived Attributes (Factors)",
           xlab=colnames(NEW_ProjectData)[factor1], 
           ylab=colnames(NEW_ProjectData)[factor2])
    } else {
      plot(NEW_ProjectData[,1],ProjectData[,1], 
           main="Only 1 Derived Variable: Using Initial Variable",
           xlab="Derived Variable (Factor) 1", 
           ylab="Initial Variable (Factor) 2")    
    }
  })

  
  ################## 
  # THE CLUSTERING CODE NOW
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  the_parameters_cluster_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$segmentation_attributes_used
    input$profile_attributes_used
    input$numb_clusters_used
    input$distance_used
    input$hclust_method
    input$kmeans_method
    input$MIN_VALUE
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData 
    ProjectData_segment = all_inputs$ProjectData_segment
    ProjectData_profile = all_inputs$ProjectData_profile
    segmentation_attributes_used = all_inputs$segmentation_attributes_used 
    profile_attributes_used = all_inputs$profile_attributes_used
    numb_clusters_used = all_inputs$numb_clusters_used
    distance_used = all_inputs$distance_used
    hclust_method = all_inputs$hclust_method
    kmeans_method = all_inputs$kmeans_method
    MIN_VALUE = all_inputs$MIN_VALUE                    
    
    
    allparameters=c(nrow(ProjectData), ncol(ProjectData),
                    ncol(ProjectData_segment), ncol(ProjectData_profile),
                    numb_clusters_used, distance_used,hclust_method,kmeans_method,
                    segmentation_attributes_used,profile_attributes_used
    )
    allparameters<-matrix(allparameters,ncol=1)    
    theparameter_names <- c("Total number of observations", "Total number of attributes", 
                            "Number of segmentation attributes used", "Number of profiling attributes used", 
                            "Number of clusters to get", "Distance Metric", "Hclust Method", "Kmeans Method",
                            paste("SEGMENTATION Attribute:",1:length(segmentation_attributes_used), sep=" "),
                            paste("PROFILING Attrbute:",1:length(profile_attributes_used), sep=" ")
    )
    if (length(allparameters) == length(theparameter_names))
      rownames(allparameters)<- theparameter_names
    colnames(allparameters)<-NULL
    allparameters<-as.data.frame(allparameters)
    
    allparameters
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$parameters_cluster<-renderTable({
    the_parameters_cluster_tab()
  })
  
  ########## The Summary Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_summary_cluster_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData
    
    my_summary(ProjectData)
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$summary_cluster <- renderTable({        
    t(the_summary_cluster_tab())
  })
  
  
  ########## The hisotgrams Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_histogram_cluster_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$var_chosen
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData
    var_chosen = max(0,min(input$var_chosen,ncol(ProjectData)))
    
    ProjectData[,var_chosen,drop=F]
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$histograms_cluster <- renderPlot({  
    data_used = unlist(the_histogram_cluster_tab())
    numb_of_breaks = ifelse(length(unique(data_used)) < 10, length(unique(data_used)), length(data_used)/5)
    hist(data_used, breaks=numb_of_breaks,main = NULL, xlab=paste("Histogram of Variable: ",colnames(data_used)), ylab="Frequency", cex.lab=1.2, cex.axis=1.2)
  })
  
  
  ########## The pairwise distances Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_pairwise_dist_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$segmentation_attributes_used
    input$dist_chosen
    input$obs_shown
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData
    ProjectData_segment = all_inputs$ProjectData_segment
    ProjectData_profile = all_inputs$ProjectData_profile
    
    pairwise_dist=as.matrix(dist(ProjectData_segment,method=input$dist_chosen))
    pairwise_dist=pairwise_dist*lower.tri(pairwise_dist)+pairwise_dist*diag(pairwise_dist)+10e10*upper.tri(pairwise_dist)
    pairwise_dist[pairwise_dist==10e10]<- NA
    
    pairwise_dist
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$dist_histogram <- renderPlot({  
    hist(the_pairwise_dist_tab(), main = NULL, 
         xlab=paste(paste("Histogram of all pairwise Distances for",input$dist_chosen,sep=" "),"distance between observtions",sep=" "), ylab="Frequency")
  })
  
  output$pairwise_dist<-renderTable({
    the_pairwise_dist_tab()[1:input$obs_shown, 1:input$obs_shown]
  })  
  
  
  ########## The next few tabs use the same "heavy computation" results for Hclust, so we do these only once
  
  the_computations_hc<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$segmentation_attributes_used
    input$numb_clusters_used
    input$distance_used
    input$MIN_VALUE    
    input$hclust_method
    input$kmeans_method
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData
    ProjectData_profile = all_inputs$ProjectData_profile
    ProjectData_segment = all_inputs$ProjectData_segment
    distance_used = all_inputs$distance_used
    numb_clusters_used = all_inputs$numb_clusters_used
    hclust_method = all_inputs$hclust_method
    kmeans_method = input$kmeans_method
    
    Hierarchical_Cluster_distances<-dist(ProjectData_segment,method=distance_used)
    Hierarchical_Cluster <- hclust(Hierarchical_Cluster_distances, method=hclust_method)
    
    cluster_memberships_hclust <- as.vector(cutree(Hierarchical_Cluster, k=numb_clusters_used)) # cut tree into 3 clusters
    cluster_ids_hclust=unique(cluster_memberships_hclust)
    ProjectData_with_hclust_membership <- cbind(cluster_memberships_hclust, ProjectData)
    colnames(ProjectData_with_hclust_membership)<-c("Cluster_Membership",colnames(ProjectData))
    Cluster_Profile_mean=sapply(cluster_ids_hclust,function(i) {
      useonly = which((cluster_memberships_hclust==i))
      apply(ProjectData_profile[useonly,,drop=F],2,mean)
    })
    colnames(Cluster_Profile_mean)<- paste("Segment",1:length(cluster_ids_hclust),sep=" ")
    
    list(
      ProjectData_segment = ProjectData_segment,
      Hierarchical_Cluster = Hierarchical_Cluster,
      cluster_memberships = cluster_memberships_hclust,
      cluster_ids = cluster_ids_hclust,
      Cluster_Profile_mean = Cluster_Profile_mean,
      ProjectData_with_hclust_membership = ProjectData_with_hclust_membership
    )
  })
  
  ########## The Hcluster related Tabs now
  
  output$dendrogram <- renderPlot({  
    data_used = the_computations_hc()
    
    plot(data_used$Hierarchical_Cluster,main = NULL, sub=NULL,labels = 1:nrow(data_used$ProjectData_segment), xlab="Our Observations", cex.lab=1, cex.axis=1) 
    rect.hclust(data_used$Hierarchical_Cluster, k=input$numb_clusters_used, border="red") 
  })
  
  output$dendrogram_heights <- renderPlot({  
    data_used = the_computations()
    
    plot(data_used$Hierarchical_Cluster$height[length(data_used$Hierarchical_Cluster$height):1],type="l")
  })
  
  
  ########## The  Hcluster Membership Tab  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_Hcluster_member_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$hclust_obs_chosen
    data_used = the_computations_hc()    
    
    hclust_obs_chosen=matrix(data_used$ProjectData_with_hclust_membership[input$hclust_obs_chosen,"Cluster_Membership"],ncol=1)
    rownames(hclust_obs_chosen)<-"Cluster Membership"
    colnames(hclust_obs_chosen)<-input$hclust_obs_chosen
    hclust_obs_chosen
  })
  
  output$hclust_membership<-renderTable({
    data_used = the_Hcluster_member_tab()
    data_used    
  })  
  
  
  ########## The next few tabs use the same "heavy computation" results for kmeans, so we do these only once
  
  the_kmeans_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$segmentation_attributes_used
    input$numb_clusters_used
    input$distance_used
    input$MIN_VALUE    
    input$hclust_method
    input$kmeans_method
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData
    ProjectData_profile = all_inputs$ProjectData_profile
    ProjectData_segment = all_inputs$ProjectData_segment
    distance_used = all_inputs$distance_used
    numb_clusters_used = all_inputs$numb_clusters_used
    hclust_method = all_inputs$hclust_method
    kmeans_method = input$kmeans_method
    
    kmeans_clusters <- kmeans(ProjectData_segment,centers= numb_clusters_used, iter.max=1000, algorithm=kmeans_method)
    
    ProjectData_with_kmeans_membership <- cbind(kmeans_clusters$cluster, ProjectData)
    colnames(ProjectData_with_kmeans_membership)<-c("Cluster_Membership", colnames(ProjectData))
    
    cluster_memberships_kmeans <- kmeans_clusters$cluster 
    cluster_ids_kmeans <- unique(cluster_memberships_kmeans)
    
    cluster_memberships <- cluster_memberships_kmeans
    cluster_ids <-  cluster_ids_kmeans
    
    Cluster_Profile_mean <- sapply(cluster_ids, function(i) apply(ProjectData_profile[(cluster_memberships==i), ], 2, mean))
    colnames(Cluster_Profile_mean) <- paste("Segment (AVG)", 1:length(cluster_ids), sep=" ")
    
    
    list(
      kmeans_clusters = kmeans_clusters,
      ProjectData_with_kmeans_membership = ProjectData_with_kmeans_membership,
      cluster_memberships = cluster_memberships,
      Cluster_Profile_mean = Cluster_Profile_mean,
      ProjectData_with_kmeans_membership = ProjectData_with_kmeans_membership
    )
  })
  
  ########## The Kmeans related Tabs now
  
  kmeans_membership<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$kmeans_obs_chosen
    data_used = the_kmeans_tab()    
    
    kmeans_obs_chosen=matrix(data_used$ProjectData_with_kmeans_membership[input$kmeans_obs_chosen,"Cluster_Membership"],ncol=1)
    rownames(kmeans_obs_chosen)<-"Cluster Membership"
    colnames(kmeans_obs_chosen)<-input$kmeans_obs_chosen
    kmeans_obs_chosen
  })
  
  output$kmeans_membership<-renderTable({
    data_used = kmeans_membership()
    data_used    
  })  
  
  output$kmeans_profiling<-renderTable({
    data_used = the_kmeans_tab()    
    # Must also show the standard deviations...!
    data_used$Cluster_Profile_mean
  })  
  
  
  ### Now do the snake plot tab. first the reactive
  
  snake_plot_tab <- reactive({  
    input$clust_method_used
    
    all_inputs <- user_inputs()
    ProjectData = all_inputs$ProjectData
    ProjectData_profile = all_inputs$ProjectData_profile
    
    data_used_kmeans = the_kmeans_tab()    
    data_used_hclust = the_Hcluster_member_tab()
    
    ProjectData_scaled_profile=apply(ProjectData_profile,2, function(r) {if (sd(r)!=0) res=(r-mean(r))/sd(r) else res=0*r; res})
    if (input$clust_method_used == "hclust"){ 
      cluster_memberships = data_used_hclust$cluster_memberships
    } else {
      cluster_memberships = data_used_kmeans$cluster_memberships      
    }
    
    cluster_ids = unique(cluster_memberships)
    Cluster_Profile_standar_mean <- sapply(cluster_ids, function(i) apply(ProjectData_scaled_profile[(cluster_memberships==i), ], 2, mean))
    colnames(Cluster_Profile_standar_mean) <- paste("Segment (AVG)", 1:length(cluster_ids), sep=" ")
    
    list(Cluster_Profile_standar_mean = Cluster_Profile_standar_mean,
         cluster_ids = cluster_ids)
  })
  
  # now pass it to ui.R
  output$snake_plot <- renderPlot({  
    data_used=snake_plot_tab()
    Cluster_Profile_standar_mean = data_used$Cluster_Profile_standar_mean
    cluster_ids = data_used$cluster_ids
    
    plot(Cluster_Profile_standar_mean[, 1,drop=F], type="l", col="red", main="Snake plot for each cluster", ylab="mean of cluster", xlab="profiling variables (standardized)",ylim=c(min(Cluster_Profile_standar_mean),max(Cluster_Profile_standar_mean))) 
    for(i in 2:ncol(Cluster_Profile_standar_mean))
      lines(Cluster_Profile_standar_mean[, i], col="blue")
  })  
  
  
  # Now the report and slides  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_slides_and_report <-reactive({
    input$datafile_name_coded
    input$factor_attributes_used
    input$manual_numb_factors_used
    input$rotation_used
    input$MIN_VALUE
    input$segmentation_attributes_used
    input$profile_attributes_used
    input$numb_clusters_used
    input$distance_used
    input$hclust_method
    input$kmeans_method
    
    all_inputs <- user_inputs()
    
    #############################################################
    # A list of all the (SAME) parameters that the report takes from RunStudy.R
    list(
      ProjectData = all_inputs$ProjectData,
      ProjectDataFactor = all_inputs$ProjectDataFactor,
      factor_attributes_used = all_inputs$factor_attributes_used,
      manual_numb_factors_used = all_inputs$manual_numb_factors_used,
      rotation_used = all_inputs$rotation_used,
      MIN_VALUE = all_inputs$MIN_VALUE,
      ProjectData_segment = all_inputs$ProjectData_segment,
      ProjectData_profile = all_inputs$ProjectData_profile,
      segmentation_attributes_used = all_inputs$segmentation_attributes_used, 
      profile_attributes_used = all_inputs$profile_attributes_used,
      numb_clusters_used = all_inputs$numb_clusters_used,
      distance_used = all_inputs$distance_used,
      hclust_method = all_inputs$hclust_method,
      kmeans_method = all_inputs$kmeans_method
    )    
  })
  
  # The new report 
  
  output$report = downloadHandler(
    filename <- function() {paste(paste('Report',Sys.time() ),'.html')},
    
    content = function(file) {
      
      filename.Rmd <- paste(local_directory, 'tools/Report.Rmd', sep="/")
      filename.md <- paste(local_directory, 'tools/Report.md', sep="/")
      filename.html <- paste(local_directory, 'tools/Report.html', sep="/")
      
      #############################################################
      # All the (SAME) parameters that the report takes from RunStudy.R
      reporting_data<- the_slides_and_report()
      
      ProjectData = reporting_data$ProjectData
      ProjectDataFactor = reporting_data$ProjectDataFactor
      factor_attributes_used = reporting_data$factor_attributes_used
      manual_numb_factors_used = reporting_data$manual_numb_factors_used
      rotation_used = reporting_data$rotation_used
      MIN_VALUE = reporting_data$MIN_VALUE
      segmentation_attributes_used = reporting_data$segmentation_attributes_used
      profile_attributes_used = reporting_data$profile_attributes_used
      numb_clusters_used = reporting_data$numb_clusters_used
      distance_used = reporting_data$distance_used
      hclust_method = reporting_data$hclust_method
      kmeans_method = reporting_data$kmeans_method
      ProjectData_segment = reporting_data$ProjectData_segment
      ProjectData_profile = reporting_data$ProjectData_profile            
      
      minimum_variance_explained = 65 # it is not used in the app anyway
      factor_selectionciterion = "manual" # this is manual as the user defines everything via the app
      #############################################################
      
      if (file.exists(filename.html))
        file.remove(filename.html)
      unlink(paste(local_directory, 'tools/.cache', sep="/"), recursive=TRUE)
      unlink(paste(local_directory, 'tools/assets', sep="/"), recursive=TRUE)
      unlink(paste(local_directory, 'tools/figures', sep="/"), recursive=TRUE)
      
      file.copy(paste(local_directory,"doc/Report.Rmd",sep="/"),filename.Rmd,overwrite=T)
      out = knit2html(filename.Rmd,quiet=TRUE)
      
      unlink(paste(local_directory, 'tools/.cache', sep="/"), recursive=TRUE)
      unlink(paste(local_directory, 'tools/assets', sep="/"), recursive=TRUE)
      unlink(paste(local_directory, 'tools/figures', sep="/"), recursive=TRUE)
      file.remove(filename.Rmd)
      file.remove(filename.md)
      
      file.rename(out, file) # move pdf to file for downloading
    },    
    contentType = 'application/pdf'
  )
  
  # The new slides 
  
  output$slide = downloadHandler(
    filename <- function() {paste(paste('Slides',Sys.time() ),'.html')},
    
    content = function(file) {
      
      filename.Rmd <- paste(local_directory, 'tools/Slides.Rmd', sep="/")
      filename.md <- paste(local_directory, 'tools/Slides.md', sep="/")
      filename.html <- paste(local_directory, 'tools/Slides.html', sep="/")
      #############################################################
      # All the (SAME) parameters that the report takes from RunStudy.R
      reporting_data<- the_slides_and_report()
      
      ProjectData = reporting_data$ProjectData
      ProjectDataFactor = reporting_data$ProjectDataFactor
      factor_attributes_used = reporting_data$factor_attributes_used
      manual_numb_factors_used = reporting_data$manual_numb_factors_used
      rotation_used = reporting_data$rotation_used
      MIN_VALUE = reporting_data$MIN_VALUE
      segmentation_attributes_used = reporting_data$segmentation_attributes_used
      profile_attributes_used = reporting_data$profile_attributes_used
      numb_clusters_used = reporting_data$numb_clusters_used
      distance_used = reporting_data$distance_used
      hclust_method = reporting_data$hclust_method
      kmeans_method = reporting_data$kmeans_method
      ProjectData_segment = reporting_data$ProjectData_segment
      ProjectData_profile = reporting_data$ProjectData_profile            
      
      minimum_variance_explained = 65 # it is not used in the app anyway
      factor_selectionciterion = "manual" # this is manual as the user defines everything via the app
      #############################################################
      
      if (file.exists(filename.html))
        file.remove(filename.html)
      unlink(paste(local_directory, 'tools/.cache', sep="/"), recursive=TRUE)
      unlink(paste(local_directory, 'tools/assets', sep="/"), recursive=TRUE)
      unlink(paste(local_directory, 'tools/figures', sep="/"), recursive=TRUE)
      
      file.copy(paste(local_directory,"doc/Slides.Rmd",sep="/"),filename.Rmd,overwrite=T)
      slidify(filename.Rmd)
      
      unlink(paste(local_directory, 'tools/.cache', sep="/"), recursive=TRUE)
      unlink(paste(local_directory, 'tools/assets', sep="/"), recursive=TRUE)
      unlink(paste(local_directory, 'tools/figures', sep="/"), recursive=TRUE)
      file.remove(filename.Rmd)
      file.remove(filename.md)
      file.rename(filename.html, file) # move pdf to file for downloading      
    },    
    contentType = 'application/pdf'
  )
  
})





