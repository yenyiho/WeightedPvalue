library(MASS)

mylm<-function(x,y){
  test<-na.omit(cbind(x,y))
  n<-ncol(test)
  y<-test[,n]
  x<-test[,-n]
  x<-cbind(1, x)
  b<-solve(t(x)%*%x)%*%t(x)%*%y
  sse<-t(y)%*%y - t(b)%*%t(x)%*%y
  invx<-solve(t(x)%*%x)
  df<-length(y)-ncol(x)
  msse<-sse/df
  c2<-msse*invx[2,2]
  tt<-as.numeric(b[2]/sqrt(c2))
  return(tt)
}


#### Need to add (trim?) and prior weights. 
#### p1 is a ix by iz matrix 
#### q1 is a iz vector 


weight<-function(data, p1, q1){
  ix<-grep(pattern="x", colnames(data))
  iz<-grep(pattern="z", colnames(data))
  iy<-grep(pattern="y",colnames(data))
  testp<-rep(NA, length(ix))
  li.w<-matrix(NA, nrow=length(ix), ncol=length(iz))
  n<-nrow(data)
  wmin<-matrix(NA, nrow=length(ix), ncol=length(iz))
  for(i in ix){
    x<-data[,ix[i]]
    y<-data[,iy]
    summ<-mylm(x, y)
    testp[i]<-min(pt(summ, n-2, lower.tail=F), pt(summ, n-2, lower.tail=T))*2
    for(j in 1:length(iz)){
      z<-data[,iz[j]]
      summ1<-mylm(cbind(x, y), z)
      summ2<-mylm(cbind(z, x), y)
      psumm1<-min(pt(summ1, n-3, lower.tail=F), pt(summ1, n-3, lower.tail=T))*2
      psumm2<-min(pt(summ2, n-3, lower.tail=F), pt(summ2, n-3, lower.tail=T))*2
      summli<-mylm(x, z)
      ppli<-min(pt(summli, n-2, lower.tail=F), pt(summli, n-2, lower.tail=T))*2
      pli<--log(ppli,10)
      if (pli==Inf){
        pli<-1000000
      }
      li.w[i,j]<-sqrt(pli)
      wmin[i,j]<-min((summ1^2 + log((1-p1[i,j])/p1[i,j])), (summ2^2 + log((1-q1[j])/q1[j])))
    }
  }
  mli<-apply(li.w, 1, max)
  if (mean(mli)==0){
    wmli<-rep(0, length(ix))
  } else{
    wmli<-mli/mean(mli)
  }
  wminp<-apply(wmin, 1, max)
  if (mean(wminp)==0){
    minw<-rep(0, length(ix))
  } else{
    minw<-wminp/mean(wminp)
  }
  return(list(testp, wmli, minw))
}



splitweight<-function(data, p1, q1){
  ix<-grep(pattern="x", colnames(data))
  iz<-grep(pattern="z", colnames(data))
  iy<-grep(pattern="y",colnames(data))
  wmin<-matrix(NA, nrow=length(ix), ncol=length(iz))
  wp<-matrix(NA, nrow=length(ix), ncol=length(iz))
  testp<-rep(NA, length(ix))
  itrain<-sample(1:nrow(data), ceiling(nrow(data)/2))
  trainDat<-data[itrain,]
  testDat<-data[-itrain,]
  for(i in 1:length(ix)){
    n<-nrow(trainDat)
    xt<-trainDat[,ix[i]]
    yt<-trainDat[,iy]
    summ<-mylm(xt, yt)
    testp[i]<-min(pt(summ, n-2, lower.tail=F), pt(summ, n-2, lower.tail=T))*2
    for(j in 1:length(iz)){
      nn<-nrow(testDat)
      xtt<-testDat[,ix[i]]
      ztt<-testDat[,iz[j]]
      ytt<-testDat[,iy]
      summ1<-mylm(cbind(xtt, ytt), ztt)
      summ2<-mylm(cbind(ztt, xtt), ytt)
      psumm1<-min(pt(summ1, nn-3, lower.tail=F), pt(summ1, nn-3, lower.tail=T))*2
      psumm2<-min(pt(summ2, nn-3, lower.tail=F), pt(summ2, nn-3, lower.tail=T))*2
      wmin[i,j]<-min((summ1^2 + log((1-p1[i,j])/p1[i,j])), (summ2^2 + log((1-q1[j])/q1[j])))
    }
  }
  wminp<-apply(wmin, 1, max)
  if (mean(wminp)==0){
    minw<-rep(0, length(ix))
  } else{
    minw<-wminp/mean(wminp)
  }
  return(list(testp, minw))
}




simDataS1fr<-function(n=50, beta1=0, beta2=0, nmiR=10, mE=50){
  x<-rnorm(n=n, mean=0, sd=1)
  z<-beta1*x + rnorm(n)
  y<-beta2*z + rnorm(n)
  xo<-matrix(rnorm(n*nmiR), nrow=n)
  rownames(xo)<-NULL
  zo<-matrix(rnorm(n*mE), nrow=n)
  dat<-cbind(x, xo, z, zo, y)
  colnames(dat)<-c(paste("x", c(1:(ncol(xo)+1)), sep=""), paste("z", c(1:(ncol(zo)+1)), sep=""), "y")
  return(dat)	
}


wholm<-function(alpha, pvalue, weight){
  padj<-pvalue/weight
  order<-order(padj, decreasing=F)
  pstar<-padj[order]
  wstar<-weight[order]
  reorder<-match(1:length(pvalue), order)
  r<-rep(0, length(pvalue))
  for(i in 1:length(pvalue)){
    ccum<-c(0, cumsum(weight))
    csum<-sum(weight)-ccum[i]
    if(pstar [i]< alpha/csum){
      r[i]<-1
    }else{
      break
    }
  }	
  ansr<-r[reorder]
  return(ansr)
}

type1wrapperS1h<-function(iter, n=50, beta1=0, beta2=0, nmiR=10, mE=50, p1, q1){
  data<-simDataS1fr(n=n, beta1=beta1, beta2=beta2, nmiR=nmiR, mE=mE)
  wp<-weight(data, p1=p1, q1=q1)
  rawp<-wp[[1]]
  lip<-wp[[1]]/wp[[2]]
  lip<-ifelse(lip>1, 1, lip)
  minp<-wp[[1]]/wp[[3]]
  minp<-ifelse(minp >1, 1, minp)
  scp<-splitweight(data, p1=p1, q1=q1)
  wminsc<-scp[[1]]/scp[[2]]
  wminsc<-ifelse(wminsc>1, 1, wminsc)
  h.raw<-wholm(0.05, wp[[1]], weight=rep(1, length(wp[[1]])))
  h.li<-wholm(0.05, wp[[1]], wp[[2]])
  h.min<-wholm(0.05, wp[[1]], wp[[3]])
  h.scp<-wholm(0.05, scp[[1]], scp[[2]])
  hom.raw<-as.numeric(any(h.raw==1))
  hom.li<-as.numeric(any(h.li==1))
  hom.min<-as.numeric(any(h.min==1))
  hom.scp<-as.numeric(any(h.scp==1))
  bon.raw<-as.numeric(any(rawp <= 0.05/length(rawp)))
  bon.li<-as.numeric(any(lip <= 0.05/length(rawp)))
  bon.minp<-as.numeric(any(minp <= 0.05/length(rawp)))
  bon.minsc<-as.numeric(any(wminsc <= 0.05/length(rawp)))
  return(c(bon.raw, bon.li, bon.minp, bon.minsc, hom.raw, hom.li, hom.min, hom.scp))
}

