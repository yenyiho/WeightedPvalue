
source("Source.R")

############################### Type I error 
### b1=0, b2=0, p1=0.5, q1=0.5
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

outS1<-sapply(1:sim, type1wrapperS1h, n=n, beta1=beta1, beta2=beta2, nmiR=nmiR, mE=mE, p1=p1, q1=q1)
rownames(outS1)<-c("bon.raw",  "bon.li", "bon.minp", "bon.minsc", "hom.raw", "hom.li", "hom.min", "hom.scp")
new<-proc.time()
new-old
fwout1<-rowMeans(outS1)
fwout1
