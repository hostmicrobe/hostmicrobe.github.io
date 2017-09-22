---
layout: post
authors: [beiting]
title: "Cloud computing for metagenomics - Part I"
excerpt: "A step-by-step guide to setting up cloud computing resources and for analyzing metagenomic data."
modified: 2017-07-14
tags: [metagenomics]
categories: [microbiome]
comments: true
---

{% include _toc.html %}

## Prelude
**Disclaimer: This is my first blog post.**  That's right, I'm a complete rookie at this.  Why now?  Well, since starting my faculty position four years ago and working to help build and direct the Center for Host-Microbial Interactions, I increasingly find myself involved in various collaborations or projects where I'm learning something I find really interesting and that I think would be useful to share with either my lab or with the broader scientific community, but which doesn't easily translate into a traditional publication.  Basically, I'm learning some cool stuff, and it's not always evident in my publications, so here we are.  

Case-in-point, I recently attended this [Microbiome Analysis in the Cloud](http://www.igs.umaryland.edu/topics/microbiome-cloud/), held at the Institute for Genome Sciences at the University of Baltimore.  The two-day workshop had a lot of high points, including excellent planning and preparation on the part of the organizers, a highly skilled staff that worked the room to help troubleshoot, and a program that covered a lot of ground.  While that latter point was explicitly stated as a goal of the workshop, it means that I left the workshop feeling I wouldn't be able to work through a full dataset on my own.  Now that I've had a chance to review the workshop materials, I feel a bit more comfortable and want to put down my workflow in this blog post.  Expect updates in the coming months as I marinate on this.

I also want to acknowledge [Joshua Orvis](https://github.com/jorvis), a bioinformatician at IGS and one of the workshop instructors.  Without his one-on-one help and his development of Chiron, this tutorial wouldn't be possible.

## Why use the cloud?
I'm not here to sell you on the idea of cloud computing.  In fact, maybe you should ignore all the buzz about 'the cloud'.  After all, you accrue charges as your cloud instance runs.  As a consequence, failure to shut down a instance could result in some hefty charges if it slips your mind.  Some people cite that it's a nussiance to move all your data to the cloud to begin working, only to then have to pull your results off the cloud before you shut it down.  But the same data gymnastics come into play when you use any remote computing resource.  Similarly, folks will often cite the problem that all programs and dependencies needed to carry out your work will have to be installed by you before your cloud instance is useful.  The arrival of [Docker](https://www.docker.com/) has largely made this a non-issue, in my opinion.  Yes, I'm aware that Docker is viewed with trepidation by some in the bioinformatics community (see [here](http://homolog.us/blogs/blog/2015/09/22/is-docker-for-suckers/), [here](http://lh3.github.io/2015/04/25/a-few-hours-with-docker/), and [here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4586803/)), but it seems to me that Docker and cloud computing make good bed fellows.

Still reluctant to dive in?  Well, an alternative to using cloud computing resources is to simply invest in your own compute cluster or leverage compute resources at your institution.  I have to say, both of these alternatives have some non-trivial downsides as well.  Running your own in-house compute cluster gives you tons of control, but with great power comes great responsibility, including that you'll have to maintain it, which requries sysadmin skills.  Acquiring your fancy new computer will also take a serious chunk of change (think 10K or more), and the hardware quickly becomes outdated.  My university has [a pretty awesome compute cluster](https://hpcwiki.genomics.upenn.edu/index.php/HPC:Main_Page), but if your favorite program isn't available, you likely won't have the access priveldges to install it yourself and it can take some time for the powers-that-be to get it installed.  We also experience frequent interruptions and server downtime on our university cluster.  Here's the bottom line: just like any other resource, cloud computing has its pros and cons, and should be thought of not as the *only* solution to your problems, but rather as one tool in your bioinformatics toolbox.  So, let's get started!

## Fire up your cloud computer
The two most popular cloud computing services are Amazon's Web Services (AWS) and Google's Cloud Platform.  Amazon, although the best known of the two, feels cumbersome to me -- the first hour of the workshop and 36 slides were devoted just to getting our AWS instance up and running.  I prefer Google.  If you're still undecided, I'd also point out that **Google gives you a $300 credit**, good for 1 year from the time you activate your cloud account!  This is more than enough cash to work your way through this tutorial and still have plenty left for some of your own analyses. 

I put together the video tutorial below to walk you through the follow steps:
* setting up your Google Cloud compute instance
* installing Docker on this instance
* installing Chiron for quick and easy access to a bunch of dockerized programs for metagenomics
* installing the Google Cloud SDK software *on your own computer* (not the cloud) so you can easily connect to your new cloud resources
* Connecting an FTP client to the instance so you can easily transfer files back and forth.
* tearing it all down when you're done

Below the video you'll find all the commands to work through these steps on your own.

{% include _vimeoPlayer.html id=225609851 %}

## Install your programs

Once your gcloud instance is running, click on the 'ssh' button next to the instance to open a terminal window.  This fast and easy way to connect to your cloud instance is one nice feature of the way gcloud is setup. We'll now use this ssh connection to install Docker and Chiron.

Install Docker  
{% highlight bash %}
sudo apt-get install docker.io
{% endhighlight %}

Install some dependencies that we'll need for Chiron
{% highlight bash %}
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F76221572C52609D
sudo apt-get update
sudo apt install -y python3 python3-pip python-pip
sudo pip3 install pyyaml requests
sudo pip install pyyaml cwlref-runner
{% endhighlight %}

Install [Chiron](https://github.com/IGS/Chiron)
{% highlight bash %}
git clone https://github.com/IGS/Chiron.git
{% endhighlight %}

Any docker images could be put on your instance at this point.  Take a look [here](http://biocontainers.pro/) to see if your favorite bioinformatics program has been dockerized

Look around your working directory.  In particular, take note of all the cool metagenomics tools that are now available in /Chiron/bin 
{% highlight bash %}
ls Chiron/bin
{% endhighlight %}

Although the ssh terminal available right on your instance is very convenient, it does not establish a connection between our local computer and the cloud instance (which we must do in order to move files back and forth).  In order to do that, we'll want to connect to our instance from the [terminal app](https://en.wikipedia.org/wiki/Terminal_(macOS)) on our local computer.  Go ahead and launch your Terminal app.  Before we do anything else, let's execute a command in the terminal that will allow us to see hidden files in our directory.  We need access to a few of these hidden files for the purposes of this tutorial.
{% highlight bash %}
defaults write com.apple.finder AppleShowAllFiles true
#then restart the finder to see these changes
killall Finder
#after this tutorial you can hide these files again by replacing 'true' with 'false'
{% endhighlight %}

Now install the google SDK.   
{% highlight bash %}
curl https://sdk.cloud.google.com | bash
{% endhighlight %}

I my experience, if you encounter any issues with this entire tutorial, it will be with getting the SDK installed and connecting to your instance. For example, you may notice that the installation fails with the following error
{% highlight bash %}
ERROR: Failed to fetch component listing from server. Check your network settings and try again
{% endhighlight %}
This error has to do with the the IPv6 settings on your computer preventing you from being able to connect with a google server to download the SDK command line tools

If you encounter this error, this fix is simple.  Begin by temporarily turning off IPv6 support for either Wi-Fi or Ethernet, depending on which one you are using to connect to the internet.  If you're using a Wi-Fi connection, then you would turn-off with:

{% highlight bash %}
networksetup -setv6off Wi-Fi #if you're using ethernet, replace 'Wi-Fi' with 'Ethernet' in this line
{% endhighlight %}

Now reattempt the installation as you did above
{% highlight bash %}
curl https://sdk.cloud.google.com | bash
{% endhighlight %} 

Once you have Google Cloud SDK installed, *be sure to turn the IPv6 back on*
{% highlight bash %}
networksetup -setv6automatic Wi-Fi
{% endhighlight %}

## Connect to your instance
Now we'll connect to the instance from within our Terminal.  
{% highlight bash %}
gcloud compute ssh instance-1 #if your instance is not called 'instance-1', be sure to modify this line accordingly
#Be patient here, as this may take a moment to connect.
{% endhighlight %}

If the above command failed with an authentication error, it's because this is the first time you've run SDK and it isn't sure that you should have access to your google account from the terminal.  Take a moment to authenticate
{% highlight bash %}
gcloud auth login
#this will open a browser window for you to select and sign-in to your google account
#after doing this, return to your terminal window and you should be good to go
#if this doesn't work, you may need to go though the gcloud initialization process by executing 'gcloud init'
#either way, once you have authenticated your account you will need to reattempt connecting with 'gcloud compute ssh instance-1'
{% endhighlight %}


## Launch an interactive session with Chiron
[Chiron](https://github.com/IGS/Chiron) gives you access to [QIIME](https://qiime2.org/) for processing marker gene sequence data, as well as the [BioBakery suite](https://bitbucket.org/biobakery/biobakery/wiki/browse/) of tools from [Curtis Huttenhower's lab](https://huttenhower.sph.harvard.edu/) for handling shotgun metagenomic sequencing data.  One of the first steps in the BioBakery workflow is using [MetaPhlan2](http://www.nature.com/nmeth/journal/v9/n8/full/nmeth.2066.html) to get species and strain level composition information from raw sequence files.  This is a logical place for us to start as well.

Launch the MetaPhlan2 interactive
{% highlight bash %}
sudo ./Chiron/bin/phlan_interactive -l ~/data
#the -l option tells the interactive to create a new folder in our home directory called 'data', and sets this folder as the default from which data will be read and to which outputs will be saved 
#This is where we'll put all our raw sequence data for analysis
{% endhighlight %}

Set permissions so you can transfer data
{% highlight bash %}
#check permissions on all files and folders in the directory
ls -l 
#make yourself owner of the 'data' folder
sudo chown danielbeiting data #replace 'danielbeiting' with your username
#set yourself as the group for the 'data' folder
sudo chgrp danielbeiting data
#give yourself read/write/execute permission for the 'data' folder
chmod 777 data
{% endhighlight %}

## Rinse and repeat
Go through the steps below to make sure have mastered this tutorial:

close your terminal, reopen, and make sure you can reconnect to your instance with 
{% highlight bash %}
gcloud compute ssh instance-1
{% endhighlight %}

relaunch the interactive metaphlan session
{% highlight bash %}
sudo ./Chiron/bin/phlan_interactive -l ~/data #always be sure to use the '-l ~/data'
{% endhighlight %}

Go back to the your google cloud account, select the instance you've been working with (checkbox to the left of the instance), and choose 'Delete' from the menu bar.  

Make sure you can repeat the whole set-up again, *except* for the installation of the SDK -- this only needed to be done once.

Once you're comfortable with the whole process, you're ready to move on to [part II of this tutorial](http://hostmicrobe.org/microbiome/2017-09-19-cloudComputing_part2.md/)!

