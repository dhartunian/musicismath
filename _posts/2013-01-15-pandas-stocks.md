---
layout: post
title:An intro to pandas using stock data from Yahoo
tags: [python]
---

## An intro to pandas using stock data from Yahoo

Setup
----

This post was created using the following Python libraries:

* pandas version 0.9.0
* numpy version 1.6.2
* matplotlib version 1.2.0

Finance Background
----

We'll be looking at two financial assets in this analysis:

* SPX is the S&P 500 Index (known as ^GSPC in Yahoo's ticker system)
 * This index is a broad average of 500 large stocks in the US stock market
* SSO is what's called a leveraged ETF
 * Here is the description from Yahoo: "The investment seeks daily investment results that correspond to two times (2x) the daily performance of the S&P 500"

The key here is that the fund is structured to receive twice the S&P __daily__ return

Many investors misunderstand leveraged ETFs because they misunderstand this one fact. Additionally, it is not at all obvious how an investment in SSO will behave relative to the S&P 500 over the long run

We will be verifying the claim the description of the fund makes and looking at what consequences arise from it for an investor in SSO vs SPX

On to the code!
----

First, we import what we'll be needing

<div class="highlight"><pre><span class="kn">import</span> <span class="nn">pandas</span> <span class="kn">as</span> <span class="nn">pd</span>
<span class="kn">from</span> <span class="nn">datetime</span> <span class="kn">import</span> <span class="n">datetime</span>
</pre></div>



<div class="highlight"><pre><span class="kn">from</span> <span class="nn">pandas.io.data</span> <span class="kn">import</span> <span class="n">DataReader</span>
</pre></div>



Here we download the data from Yahoo finance with a Jan 1 2000 start date

SSO did not exist then so its start date will be in 2006

A good way to easily get a glance at your DataFrames is the head(n) method which shows the first n rows of your data (5 by default)

<div class="highlight"><pre><span class="n">spx</span> <span class="o">=</span> <span class="n">DataReader</span><span class="p">(</span><span class="s">&quot;^GSPC&quot;</span><span class="p">,</span> <span class="s">&quot;yahoo&quot;</span><span class="p">,</span> <span class="n">datetime</span><span class="p">(</span><span class="mi">2000</span><span class="p">,</span><span class="mi">1</span><span class="p">,</span><span class="mi">1</span><span class="p">))</span>
<span class="n">sso</span> <span class="o">=</span> <span class="n">DataReader</span><span class="p">(</span><span class="s">&quot;SSO&quot;</span><span class="p">,</span> <span class="s">&quot;yahoo&quot;</span><span class="p">,</span> <span class="n">datetime</span><span class="p">(</span><span class="mi">2000</span><span class="p">,</span><span class="mi">1</span><span class="p">,</span><span class="mi">1</span><span class="p">))</span>
</pre></div>



<div class="highlight"><pre><span class="n">spx</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre></div>


<pre>
                   Open     High      Low    Close      Volume  Adj Close
    Date                                                                 
    2000-01-03  1469.25  1478.00  1438.36  1455.22   931800000    1455.22
    2000-01-04  1455.22  1455.22  1397.43  1399.42  1009000000    1399.42
    2000-01-05  1399.42  1413.27  1377.68  1402.11  1085500000    1402.11
    2000-01-06  1402.11  1411.90  1392.10  1403.45  1092300000    1403.45
    2000-01-07  1403.45  1441.47  1400.73  1441.47  1225200000    1441.47
</pre>


<div class="highlight"><pre><span class="n">sso</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre></div>


<pre>
                 Open   High    Low  Close  Volume  Adj Close
    Date                                                     
    2006-06-21  70.88  71.81  70.82  71.50  277300      62.42
    2006-06-22  71.08  71.08  70.26  70.74  136600      61.76
    2006-06-23  70.32  71.38  70.13  70.73   44600      61.75
    2006-06-26  70.75  71.17  70.51  71.14   37700      62.10
    2006-06-27  71.37  71.37  69.88  69.88  114700      61.00
</pre>


From the data above we can see that we've got a few columns downloaded from Yahoo automatically.

First, we'll make sure that the spx dataset has the same dates as the sso dataset

The reindex function will look up each date in sso's index and find the corresponding data in spx

<div class="highlight"><pre><span class="n">spx</span> <span class="o">=</span> <span class="n">spx</span><span class="o">.</span><span class="n">reindex</span><span class="p">(</span><span class="n">sso</span><span class="o">.</span><span class="n">index</span><span class="p">)</span>
</pre></div>



Below you can see that our subset of SPX data now starts from June 21, 2006

<div class="highlight"><pre><span class="n">spx</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre></div>


<pre>
                   Open     High      Low    Close      Volume  Adj Close
    Date                                                                 
    2006-06-21  1240.09  1257.96  1240.09  1252.20  2361230000    1252.20
    2006-06-22  1251.92  1251.92  1241.53  1245.60  2148180000    1245.60
    2006-06-23  1245.59  1253.13  1241.43  1244.50  2017270000    1244.50
    2006-06-26  1244.50  1250.92  1243.68  1250.56  1878580000    1250.56
    2006-06-27  1250.55  1253.37  1238.94  1239.20  2203130000    1239.20
</pre>


From all this data, all we'll need is the Adj Close column. This column tracks all dividends and splits in the stock and provides us with one time series that corrects for all those events

In order to work with both datasets at once, I join their "Adj Close" columns into one DataFrame

The easiest way I've found to create a DataFrame from a bunch of series is to put them in a python dictionary so that pandas can use the keys as the column names

<div class="highlight"><pre><span class="n">both</span> <span class="o">=</span> <span class="n">pd</span><span class="o">.</span><span class="n">DataFrame</span><span class="p">(</span><span class="n">data</span> <span class="o">=</span> <span class="p">{</span><span class="s">&#39;spx&#39;</span><span class="p">:</span> <span class="n">spx</span><span class="p">[</span><span class="s">&#39;Adj Close&#39;</span><span class="p">],</span> <span class="s">&#39;sso&#39;</span><span class="p">:</span> <span class="n">sso</span><span class="p">[</span><span class="s">&#39;Adj Close&#39;</span><span class="p">]})</span>
</pre></div>



<div class="highlight"><pre><span class="n">both</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre></div>


<pre>
                    spx    sso
    Date                      
    2006-06-21  1252.20  62.42
    2006-06-22  1245.60  61.76
    2006-06-23  1244.50  61.75
    2006-06-26  1250.56  62.10
    2006-06-27  1239.20  61.00
</pre>


If we attempt to plot the two time series, we notice that since they don't start from the same value, it's impossible to compare their performance

<div class="highlight"><pre><span class="n">both</span><span class="o">.</span><span class="n">plot</span><span class="p">()</span>
</pre></div>


![]({{site.localurl}}/images/2013-01-15-pandas-stocks_files/Pandas___Stocks_fig_00.png)


To compare performance on a graph we'll need to assume a starting point and rebase the time series

We'll assume that we're comparing investments from the inception date of the SSO fund

pct_change() computes the percent change between datapoints for each column of the DataFrame

The resulting DataFrame will contain a NaN for the first index value (June 21, 2006) beacause there is no prior value to compute a return from

We will set this to 0 in the next line to aid with rebasing

<div class="highlight"><pre><span class="n">both_ret</span> <span class="o">=</span> <span class="n">both</span><span class="o">.</span><span class="n">pct_change</span><span class="p">()</span>
<span class="n">both_ret</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre></div>


<pre>
                     spx       sso
    Date                          
    2006-06-21       NaN       NaN
    2006-06-22 -0.005271 -0.010574
    2006-06-23 -0.000883 -0.000162
    2006-06-26  0.004869  0.005668
    2006-06-27 -0.009084 -0.017713
</pre>


<div class="highlight"><pre><span class="n">both_ret</span><span class="o">.</span><span class="n">ix</span><span class="p">[</span><span class="s">&#39;2006-06-21&#39;</span><span class="p">]</span> <span class="o">=</span> <span class="mi">0</span>
</pre></div>



<div class="highlight"><pre><span class="n">both_ret</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre></div>


<pre>
                     spx       sso
    Date                          
    2006-06-21  0.000000  0.000000
    2006-06-22 -0.005271 -0.010574
    2006-06-23 -0.000883 -0.000162
    2006-06-26  0.004869  0.005668
    2006-06-27 -0.009084 -0.017713
</pre>


To rebase the time series we simply accumulate the returns from a starting value of 1

cumprod() produces a time series that is a cumulative product of all the numbers in the series

<div class="highlight"><pre><span class="n">both_rebased</span> <span class="o">=</span> <span class="p">(</span><span class="n">both_ret</span> <span class="o">+</span> <span class="mi">1</span><span class="p">)</span><span class="o">.</span><span class="n">cumprod</span><span class="p">()</span>
</pre></div>



<div class="highlight"><pre><span class="n">both_rebased</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre></div>


<pre>
                     spx       sso
    Date                          
    2006-06-21  1.000000  1.000000
    2006-06-22  0.994729  0.989426
    2006-06-23  0.993851  0.989266
    2006-06-26  0.998690  0.994873
    2006-06-27  0.989618  0.977251
</pre>


Now we can plot the stocks together and compare their performance from the given starting point

We observe two things:

1. At the end of the time period, the SPX Index is up from its initial value while the SSO fund is down
2. At no point in this graph is the value of the SSO fund equal to twice the value of the SPX investment

Because the SSO fund delivers twice the returns, periods of negative returns will be twice as bad for the fund. In the graph below, 2008 was a much worse year for the SSO fund than the S&P 500 Index due to this behavior. The positive returns of 2009 were not large enough to allow an investor to make back the money they may have lost

<div class="highlight"><pre><span class="n">both_rebased</span><span class="o">.</span><span class="n">plot</span><span class="p">(</span><span class="n">figsize</span><span class="o">=</span><span class="p">(</span><span class="mi">10</span><span class="p">,</span><span class="mi">5</span><span class="p">))</span>
</pre></div>

![]({{site.localurl}}/images/2013-01-15-pandas-stocks_files/Pandas___Stocks_fig_01.png)


The function below creates a scatterplot given the data in a dataframe, df, with columns 'spx' and 'sso'.

We will use this function to compare returns over various timescales

<div class="highlight"><pre><span class="k">def</span> <span class="nf">plot_scatter</span><span class="p">(</span><span class="n">df</span><span class="p">):</span>
    <span class="n">fig</span> <span class="o">=</span> <span class="n">plt</span><span class="o">.</span><span class="n">figure</span><span class="p">()</span>
    
    <span class="c">#create axis and scatterplot our data</span>
    <span class="n">ax</span> <span class="o">=</span> <span class="n">fig</span><span class="o">.</span><span class="n">add_subplot</span><span class="p">(</span><span class="mi">111</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">scatter</span><span class="p">(</span><span class="n">df</span><span class="p">[</span><span class="s">&#39;spx&#39;</span><span class="p">],</span> <span class="n">df</span><span class="p">[</span><span class="s">&#39;sso&#39;</span><span class="p">])</span>
    
    <span class="c">#prevent matplotlib from automatically changing axis ranges</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">autoscale</span><span class="p">(</span><span class="bp">False</span><span class="p">)</span> 
    
    <span class="c">#add x = 0 and y = 0 lines</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">vlines</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span><span class="o">-</span><span class="mi">10</span><span class="p">,</span><span class="mi">10</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">hlines</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span><span class="o">-</span><span class="mi">10</span><span class="p">,</span><span class="mi">10</span><span class="p">)</span>
    
    <span class="c">#add y = x and y = 2*x lines</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">plot</span><span class="p">((</span><span class="o">-</span><span class="mi">10</span><span class="p">,</span><span class="mi">10</span><span class="p">),(</span><span class="o">-</span><span class="mi">10</span><span class="p">,</span><span class="mi">10</span><span class="p">))</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">plot</span><span class="p">((</span><span class="o">-</span><span class="mi">10</span><span class="p">,</span><span class="mi">10</span><span class="p">),(</span><span class="o">-</span><span class="mi">20</span><span class="p">,</span><span class="mi">20</span><span class="p">),</span> <span class="n">color</span><span class="o">=</span><span class="s">&#39;r&#39;</span><span class="p">)</span>
    
    <span class="n">ax</span><span class="o">.</span><span class="n">set_xlabel</span><span class="p">(</span><span class="s">&quot;SPX Returns&quot;</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">set_ylabel</span><span class="p">(</span><span class="s">&quot;SSO Returns&quot;</span><span class="p">)</span>
</pre></div>



By taking a look at the scatterplot of daily returns below we can see exactly how the returns of the SSO etf compare with the SPX index:

The blue line represents the function y = x. The return would like along this line if the two funds offered the same exposure.

The red line represents the function y = x * 2. The returns cluster along this line because the SSO etf delivers 2 times the daily return of the SPX

<div class="highlight"><pre><span class="n">both_rebased_ret</span> <span class="o">=</span> <span class="n">both_rebased</span><span class="o">.</span><span class="n">pct_change</span><span class="p">()</span>
<span class="n">plot_scatter</span><span class="p">(</span><span class="n">both_rebased_ret</span><span class="p">)</span>
</pre></div>



![]({{site.localurl}}/images/2013-01-15-pandas-stocks_files/Pandas___Stocks_fig_02.png)


The plot below is the same as the one above except the returns are taken over rolling 252-day periods (equivalent to a year in business days)

What we see is that the returns of the SSO fund can differ much more than the stated 2x over longer periods of time as the difference compounds

Further below, we can see the same plot over a 3-year rolling-period

Note that there are points where the SPX index has performed positively and the SSO has delivered negative returns and in all cases where the SPX is down over a 3 year period, the SSO fund is down more than 2 times as much

<div class="highlight"><pre><span class="n">plot_scatter</span><span class="p">(</span><span class="n">both_rebased</span> <span class="o">/</span> <span class="n">both_rebased</span><span class="o">.</span><span class="n">shift</span><span class="p">(</span><span class="mi">252</span><span class="p">)</span> <span class="o">-</span> <span class="mi">1</span><span class="p">)</span>
</pre></div>



![]({{site.localurl}}/images/2013-01-15-pandas-stocks_files/Pandas___Stocks_fig_03.png)


<div class="highlight"><pre><span class="n">plot_scatter</span><span class="p">(</span><span class="n">both_rebased</span> <span class="o">/</span> <span class="n">both_rebased</span><span class="o">.</span><span class="n">shift</span><span class="p">(</span><span class="mi">252</span><span class="o">*</span><span class="mi">3</span><span class="p">)</span> <span class="o">-</span> <span class="mi">1</span><span class="p">)</span>
</pre></div>



![]({{site.localurl}}/images/2013-01-15-pandas-stocks_files/Pandas___Stocks_fig_04.png)
