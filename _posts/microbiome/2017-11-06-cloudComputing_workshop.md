---
layout: post
authors: [Beiting]
title: "Cloud computing for metagenomics - 4hr workshop"
excerpt: "This workshop, led by Dan Beiting and Kyle Bittinger at UPenn on Nov 8th, uses cloud compute resources and a Snakemake-based pipeline called Sunbeam for analysis of shotgun metagenomic data"
modified: 2017-11-06
tags: [metagenomics]
categories: [microbiome]
comments: true
---

{% include _toc.html %}

## Before starting
Around the time my lab was starting to experiment with using Dockerized tools and cloud compute resources for analzying metagenomic data -- which culminated in a two part blog post [here](http://hostmicrobe.org/microbiome/cloudComputing_part1/) and [here](http://hostmicrobe.org/microbiome/cloudComputing_part2/) -- [Kyle Bittinger](https://microbiome.research.chop.edu/our-team/kyle-bittinger.html) and his group at the PennCHOP Microbiome Center were finishing up their work developing a Snakemake-based pipeline for metagenomics.  With our annual microbiome symposium quickly approaching, Kyle and I decided to team-up to put on a 1/2 day workshop that would combine these elements.  

The material below is intended to walk you through this workshop, and provide others with a web-based lesson plan for how do this themselves.  

To participate in this workshop, you'll only need a few things:
* a laptop computer
* an internet connection
* a google account (free)
* [a google cloud account](https://cloud.google.com) (free sign-up and $300 credit)
* example data that you can [download here](https://www.dropbox.com/sh/dqo9gfawyrnan3r/AADBohOlcnlsyl2VKBtzTGF3a?dl=0). This dataset will be explained in more detail during the workshop, but is also described [here](http://hostmicrobe.org/microbiome/cloudComputing_part2/)


## Launch the Google Cloud instance 

We'll begin the workshop with a demonstration of how to launch your first Google Cloud instance.  We'll then connect to this instance via the gcloud SSH button.  Once connected, we're all using exactly the same type of computer with the same operating system, regardless of your local machine and OS.

## Installing the Sunbeam metagenomics pipeline

After launching, we need to install some system programs on the computer.  For this, we'll use the `apt-get` utility provided with the operating system.


```bash
sudo apt-get install unzip xvfb xdotool libxrender1 libxi6
```

We'll download the [Sunbeam software](https://github.com/eclarke/sunbeam) from GitHub, where it is distributed.  **Again, this is a new pipeline from Kyle's group, and he'll spend substantial time during the workshop talking about what is happening under the hood as we run Sunbeam.**  We'll also briefly discuss why this pipeline was created with [Snakemake](http://snakemake.readthedocs.io/en/stable/) and uses a [Conda environment](https://conda.io/docs/).

```bash
wget https://github.com/eclarke/sunbeam/archive/master.zip
```

After the software is downloaded successfully, you'll have a new file called `master.zip` in your home directory.  You can verify this with the `ls` command. Now that the file is downloaded, we'll decompress
the file with `unzip`.

```bash
unzip master.zip
```

We move into the software directory, where the installation scripts are located.

```bash
cd sunbeam-master
```

Now, we're ready to actually install the Sunbeam analysis pipeline. Sunbeam provides a script for this purpose.

```bash
./install.sh
./install_igv.sh
```

The pipeline uses a system called Conda to manage all the bioinformatics analysis programs. This system works by storing all the programs inside your home directory, so that we can use special versions of programs just for this pipeline. We'll tell the computer where to find the Conda system.

```bash
echo "export PATH=$HOME/miniconda3/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc
```

To actually use Sunbeam, we'll "turn on" the bioinformatics software.

```bash
source activate sunbeam
```

This is the command you'll want to remember for future sessions.  Each time you log into your cloud instance, you'll need to activate the pipeline with `source activate sunbeam`.  Upon activation, you should see that your command prompt begins with "(sunbeam)".  Anytime you want to exit out of sunbeam, simply type `source deactivate sunbeam` and hit return.

## test drive

Now that our software is installed and activated, we'll run the tests included with Sunbeam to make sure everything is OK.

```bash
bash tests/test.sh
```

As the tests are running, you should see messages scrolling by on your screen. This is a preview of what you might see when the actual pipeline is running, so we'll devote some time in our session to understanding the messages.

Our next step is to download our data files and get moving with some real data analysis!

## connect to glcoud instance
Although the ssh terminal available right on your instance is very convenient, it does not establish a connection between our local computer and the cloud instance (which we must do in order to move files back and forth).  In order to do that, we'll want to connect to our instance from the [terminal app](https://en.wikipedia.org/wiki/Terminal_(macOS)) on our local computer.  Go ahead and launch your Terminal app.  Before we do anything else, let's execute a command in the terminal that will allow us to see hidden files in our directory.  We need access to a few of these hidden files for the purposes of this tutorial.
```bash
defaults write com.apple.finder AppleShowAllFiles true
#then restart the finder to see these changes
killall Finder
#after this tutorial you can hide these files again by replacing 'true' with 'false'
```

Now install the google SDK.   
```bash
curl https://sdk.cloud.google.com | bash
```

I my experience, if you encounter any issues with this entire tutorial, it will be with getting the SDK installed and connecting to your instance. For example, you may notice that the installation fails with the following error
```bash
ERROR: Failed to fetch component listing from server. Check your network settings and try again
```
This error has to do with the the IPv6 settings on your computer preventing you from being able to connect with a google server to download the SDK command line tools

If you encounter this error, this fix is simple.  Begin by temporarily turning off IPv6 support for either Wi-Fi or Ethernet, depending on which one you are using to connect to the internet.  If you're using a Wi-Fi connection, then you would turn-off with:

```bash
networksetup -setv6off Wi-Fi #if you're using ethernet, replace 'Wi-Fi' with 'Ethernet' in this line
```

Now reattempt the installation as you did above
```bash
curl https://sdk.cloud.google.com | bash
```

Once you have Google Cloud SDK installed, *be sure to turn the IPv6 back on*
```bash
networksetup -setv6automatic Wi-Fi
```

Now we'll connect to the instance from within our Terminal.  
```bash
gcloud compute ssh instance-1 #if your instance is not called 'instance-1', be sure to modify this line accordingly
#Be patient here, as this may take a moment to connect.
```

If the above command failed with an authentication error, it's because this is the first time you've run SDK and it isn't sure that you should have access to your google account from the terminal.  Take a moment to authenticate

```bash
gcloud auth login
#this will open a browser window for you to select and sign-in to your google account
#after doing this, return to your terminal window and you should be good to go
#if this doesn't work, you may need to go though the gcloud initialization process by executing 'gcloud init'
#either way, once you have authenticated your account you will need to reattempt connecting with 'gcloud compute ssh instance-1'
```

## transfer data to glcoud

In this part of the workshop you'll learn all the point-and-click steps to connect to your gcloud instance via SFTP using the [FileZilla program](https://filezilla-project.org/).

It is important to keep our file system organized by project.  To do this, we'll use FileZilla to create a new folder in your home directory called 'deadmice', which will be our project folder for today.  Open this folder (double click) and create a subfolder called 'data_files'.  Your project folder can be named anything, but each project folder must have a 'data_files' subfolder where all raw data input files should be stored.

With these folders in place, use FileZilla to drag-and-drop all the fastq files you downloaded for the workshop into the 'data_files' folder.

## fetch your reference files

We have bundled a number of commands for getting reference files into a shell script that you can download [here](http://hostmicrobe.github.io/myPapers/download_refdata.sh).  We'll discuss the content of this file during the workshop.

Use FileZilla to drag-and-drop this shell script into your home directory on gcloud.

Now run the shell script
```bash
cd ~
bash download_refdata.sh
```

## Run Sunbeam

Run sunbeam (this will take about 1hr to complete)
```bash
cd ~/sunbeam-master
snakemake --configfile deadmice-config.yml --cores 8
```

## Interpreting your results

Running Sunbeam will produce a third subdirectory for the output files ("sunbeam_output").

