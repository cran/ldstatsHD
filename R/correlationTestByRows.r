## Function cor2meanbyVar
correlationTest.byRows <- function(D1, testStatistic = c("AS", "max"), nite= 1000, 
 								   subMatComp = FALSE, conf.level = 0.95)
{
  ## test  
  r1         <- scale(D1)
  n          <- dim(r1)[1]
  p          <- dim(r1)[2]
  if(any(testStatistic == "AS"))  Adj1       <- cor2mean.adj(t(r1))
  if(any(testStatistic == "max")){
   if(subMatComp) max1       <- apply(as.matrix(1:p), 1, function(i) max(abs(cor(r1[,i],r1[,-i]))))
   else{
    cor1 		<- cor(r1)
    diag(cor1) 	<- 0   
    max1        <- apply(abs(cor1), 1, max)
   } 		  
  } 
  pb        <- txtProgressBar(min = 0, max = nite, style = 3)
  if(length(testStatistic) == 2){
   TheoCors1 <- apply(as.matrix(1:nite),1,function(k){
     setTxtProgressBar(pb, k)
     rand.mat 	<- matrix(rnorm(n))
     AX 		<- cor(rand.mat, r1)
     c(mean(AX^2), max(abs(AX)))
   })
  } 
  else{
   if(testStatistic == "max")
   {
    TheoCors1 <- apply(as.matrix(1:nite),1,function(k){
     setTxtProgressBar(pb, k)
     rand.mat 	<- matrix(rnorm(n))
     AX 		<- cor(rand.mat, r1)
     c(NA, max(abs(AX)))
    })
   }
   if(testStatistic == "AS")
   {
    TheoCors1 <- apply(as.matrix(1:nite),1,function(k){
     setTxtProgressBar(pb, k)
     rand.mat 	<- matrix(rnorm(n))
     AX 		<- cor(rand.mat, r1)
     c(mean(AX^2), NA)
    })
   }
  }
  close(pb)
 
  obj 		    		<- list()
  obj$Maxtest 			<- NULL
  obj$pvalMax 			<- NULL
  obj$ciMax   			<- NULL
  obj$AStest 			<- NULL
  obj$pvalAS 			<- NULL
  obj$ciAS   			<- NULL
  obj$testStatistic 	<- testStatistic
  obj$conf.level 		<- conf.level  
  obj$paired	 		<- NULL  
    
  if(any(testStatistic == "AS")){
     TheoAdCors1 	<- ((n-1)/(n-2) * TheoCors1[1,] - 1/(n-2))
     obj$pvalAS		<- apply(as.matrix(Adj1), 1, function(x) mean(TheoAdCors1 > x))
     obj$ciAS       <- t(apply(as.matrix(Adj1), 1, function(x) quantile(x - TheoAdCors1, c((1-conf.level), 1),na.rm =TRUE)))
  	 obj$AStest     <- Adj1
  }
  if(any(testStatistic == "max")){
     obj$pvalMax     	<- apply(as.matrix(max1), 1, function(x) mean(TheoCors1[2,] > x))
     obj$ciMax        	<- t(apply(as.matrix(max1), 1, function(x) quantile(x - TheoCors1[2,], c((1-conf.level), 1),na.rm =TRUE)))
  	 obj$Maxtest   		<- max1
  }
     
  return(obj)
}
