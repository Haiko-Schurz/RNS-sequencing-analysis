# TANDEM-SA
RNA-sequencing analysis on TANDEM samples for eQTL mapping in a five-way admixed SA population

## RNA-Sequencing analysis 

**1. Run 01_HTS_stats.sh to get statistics of raw reads and to pre-processing on raw reads**

Pre-processing of raw reads include:
1.	hts_Stats: get stats on input raw reads
2.	hts_SeqScreener: screen out (remove) phiX
3.	hts_SeqScreener: screen for (count) rRNA – just count them and not remove them 
4.	hts_SuperDeduper: identify and remove PCR duplicates – only for Pair end reads and do not remove for SDingle end pair end reads!
5.	hts_AdapterTrimmer: identify and remove adapter sequence
6.	hts_PolyATTrim: remove polyA/T from the end of reads.
7.	hts_NTrimmer: trim to remove any remaining N characters
8.	hts_QWindowTrim: remove poor quality bases
9.	hts_LengthFilter: use to remove all reads < 50bp
10.	hts_Stats: get stats on output cleaned reads

*We did not remove any PCR duplicates, since we have single-end reads and not paired-end reads.* 

- Appends statistics of each command into a .json file which are then visualised via MultiQC for each sample. 
- Pre-processing statistics visualised with multiQC version 1.10.0 – new version with the HTStream as one of the new modules included - link to my report as an example: file:///Users/yolandiswart/Documents/Multiqc_test/01-HTS-mulitqc-report/multiqc_report.html

**2. Index genome with annotation file using 02_Index.sh** 

Indexed with ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/gencode.v34.primary_assembly.annotation.gtf.gz gencode.v34.primary_assembly.annotation.gtf.gz
GTF=../gencode.v34.primary_assembly.annotation.gtf

**3. Align to reference genome (GRCh38) using STAR.v.2.5.3**

The –quantMode option in STAR enables the GeneCount tables we are getting, therefore we don’t have to use HTSe Count or any other software to quantify gene counts 

**4. Get statistics of alignments using 04_STAR_stats.sh**

Alignment output: 

![image](https://user-images.githubusercontent.com/49681556/196138925-97c9dfcd-1f06-4c94-9025-c3e6cd9aca81.png)

- First column indicates mapped either to reverse or double strand = total read count ; this is how you find out if your samples mapped to either the everse or forward stand if it is single end paired end reads
- Second column indicates counts if it mapped to the forward strand
- Third column indicates reads mapped to the reverse strand (mine mapped to the reverse strand)

Look at the following for mapping accuracy: 
      Ambiguous = Mapped over two genes – Alignment is confident 
      NoFeature = Didn’t map to a gene 
      Multimapping = Mapped over two regions or multiple regions – Alignment is not confident 

*It is all about the amount of fragments you captured during sequencing and aligning to the Reference Genome. Therefore the more you count, the better. We use gene count as proxy for gene expression.*

- Generated gene count tables (Quantification step). We do not use HTSeq count due to mapping not strand-specific, which STAR does although we refer to counting “genes” – these can also refer to as transcripts, exons, or any other type of feature. 

**5. Get raw count table from STAR alignment output using 05_Count_tables.sh**

Example of raw gene count table that is going to be imported into R:

![image](https://user-images.githubusercontent.com/49681556/196139688-2e68520f-db89-4c6e-891c-329df7b80838.png)

**6.Filter and normalise raw gene count tables with R scripts (DEG_Yolandi.Rmd)**




## cis-eQTL mapping analysis

Run eQTL analysis (eqtl_localaa_globalaa_afr.R and run_eqtl_afr.sh). 

**Inputfiles required for analysis:**
1. Expression file - normalised gene counts (split into chunks of 50 genes per file using split_chunks.sh). Example file: expression.00
2. Genotype information - vcf file format 
3. Covariates - including PEER confounders (run_PEER.R) and global ancestry proportions calculated with RFMix. 
4. Local ancestry information - inferred with RFMix - coded as 0, 1 or 2 for every genomic region (interpolate-local-anc.py). Example file: ancestry.chr22.bed

**Output file:** LocalAA-GlobalAA-allpairs_afr_filt.tsv.gz

Extract top eGenes and unique eGenes (extract_egenes_afr.py and get_uniq_egenes.R). 
Example file of output: gtex.admix.global.egenes.tied_afr.txt.gz +  gtex.admix.lava.egenes.tied_afr.txt.gz


*Example files and scripts are for only Bantu-speaking African ancestry. Where ancestry of interest = 1 (additive model). Therefore, scripts were run separately for all five contributing ancestries.*
