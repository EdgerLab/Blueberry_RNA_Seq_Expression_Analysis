import pandas as pd

col_names = ['Chromosome', 'Software', 'Feature', 'Start', 'Stop', 'Score', 'Strand', 'Frame', 'Fullname']

col_to_use = ['Chromosome', 'Software', 'Feature', 'Start', 'Stop', 'Score', 'Strand', 'Frame', 'Fullname']

annot = pd.read_csv('/mnt/research/edgerpat_lab/Scotty/Blueberry_RNA_Seq/Input/Raw_Input/V_corymbosum_v1.0_geneModels.gff',
			header=None,
			sep='\t+',
			engine='python',
			names=col_names)

chromosomes_i_want = ['VaccDscaff1','VaccDscaff2','VaccDscaff4','VaccDscaff6','VaccDscaff7','VaccDscaff11','VaccDscaff12','VaccDscaff13','VaccDscaff17','VaccDscaff20','VaccDscaff21','VaccDscaff22']
annot = annot[annot.Chromosome.isin(chromosomes_i_want)]
annot.to_csv('Filtered_Blueberry_Annot.gff', sep='\t', header=False, index=False)

