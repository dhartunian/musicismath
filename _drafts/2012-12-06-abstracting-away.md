---
layout: post
tags: [python]
---

## Abstracting away a visualization pattern

One of the most useful little tools I've created for myself lately has been a little python script that fires up a GUI with an embedded matplotlib plot.

I have a function plot_viewer(df_dict, plot_fn) that takes a dictionary of pandas DataFrames and a function plot_fun(df, fig) which plots the given DataFrame, df on the matplotlibe figure fig.