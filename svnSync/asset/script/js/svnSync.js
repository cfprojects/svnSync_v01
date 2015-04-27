pic1= new Image(100,100); 
pic1.src="./asset/image/loadingAnimation.gif";

function showLoading()
{
	if (typeof document.body.style.maxHeight === "undefined") {//if IE 6
		$("body","html").css({height: "100%", width: "100%"});
		$("html").css("overflow","hidden");
		if (document.getElementById("TB_HideSelect") === null) {//iframe to hide select elements in ie6
			$("body").append("<iframe id='TB_HideSelect'></iframe><div id='TB_overlay'></div><div id='TB_window'></div>");
			$("#TB_overlay").click(tb_remove);
		}
	}else{//all others
		if(document.getElementById("TB_overlay") === null){
			$("body").append("<div id='TB_overlay'></div><div id='TB_window'></div>");
			$("#TB_overlay").click(tb_remove);
		}
	}
	
	if(tb_detectMacXFF()){
		$("#TB_overlay").addClass("TB_overlayMacFFBGHack");//use png overlay so hide flash
	}else{
		$("#TB_overlay").addClass("TB_overlayBG");//use background and opacity
	}
	$("body").append("<div id='TB_load'><img src='"+imgLoader.src+"' /></div>");//add loader to the page
	$('#TB_load').show();//show loader
}

function popUp(URL,popUpToolbar,popUpScrollbars,popUpLocation,popUpStatusbar,popUpMenubar,popUpResizable,popUpWidth,popUpHeight) 
{
	day = new Date();
	id = day.getTime();
	var winl = (screen.width-popUpWidth)/2;
	var wint = (screen.height-popUpHeight)/2;
	eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar='+popUpToolbar+',scrollbars='+popUpScrollbars+',location='+popUpLocation+',statusbar='+popUpStatusbar+',menubar='+popUpMenubar+',resizable='+popUpResizable+',width='+popUpWidth+',height='+popUpHeight+',left='+winl+',top='+wint);");
}

function highlightRow(row_id,row_action)
{
	if ((row_action == 'on') && (document.getElementById(row_id).className != 'rowSelected'))
	{
		document.getElementById(row_id).className = 'rowHighLightOn';
	}
	else if ((row_action == 'off') && (document.getElementById(row_id).className != 'rowSelected'))
	{
		document.getElementById(row_id).className = 'row2';
	}
	else if (row_action == 'selected')
	{
		document.getElementById(row_id).className = 'rowSelected';
	}
	else if (row_action == 'reset')
	{
		document.getElementById(row_id).className = 'row2';
	}
	
}

function refreshRows()
{
	var aRows = document.getElementsByName('pathsToUpdate');
	for (var i=0;i<aRows.length;i++) {
		if (aRows[i].checked) {
			document.getElementById('row'+aRows[i].id).className = 'rowSelected';
		}
	}
}

function sortSearch(pSearchField)
{
	showLoading();
	var sortBy = browserForm.sortBy.value;
	var sortDir = browserForm.sortDir.value;
	
	if((pSearchField == sortBy) && (sortDir == 'desc'))
	{
		document.browserForm.sortDir.value = 'asc'	
	}
	else if ((pSearchField == sortBy) && (sortDir == 'asc'))
	{
		document.browserForm.sortDir.value = 'desc'	
	}
	document.browserForm.sortBy.value=pSearchField;
	document.browserForm.submit();
}

function selectAll()
 {
 	var vChecked = 0;
	var tArray = document.getElementsByName("pathsToUpdate");
	var newVal = true;
	document.getElementById('selectAllImg').src = './asset/image/bullet_delete.gif';
	
	if (tArray.length > 0)
	{
		if (tArray[0].checked == true)
		{
			newVal = false;
			document.getElementById('selectAllImg').src = './asset/image/bullet_add.gif';
		}
	
		for (var i=0; i<tArray.length; i++)
		{
			tArray[i].checked = newVal;
			if(newVal){
				highlightRow('row'+tArray[i].id,'selected');
			}else{
				highlightRow('row'+tArray[i].id,'reset');
			}
		}
	}
}

function viewFile(browser_path, revision)
{
	var pageURL = './index.cfm?event=svnSync.viewFile&layout=popUp&browserPath=' + browser_path + '&revision=' + revision;
	popUp(pageURL,0,1,0,0,0,1,800,600);
}

