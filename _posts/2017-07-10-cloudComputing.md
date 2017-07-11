---
layout: post
authors: [beiting]
title: "Cloud computing for metagenomics"
excerpt: "A step-by-step guide to setting up cloud computing resources and analyzing shotgun metagenomic data, all on your laptop."
modified: 2017-07-10
comments: true
---

{% include _toc.html %}

# this post is a work in progress

## Some comments before starting

Disclaimer: This is my first blog post.  That's right, I'm a complete rookie at this.  So why now?  Well, since starting my faculty position four years ago and working to help build and direct the Center for Host-Microbial Interactions, I increasingly find myself involved in various collaborations or projects where there's something really interesting that I think would be useful to share with either my lab or with the broader scientific community, but which doesn't easily translate into a traditional publication.  Basically, I'm learning some cool stuff, and it's not always evident in my publications, so here we are.  

Case-in-point, I was recently at this [Microbiome Analysis in the Cloud](http://www.igs.umaryland.edu/topics/microbiome-cloud/), held at the Institute for Genome Sciences at the University of Baltimore.  The two-day workshop had a lot of highlights, including excellent planning and preparation on the part of the organizers, a highly skilled staff the worked the room to help troubleshoot, and a program that covered a lot of different tools and methods.  While that latter point was explicitly stated as a goal of the workshop, it means that I really felt left the workshop feeling like I wasn't going to be able to work through a full dataset on my own.  Now that I've had a chance to work through the workshop materials, I feel a bit more comfortable and want to put down my workflow in this blog post.  Expect updates in the coming months as I continue to navigate this workflow.


## why should you even care about cloud computing?

I'm not here to sell you on the idea of cloud computing.  In fact, maybe you should ignore all the buzz about 'the cloud'.  After all, you accrue charges as your cloud instance runs, so failure to shut down a instance could result in some hefty charges.  Some people cite that it's a nussiance to move all your data to the cloud to begin working, only to then have to pull your results off the cloud before you shut it down.  But the same data gymnastics come into play when you use any remote computing resource.  Similarly, folks will often cite the problem that all programs and dependencies needed to carry out your work have will have to be installed by you before your cloud instance is useful.  The arrival of [Docker]() (more on this later in the post) has largely made this a non-issue. Still reluctant to dive in?  Well, an alternative to using cloud computing resources is to simply use your own compute cluster or compute resources available at your institution.  I have to say, both of these alternatives have some pretty darn obvious downsides as well.  Running your own in-house compute cluster gives you tons of control, but with great power comes great responsibility, including that maintining your own compute server requires some sysadmin skills, and serious computer hardware requires a substantial up front investment (think 10K or more) and quickly becomes obsolete.  My university has [a pretty awesome compute cluster](), but if your favorite program isn't available, you likely won't have the access priveldges to install it yourself and it can take some time for the powers-that-be to get it installed.  Here's the bottom line: just like any other resource, cloud computing has its pros and cons, and should be thought of not as the *only* solution to your problems, but rather as one tool in your bioinformatics toolbox.  I know many people who switch between using local compute resources and using a cloud service.  So, let's get started!


## Fire up your cloud computer

The two most popular cloud computing services are Amazon's Web Services (AWS) and Google's Cloud Platform.  Amazon, although the best known of the two, feels incredibly complicated and cumbersome to me -- the first 45 mintues of the workshop and X slides were devoted just to getting our AWS instance up and running.  I prefer Google.  If that doesn't tip the scales for you, I'd also point out that Google gives you a $300 credit, good for 1 year from the time you activated the account.  This is more than enough cash to work your way through this tutorial and still have plenty left  for some of your own analyses. 

To get started, navigate to the [Google Cloud Platform](https://cloud.google.com/).  You'll need to log in with your Google credentials and fill out some basic information (including credit card or bank account) to activate your cloud account.  Once that's done, you'll be able to access the console, the landing page for all things related to your Google Cloud.  It's through this interface that you'll be able to access compute resources and track your expenses.  

< screen cap 1 >

The sidebar provides access to all the produces and services.  There's a lot here that I haven't had a chance to explore, so for the purposes of this tutorial we will only be using the **Compute Engine** -> *VM instances*.  

< screen cap 2 >

* install some dependencies that are needed to run Chiron.
{% highlight bash %}
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F76221572C52609D
sudo apt-get update
sudo apt install -y python3 python3-pip python-pip
sudo pip3 install pyyaml requests
sudo pip install pyyaml cwlref-runner
{% endhighlight %}

## Preparing the FASTA file

The power of the algorithm comes from the principle of entropy minimization to achieve ecologically relevant units in high-throughput sequencing datasets of marker genes, which was introduced by oligotyping in 2013.
