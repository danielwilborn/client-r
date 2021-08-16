library(RJSONIO)
library("stringr")
library(data.table)
hapi <- function(server = NULL, dataset = NULL, parameters = NULL, start = NULL, stop = NULL) {
  

  if (is.null(server)) {
    url <- "https://github.com/hapi-server/servers/raw/master/all.txt"
    print(paste("hapi(): Downloading", url, sep=" "))
    servers <- data.table::fread(url, header=FALSE)
    return(servers[[1]])
  }
  if (is.null(dataset)) {
    url <- paste(server, "catalog", sep="")
    print(paste("hapi(): Downloading", url, sep=" "))
    catalog <- fromJSON(url)
    return(catalog)
  }
  if (is.null(parameters)) {
    url <- paste(server, "info?id=", dataset, sep="")
    print(paste("hapi(): Downloading", url, sep=" "))
    info <- fromJSON(url)
    return(info)
  }
  if (is.null(start)) {
    url <- paste(server, "info?id=", dataset, "&parameters=", parameters, sep="")
    print(paste("hapi(): Downloading", url, sep=" "))
    info <- fromJSON(url)
    return(info)
  }
  if (is.null(stop)){
    stop("must enter a stop value")
  }

  meta <- hapi(server, dataset, parameters)
    
  url <- paste(server, "data?id=", dataset, "&parameters=", parameters, "&time.min=", start, "&time.max=", stop, sep="")
  print(paste("hapi(): Downloading", url, sep=" "))
  csv <- data.table::fread(url)
    
  parameters <- unlist(strsplit(paste("Time", parameters, sep=","), ","))
    
    # Put each column from csv into individual list element
  data <- list(csv[, 1])
    
    # Number of rows (time values)
  Nr <- nrow(data[[1]])
    
  k = 2
  for (i in 2:length(parameters)) {
    if ("size" %in% names(meta$parameters[[i]])) {
      size <- meta$parameters[[i]]$size
    } else {
      size <- 1
    }
      
      
      # Number of columns of parameter
    Nc <- prod(size)
      
    print(paste("Extracting columns ", k, "through", (k+Nc-1)), sep="")
      
      
   
    size <- append(Nr, size)
        

        
        
    print(paste("Extracting columns ", k, "through", (k+Nc-1)), sep="")
        
        # Extract columns and re-shape 
    data2 <- data.matrix(as.factor(unlist((csv[, k:(k+Nc-1)]))))
    dim(data2) <- size
        
        
        # Add to named list 
    data <- c(data, list(data2))
      
    k <- k + Nc
      
    }
    # Add names based on request parameters
    # If args[3] = "param1,param2", the following is equivalent to 
    # e.g., names(data) <- c("Time", "param1", "param2")
  names(data) <- c(parameters)
    
  return(data)
  
}

