# Title: Plot the master dataset with the invariant sites and bad individuals filtered out
# Note: SnpEff impact HIGH/MODERATE/LOW matching version
# Author: Meixi Lin
# Date: Thu Apr 22 16:37:56 2021
# Modification: FINAL use average counts
# Date: Sun Sep  5 18:26:48 2021
# Modification: Add source_data
# Date: Mon Jan 23 11:14:16 2023
# Modification: Add p-value
# Date: Mon Mar 20 11:26:44 2023


# preparation --------
rm(list = ls())
cat("\014")
options(echo = TRUE, stringsAsFactors = FALSE)

library(dplyr)
library(reshape2)
library(ggplot2)
library(ggpubr)

source("~/Lab/fin_whale/scripts_analyses/config/plotting_config.R")

# def functions --------
# from: step3.2_plot_mutdt_20210521.R
source('<homedir>/fin_whale/scripts_analyses/config/facet_functions.R')
# from: step4_generate_summarystats_20210218.R in all50
# get mean normalized variations (by mean value)
get_mean_rawdt <- function(rawdt) {
    # from nopopdt, get Average CalledCount and CalledAlleleCount
    meandt = rawdt %>%
        dplyr::select(CalledCount, MutType) %>%
        group_by(MutType) %>%
        summarise(meanCalledCount = mean(CalledCount),
                  meanCalledAllele = 2*meanCalledCount,
                  .groups = 'drop')
    outdt = dplyr::left_join(x=rawdt, y = meandt, by = 'MutType') %>%
        dplyr::mutate(normHomRef = HomRefPer * meanCalledCount,
                      normHomAlt = HomAltPer * meanCalledCount,
                      normHet = HetPer * meanCalledCount,
                      normRefAllele = RefAllelePer * meanCalledAllele,
                      normAltAllele = AltAllelePer * meanCalledAllele)
    return(outdt)
}

# def variables --------
today = format(Sys.Date(), "%Y%m%d")
dataset = 'all50_snpEff_matching'
ref = 'Minke'
gttype = 'PASSm6'
# gttype = 'PASSm6CL' # IMPORTANT: DON'T USE THIS VERSION!!!
prefixlist = c('HIGH','MODERATE','LOW')

# <homedir>/finwhale/analyses/DelVar_vcfR/all50_snpEff_matching/Minke
workdir = paste('<homedir>/finwhale/analyses/DelVar_vcfR/', dataset, ref, sep = '/')
setwd(workdir)

plotdir = './pub_plots/'
dir.create(plotdir)

sink(file = paste0('logs/step3_plot_mutdt_count_', paste(dataset, ref, gttype, today, sep = '_'), ".log"))
date()
sessionInfo()

# load data --------
rawdt = readRDS(file = './derive_data/sum_table/HML_all50_snpEff_matching_Minke_SUMtable_Seg_PASSm6_20210422.rds')

# convert percentages to number of average variations ========
normdt = get_mean_rawdt(rawdt)

# output this
saveRDS(normdt, file = './derive_data/sum_table/HML_all50_snpEff_matching_Minke_SUMtable_Seg_PASSm6_Norm_20210905.rds')

# main --------
# load normdt
mutdt = readRDS(file = './derive_data/sum_table/HML_all50_snpEff_matching_Minke_SUMtable_Seg_PASSm6_Norm_20210905.rds')

mutdt = normdt

mutdt$MutType = factor(mutdt$MutType, levels = prefixlist)

# the allele proportion plot ========
# alleledt = read.csv(file = './source_data/FigS19a.csv', row.names = 1)
# alleledt$MutType = factor(alleledt$MutType, levels = prefixlist)

alleledt = reshape2::melt(mutdt, id.vars = c("SampleId", "PopId", "SubPopId", "MutType")) %>%
    dplyr::filter(variable %in% c("normAltAllele"))

