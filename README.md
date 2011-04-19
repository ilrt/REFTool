# Welcome to REFTool #

## What is REFTool? ##

REFTool is a application for bookmarking evidence of impact with a minimum of fuss. It is a [caboto](http://caboto.org) application, which means that you can access it via a [REST API](http://code.google.com/p/caboto/wiki/RestfulResources) and SPARQL. Indeed REFTool itself is little more than a web page using that API.

## Getting Started ##

REFTool stores data using jena's SDB storage engine. By default it uses derby, a small embedded database. You can change the location of the store by editing:

    $ vi web/WEB-INF/classes/sdb.ttl
    
(`sdb:sdbName` is the location)

REFTool can use an spring security supported system, and as supplied is configured for simple http authentication. At the University of Bristol we use CAS, as single sign on system. See:

    web/WEB-INF/spring/caboto-context.xml

if you want to change this.

Finally invoke:

    $ sh merge.sh
    All done!

to create `reftool.war`. This will merge in the REFTool specific parts into caboto. Deploy to your server. You can now visit [http://localhost:8080/reftool/] and hopefully see everything working.

Finally drag [this bookmarklet][bookmark] to you bookmark bar. When you find a web page you want to add as evidence of impact just hit the reftool button.

## Further integration work ##

As noted above, adding your own authentication can be done using [Spring Security](http://static.springsource.org/spring-security/site/).

The principal task is allowing autocompletion to work over your researchers, papers and grants. REFTool uses jquery autocompletion for this. You need to provide three services which take a parameter `q` -- the text to match -- and return data of the form:

    Damian Steer|http://resrev.ilrt.bris.ac.uk/research-revealed-hub/people/157883#person
    ....
    
i.e. a label and URI separated by `|`.

If you arrange your URLs as `BASE/person`, `BASE/grant` and `BASE/pub` you can simply set `ENDPOINT` in `index.jsp`, otherwise set each in turn.

[bookmark]: <javascript:(function(){f='http://localhost:8080/reftool/index.jsp?url='+encodeURIComponent(window.location.href)+'&title='+encodeURIComponent(document.title)+'&';a=function(){if(!window.open(f+'noui=1&jump=doclose','RR-bookmark','location=yes,links=no,scrollbars=yes,toolbar=no,width=600,height=550'))location.href=f+'jump=yes'};if(/Firefox/.test(navigator.userAgent)){setTimeout(a,0)}else{a()}})()>
