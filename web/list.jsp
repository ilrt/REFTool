<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:security="http://www.springframework.org/security/tags"
      xmlns:function="http://java.sun.com/jsp/jstl/functions">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>My Bookmarked Items</title>
        <script type="text/javascript" src="js/jquery-1.3.2.min.js"></script>
        <script type="text/javascript" src="js/jquery-ui-1.7.2.custom.min.js"></script>
        <script type="text/javascript">
            jQuery(function(){
				var uid = readCookie('uid');
				$('#uid').text(uid);
   				// Load Data...
				$.getJSON(
					'annotation/person/' + uid + "/public/", 
					function(data) {
						var row = '<tr>';
						for (var i in data) {
							var anno = data[i];
							var row = '<tr>';
							row += '<td><button onClick="deleteItem(\'' + anno['id'] + '\')">!</button></td>';
							row += '<td><a href="' + anno.annotates +
							    '">' + anno.body.title[0] + '</a></td>';
							row += '<td>' + anno.body.description[0] + '</td>';
							row += '<td>';
							row += anno.body.associatedResearcherName.join(' ,<br />');
							row += '</td>';
							row += '<td>';
							row += anno.body.associatedPublicationTitle.join(' ,<br />');
							row += '</td>';
							row += '<td>';
							row += anno.body.associatedGrantName.join(' ,<br />');
							row += '</td>';
							row += '<td>' + anno.created + '</td>';
							$('#results').append(row);
						}
				});
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
      function deleteItem(item) {
          var goAhead = confirm("Are you sure you want to delete this item?");
          if (goAhead) {
            $.ajax({ url: item , type: 'DELETE' , 
            success: function() { location.reload(); } ,
            error:   function() { alert("Sorry, for some reason delete failed"); } 
            });
          }
      }
        </script>
        <style type="text/css">
            @import url(css/jquery.autocomplete.css);
            @import url(css/jquery-ui-1.7.2.custom.css);

            body { font-family: sans-serif; font-size: 80%; }
            h1, h4 { font-weight: normal; }
            h1 { font-size: 140%; }
            h4 { padding-left: 1em; }
            .purpose { color: #aaa; }

			th { 
				padding: 5pt;
				background: #ddd; 
			}
			
			tr:nth-child(even) {
				background: #eee;
			}
			
			td {
				padding: 3pt;
			}
			
            input { width: 25em; }
            input.hidden { display: none; }
            label {
                width: 11em;
                display: -moz-inline-box;
                display: inline-block;
                vertical-align: top;
                padding-right: 0.5em;
                text-align: right;
            }
            input[type='checkbox'] {
                width: 1em;
            }

            /* The angled part of the tab */

            span.angle {
                font-size: 0px; line-height: 0%; width: 0px;
                border-top: 12pt solid #eee;
                border-bottom: 12pt solid #eee;
                border-left: 12pt solid #bbb;
                float: right;
            }

            .ui-state-hover span.angle {
                border-top: 12pt solid #eee;
                border-bottom: 12pt solid #eee;
                border-left: 12pt solid #fdf5ce;
            }

            .ui-state-active span.angle {
                border-top: 12pt solid #eee;
                border-bottom: 12pt solid #eee;
                border-left: 12pt solid #333;
            }

            span.count { font-weight: bold }

            /* Vertical Tabs
            ----------------------------------*/
            /*.ui-tabs-vertical { width: 90%; }*/
            .ui-tabs-vertical .ui-tabs-nav { padding: .2em .1em .2em .2em; float: left; width: 18em; }
            .ui-tabs-vertical .ui-tabs-nav li { clear: left; width: 100%; border-bottom-width: 1px !important; border-right-width: 0 !important; margin: 0 -1px .2em 0; }
            .ui-tabs-vertical .ui-tabs-nav li a { display:block; }
            .ui-tabs-vertical .ui-tabs-nav li.ui-tabs-selected { padding-bottom: 0; border-right-width: 0; border-right-width: 0 !important; }
            .ui-tabs-vertical .ui-tabs-panel { padding-left: 19em;}

            input.btn {
                border: 1px solid;
                font-size: 100%;
                margin-left: 4em;
                margin-right: 4em;
                width: 10em
            }

            div#bookmarklet {
                position: absolute;
                top: 0;
                right: 0;
                padding: 10pt;
                background: #eee;
            }
        </style>
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

        <h1>Research Revealed <span class="purpose">Recorded Research Impacts</span></h1>
		
		<div id="bookmarklet">
            <a href="javascript:(function(){f='${pageContext.request.requestURL}?url='+encodeURIComponent(window.location.href)+'&amp;title='+encodeURIComponent(document.title)+'&amp;';a=function(){if(!window.open(f+'noui=1&amp;jump=doclose','RR-bookmark','location=yes,links=no,scrollbars=yes,toolbar=no,width=550,height=550'))location.href=f+'jump=yes'};if(/Firefox/.test(navigator.userAgent)){setTimeout(a,0)}else{a()}})()">
                Bookmarklet
            </a>
        </div>
		
        <%-- message if not logged in --%>
        <security:authorize ifNotGranted="ROLE_USER,ROLE_ADMIN">
            <p>You must be <a href="secured/">logged in</a> to see your bookmarks.</p>
            <p>Authentication uses a CAS Single Sign-on Service</p>
        </security:authorize>
        <security:authorize ifAnyGranted="ROLE_USER,ROLE_ADMIN">
            <p>Logged in as <i id='uid'></i></p>
        </security:authorize>

		<div id="content">
			<table>
				<thead>
					<tr>
					  <th></th>
						<th>Evidence</th>
						<th>Description</th>
						<th>Researchers</th>
						<th>Publications</th>
						<th>Grants</th>
						<th>Time</th>
					</tr>
				</thead>
				<tbody id="results"></tbody>
			</table>	
		</div>

        </form>
    </body>
</html>
