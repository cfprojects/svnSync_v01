<cfoutput>
<style type="text/css">
table.diff { width: 100%; }
.diff tr, table.diff { margin: 0px; padding: 0px; }
.diff td { margin: 0px; padding: 3px; border-collapse: collapse; font-family:  'Bitstream Vera Sans Mono', 'Bitstream Vera Mono', 'Lucida Console', 'Lucida Typewriter', 'Courier New', monspace, fixed, fixed-width; font-size: 12px; vertical-align: top; }
.diff td.linenum {background-color: ##e0e0e0; color: ##666666; border-right: 1px solid ##d0d0d0; border-left: 1px solid ##c0c0c0; text-align: right; }
.diff .code div { line-height: 1.2em; width:50%;}
<!--- .diff tr:hover .code div { height: auto; overflow: auto; } --->
.diff .ins { background-color: ##afa; }
.diff .del { background-color: ##faa; }
.diff .upd { background-color: ##aaf; }
</style>
<table class="diff" cellspacing="0" border="1">
<tr>
	<td colspan="2" align="center" style="border-bottom:1px solid ##C0C0C0;"><cfif url.revision lt 0>LOCAL FILE<cfelseif url.revision eq 0>SVN REVISION - HEAD<cfelse>SVN REVISION - #url.revision#</cfif></td>
	<td colspan="2" align="center" style="border-bottom:1px solid ##C0C0C0;"><cfif url.diffRevision lt 0>LOCAL FILE<cfelseif url.diffRevision eq 0>SVN REVISION - HEAD<cfelse>SVN REVISION - #url.diffRevision#</cfif></td>
</tr>
<cfloop query="P">
	<tr>
		<td class="linenum"><cfif IsNumeric(AtSecond)>#NumberFormat(AtSecond)#<cfelse>&nbsp;</cfif></td>
		<td width="50%" class="code<cfif Operation NEQ '-'> #OpClasses[Operation]#</cfif>"><div style="width:100%;overflow:auto;">#Replace(HTMLEditFormat(ValueSecond),Chr(9),"&nbsp;&nbsp;&nbsp;","ALL")#</div></td>
		<td class="linenum"><cfif IsNumeric(AtFirst)>#NumberFormat(AtFirst)#<cfelse>&nbsp;</cfif></td>
		<td width="50%" class="code<cfif Operation NEQ '+'> #OpClasses[Operation]#</cfif>"><div style="width:100%;overflow:auto;">#Replace(HTMLEditFormat(ValueFirst),Chr(9),"&nbsp;&nbsp;&nbsp;","ALL")#</div></td>
	</tr>
</cfloop>
</table>
</cfoutput>