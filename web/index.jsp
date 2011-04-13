<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:security="http://www.springframework.org/security/tags"
      xmlns:function="http://java.sun.com/jsp/jstl/functions">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Bookmarking</title>
	<link rel="stylesheet" href="css/main.css" />
	<link rel="stylesheet" href="css/bookmarklet.css" />
	<link rel="stylesheet" href="css/jquery.autocomplete.css" />
        <script type="text/javascript" src="js/jquery-1.3.2.min.js"></script>
        <script type="text/javascript" src="js/jquery.autocomplete.js"></script>
        <script type="text/javascript" src="js/jquery-ui-1.7.2.custom.min.js"></script>
        <script type="text/javascript">
            var ENDPOINT = 'http://resrev.ilrt.bris.ac.uk/Completor/resources/complete/a';

            jQuery(function(){
	
				$('.add').click(function () {
					addAnother(this);
					return false;
					});
				
				$('.del').click(function () {
					removeThis(this);
					return false;
					});
				
				$('.flagoff').click(function () {
				  console.log("zing");
				  $(this).toggleClass('flagenabled');
				  if ($(this).hasClass('flagenabled')) {
				    $(this).find('input').val('true');
				  } else {
				    $(this).find('input').val('');
				  }
				  return false;
				});
				
                var thing = $('#repeat');
                thing.find('input.complete').autocomplete(ENDPOINT + '/person').
                    result(function(event, data, formatted) {
                    if (data) thing.find('input.target').val(data[1]);
                    else thing.find('input.target').val('');
                });
				
				var grants = $('#grant-repeat');
                grants.find('input.complete').autocomplete(ENDPOINT + '/grant').
                    result(function(event, data, formatted) {
                    if (data) grants.find('input.target').val(data[1]);
                    else grants.find('input.target').val('');
                });

								var pubs = $('#pub-repeat');
				                pubs.find('input.complete').autocomplete(ENDPOINT + '/pub').
				                    result(function(event, data, formatted) {
				                    if (data) pubs.find('input.target').val(data[1]);
				                    else pubs.find('input.target').val('');
				                });

                $('#keywords').autocomplete(ENDPOINT + '/keyword', {
                    multiple: true,
                    autoFill: true
                });

                $("#classify").tabs();

                // Attach counts of selected items under tabs
                $("#classify li a").each( function(i) {
                    $(this.getAttribute('href') + ' input:checkbox').click(updateTabCounts);
                });

                updateTabCounts();

                var uid = readCookie('uid');
                if (uid == null || uid == '' || uid == 'null' || uid == '""') { /* Disable form */
                    $('#data input').attr('disabled','disabled');
                    $('#data textarea').attr('disabled','disabled');
                    $('#data button').attr('disabled','disabled');
                } else {
                    $('#uid').text(uid);
                }
            });
            
            function readCookie(name) {
                var nameEQ = name + "=";
                var ca = document.cookie.split(';');
                for(var i=0;i < ca.length;i++) {
                    var c = ca[i];
                    while (c.charAt(0)==' ') c = c.substring(1,c.length);
                    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
                }
                return null;
            }
            
            function updateTabCounts() {
                $("#classify li a").each( function(i) {
                    // Deref link and get all checked items
                    var count = $(this.getAttribute('href') + ' input:checkbox:checked').length;
                    var countElement = $(this).parent().find('span.count');
                    if (count == 0) countElement.hide();
                    else { countElement.show(); countElement.text(count); }
                });
            }

            function addAnother(item) {
                var cloned = $(item).parent().parent().clone(true);
                blank(cloned);
                cloned.find('input.complete').autocomplete(ENDPOINT + '/person').result(function(event, data, formatted) {
                    if (data) cloned.find('input.target').val(data[1]);
                    else thing.find('input.target').val('');
                });
                $(item).parent().parent().after(cloned);
            }

            function removeThis(item) {
                var toRemove = $(item).parent().parent();
                if (toRemove.siblings().length == 0) blank(toRemove, false);
                else toRemove.remove();
            }

            function blank(item, unbind) {
                if (unbind == null) unbind = true;
                item.removeAttr('id');
                item.find('input.complete').val('');
                if (unbind) item.find('input.complete').unbind();
                item.find('input.target').val('');
            }

            function submitForm() {
                /* TODO: Validate */
                var datas = $('#data').serialize();
                /*$('#saveButton').val('...Saving...');*/
                $.ajax({
                    beforeSend: function(x) { $('#saveButton').val('...Saving...'); $('#saveButton').attr('disabled','disabled'); },
                    data: datas,
                    error: function(x, status, error) { alert("Save failed: " + x.responseText + ' \nStatus: ' + x.status); $('#saveButton').val('Save'); $('#saveButton').attr('disabled',false); },
                    success: function(data, status, x) { $('#saveButton').val('Saved'); window.close(); },
                    type: 'POST',
                    url: 'annotation/person/' + readCookie('uid') + '/public/'
                });
            }
	    
            function cancelForm() {
                window.close();
            }
        </script>
    </head>
    <body>
        
       <%
            Cookie uid = new Cookie("uid", null);
            Cookie admin = new Cookie("admin", null);

            if (request.getUserPrincipal() != null) {
                uid.setValue(request.getUserPrincipal().getName());
                if (request.isUserInRole("ADMIN")) {
                    admin.setValue("true");
                }
            }

            response.addCookie(uid);
            response.addCookie(admin);
        %>

	    <div id="page">
		    <div id="header">

		    <div id="logo"><a href="/" title="Go to the Research Revealed website"><img src="images/bm-logo.png" alt="Research Revealed" width="322" height="47" /></a></div><!-- /logo -->
	        <security:authorize ifAnyGranted="ROLE_USER,ROLE_ADMIN">
	            <div id="loggedin">Logged in as <strong id='uid'></strong>| <a href="#">Log out</a></div>
	        </security:authorize>
	    </div><!-- /header -->

        <h1>Add new impact</h1>

	
    <%-- message if not logged in --%>
    <security:authorize ifNotGranted="ROLE_USER,ROLE_ADMIN">
        <p class="info">Please <a href="secured/">log in</a> to add an impact.</p>
    </security:authorize>

	<p class="info"><!--<strong><em>Oops!</em></strong> A URL is required--></p>

        
        <form id="data" action="javascript:submitForm()">
                <input type="hidden" name="type" value="Impact"/>
                <input type="hidden" name="rdftype" value="http://vocab.bris.ac.uk/resrev#ImpactEvidence"/> 

		<table cellspacing="0">
			<tr class="title"><th><label for="title">Title</label></th><td><input name="title" type="text" class="text" value="${fn:escapeXml(param.title)}" /><p class="note">Make your title concise and meaningful</p></td></tr>

			<tr class="url"><th><label for="annotates">URL</label></th><td><input name="annotates" type="text" class="text" value="${fn:escapeXml(param.url)}" /></td></tr>
		<tr class="description"><th><label for="abstract">Description of Impact</label></th><td><textarea name="abstract" cols="40" rows="6"></textarea></td></tr>
		<tr class="flag"><th>Importance</th><td><a class="flagoff" href="#">Flag as high priority<input type="hidden" name="flagged" value=""/></a></td></tr>
		<tr class="keywords"><th><label for="keywords">Keywords</label></th><td><input id="keywords" type="text" class="text" name="keywords"/><p class="note">Separate keywords with a comma. E.g. neural nets, heuristics</p></td></tr>
		<tr id="repeat" class="researcher"><th><label for="researchername">Researcher involved<label></th><td><input name="researchername" type="text" class="text complete" /> <input type="hidden" name="researcherid" class="target"/> <a class="del" href="#">delete</a><br /><a class="add" href="#">another</a></td></tr>
		<tr id="grant-repeat" class="grant"><th><label for="grantname">Grant involved<label></th><td><input name="grantname" type="text" class="text complete" /> <input type="hidden" name="grantid" class="target"/> <a class="del" href="#">delete</a><br /><a class="add" href="#">another</a></td></tr>
		<tr id="pub-repeat" class="publication repeat"><th><label for="pubname">Publication involved<label></th><td><input name="pubname" type="text" class="text complete" /> <input type="hidden" name="pubid" class="target"/> <a class="del" href="#">delete</a><br /><a class="add" href="#">another</a></td></tr>
		</table>


            <!-- Autogenerated -->

    <h2>Classification of impact</h2>
	    <div id="classify">

    <ul id="categories" about="#ref-root" typeof="skos:Concept">
        <li rev='skos:broader'>
            <a about='#989ijh' href='#l_989ijh' typeof='skos:Concept'><span property='skos:definition' content='Delivering highly skilled people '><span property='skos:prefLabel'>People &amp; Skills</span></span></a> <span class='count'></span>
        </li>
        <li rev='skos:broader'>
            <a about='#pfw8je' href='#l_pfw8je' typeof='skos:Concept'><span property='skos:definition' content='Creating new businesses, improving the performance of existing businesses, or commercialising new products or processes'><span property='skos:prefLabel'>Commercialisation</span></span></a> <span class='count'></span>
        </li>
        <li rev='skos:broader'>
            <a about='#ep5811' href='#l_ep5811' typeof='skos:Concept'><span property='skos:definition' content='Attracting R&amp;D investment from global business'><span property='skos:prefLabel'>Overseas R&amp;D Investment</span></span></a> <span class='count'></span>
        </li>
        <li rev='skos:broader'>
            <a about='#huv9hf' href='#l_huv9hf' typeof='skos:Concept'><span property='skos:definition' content='Better informed public policy-making or improved public services'><span property='skos:prefLabel'>Public Policy</span></span></a> <span class='count'></span>
        </li>
        <li rev='skos:broader'>
            <a about='#bo86m5' href='#l_bo86m5' typeof='skos:Concept'><span property='skos:definition' content='Improved patient care or health outcomes'><span property='skos:prefLabel'>Patients and healthcare</span></span></a> <span class='count'></span>
        </li>
        <li rev='skos:broader'>
            <a about='#62vbqe' href='#l_62vbqe' typeof='skos:Concept'><span property='skos:definition' content='Progress towards sustainable development, including environmental sustainability'><span property='skos:prefLabel'>Sustainability &amp; environment</span></span></a> <span class='count'></span>
        </li>
        <li rev='skos:broader'>
            <a about='#htflb0' href='#l_htflb0' typeof='skos:Concept'><span property='skos:definition' content='Cultural enrichment, including improved public engagement with science and research'><span property='skos:prefLabel'>Public Engagement</span></span></a> <span class='count'></span>
        </li>
        <li rev='skos:broader'>
            <a about='#m9zu7g' href='#l_m9zu7g' typeof='skos:Concept'><span property='skos:definition' content='Improved social welfare, social cohesion or national security'><span property='skos:prefLabel'>Social Impact</span></span></a> <span class='count'></span>
        </li>
    </ul>


    <div id="options">

    <ul id="l_989ijh">
	    <li><span rev='skos:broader' about='#s4bosm' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#s4bosm' /> <span property='skos:definition' content='Staff movement between academia and industry'><span property='skos:prefLabel'>Staff movement</span></span></span></li>
	    <li><span rev='skos:broader' about='#9co2ud' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#9co2ud' /> <span property='skos:definition' content='Employment of post-doctoral researchers in industry or spin-out companies'><span property='skos:prefLabel'>Employment</span></span></span></li>
    </ul>

    <ul id="l_pfw8je">
	    <li><span rev='skos:broader' about='#r8ei9n' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#r8ei9n' /> <span property='skos:definition' content='Research contracts and income from industry '><span property='skos:prefLabel'>Contracts and industry income</span></span></span></li>
	    <li><span rev='skos:broader' about='#qzsf6e' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#qzsf6e' /> <span property='skos:definition' content='Collaborative research with industry (for example, measured through numbers of co-authored outputs)'><span property='skos:prefLabel'>Industrial collaborative research</span></span></span></li>
	    <li><span rev='skos:broader' about='#k0y9uy' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#k0y9uy' /> <span property='skos:definition' content='Income from intellectual property '><span property='skos:prefLabel'>IP income</span></span></span></li>
	    <li><span rev='skos:broader' about='#8f8mdp' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#8f8mdp' /> <span property='skos:definition' content='Increased turnover/reduced costs for particular businesses/industry'><span property='skos:prefLabel'>Industrial efficiency</span></span></span></li>
	    <li><span rev='skos:broader' about='#9rb17t' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#9rb17t' /> <span property='skos:definition' content='Success measures for new products/services (for example, growth in revenue) '><span property='skos:prefLabel'>New product success</span></span></span></li>
	    <li><span rev='skos:broader' about='#qziqoq' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#qziqoq' /> <span property='skos:definition' content='Success measures for spin-out companies (for example, growth in revenue or numbers of employees)'><span property='skos:prefLabel'>Spin-out success</span></span></span></li>
	    <li><span rev='skos:broader' about='#pp8ufa' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#pp8ufa' /> <span property='skos:definition' content='Patents granted/licences awarded and brought to market'><span property='skos:prefLabel'>Patents</span></span></span></li>
	    <li><span rev='skos:broader' about='#i0194k' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#i0194k' /> <span property='skos:definition' content='Staff movement between academia and industry '><span property='skos:prefLabel'>Staff movement</span></span></span> <br />
    </ul>
	
	<ul id='l_ep5811' about='#ep5811'>
        <li><span rev='skos:broader' about='#gmk4xs' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#gmk4xs' />
        <span property='skos:definition' content='Research income from overseas business'><span property='skos:prefLabel'>International research income</span></span></span></li>
        <li><span rev='skos:broader' about='#sbtkrh' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#sbtkrh' />
        <span property='skos:definition' content='Collaborative research with overseas businesses'><span property='skos:prefLabel'>International business collaboration</span></span></span></li>
    </ul>

    <ul id='l_huv9hf' about='#huv9hf'>
        <li><span rev='skos:broader' about='#uy7gl7' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#uy7gl7' />
        <span property='skos:definition' content='Research income from government organisations'><span property='skos:prefLabel'>Income from government</span></span></span></li>
        <li><span rev='skos:broader' about='#kk9yho' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#kk9yho' />
        <span property='skos:definition' content='Changes to legislation/regulations/government policy (including references in relevant documents)'><span property='skos:prefLabel'>Legislative / regulatory / policy</span></span></span></li>
        <li><span rev='skos:broader' about='#nd6smi' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#nd6smi' />
        <span property='skos:definition' content='Changes to public service practices/guidelines (including references in guidelines)'><span property='skos:prefLabel'>Public service practice</span></span></span></li>
        <li><span rev='skos:broader' about='#guoyk6' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#guoyk6' />
        <span property='skos:definition' content='Measures of improved public services (for example, increased literary and numeracy rates) '><span property='skos:prefLabel'>Improvement is public services</span></span></span></li>
        <li><span rev='skos:broader' about='#87cjyf' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#87cjyf' />
        <span property='skos:definition' content='Staff exchanges with government organisations '><span property='skos:prefLabel'>Staff exchanges with government</span></span></span></li>
        <li><span rev='skos:broader' about='#uo6imo' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#uo6imo' />
        <span property='skos:definition' content='Participation on public policy/advisory committees'><span property='skos:prefLabel'>Participation in committees</span></span></span></li>
        <li><span rev='skos:broader' about='#wt7ge3' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#wt7ge3' />
        <span property='skos:definition' content='Influence on public policy debate (for example, as indicated by citations by non-government organisations or the media)'><span property='skos:prefLabel'>Influence in policy debate</span></span></span></li>
    </ul>

    <ul id='l_bo86m5' about='#bo86m5'>
        <li><span rev='skos:broader' about='#3qhxkg' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#3qhxkg' />
        <span property='skos:definition' content='Research income from the NHS and medical research charities '><span property='skos:prefLabel'>Income from NHS &amp; medical charities</span></span></span></li>
        <li><span rev='skos:broader' about='#39jj1n' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#39jj1n' />
        <span property='skos:definition' content='Measures of improved health outcomes (for example, lives saved, reduced infection rates)'><span property='skos:prefLabel'>Improved health outcomes</span></span></span></li>
        <li><span rev='skos:broader' about='#mshs0m' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#mshs0m' />
        <span property='skos:definition' content='Measures of improved health services (for example, reduced treatment times or costs, equal access to services)'><span property='skos:prefLabel'>Improved health services</span></span></span></li>
        <li><span rev='skos:broader' about='#fov6i' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#fov6i' />
        <span property='skos:definition' content='Changes to clinical or healthcare training, practice or guidelines (including references in relevant documents such as National Institute for Health and Clinical Excellence guidelines)'><span property='skos:prefLabel'>Changes to healthcare practice</span></span></span></li>
        <li><span rev='skos:broader' about='#ywtj06' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#ywtj06' />
        <span property='skos:definition' content='Development of new or improved drugs, treatments or other medical interventions; numbers of advanced phase clinical trials '><span property='skos:prefLabel'>New or improved treatments</span></span></span></li>
        <li><span rev='skos:broader' about='#qdyq9s' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#qdyq9s' />
        <span property='skos:definition' content='Participation on health policy/advisory committees'><span property='skos:prefLabel'>Participation in health committees</span></span></span></li>
        <li><span rev='skos:broader' about='#ku1glo' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#ku1glo' />
        <span property='skos:definition' content='Changes to public behaviour (for example, reductions in smoking)'><span property='skos:prefLabel'>Changed public behaviour</span></span></span></li>
    </ul>

    <ul id='l_62vbqe' about='#62vbqe'>
        <li><span rev='skos:broader' about='#gyvwc0' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#gyvwc0' />
        <span property='skos:definition' content='Application of solutions to sustainable development (new technologies, behavioural change and so on)'><span property='skos:prefLabel'>Application in sustainable development</span></span></span></li>
        <li><span rev='skos:broader' about='#oft089' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#oft089' />
        <span property='skos:definition' content='Measures of improved sustainability (for example, reduced pollution, regeneration of natural resources)'><span property='skos:prefLabel'>Improved sustainibility</span></span></span></li>
    </ul>

    <ul id='l_htflb0' about='#htflb0'>
        <li><span rev='skos:broader' about='#3ms645' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#3ms645' />
        <span property='skos:definition' content='Increased levels of public engagement with science and research (for example, as measured through surveys)'><span property='skos:prefLabel'>Increased public engagement</span></span></span></li>
        <li><span rev='skos:broader' about='#ywoern' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#ywoern' />
        <span property='skos:definition' content='Changes to public attitudes to science (for example, as measured through surveys)'><span property='skos:prefLabel'>Changes to public attitudes to science</span></span></span></li>
        <li><span rev='skos:broader' about='#7fpex8' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#7fpex8' />
        <span property='skos:definition' content='Enriched appreciation of heritage or culture (for example, as measured through surveys)'><span property='skos:prefLabel'>Enriched appreciation of heritage or culture</span></span></span></li>
        <li><span rev='skos:broader' about='#kck03x' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#kck03x' />
        <span property='skos:definition' content='Audience/participation levels at public dissemination or engagement activities (exhibitions, broadcasts and so on)'><span property='skos:prefLabel'>Participation in public engagement</span></span></span></li>
        <li><span rev='skos:broader' about='#sovmr4' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#sovmr4' />
        <span property='skos:definition' content='Positive reviews or participant feedback on public dissemination or engagement activities'><span property='skos:prefLabel'>Review of public engagement</span></span></span></li>
    </ul>

    <ul id='l_m9zu7g' about='#m9zu7g'>
        <li><span rev='skos:broader' about='#w1oaya' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#w1oaya' />
        <span property='skos:definition' content='Application of new ideas to improve social equity, inclusion or cohesion '><span property='skos:prefLabel'>Application that improves social equity</span></span></span></li>
        <li><span rev='skos:broader' about='#25x3tz' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#25x3tz' />
        <span property='skos:definition' content='Measures of improved social equity, inclusion or cohesion (for example, improved educational attainment among disadvantaged groups, or increased voting rates in lower participation communities)'><span property='skos:prefLabel'>Evidence of improved social equity</span></span></span></li>
        <li><span rev='skos:broader' about='#mrkyqz' typeof='skos:Concept'><input type='checkbox' name='classification' value='http://resrev.ilrt.bris.ac.uk/caboto-rr/#mrkyqz' />
        <span property='skos:definition' content='Application of new security technologies or practices '><span property='skos:prefLabel'>Application of new security techniques</span></span></span></li>
    </ul>
	
    </div><!-- /options -->
    </div><!-- /classify -->

            <!-- end autogenerated -->

	    <div id="actions">
		    <input id="saveButton" class="btn" type="submit" value="Submit" /> or <a class="cancel" href="#">cancel</a>
	</div><!-- /actions -->

        </form>

	<div id="footer">
		<p>Some footer text here</p>
	</div><!-- /footer -->
</div><!-- /page -->
    </body>
</html>
