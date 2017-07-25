---
layout: post
authors: [beiting]
title: "Cloud computing for metagenomics - Part I"
excerpt: "from raw sequences to strain-level composition."
modified: 2017-07-18
tags: [metagenomics]
categories: [microbiome]
comments: true
---

{% include _toc.html %}

## Before starting


## Metaphlan2



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

Once you're comfortable with the whole process, you're ready to move on to [part II of this tutorial]()!

