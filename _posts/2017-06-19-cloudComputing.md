---
layout: post
title: "Cloud computing for biologists"
excerpt: "asdfasdfasdfasdf."
modified: 2017-06-19
---

The anvi'o [metagenomic workflow]({% post_url anvio/2016-06-22-anvio-tutorial-v2 %}){:target="_blank"} assumes that you have metagenomic short reads. But what if all you have is a bunch of contigs, or a draft genome, or a MAG without any short reads to map to?

This need was brought up by one of our early users, and there has been an [open issue](https://github.com/meren/anvio/issues/226) to address this at some point. It is now resolved, and the following functionality is available in the [master branch](https://github.com/meren/anvio/tree/master).

The key is to create a *blank anvi'o profile database* to go with the contigs database, and this is what I will demonstrate here. But before I start, let me put this here so you know what version I am using:

{% highlight bash %}
$ anvi-profile -v
Anvi'o version ...............................: 2.0.0
Profile DB version ...........................: 15
Contigs DB version ...........................: 5
Samples information DB version ...............: 2
Auxiliary HDF5 DB version ....................: 1
Users DB version (for anvi-server) ...........: 1
{% endhighlight %}

## Preparing the FASTA file