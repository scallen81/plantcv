
library(ggplot2)


#Read in data

dir<-"~/Desktop/r/"
setwd(dir)

# Planting date
planting_date = as.POSIXct("2013-11-26")

signal<-read.table("flu_signal_burnin2.sqlite3_10-24-2014_02:05:21.txt", sep=',', header=TRUE)

#Add treatment and genotype columns
  
format_data=function(data){
  # Treatment column
  data$treatment <- NA
  data$treatment[grep("AA", data$plant_id)] <- 100
  data$treatment[grep("AB", data$plant_id)] <- 0
  data$treatment[grep("AC", data$plant_id)] <- 0
  data$treatment[grep("AD", data$plant_id)] <- 33
  data$treatment[grep("AE", data$plant_id)] <- 66
  
  data$genotype <- NA
  data$genotype[grep("p1", data$plant_id)] <- 'A10'
  data$genotype[grep("p2", data$plant_id)] <- 'B100'
  data$genotype[grep("r1", data$plant_id)] <- 'R20'
  data$genotype[grep("r2", data$plant_id)] <- 'R70'
  data$genotype[grep("r3", data$plant_id)] <- 'R98'
  data$genotype[grep("r4", data$plant_id)] <- 'R102'
  data$genotype[grep("r5", data$plant_id)] <- 'R128'
  data$genotype[grep("r6", data$plant_id)] <- 'R133'
  data$genotype[grep("r7", data$plant_id)] <- 'R161'
  data$genotype[grep("r8", data$plant_id)] <- 'R187'
  
  data$day<-NA
  data$day<-as.integer((data$date_time-1385445600)/86400) 
  
  data=data[grep('000A',data$plant_id, invert=TRUE),]
  
  return(data)
}


signal1<-format_data(signal)
signal2<-as.data.frame(signal1)


#read in shape data
        
height_table<-read.table("vis.traits.csv",sep=',', header=TRUE)
height_table$date_time=height_table$datetime


#merge shape data with PSII signal data and subset 100%fc and 33%fc
  
signal_height<-merge(signal2,height_table,by=c("date_time","plant_id","treatment")) 
signal100<-signal_height[ (signal_height$treatment==100 |signal_height$treatment==33),]


#Correlate height and median fv/fv signal
  
cor.test(signal100$height_above_bound, signal100$median_bin, method="spearman")

pdf(file="height_psII_corr.pdf",width=6,height=6,useDingbats = FALSE)
plot6<-ggplot(signal100,aes(y=height_above_bound, x=median_bin ))+
  geom_point(size=1)+
  theme_bw()+
  stat_smooth(method="lm",formula=y~poly(x,2),se=FALSE, size=1)+
  annotate("text", x = 0.55, y =0, label = "Spearman Correlation: p-value < 2.2e-16 rho=-0.859")
plot6
dev.off()

#read data from 3D printed plant
  
fakeplant<-read.table("3dplant_data.txt", sep='\t', header=TRUE)

cor.test(fakeplant$Median_Fv.Fm, fakeplant$Height, method="pearson")

pdf(file="fakeplant_psii.pdf",width=6,height=6,useDingbats = FALSE)
plot1 <- ggplot(fakeplant,aes(x=Median_Fv.Fm,y=Height))+
  geom_point(size=2)+
  stat_smooth(method="lm", se=TRUE)+
  annotate("text",x=0.72, y=1, label="r=-0.976")+
  theme_bw()+
  theme(legend.background = element_rect(),legend.position=c(.5,.5))
plot1
dev.off()