function viewDiff(browser_path, revision, diff_revision)
{
	var pageURL = './index.cfm?event=svnSync.showDiff&layout=popUp&browserPath=' + browser_path + '&revision=' + revision + '&diffRevision=' + diff_revision;
	popUp(pageURL,0,1,0,0,0,1,1024,768);
}

function viewLog(browser_path, type, revision)
{
	var pageURL = './index.cfm?event=svnSync.getLog&layout=popUp&browserPath=' + browser_path + '&type=' + type + '&revision=' + revision;
	popUp(pageURL,0,1,0,0,0,1,800,600);
}

function viewDetailedLog(browser_path, type, revision)
{
	var pageURL = './index.cfm?event=svnSync.getDetailedLog&layout=popUp&browserPath=' + browser_path + '&type=' + type + '&revision=' + revision;
	popUp(pageURL,0,1,0,0,0,1,800,600);
}

function changePath(target_path)
{
	showLoading();
	document.browserForm.browserPath.value = target_path;
	document.browserForm.submit();
}

function exportFile(target_path)
{
	location.href = './index.cfm?event=svnSync.getFile&browserPath=' + target_path; 
}

function exportZip(target_path)
{
	location.href = './index.cfm?event=svnSync.exportZip&browserPath=' + target_path; 
}

function deleteFile(target_path)
{
	if (confirm('You Are About to Delete The Local File - Are you sure?')){
		showLoading();
		document.browserForm.event.value = 'svnSync.deleteFile';
		var fileField = document.createElement('input');
  		fileField.setAttribute('name','deletePath');
  		fileField.setAttribute('type','hidden');
		fileField.setAttribute('value',target_path);
		document.browserForm.appendChild(fileField);
		document.browserForm.submit();
	}
}

function deleteDirectory(target_path)
{
	if (confirm('You Are About to Delete The Local Directory - Are you sure?')){
		showLoading();
		document.browserForm.event.value = 'svnSync.deleteDirectory';
		var fileField = document.createElement('input');
  		fileField.setAttribute('name','deletePath');
  		fileField.setAttribute('type','hidden');
		fileField.setAttribute('value',target_path);
		document.browserForm.appendChild(fileField);
		document.browserForm.submit();
	}
}

function syncSelected()
{
	var tVal = false;
	var tArray = document.getElementsByName("pathsToUpdate");
	
	if (tArray.length > 0)
	{
		for (var i=0; i<tArray.length; i++)
		{
			if (tArray[i].checked == true)
			{
			tVal = true;
			break;
			}
		}
	}
	
	if (tVal)
	{	
		showLoading();
		document.browserForm.event.value = 'svnSync.syncFiles';
		document.browserForm.submit();	
	}
	else
	{
		alert('Nothing Selected To Sync');
	}
}

function menuAction (v_action){	
	if(v_action == 'syncOOS'){
		if (confirm('You Are About to Overwrite Local Files With HEAD Revision - Are you sure?')){
			document.menuForm.event.value = 'svnSync.syncOOS';
		}else{
			return false;
		}
	}else if(v_action == 'syncToRevision'){
		if (confirm('You Are About to Overwrite Local Files With Active Revision - Are you sure?')){
			document.menuForm.event.value = 'svnSync.syncToRevision';
		}else{
			return false;
		}
	}else if(v_action == 'syncToRevision'){
		if (confirm('You Are About to Overwrite Local Files With Active Revision - Are you sure?')){
			document.menuForm.event.value = 'svnSync.syncToRevision';
		}else{
			return false;
		}
	}else if(v_action == 'syncBrowser'){
		document.menuForm.event.value = 'svnSync.syncBrowser';
	}
	showLoading();
	document.menuForm.submit();
}

function IsNumeric(sText)

{
   var ValidChars = "0123456789.";
   var IsNumber=true;
   var Char;

 
   for (i = 0; i < sText.length && IsNumber == true; i++) 
      { 
      Char = sText.charAt(i); 
      if (ValidChars.indexOf(Char) == -1) 
         {
         IsNumber = false;
         }
      }
   return IsNumber;
   
   }
   
function checkRevision(v_revision) {
	if ((v_revision != 'HEAD') && (!(IsNumeric(v_revision)))){
		alert('Revision must be Numeric');
		return false;
	}
	return true;
}