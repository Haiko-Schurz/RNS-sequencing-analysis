# Interpolate local ancestry

import gzip
import sys

c = int(sys.argv[1])

subset = "/mnt/lustre/users/yswart/eQTL/vcfdir/TANDEM_chr"+str(c)+".recode.vcf.gz"
mapfile = "/mnt/lustre/users/yswart/eQTL/combined_bed/ancestry.chr"+str(c)+".bed"
outfile = "/mnt/lustre/users/yswart/eQTL/combined_bed/master/chr"+str(c)+".localcov.tsv.gz"

# make a dictionary of dictionaries for all haplotypes
master = {}
with open(mapfile, 'r') as snpmap:
    next(snpmap)
    for line in snpmap:
        line = line.strip().split('\t')
        subjid = line[4].split('_')[0] # GTEx subject ID
        try:
            haplo = line[4].split('_')[1] # A or B
        except IndexError:
            print line
        start = line[1]
        stop = line[2]
        anc = line[3]
        if subjid in master:
            if haplo in master[subjid]:
                master[subjid][haplo][start] = [stop, anc]
            else:
                master[subjid][haplo] = {}
                master[subjid][haplo][start] = [stop, anc]
        else:
            master[subjid] = {}
            master[subjid][haplo] = {}
            master[subjid][haplo][start] = [stop, anc]

# now go through the subset file and assign local ancestry
with gzip.open(subset, 'rb') as sub, gzip.open(outfile, 'wb') as out:
    # header
    #out.write('SUBJID\tSNP_ID\tPOS\tAFR_1\tNAMA_1\tEUR_1\tEAS_1\tSEA\tAFR_2\tNAMA_2\tEUR_2\tEAS_2\tSEA_2\n')
    out.write('SUBJID\tSNP_ID\tPOS\tAFR\tNAMA\tEUR\tSEA\tEAS\n')
    next(sub)
    # now find local ancestry for each SNP
    for line in sub:
        line = line.strip().split('\t')
        pos = int(line[1])
        snp_id = line[2]
        for key in master: # for each subject
            # initialize local covariates
            AFR_1 = 0
            EUR_1 = 0
            NAMA_1 = 0
            EAS_1 = 0
            SEA_1 = 0
            AFR_2 = 0
            EUR_2 = 0
            NAMA_2 = 0
            EAS_2 = 0
            SEA_2 = 0
            # look at haplotype A/1
            adict = master[key]['A.bed']
            anc = ''
            for start in adict:
                if pos >= int(start) and pos <= int(adict[start][0]):
                    anc = adict[start][1]
                    break
            if anc == 'AFR':
                AFR_1 = 1
            elif anc == 'EUR':
                EUR_1 = 1
            elif anc == 'NAMA':
                NAMA_1 = 1
            elif anc == 'SEA':
                SEA_1 = 1
            elif anc == 'EAS':
                EAS_1 = 1
            # look at haplotype B/2
            bdict = master[key]['B.bed']
            anc = ''
            for start in bdict:
                if pos >= int(start) and pos <= int(bdict[start][0]):
                    anc = bdict[start][1]
                    break
            if anc == 'AFR':
                AFR_2 = 1
            elif anc == 'EUR':
                EUR_2 = 1
            elif anc == 'NAMA':
                NAMA_2 = 1
            elif anc == 'SEA':
                SEA_2 = 1
            elif anc == 'EAS':
                EAS_2 = 1
            AFR = AFR_1 + AFR_2
            EUR = EUR_1 + EUR_2
            NAMA = NAMA_1 + NAMA_2
            SEA = SEA_1 + SEA_2
            EAS = EAS_1 + EAS_2
            out.write(str(key)+'\t'+str(snp_id)+'\t'+str(pos)+'\t'+str(AFR)+'\t'+str(NAMA)+'\t'+str(EUR)+'\t'+str(SEA)+'\t'+str(EAS)+'\n')
