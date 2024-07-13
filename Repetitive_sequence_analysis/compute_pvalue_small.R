table <- read.table("random_windows_overlap_small_re.stats",header = T)           #Count the number of each repeat family in 10,000 simulated random regions
rownames(table) <- table$file_id
table <- table[,-1]
breakpoint <- read.table("SMI.API.blocks.API.30000.intersect.out.stats.small")    #Count the number of each repeat family in the breakpoint regions
breakpoint <- breakpoint$V1
pvalue <- c()
for(i in 1:ncol(table)){
  pvalue[i] <- length(which(table[,i]>breakpoint[i]))/10000
}
df <- data.frame(retype = colnames(table),pvalue = pvalue)
write.csv(df,"random_windows_overlap_small_re_pvalue.csv")
