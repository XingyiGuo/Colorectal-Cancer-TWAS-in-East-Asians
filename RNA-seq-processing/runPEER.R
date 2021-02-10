# Use R/3.3.3
# load packages
library(dplyr)
library(peer)


###### I. parameter  ######
expression_file = "expression.bed.file"
cov_file = "covariates.file"

peer_out1 = "expression_PEER_inverse.file"

##### II. funtion #####
peer_adj <- function(expression_file, cov_file)
{
    exp <- read.table(expression_file,header=T,sep="\t")
    exp2 <- exp[,-c(1:3)]
    row.names(exp2) <- exp2[,1]
    exp2 <- exp2[,-1]
    expression_used <- as.data.frame(t(exp2))    
    cov  <- read.table(cov_file,header=T,sep="\t")
    
    model=PEER()
    PEER_setPhenoMean(model,as.matrix(expression_used))
    PEER_setCovariates(model,as.matrix(cov))
    PEER_setNk(model,45)
    PEER_update(model)
    PEER_getNk(model)

    factor=PEER_getX(model)
    residuals = PEER_getResiduals(model)

    rownames(residuals) <- rownames(expression_used)
    colnames(residuals) <- colnames(expression_used)
    residuals_update <- apply(residuals, 2, function(x) {qnorm( rank(x,ties.method="r") / (length(x)+1)  )})
    write.table(residuals_update, file = peer_out1, row.names=T, quote=F,sep = '\t')
}

###### III. running analysis  ######

peer_adj(expression_file,cov_file)
