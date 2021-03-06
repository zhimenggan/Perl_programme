#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
my $yl;
GetOptions("n:s" => \$yl);
die "perl $0 <genetable> <profiletable> <outprefix> [option]
	-n		normarlize method: log, n and i
\n" if @ARGV < 3;

if($yl eq "log")
{
	$yl = "log(V(i) / logV(0))";
}elsif($yl eq "n"){
	$yl = "V(i) - V(0)";
}elsif($yl eq "i"){
	$yl = "V(i)"
}else{
	die "-n option: log, n, i";
}
my %hash;
`mkdir -p $ARGV[2]_profiles`;
open GT, $ARGV[0] or die $!;
my %sample;
my $head = <GT>;
chomp($head);
my @hds = split /\t/, $head;
my @aaaaa;
foreach(@hds[3..$#hds])
{
	push @aaaaa, "\"$_\"";
}
my $hl = join ",", @aaaaa;
while(<GT>)
{
	chomp;
	my @tmp = split;
	$hash{$tmp[2]} ++;
	$tmp[1] =~ s/ID_//;
	push @{$sample{$tmp[2]}}, "$tmp[1] @tmp[3..$#tmp]";
}
foreach(keys %sample)
{
	open PFO, "> $ARGV[2]_profiles/profile$_" or die $!;
	print PFO "sample\tvalue\txl\n";
	foreach my $i(@{$sample{$_}})
	{
		my ($id, @x) = split /\s+/, $i;
		for(my $j = 0; $j < @x; $j ++)
		{
			print PFO "$id\t$x[$j]\t$hds[$j + 3]\n";
		}
	}
}

open EVE, "> $ARGV[2].r" or die $!;
print EVE "
library(ggplot2)
fs = dir()
fs <- fs[fs != \"$ARGV[2].r\"]
n = length(fs)
for(i in 1:n){
	m <- read.table(fs[i], header=T, sep=\"\t\")
	m\$xl <- factor(m\$xl, levels = c($hl))
	y_max = max(abs(m\$value))
	ggplot(m, aes(x = xl, y= value, group = sample, color = sample)) + geom_line() + scale_color_gradientn(colours=rainbow(15)) + labs(x=\"\", y=\"\") + theme_bw() + theme(legend.position = \"none\") + ylim(-y_max, y_max) + labs(y=\"$yl\") + scale_x_discrete(expand=c(0.05, 0))
	ggsave(paste(fs[i], \".png\", sep=\"\"), width = 8, dpi = 300)
}
";
chdir "$ARGV[2]_profiles/";
`Rscript $ARGV[2].r`;
`rm $ARGV[2].r Rplots.pdf -rf`;
chdir "..";

open FA, $ARGV[1] or die $!;
open TMP, ">$ARGV[2].tmp" or die $!;
print TMP "cls\tvalue\txl\tpv\n";
<FA>;
my(@sig, @non);
while(<FA>)
{
	chomp;
	my @tmp = split;
	my @dot = split /,/, $tmp[1];
	for(my $i = 0; $i < @dot; $i ++)
	{
		if($tmp[5] < 0.05)
		{
			push @sig, "profile$tmp[0]: $hash{$tmp[0]}\t$dot[$i]\t$i\tyes\n";
		}else{
			push @non, "profile$tmp[0]: $hash{$tmp[0]}\t$dot[$i]\t$i\tno\n";
		}
	}
}
my @sort;
foreach(@sig)
{
	my @tmp = split /\t/;
	push @sort, "\"$tmp[0]\"";
	print TMP "$_";
}
foreach(@non)
{
	my @tmp = split /\t/;
	push @sort, "\"$tmp[0]\"";
	print TMP "$_";
}

my $line = join ",", @sort;

open CMD, "> $ARGV[2].r" or die $!;
=cut
print CMD "
library(ggplot2)
m <- read.table(\"$ARGV[2].tmp\", header=T, sep=\"\t\")
m\$cls <- factor(m\$cls, levels = c($line))
ggplot(m, aes(x = xl, y= value, colour = pv)) + geom_line(size=1) + facet_wrap(~cls) + scale_color_manual(values = c(\"black\", \"red\")) + geom_rect(data=subset(m, pv==\"yes\"), aes(xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf, fill=pv), alpha = 0.05) + scale_fill_manual(values = c(\"blue\", \"blank\")) + theme_bw() + labs(x=\"\", y=\"\") + theme(legend.position = \"none\")
ggsave(\"$ARGV[2].png\", width=7, height=7, dpi=300)
";
=cut

## add by guanpeikun code from gaochuan

`cp $ARGV[1] $ARGV[1].tmp`;
`sed -i "1d" $ARGV[1].tmp`;
print CMD "
m=read.table(\"$ARGV[1].tmp\", sep = \"\t\")
profile_counts=nrow(m)
rx=1
while(rx*rx<=profile_counts)
{
	rx=rx+1
}
#rx
#row_counts=as.numeric(args[2])
row_counts=rx
total_counts=0
if(profile_counts%%row_counts==0)
{
	total_counts=profile_counts
}
if(profile_counts%%row_counts!=0)
{
	total_counts=(as.integer(profile_counts/row_counts)+1)*row_counts
}
mat=t(matrix(1:total_counts,nrow=row_counts))
png(paste(\"$ARGV[2]\",\"sort_by_genes.png\",sep=\".\"), width = 800, height = 600, units = \"px\")
layout(mat)
colors=c(\"lightgreen\",\"lightblue\",\"lightpink\")
palette(colors)
ddd=1
for(i in order(m[,4],decreasing=T))
{
	y=as.numeric(strsplit(as.character(m[i,2]),\",\")[[1]])
	x=1:length(y)
	max_y=max(abs(y))*1.15
	par(mar=c(2,2,2,2))
	plot(x,y,type=\"n\",xlim=c(min(x),max(x)),ylim=c(-max_y,max_y),xlab=\"\",ylab=\"\",xaxt=\"n\",yaxt=\"n\",main=paste(\"profile\",as.character(m[i,1]),\" : \",as.numeric(m[i,4]),\" genes\",sep=\"\"),cex.main=7/row_counts,las=2)
	if(m[i,6]<0.05)
	{
		rect(-max_y*2, -max_y*2, 100, 100, col=ddd)
		ddd=ddd+1
	}
	points(x,y,type=\"l\",lwd=7/row_counts*2.5)
	box()
}
mat=t(matrix(1:total_counts,nrow=row_counts))
png(paste(\"$ARGV[2]\",\"sort_by_pvalue.png\",sep=\".\"), width = 800, height = 600, units = \"px\")
layout(mat)
colors=c(\"lightgreen\",\"lightblue\",\"lightpink\")
palette(colors)
ddd=1
for(i in order(m[,6]))
{
	y=as.numeric(strsplit(as.character(m[i,2]),\",\")[[1]])
	x=1:length(y)
	max_y=max(abs(y))*1.15
	par(mar=c(2,2,2,2))
	plot(x,y,type=\"n\",xlim=c(min(x),max(x)),ylim=c(-max_y,max_y),xlab=\"\",ylab=\"\",xaxt=\"n\",yaxt=\"n\",main=paste(\"profile\",as.character(m[i,1]),\" : \",as.numeric(m[i,4]),\" genes\",sep=\"\"),cex.main=7/row_counts,las=2)
	if(m[i,6]<0.05)
	{
		rect(-max_y*2, -max_y*2, 100, 100, col=ddd)
		ddd=ddd+1
	}
	points(x,y,type=\"l\",lwd=7/row_counts*2.5)
	box()
}
dev.off()
";

`Rscript $ARGV[2].r`;
`rm Rplots.pdf $ARGV[2].tmp $ARGV[2].r $ARGV[1].tmp -rf`;
