#!/bin/bash


if [ $# != 5 ]
then
	echo $0 ali feat.scp "split(0)" outdir copy_feats
	exit 1
fi
ali=$1
feat_scp=$2
alifile=${ali##*/}
feat_scpfile=${feat_scp##*/}
split=$3
outdir=$4
copy_feats=$5
mkdir -p $outdir
awk '{printf("%d\n",NF);}' $ali > $outdir/ali.len
paste $outdir/ali.len $ali|sort -nk 1 |\
   	awk '{for(i=2;i<=NF;++i)printf("%s ",$i); printf("\n")}' > $outdir/sort_$alifile || exit 1
#paste $outdir/ali.len $ali|sort -nk 1 |while read len aliinfo
#do
#	echo $aliinfo 
#done > $outdir/sort_$alifile || exit 1

python map-feat-ali.py $feat_scp $outdir/sort_$alifile $outdir/sort_$feat_scpfile || exit 1

echo "python map-feat-ali.py $feat_scp $outdir/sort_$alifile $outdir/sort_$feat_scpfile OK"

python map-feat-ali.py $outdir/sort_$alifile $outdir/sort_$feat_scpfile $outdir/mapsort_$alifile

echo "python map-feat-ali.py $outdir/sort_$alifile $outdir/sort_$feat_scpfile $outdir/mapsort_$alifile OK"

python split_feat_ali.py $outdir/sort_$feat_scpfile  \
	$outdir/mapsort_$alifile $split \
	$outdir/split || exit 1

echo "split OK"

./copy-feat.sh  $copy_feats  $outdir/split/sort_$feat_scpfile  $split $outdir/split$split

echo "uncompress and sort ok"

