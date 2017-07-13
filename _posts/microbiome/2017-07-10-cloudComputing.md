---
layout: post
authors: [beiting]
title: "Cloud computing for metagenomics"
excerpt: "A step-by-step guide to setting up cloud computing resources and analyzing shotgun metagenomic data, all on your laptop."
modified: 2017-07-10
tags: [metagenomics]
categories: [microbiome]
comments: true
---

{% include _toc.html %}

## Prelude

**Disclaimer: This is my first blog post.**  That's right, I'm a complete rookie at this.  Why now?  Well, since starting my faculty position four years ago and working to help build and direct the Center for Host-Microbial Interactions, I increasingly find myself involved in various collaborations or projects where there's something really interesting that I think would be useful to share with either my lab or with the broader scientific community, but which doesn't easily translate into a traditional publication.  Basically, I'm learning some cool stuff, and it's not always evident in my publications, so here we are.  

Case-in-point, I recently attended this [Microbiome Analysis in the Cloud](http://www.igs.umaryland.edu/topics/microbiome-cloud/), held at the Institute for Genome Sciences at the University of Baltimore.  The two-day workshop had a lot of high points, including excellent planning and preparation on the part of the organizers, a highly skilled staff that worked the room to help troubleshoot, and a program that covered a lot of ground.  While that latter point was explicitly stated as a goal of the workshop, it means that I left the workshop feeling I wouldn't be able to work through a full dataset on my own.  Now that I've had a chance to review the workshop materials, I feel a bit more comfortable and want to put down my workflow in this blog post.  Expect updates in the coming months as I marinate on this.


## Why use the cloud?
I'm not here to sell you on the idea of cloud computing.  In fact, maybe you should ignore all the buzz about 'the cloud'.  After all, you accrue charges as your cloud instance runs, so failure to shut down a instance could result in some hefty charges.  Some people cite that it's a nussiance to move all your data to the cloud to begin working, only to then have to pull your results off the cloud before you shut it down.  But the same data gymnastics come into play when you use any remote computing resource.  Similarly, folks will often cite the problem that all programs and dependencies needed to carry out your work will have to be installed by you before your cloud instance is useful.  The arrival of [Docker](https://www.docker.com/) (more on this later in the post) has largely made this a non-issue, in my opinion. 

Still reluctant to dive in?  Well, an alternative to using cloud computing resources is to simply invest in your own compute cluster or leverage compute resources at your institution.  I have to say, both of these alternatives have some non-trivial downsides as well.  Running your own in-house compute cluster gives you tons of control, but with great power comes great responsibility, including that you'll have to maintain your own compute server, which requries some sysadmin skills.  Not to mention the fact that serious computer hardware requires a substantial up front investment (think 10K or more) and quickly becomes obsolete.  My university has [a pretty awesome compute cluster](https://hpcwiki.genomics.upenn.edu/index.php/HPC:Main_Page), but if your favorite program isn't available, you likely won't have the access priveldges to install it yourself and it can take some time for the powers-that-be to get it installed.  Here's the bottom line: just like any other resource, cloud computing has its pros and cons, and should be thought of not as the *only* solution to your problems, but rather as one tool in your bioinformatics toolbox.  I know many people who switch between using local compute resources and using a cloud service.  So, let's get started!

## Fire up your cloud computer

The two most popular cloud computing services are Amazon's Web Services (AWS) and Google's Cloud Platform.  Amazon, although the best known of the two, feels incredibly complicated and cumbersome to me -- the first hour of the workshop and 36 slides were devoted just to getting our AWS instance up and running.  I prefer Google.  If you're still undecided, I'd also point out that **Google gives you a $300 credit**, good for 1 year from the time you activate your cloud account.  This is more than enough cash to work your way through this tutorial and still have plenty left for some of your own analyses. 

I put together the video tutorial below to walk you through the follow steps:
* setting up your Google Cloud compute instance
* installing Docker on this instance
* installing Chrion for quick and easy access to a bunch of dockerized programs for metagenomics
* installing the Google Cloud SDK software *on your own computer* (not the cloud) so you can easily connect to your new cloud resources
* Connecting an FTP client to the instance so you can easily transfer files back and forth.
* tearing it all down when you're done

I've also included the commands used in the video, below.  

## Install your programs

Install Docker
Once your gcloud instance is running, click on the 'ssh' button beside the instance and you will open .  The is a really nice feature of glcoud.  Use this ssh terminal window to install Docker
{% highlight bash %}
sudo apt-get install docker.io
{% endhighlight %}

Install some dependencies.
{% highlight bash %}
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F76221572C52609D
sudo apt-get update
sudo apt install -y python3 python3-pip python-pip
sudo pip3 install pyyaml requests
sudo pip install pyyaml cwlref-runner
{% endhighlight %}

Install [Chiron](https://github.com/IGS/Chiron).
{% highlight bash %}
git clone https://github.com/IGS/Chiron.git
{% endhighlight %}
Any docker images could be installed loaded on your instance.  Take a look [here](http://biocontainers.pro/) to see if your favorite bioinformatics program has been dockerized

Take a look around your working directory and the Chiron folder.  Take a look at all the metagenomics tools you now have installed that are available in /Chiron/bin 
{% highlight bash %}
ls Chiron/bin
{% endhighlight %}

Although it has been great to use the ssh window, we'll want to be able to connect to our instance from our own terminal window.  Go ahead and launch your terminal app.  Before we do anything else, now is a good time to execute a command in the terminal that will allow us to see hidden files in our directory.  We need to get at a few of these hidden files for the purposes of this tutorial.
{% highlight bash %}
defaults write com.apple.finder AppleShowAllFiles true
#then restart the finder to see these changes
killall Finder
{% endhighlight %}

Now install the google SDK.   
{% highlight bash %}
curl https://sdk.cloud.google.com | bash
{% endhighlight %}

I my experience, if you encounter any issues with this entire tutorial, with getting the SDK installed and making sure you can connect to your instance. For instance, you may notice that the installation fails with the following error:
{% highlight bash %}
ERROR: Failed to fetch component listing from server. Check your network settings and try again
{% endhighlight %}
This error has to do with the the IPv6 settings on your computer preventing you from being able to connect with a google server to download the SDK command line tools

If you encounter this error, this fix is simple.  Begin by temporarily turning off IPv6 support for either Wi-Fi or Ethernet, depending on which one you are using to connect to the internet.  If Wi-Fi, then you would turn-off with:

{% highlight bash %}
networksetup -setv6off Wi-Fi
{% endhighlight %}

Now reattempt the installation as you did above with:
{% highlight bash %}
curl https://sdk.cloud.google.com | bash
{% endhighlight %} 

Once you have Google Cloud SDK installed, *be sure to turn the IPv6 back on*
{% highlight bash %}
networksetup -setv6automatic Wi-Fi
{% endhighlight %}

## Connect to your instance
Open *your terminal app* (not the ssh window) and connect to your instance.  Be patient here, as this may take a moment to connect.
{% highlight bash %}
gcloud compute ssh instance-1
{% endhighlight %}

## Move data onto your instance

Key files have been generated, but will not be visible on your file system until you instruct you OS to show all files using this command