pp1 <- ggplot(data = alleledt, aes(x = PopId, y = value, fill = PopId)) +
    geom_boxplot() +
    scale_fill_manual(values = mycolors) +
    # facet_wrap_custom(. ~ MutType, scales = "free_y",scale_overrides = list(
    #     scale_override(1, scale_y_continuous(breaks = c(25400, 25600, 25800))),
    #     scale_override(2, scale_y_continuous(breaks = c(13700, 13900))),
    #     scale_override(3, scale_y_continuous(breaks = c(5800, 6000))),
    #     scale_override(4, scale_y_continuous(breaks = c(360, 380)))
    # )) +
    facet_wrap(. ~ MutType, scales = "free_y") +
    labs(fill = "Population", x = "Population", y = "Derived Allele Count") +
    theme_pubr() +
    theme(legend.position = "none")

pp1.2 <- pp1 +
    stat_compare_means(aes(label = ..p.signif..),
                       method = "wilcox.test",
                       label.x.npc = 'center',
                       vjust = 1,
                       size = 4)

ggsave(filename = paste0(plotdir, "SnpEffType_allele_number_box_", gttype, "_", today, ".pdf"), plot =  pp1.2, height = 4, width = 7)

# the genotype proportion plot ========
# genodt = read.csv(file = './source_data/FigS19b.csv', row.names = 1)
# genodt$MutType = factor(genodt$MutType, levels = prefixlist)

genodt = reshape2::melt(mutdt, id.vars = c("SampleId", "PopId", "SubPopId", "MutType")) %>%
    dplyr::filter(variable %in% c("normHet", "normHomAlt"))
genodt$variable = as.character(genodt$variable)
genodt$variable = factor(genodt$variable, levels = c("normHomAlt", "normHet"), labels = c("Homozygous Derived", "Heterozygous"))

pp2 <- ggplot(data = genodt,
              aes(x = PopId, y = value, fill = PopId)) +
    geom_boxplot() +
    scale_fill_manual(values = mycolors) +
    facet_grid(MutType ~ variable, scale = 'free_y') +
    # facet_grid_custom(MutType ~ variable, scale = 'free_y',scale_overrides = list(
    #     # scale_override(1, scale_y_continuous(limits = c(5500, 11500))),
    #     scale_override(2, scale_y_continuous(limits = c(3000, 6500))),
    #     scale_override(3, scale_y_continuous(limits = c(1200, 3200)))
    #     # scale_override(4, scale_y_continuous(breaks = c(100, 150)))
    # )) +
    labs(fill = "Population", x = "Population", y = "Genotype Count") +
    theme_pubr() +
    theme(legend.position = "none")

pp2.2 <- pp2 +
    stat_compare_means(aes(label = ..p.signif..),
                       method = "wilcox.test",
                       label.x.npc = 'center',
                       vjust = 1,
                       size = 4)


ggsave(filename = paste0(plotdir, "SnpEffType_geno_number_box_", gttype, "_", today, ".pdf"), plot =  pp2.2, height = 7, width = 5)

# Modification: Add source_data
# Date: Mon Jan 23 11:17:14 2023
alleledt$variable = 'Derived Alleles'
write.csv(alleledt, file = '~/Lab/fin_whale/FinWhale_PopGenomics_2021/source_data/FigS19a.csv')
write.csv(genodt, file = '~/Lab/fin_whale/FinWhale_PopGenomics_2021/source_data/FigS19b.csv')

# Modification: Add p-value
# Date: Mon Mar 20 11:30:05 2023
pval_allele = ggplot_build(pp1.2)$data[[2]][,'p.adj']
pval_geno = ggplot_build(pp2.2)$data[[2]][,'p.adj']
outpval = expand.grid(c('HIGH', 'MODERATE', 'LOW'),
                      c('Number of derived alleles', 'Number of heterozygous genotypes', 'Number of derived homozygous genotypes'))
outpval$P_adj = c(pval_allele, pval_geno)
outpval$Groups = 'ENP-GOC'
colnames(outpval)[1:2] = c('SnpEff Mutation Type', 'Comparisons')
write.csv(outpval, file = '~/Lab/fin_whale/FinWhale_PopGenomics_2021/source_data/FigS19ab_pval.csv')

# cleanup --------
sink()
closeAllConnections()
