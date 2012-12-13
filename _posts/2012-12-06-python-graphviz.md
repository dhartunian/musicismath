---
layout: post
title: Using graphviz to visualize my Python code
tags: [python]
---

## Using graphviz to visualize my Python code

After reading a chapter in _Land of Lisp_ that used graphviz to plot the game board I was embarrassed to discover that it's really easy to make your own graphs with the tool! All you need is a list of edges, like this:

    digraph {
	    Jeff Goldblum -> The_Fly
	    Jeff Goldblum -> Jurassic_Park
	    Richard_Attenborough -> Jurassic_Park
    }

![example graph](../../../images/example_graph.png "Example Graph")

Last week when I was returning to a piece of code I hadn't touched in months I decided to see if I could quickly use it to code up a visualization of my code's call structure. The trick here was that it didn't have to be perfect, otherwise I'd get bogged down for hours.

I put a simple regex together that detected most of my method calls, remembered which function they were called from, and output the data in the form of a simple directed graph in .dot format.

{% highlight python linenos%}
function_regex = re.compile("\s?def\s(\w+)")
funcall_regex = re.compile("\.(\w+)\(")
{% endhighlight %}

With almost no further effort required I get a beautiful graph of which method call other ones and can quickly remember how the control flows within the class.

{% highlight python linenos%}
with open(filename, 'r') as codefile:
	with open('spec.py.dot','w') as dotfile:
		current_fun = ""
		dotfile.write("digraph {\n")
		for line in codefile:
			fun_name = function_regex.findall(line)
			if fun_name:
				current_fun = fun_name[0]
				funcall_names = funcall_regex.findall(line)
				for name in funcall_names:
					dotfile.write("".join([current_fun,
					                       "->", name, "\n"]))
				dotfile.write("}\n")
{% endhighlight %}

I can definitely see how producing a tool that did this correctly in all cases using only static analysis is really difficult and probably not worth it. But for quick and dirty visualization while you're coding, it only takes a few minutes to cook up from scratch and lets you see something a text editor can't show you!

Now, I know: If I can just get a list of the edges of any graph, I can visualize it almost instantly!

So don't forget to check out:

[graphviz](http://www.graphviz.org)

[Land of Lisp](http://www.landoflisp.com)


