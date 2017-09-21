---
layout: post
authors: [beiting]
title: "Cloud computing for metagenomics - Part II"
excerpt: "A step-by-step guide to setting up cloud computing resources and analyzing shotgun metagenomic data, all on your laptop."
modified: 2017-09-19
tags: [metagenomics]
categories: [microbiome]
comments: true
---

{% include _toc.html %}


## Getting started
We spent [part I](http://hostmicrobe.org/microbiome/cloudComputing_part1/) of this series going over each step involved in setting up a Google Cloud Instance, installing [Docker](https://www.docker.com/) on this instance, and then installing a suite of dockerized metagenomics tools via [Chiron](https://github.com/IGS/Chiron).  If you haven't read part I, please *stop reading* and go back now.  

In this post, we actually get to put all those painstaking steps from Part 1 to good use by employing [MetaPhlAn2]() to go from raw .fastq files to a table of microbial composition.  To really get the most from this tutorial, you'll need some 'real' data, and for that we'll turn an unfortunate series of events that unfolded in the summer of 2015.  UPenn's University Lab Animal Resources (ULAR) group, which oversees all veterinary care and support for research animals on campus, began to notice diarrhea in a few cages of immuno-compromised mice.  If you're not familiar with mouse models for research, there a many genetically engineered mice that lack various immune system components.  The particular mice that fell ill are what we would call NSG and NSGS mice, strains that are effectively devoid of nearly all aspects of the immune system.  Such mice are ideal recipients for xenografts (i.e. human tumor grafts) and critical for understanding cancer biology and therpeutics, but they also pose a real challenge in terms of infection control.  You can probably guess where this is going.  Despite the strictest precautions, what started out as a few cages of sick mice quickly became an outbreak of diarrheal disease, eventually decimating the entire suite.

After extenisve molecular and culture-based diagnostics turned up negative, we were asked whether microbiome profiling might be able to identify putative organisms associated with the outbreak.  Given that the causative agent could be bacterial, viral or something else entirely, we opted to carry out 'shotgun' metagenomic profiling of stool samples obtained from affected mice and controls.  To start this tutorial, you'll want to download that data [here](https://www.dropbox.com/sh/kznl838218eozdk/AAA1DECGgb0SHBXLeEBjFsMEa?dl=0).  A few things to take note of:
- there are 8 .fastq files total.  Download them all, and it doesn't matter where you put them on your computer
- you'll need about 15Gb of space on your harddrive to store these files 
- each file contains sequence reads from the stool of 1 mouse.
- each file is gzip'd (ends in .gz).  This is a compression format.  *Do not* unzip the files after you've downloaded them
- There are 4 files from control mice and 4 from affected.  This will be obvious from the file names 

**The goal of this tutorial is to use cloud-based metagenomics to identify organisms associated with this devastating outbreak.** 

## Running MetaPhlAn2
Back in Part I of this series, you launched an interactive MetaPhlAn2 session and used the -l option to create a folder called {% highlight bash %} data {% endhighlight %}.  You'll want to make sure to fire up this interactive session again
{% highlight bash %}
sudo ./Chiron/bin/phlan_interactive -l ~/data
#the -l option tells the interactive to create a new folder in our home directory called 'data', and sets this folder as the default from which data will be read and to which outputs will be saved 
#This is where we'll put all our raw sequence data for analysis
{% endhighlight %}

Using FileZilla, transfer these files from your computer to the 'data' folder on your cloud instance.  If your confused about how to do this, you may want to go back and watch [my video](http://hostmicrobe.org/microbiome/cloudComputing_part1/#fire-up-your-cloud-computer) on how to connect use and FTP client to transfer files to the cloud

Now that you have everything in place, let's run MetaPhlAn2 on one sample using a single line of code
{% highlight bash %}
metaphlan2.py Control7_merged_trimmed.fastq.gz --input_type fastq --nproc 8 > Control7_profile.txt
#the --nproc option lets us choose the number of processors we'd like to use for this job
{% endhighlight %}

Once this is done running, take a look at the resulting output file that contains all the taxa identified in a sample  You can now modify the input and output to analyze each sample.  There's a more efficient way to do this, using something called a shell script to automate the analysis of all your .fastq files.  We'll come back to this idea at the end of the tutorial.

Now let's merge all 8 of the profile.txt output files to create a single analysis output file
{% highlight bash %}
merge_metaphlan_tables.py *_profile.txt > merged_abundance_table.txt
{% endhighlight %}

Now you have a single file {% highlight bash %} merged_abundance_table.txt {% endhighlight %} which contains a breakdown of all the taxa present in all of your samples.


## visualize your result
Now you'll use [regular expressions]() to parse this file, and create a new file that only lists abundance for species
{% highlight bash %}
grep -E "(s__)|(^ID)" merged_abundance_table.txt | grep -v "t__" | sed 's/^.*s__//g' > merged_abundance_table_species.txt
{% endhighlight %}


You're now ready to use MetaPhlAn to create a heatmap of these species
{% highlight bash %}
hclust2.py -i merged_abundance_table_species.txt -o abundance_heatmap_species.png --ftop 25 --f_dist_f braycurtis --s_dist_f braycurtis --cell_aspect_ratio 0.5 -l --flabel_size 6 --slabel_size 6 --max_flabel_len 100 --max_slabel_len 100 --minv 0.1 --dpi 300
{% endhighlight %}

While heatmaps are a great way to visualize changes in the abundance of taxa across treatment groups, they don't preserve the taxonomic relationship between taxa.  For that, we'll use another tool from the Huttenhower lab, [GraPhlAn](https://huttenhower.sph.harvard.edu/graphlan)
{% highlight bash %}
export2graphlan.py -i merged_abundance_table.txt -t tree.txt -a annot1.txt --skip_rows 1
graphlan_annotate.py --annot annot1.txt tree.txt tree1.xml
graphlan.py tree1.xml tree1.png --dpi 150
{% endhighlight %}

Let's clean the taxonomy by removing taxon, "_noname", and "_unclassified"
{% highlight bash %}
grep -v "t__" merged_abundance_table.txt | sed 's/_noname//g' | sed 's/_unclassified//g' > merged_abundance_table_clean.txt
{% endhighlight %}


Now redo the graphic, this time with the clean taxonomy
{% highlight bash %}
export2graphlan.py -i merged_abundance_table_clean.txt -t tree.txt -a annot1.txt --skip_rows 1
graphlan_annotate.py --annot annot1.txt tree.txt tree_clean1.xml
graphlan.py tree_clean1.xml tree_clean1.png --dpi 150
{% endhighlight %}

redo the graphic again, this time with annotations
{% highlight bash %}
export2graphlan.py -i merged_abundance_table_clean.txt -t tree.txt -a annot2.txt --skip_rows 1 --most_abundant 50 --annotations 2,3,4,5,6 --external_annotations 7 --title "MetaPhlAn2 taxonomic results"
graphlan_annotate.py --annot annot2.txt tree.txt tree_clean2.xml
graphlan.py tree_clean2.xml tree_clean2.png --dpi 150
{% endhighlight %}

redo the graphic again, this time with annotations
{% highlight bash %}
echo -e "total_plotted_degrees\t330" > annot3.txt
echo -e "start_rotation\t270" >> annot3.txt
colors=('#0000FF' '#FFA500' '#888888' '#FF0000' '#006400' '#800080')
n=1
OLDIFS=$IFS
IFS=$'\n'

for i in $(ls *_profile.txt); do
    bs=`echo ${i} | cut -f2 -d'-' | rev | cut -f2- -d'_' | tr '_' ' ' | rev`
    echo -e "ring_label\t${n}\t${bs}" >> annot3.txt
    echo -e "ring_label_color\t${n}\t${colors[n-1]}" >> annot3.txt
    echo -e "ring_internal_separator_thickness\t${n}\t0.25" >> annot3.txt

    for j in $(cat ${i} | grep s__ | grep -v t__); do
        l=`echo ${j} | cut -f1 | rev | cut -f1 -d '|' | rev | sed 's/_noname//g' | sed 's/_unclassified//g'`
        h=`echo ${j} | cut -f2`
        h=`echo "scale=4; ${h}/100" | bc`
        echo -e "${l}\tring_color\t${n}\t${colors[n-1]}" >> annot3.txt
        echo -e "${l}\tring_alpha\t${n}\t0${h}" >> annot3.txt
    done

    let n=n+1
done

IFS=$OLDIFS

graphlan_annotate.py --annot annot3.txt tree_clean2.xml tree_clean3.xml
graphlan.py tree_clean3.xml tree_clean3.png --dpi 150
{% endhighlight %}

## Automate


