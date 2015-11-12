#lang pollen/markup

◊(define (java . java_code) `(pre (code ((class "java")) ,@java_code)))
◊(define (link title path) `(a ((href ,path))))

◊h2{How I'm used to doing DI in Java}

I'm used to using Guice and having plenty of interfaces in my code. So generally you do:

◊java{
    bind(IGameService.class).to(GameServiceImpl.class);
}
and then when you need it:

◊java{
    @Inject
    IGameService gameService;
}

which is mostly straightforward to use.

◊h2{How the component framework for Clojure does DI}

◊p{I just saw Stuart Sierra talk about this at the Lisp NYC Meetup so all my info is from there. I've never used this framework myself.}

◊p{
◊a[#:href "https://github.com/stuartsierra/component"]{Component} refers to dependencies using keys in a map which end up being strings. What's cool with this approach is that you can have multiple dependencies of the same type in your application and not have them conflict. For instance, if your application wants to have 2 SQL Databases you can trivially define them with different names.
}

With Guice you can:
◊ul{
  ◊li{Define "Named" dependencies which require a extra boilerplate both in the Module and an additional annotation where it is to be injected.}
  ◊li{Define a ◊a[#:href "https://github.com/google/guice/wiki/BindingAnnotations"]{Binding Annotation} which requires an extra class file!}
}

◊h2{How could we make Java DI work instead?}

I'm jealous of the simplicity and terseness of the code for component. I wonder if something similar would be possible in straight Java. Something like

◊java{
    bind(GameServiceImpl.class).as("Game")
}

and then to request it

◊java{
    @Inject("Game")
    IGameService.class
}

Which will result in an injection as long as GameServiceImpl is a subclass of IGameService.

◊p{The one other thing I liked about component which speaks more to Clojure style in general is that any confusion about how dependencies are set in your system boils down to: it's just a map. The semantics of your system with respect to how dependencies are defined and resolved doesn't need to be learned. It just inherits it from a built-in datatype which everyone understands. That's one things Java can't really imitate.}
