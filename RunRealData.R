

source("Source.R")

### Create simulated data
sim<-1000
old<-proc.time()
n=300
nmiR=9
mE=50
beta1=0
beta2=0
p1<-matrix(0.5, nrow=(nmiR+1), ncol=(mE+1))
p1[1,1]<-0.5
q1<-rep(0.5, (mE+1))
q1[1]<-0.5
dat<-simDataS1fr(n=n, beta1=beta1, beta2=beta2, nmiR=nmiR, mE=mE)

###Input data object with this format  
head(dat)

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

ans<-c(bon.raw, bon.li, bon.minp, bon.minsc, hom.raw, hom.li, hom.min, hom.scp)


