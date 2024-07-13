#对随机windows重叠的重复序列进行统计分???
data <- read.table("random_windows_10000_overlap.stats",header = TRUE)
a <- array()
a[1] <- length(which(data$DNA>8716))/10000
a[2] <- length(which(data$SINE>1982))/10000
a[3] <- length(which(data$LINE>606))/10000
a[4] <- length(which(data$LTR>333))/10000
a[5] <- length(which(data$RC>479))/10000
a[6] <- length(which(data$Retroposon>78))/10000
a[7] <- length(which(data$UNKOWN>3277))/10000
a[8] <- length(which(data$simple_repeat>22538))/10000
a[9] <- length(which(data$Low_complexity>3287))/10000
write(a,"pvalue.txt")

library(ggplot2)
library(gridExtra)
library(ggpubr)
p1 <- ggplot(data,aes(DNA))+
  geom_histogram(binwidth = 3, fill = "#FF4500") +
  geom_vline(xintercept = 16533,col = 'blue',lty = 2, lwd = 1) +
  theme(text=element_text(size=12,face = "bold")) +
  xlab("DNA counts")
p1


p2 <- ggplot(data,aes(SINE))+
  geom_histogram(binwidth = 2, fill = "#800080") +
  geom_vline(xintercept = 2445,col = 'blue',lty = 2, lwd = 1)+
  theme(text=element_text(size=12,face = "bold")) +
  xlab("SINE counts")
p2

p3 <- ggplot(data,aes(LINE))+
  geom_histogram(binwidth = 2, fill = "#7CFC00") +
  geom_vline(xintercept = 1330,col = 'blue',lty = 2, lwd = 1)+
  theme(text=element_text(size=12,face = "bold")) +
  xlab("LINE counts")
p3

p4 <- ggplot(data,aes(LTR))+
  geom_histogram(binwidth = 2, fill = "#4169E1") +
  geom_vline(xintercept = 624,col = 'blue',lty = 2, lwd = 1)+
  theme(text=element_text(size=12,face = "bold")) +
  xlab("LTR counts")
p4

p5 <- ggplot(data,aes(RC))+
  geom_histogram(binwidth = 2, fill = "#FFB6C1") +
  geom_vline(xintercept = 1071,col = 'blue',lty = 2, lwd = 1)+
  theme(text=element_text(size=12,face = "bold")) +
  xlab("RC counts")
p5

p6 <- ggplot(data,aes(Retroposon))+
  geom_histogram(binwidth = 2, fill = "#87CEFA") +
  geom_vline(xintercept = 3914,col = 'blue',lty = 2, lwd = 1)+
  theme(text=element_text(size=12,face = "bold")) +
  xlab("Retroposon counts")
p6

p7 <- ggplot(data,aes(UNKOWN))+
  geom_histogram(binwidth = 2, fill = "#BDB76B") +
  geom_vline(xintercept = 11869,col = 'blue',lty = 2, lwd = 1)+
  theme(text=element_text(size=12,face = "bold")) +
  xlab("UNKNOWN counts")
p7

p8 <- ggplot(data,aes(simple_repeat))+
  geom_histogram(binwidth = 2, fill = "#6B8E23") +
  geom_vline(xintercept = 13351,col = 'blue',lty = 2, lwd = 1)+
  theme(text=element_text(size=12,face = "bold")) +
  xlab("simple_repeat counts")
p8

p9 <- ggplot(data,aes(Low_complexity))+
  geom_histogram(binwidth = 2, fill = "#00FFFF") +
  geom_vline(xintercept = 1661,col = 'blue',lty = 2, lwd = 1)+
  theme(text=element_text(size=12,face = "bold")) +
  xlab("Low_complexity counts")
p9

pdf("10000windows_overlap.pdf",width = 10,height = 10)
ggarrange(p1,p2,p3,p4,p5,p6,p7,p8,p9,nrow=3,ncol=3,common.legend=TRUE,legend="top")
dev.off()
