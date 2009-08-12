#!/usr/local/bin/php
<?php 
/*
	$Id: services_captiveportal.php 340 2009-05-20 13:53:37Z jdegraeve $
	part of m0n0wall (http://m0n0.ch/wall)
	
	Copyright (C) 2003-2006 Manuel Kasper <mk@neon1.net>.
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	1. Redistributions of source code must retain the above copyright notice,
	   this list of conditions and the following disclaimer.
	
	2. Redistributions in binary form must reproduce the above copyright
	   notice, this list of conditions and the following disclaimer in the
	   documentation and/or other materials provided with the distribution.
	
	THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
	AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
	OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/

require("guiconfig.inc");

$pgtitle = array(gettext("Services"),gettext("Captive portal"));

if (!is_array($config['captiveportal'])) {
	$config['captiveportal'] = array();
	$config['captiveportal']['page'] = array();
	$config['captiveportal']['timeout'] = 60;
}

if ($_GET['act'] == "viewhtml") {
	echo base64_decode($config['captiveportal']['page']['htmltext']);
	exit;
} else if ($_GET['act'] == "viewerrhtml") {
	echo base64_decode($config['captiveportal']['page']['errtext']);
	exit;
}

$pconfig['cinterface'] = $config['captiveportal']['interface'];
$pconfig['maxproc'] = $config['captiveportal']['maxproc'];
$pconfig['maxprocperip'] = $config['captiveportal']['maxprocperip'];
$pconfig['timeout'] = $config['captiveportal']['timeout'];
$pconfig['idletimeout'] = $config['captiveportal']['idletimeout'];
$pconfig['enable'] = isset($config['captiveportal']['enable']);
$pconfig['auth_method'] = $config['captiveportal']['auth_method'];
$pconfig['radacct_enable'] = isset($config['captiveportal']['radacct_enable']);
$pconfig['radmac_enable'] = isset($config['captiveportal']['radmac_enable']);
$pconfig['radmac_secret'] = $config['captiveportal']['radmac_secret'];
$pconfig['reauthenticate'] = isset($config['captiveportal']['reauthenticate']);
$pconfig['reauthenticateacct'] = $config['captiveportal']['reauthenticateacct'];
$pconfig['httpslogin_enable'] = isset($config['captiveportal']['httpslogin']);
$pconfig['httpsname'] = $config['captiveportal']['httpsname'];
$pconfig['cert'] = base64_decode($config['captiveportal']['certificate']);
$pconfig['key'] = base64_decode($config['captiveportal']['private-key']);
$pconfig['logoutwin_enable'] = isset($config['captiveportal']['logoutwin_enable']);
$pconfig['peruserbw'] = isset($config['captiveportal']['peruserbw']);
$pconfig['bwdefaultdn'] = $config['captiveportal']['bwdefaultdn'];
$pconfig['bwdefaultup'] = $config['captiveportal']['bwdefaultup'];
$pconfig['nomacfilter'] = isset($config['captiveportal']['nomacfilter']);
$pconfig['noconcurrentlogins'] = isset($config['captiveportal']['noconcurrentlogins']);
$pconfig['redirurl'] = $config['captiveportal']['redirurl'];
$pconfig['radiusip'] = $config['captiveportal']['radiusip'];
$pconfig['radiusip2'] = $config['captiveportal']['radiusip2'];
$pconfig['radiusport'] = $config['captiveportal']['radiusport'];
$pconfig['radiusport2'] = $config['captiveportal']['radiusport2'];
$pconfig['radiusacctport'] = $config['captiveportal']['radiusacctport'];
$pconfig['radiuskey'] = $config['captiveportal']['radiuskey'];
$pconfig['radiuskey2'] = $config['captiveportal']['radiuskey2'];
$pconfig['radiusvendor'] = $config['captiveportal']['radiusvendor'];
$pconfig['radiussession_timeout'] = isset($config['captiveportal']['radiussession_timeout']);
$pconfig['radmac_format'] = $config['captiveportal']['radmac_format'];

if ($_POST) {

	unset($input_errors);
	$pconfig = $_POST;

	/* input validation */
	if ($_POST['enable']) {
		$reqdfields = explode(" ", "cinterface");
		$reqdfieldsn = explode(",", "Interface");
		
		do_input_validation($_POST, $reqdfields, $reqdfieldsn, &$input_errors);
		
		/* make sure no interfaces are bridged */
		for ($i = 1; isset($config['interfaces']['opt' . $i]); $i++) {
			$coptif = &$config['interfaces']['opt' . $i];
			if (isset($coptif['enable']) && $coptif['bridge']) {
				$input_errors[] = "The captive portal cannot be used when one or more interfaces are bridged.";
				break;
			}
		}
		
		if ($_POST['httpslogin_enable']) {
		 	if (!$_POST['cert'] || !$_POST['key']) {
				$input_errors[] = "Certificate and key must be specified for HTTPS login.";
			} else {
				if (!strstr($_POST['cert'], "BEGIN CERTIFICATE") || !strstr($_POST['cert'], "END CERTIFICATE"))
					$input_errors[] = "This certificate does not appear to be valid.";
				if (!strstr($_POST['key'], "BEGIN RSA PRIVATE KEY") || !strstr($_POST['key'], "END RSA PRIVATE KEY"))
					$input_errors[] = "This key does not appear to be valid.";
			}
			
			if (!$_POST['httpsname'] || !is_domain($_POST['httpsname'])) {
				$input_errors[] = "The HTTPS server name must be specified for HTTPS login.";
			}
		}
	}
	
	if ($_POST['timeout'] && (!is_numeric($_POST['timeout']) || ($_POST['timeout'] < 1))) {
		$input_errors[] = "The timeout must be at least 1 minute.";
	}
	if ($_POST['idletimeout'] && (!is_numeric($_POST['idletimeout']) || ($_POST['idletimeout'] < 1))) {
		$input_errors[] = "The idle timeout must be at least 1 minute.";
	}
	if ($_POST['peruserbw'] && (!isset($config['shaper']['enable']))) {
		$input_errors[] = "The Traffic shaper has to be enabled first.";
	}
	if ($_POST['bwdefaultdn'] && (!is_numeric($_POST['bwdefaultdn']) || ($_POST['bwdefaultdn'] < 16))) {
		$input_errors[] = "The per-user bandwidth download speed must be at least 16.";
	}
	if ($_POST['bwdefaultup'] && (!is_numeric($_POST['bwdefaultup']) || ($_POST['bwdefaultup'] < 16))) {
		$input_errors[] = "The per-user bandwidth upload speed must be at least 16.";
	}
	if (($_POST['radiusip'] && !is_ipaddr($_POST['radiusip']))) {
		$input_errors[] = "A valid IP address must be specified. [".$_POST['radiusip']."]";
	}
	if (($_POST['radiusip2'] && !is_ipaddr($_POST['radiusip2']))) {
		$input_errors[] = "A valid IP address must be specified. [".$_POST['radiusip2']."]";
	}
	if (($_POST['radiusport'] && !is_port($_POST['radiusport']))) {
		$input_errors[] = "A valid port number must be specified. [".$_POST['radiusport']."]";
	}
	if (($_POST['radiusport2'] && !is_port($_POST['radiusport2']))) {
		$input_errors[] = "A valid port number must be specified. [".$_POST['radiusport2']."]";
	}
	if (($_POST['radiusacctport'] && !is_port($_POST['radiusacctport']))) {
		$input_errors[] = "A valid port number must be specified. [".$_POST['radiusacctport']."]";
	}
	if ($_POST['maxproc'] && (!is_numeric($_POST['maxproc']) || ($_POST['maxproc'] < 4) || ($_POST['maxproc'] > 100))) {
		$input_errors[] = "The total maximum number of concurrent connections must be between 4 and 100.";
	}
	$mymaxproc = $_POST['maxproc'] ? $_POST['maxproc'] : 16;
	if ($_POST['maxprocperip'] && (!is_numeric($_POST['maxprocperip']) || ($_POST['maxprocperip'] > $mymaxproc))) {
		$input_errors[] = "The maximum number of concurrent connections per client IP address may not be larger than the global maximum.";
	}

	if (!$input_errors) {
		$config['captiveportal']['interface'] = $_POST['cinterface'];
		$config['captiveportal']['maxproc'] = $_POST['maxproc'];
		$config['captiveportal']['maxprocperip'] = $_POST['maxprocperip'] ? $_POST['maxprocperip'] : false;
		$config['captiveportal']['timeout'] = $_POST['timeout'];
		$config['captiveportal']['idletimeout'] = $_POST['idletimeout'];
		$config['captiveportal']['enable'] = $_POST['enable'] ? true : false;
		$config['captiveportal']['auth_method'] = $_POST['auth_method'];
		$config['captiveportal']['radacct_enable'] = $_POST['radacct_enable'] ? true : false;
		$config['captiveportal']['reauthenticate'] = $_POST['reauthenticate'] ? true : false;
		$config['captiveportal']['radmac_enable'] = $_POST['radmac_enable'] ? true : false;
		$config['captiveportal']['radmac_secret'] = $_POST['radmac_secret'] ? $_POST['radmac_secret'] : false;
		$config['captiveportal']['reauthenticateacct'] = $_POST['reauthenticateacct'];
		$config['captiveportal']['httpslogin'] = $_POST['httpslogin_enable'] ? true : false;
		$config['captiveportal']['httpsname'] = $_POST['httpsname'];
		$config['captiveportal']['certificate'] = base64_encode($_POST['cert']);
		$config['captiveportal']['private-key'] = base64_encode($_POST['key']);
		$config['captiveportal']['logoutwin_enable'] = $_POST['logoutwin_enable'] ? true : false;
		$config['captiveportal']['peruserbw'] = $_POST['peruserbw'] ? true : false;
		$config['captiveportal']['bwdefaultdn'] = $_POST['bwdefaultdn'];
		$config['captiveportal']['bwdefaultup'] = $_POST['bwdefaultup'];
		$config['captiveportal']['nomacfilter'] = $_POST['nomacfilter'] ? true : false;
		$config['captiveportal']['noconcurrentlogins'] = $_POST['noconcurrentlogins'] ? true : false;
		$config['captiveportal']['redirurl'] = $_POST['redirurl'];
		$config['captiveportal']['radiusip'] = $_POST['radiusip'];
		$config['captiveportal']['radiusip2'] = $_POST['radiusip2'];
		$config['captiveportal']['radiusport'] = $_POST['radiusport'];
		$config['captiveportal']['radiusport2'] = $_POST['radiusport2'];
		$config['captiveportal']['radiusacctport'] = $_POST['radiusacctport'];
		$config['captiveportal']['radiuskey'] = $_POST['radiuskey'];
		$config['captiveportal']['radiuskey2'] = $_POST['radiuskey2'];
		$config['captiveportal']['radiusvendor'] = $_POST['radiusvendor'] ? $_POST['radiusvendor'] : false;
		$config['captiveportal']['radiussession_timeout'] = $_POST['radiussession_timeout'] ? true : false;
        $config['captiveportal']['radmac_format'] = $_POST['radmac_format'] ? $_POST['radmac_format'] : false;
		
		/* file upload? */
		if (is_uploaded_file($_FILES['htmlfile']['tmp_name']))
			$config['captiveportal']['page']['htmltext'] = base64_encode(file_get_contents($_FILES['htmlfile']['tmp_name']));
		if (is_uploaded_file($_FILES['errfile']['tmp_name']))
			$config['captiveportal']['page']['errtext'] = base64_encode(file_get_contents($_FILES['errfile']['tmp_name']));
			
		write_config();
		
		$retval = 0;
		if (!file_exists($d_sysrebootreqd_path)) {
			config_lock();
			$retval = captiveportal_configure();
			config_unlock();
		}
		$savemsg = get_std_save_message($retval);
	}
}
?>
<?php include("fbegin.inc"); ?>
<script language="JavaScript">
<!--
function enable_change(enable_change) {
	var endis, radius_endis;
	endis = !(document.iform.enable.checked || enable_change);
	radius_endis = !((!endis && document.iform.auth_method[2].checked) || enable_change);
	
	document.iform.cinterface.disabled = endis;
	document.iform.maxproc.disabled = endis;
	document.iform.maxprocperip.disabled = endis;
	document.iform.idletimeout.disabled = endis;
	document.iform.timeout.disabled = endis;
	document.iform.redirurl.disabled = endis;
	document.iform.radiusip.disabled = radius_endis;
	document.iform.radiusip2.disabled = radius_endis;
	document.iform.radiusport.disabled = radius_endis;
	document.iform.radiusport2.disabled = radius_endis;
	document.iform.radiuskey.disabled = radius_endis;
	document.iform.radiuskey2.disabled = radius_endis;
	document.iform.radacct_enable.disabled = radius_endis;
	document.iform.reauthenticate.disabled = radius_endis;
	document.iform.auth_method[0].disabled = endis;
	document.iform.auth_method[1].disabled = endis;
	document.iform.auth_method[2].disabled = endis;
	document.iform.peruserbw.disabled = endis;
	document.iform.bwdefaultdn.disabled = endis;
	document.iform.bwdefaultup.disabled = endis;
	document.iform.radmac_enable.disabled = radius_endis;
	document.iform.radmac_format.disabled = radius_endis;
	document.iform.httpslogin_enable.disabled = endis;
	document.iform.httpsname.disabled = endis;
	document.iform.cert.disabled = endis;
	document.iform.key.disabled = endis;
	document.iform.logoutwin_enable.disabled = endis;
	document.iform.nomacfilter.disabled = endis;
	document.iform.noconcurrentlogins.disabled = endis;
	document.iform.radiusvendor.disabled = radius_endis;
	document.iform.radiussession_timeout.disabled = radius_endis;
	document.iform.htmlfile.disabled = endis;
	document.iform.errfile.disabled = endis;
	
	document.iform.radiusacctport.disabled = (radius_endis || !document.iform.radacct_enable.checked) && !enable_change;
	
	document.iform.radmac_secret.disabled = (radius_endis || !document.iform.radmac_enable.checked) && !enable_change;
	
	var reauthenticate_dis = (radius_endis || !document.iform.reauthenticate.checked) && !enable_change;
	document.iform.reauthenticateacct[0].disabled = reauthenticate_dis;
	document.iform.reauthenticateacct[1].disabled = reauthenticate_dis;
	document.iform.reauthenticateacct[2].disabled = reauthenticate_dis;
}
//-->
</script>
<?php if ($input_errors) print_input_errors($input_errors); ?>
<?php if ($savemsg) print_info_box($savemsg); ?>



<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
		<td class="tabnavtbl">
  		<ul id="tabnav">
				<li class="tabact"><a href="services_captiveportal.php" title="<?=gettext("Reload page");?>"><span><?=gettext("Captive Portal");?></span></a></li>
				<li class="tabinact"><a href="services_captiveportal_mac.php"><span><?=gettext("Pass-through MAC");?></span></a></li>
				<li class="tabinact"><a href="services_captiveportal_ip.php"><span><?=gettext("Allowed IP addresses");?></span></a></li>
				<li class="tabinact"><a href="services_captiveportal_users.php"><span><?=gettext("Users");?></span></a></li>
				<li class="tabinact"><a href="services_captiveportal_filemanager.php"><span><?=gettext("File Manager");?></span></a></li>
  		</ul>
  	</td>
	</tr>
  <tr>
  <td class="tabcont">
  <table width="100%" border="0" cellpadding="6" cellspacing="0">
	<tr> 
	  <td width="22%" valign="top" class="vtable">&nbsp;</td>
	  <td width="78%" class="vtable">
		<input name="enable" type="checkbox" value="yes" <?php if ($pconfig['enable']) echo "checked"; ?> onClick="enable_change(false)">
		<strong>Enable captive portal </strong></td>
	</tr>
	<tr> 
	  <td width="22%" valign="top" class="vncellreq">Interface</td>
	  <td width="78%" class="vtable">
		<select name="cinterface" class="formfld" id="cinterface">
		  <?php $interfaces = array('lan' => 'LAN');
		  for ($i = 1; isset($config['interfaces']['opt' . $i]); $i++) {
			if (isset($config['interfaces']['opt' . $i]['enable']))
				$interfaces['opt' . $i] = $config['interfaces']['opt' . $i]['descr'];
		  }
		  foreach ($interfaces as $iface => $ifacename): ?>
		  <option value="<?=$iface;?>" <?php if ($iface == $pconfig['cinterface']) echo "selected"; ?>> 
		  <?=htmlspecialchars($ifacename);?>
		  </option>
		  <?php endforeach; ?>
		</select> <br>
		<span class="vexpl">Choose which interface to run the captive portal on.</span></td>
	</tr>
	<tr>
	  <td valign="top" class="vncell">Maximum concurrent connections</td>
	  <td class="vtable">
		<table cellpadding="0" cellspacing="0">
                 <tr>
           <td><input name="maxprocperip" type="text" class="formfld" id="maxprocperip" size="5" value="<?=htmlspecialchars($pconfig['maxprocperip']);?>"> per client IP address (0 = no limit)</td>
                 </tr>
                 <tr>
           <td><input name="maxproc" type="text" class="formfld" id="maxproc" size="5" value="<?=htmlspecialchars($pconfig['maxproc']);?>"> total</td>
                 </tr>
               </table>
This setting limits the number of concurrent connections to the captive portal HTTP(S) server. This does not set how many users can be logged in
to the captive portal, but rather how many users can load the portal page or authenticate at the same time!
Default is 4 connections per client IP address, with a total maximum of 16 connections.</td>
	</tr>
	<tr>
	  <td valign="top" class="vncell">Idle timeout</td>
	  <td class="vtable">
		<input name="idletimeout" type="text" class="formfld" id="idletimeout" size="6" value="<?=htmlspecialchars($pconfig['idletimeout']);?>">
minutes<br>
Clients will be disconnected after this amount of inactivity. They may log in again immediately, though. Leave this field blank for no idle timeout.</td>
	</tr>
	<tr> 
	  <td width="22%" valign="top" class="vncell">Hard timeout</td>
	  <td width="78%" class="vtable"> 
		<input name="timeout" type="text" class="formfld" id="timeout" size="6" value="<?=htmlspecialchars($pconfig['timeout']);?>"> 
		minutes<br>
	  Clients will be disconnected after this amount of time, regardless of activity. They may log in again immediately, though. Leave this field blank for no hard timeout (not recommended unless an idle timeout is set).</td>
	</tr>
	<tr> 
	  <td width="22%" valign="top" class="vncell">Logout popup window</td>
	  <td width="78%" class="vtable"> 
		<input name="logoutwin_enable" type="checkbox" class="formfld" id="logoutwin_enable" value="yes" <?php if($pconfig['logoutwin_enable']) echo "checked"; ?>>
		<strong>Enable logout popup window</strong><br>
	  If enabled, a popup window will appear when clients are allowed through the captive portal. This allows clients to explicitly disconnect themselves before the idle or hard timeout occurs.</td>
	</tr>
	<tr>
	  <td valign="top" class="vncell">Redirection URL</td>
	  <td class="vtable">
		<input name="redirurl" type="text" class="formfld" id="redirurl" size="60" value="<?=htmlspecialchars($pconfig['redirurl']);?>">
		<br>
If you provide a URL here, clients will be redirected to that URL instead of the one they initially tried
to access after they've authenticated.</td>
	</tr>
	<tr>
      <td valign="top" class="vncell">Concurrent user logins</td>
      <td class="vtable">
	<input name="noconcurrentlogins" type="checkbox" class="formfld" id="noconcurrentlogins" value="yes" <?php if ($pconfig['noconcurrentlogins']) echo "checked"; ?>>
	<strong>Disable concurrent logins</strong><br>
	If this option is set, only the most recent login per username will be active. Subsequent logins will cause machines previously logged in with the same username to be disconnected.</td>
	</tr>
	<tr>
      <td valign="top" class="vncell">MAC filtering </td>
      <td class="vtable">
        <input name="nomacfilter" type="checkbox" class="formfld" id="nomacfilter" value="yes" <?php if ($pconfig['nomacfilter']) echo "checked"; ?>>
        <strong>Disable MAC filtering</strong><br>
    If this option is set, no attempts will be made to ensure that the MAC address of clients stays the same while they're logged in.
    This is required when the MAC address of the client cannot be determined (usually because there are routers between m0n0wall and the clients).</td>
	</tr>
    <tr>
      <td valign="top" class="vncell">Per-user bandwidth restriction</td>
      <td class="vtable">
        <input name="peruserbw" type="checkbox" class="formfld" id="peruserbw" value="yes" <?php if ($pconfig['peruserbw']) echo "checked"; ?>>
        <strong>Enable per-user bandwidth restriction</strong><br><br>
        <table cellpadding="0" cellspacing="0">
        <tr>
        <td>Default download</td>
        <td><input type="text" class="formfld" name="bwdefaultdn" id="bwdefaultdn" size="10" value="<?=htmlspecialchars($pconfig['bwdefaultdn']);?>"> Kbit/s</td>
        </tr>
        <tr>
        <td>Default upload</td>
        <td><input type="text" class="formfld" name="bwdefaultup" id="bwdefaultup" size="10" value="<?=htmlspecialchars($pconfig['bwdefaultup']);?>"> Kbit/s</td>
        </tr></table>
        <br>
        If this option is set, the captive portal will restrict each user who logs in to the specified default bandwidth. RADIUS can override the default settings. Leave empty or set to 0 for no limit. You will <strong>need</strong> to enable the traffic shaper for this to be effective.</td>
        </tr>
	<tr> 
	  <td width="22%" valign="top" class="vncell">Authentication</td>
	  <td width="78%" class="vtable"> 
		<table cellpadding="0" cellspacing="0">
		<tr>
		  <td colspan="2"><input name="auth_method" type="radio" id="auth_method" value="none" onClick="enable_change(false)" <?php if($pconfig['auth_method']!="local" && $pconfig['auth_method']!="radius") echo "checked"; ?>>
  No authentication</td>  
		  </tr>
		<tr>
		  <td colspan="2"><input name="auth_method" type="radio" id="auth_method" value="local" onClick="enable_change(false)" <?php if($pconfig['auth_method']=="local") echo "checked"; ?>>
  Local <a href="services_captiveportal_users.php">user manager</a></td>  
		  </tr>
		<tr>
		  <td colspan="2"><input name="auth_method" type="radio" id="auth_method" value="radius" onClick="enable_change(false)" <?php if($pconfig['auth_method']=="radius") echo "checked"; ?>>
  RADIUS authentication</td>  
		  </tr><tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  </tr>
		</table>
		<table width="100%" border="0" cellpadding="6" cellspacing="0">
        	<tr> 
            	<td colspan="2" valign="top" class="optsect_t2">Primary RADIUS server</td>
			</tr>
			<tr>
				<td class="vncell" valign="top">IP address</td>
				<td class="vtable"><input name="radiusip" type="text" class="formfld" id="radiusip" size="20" value="<?=htmlspecialchars($pconfig['radiusip']);?>"><br>
				Enter the IP address of the RADIUS server which users of the captive portal have to authenticate against.</td>
			</tr>
			<tr>
				<td class="vncell" valign="top">Port</td>
				<td class="vtable"><input name="radiusport" type="text" class="formfld" id="radiusport" size="5" value="<?=htmlspecialchars($pconfig['radiusport']);?>"><br>
				 Leave this field blank to use the default port (1812).</td>
			</tr>
			<tr>
				<td class="vncell" valign="top">Shared secret&nbsp;&nbsp;</td>
				<td class="vtable"><input name="radiuskey" type="text" class="formfld" id="radiuskey" size="16" value="<?=htmlspecialchars($pconfig['radiuskey']);?>"><br>
				Leave this field blank to not use a RADIUS shared secret (not recommended).</td>
			</tr>
			<tr> 
			  <td colspan="2" class="list" height="12"></td>
			</tr>
			<tr>
				<td colspan="2" valign="top" class="optsect_t2">Secondary RADIUS server</td>
			</tr>
			<tr>
				<td class="vncell" valign="top">IP address</td>
				<td class="vtable"><input name="radiusip2" type="text" class="formfld" id="radiusip2" size="20" value="<?=htmlspecialchars($pconfig['radiusip2']);?>"><br>
				If you have a second RADIUS server, you can activate it by entering its IP address here.</td>
			</tr>
			<tr>
				<td class="vncell" valign="top">Port</td>
				<td class="vtable"><input name="radiusport2" type="text" class="formfld" id="radiusport2" size="5" value="<?=htmlspecialchars($pconfig['radiusport2']);?>"></td>
			</tr>
			<tr>
				<td class="vncell" valign="top">Shared secret&nbsp;&nbsp;</td>
				<td class="vtable"><input name="radiuskey2" type="text" class="formfld" id="radiuskey2" size="16" value="<?=htmlspecialchars($pconfig['radiuskey2']);?>"></td>
			</tr>
			<tr> 
			  <td colspan="2" class="list" height="12"></td>
			</tr>
			<tr>
				<td colspan="2" valign="top" class="optsect_t2">Accounting</td>
			</tr>
			<tr>
				<td class="vncell">&nbsp;</td>
				<td class="vtable"><input name="radacct_enable" type="checkbox" id="radacct_enable" value="yes" onClick="enable_change(false)" <?php if($pconfig['radacct_enable']) echo "checked"; ?>>
				<strong>send RADIUS accounting packets</strong><br>
				If this is enabled, RADIUS accounting packets will be sent to the primary RADIUS server.</td>
			</tr>
			<tr>
			  <td class="vncell" valign="top">Accounting port</td>
			  <td class="vtable"><input name="radiusacctport" type="text" class="formfld" id="radiusacctport" size="5" value="<?=htmlspecialchars($pconfig['radiusacctport']);?>"><br>
			  Leave blank to use the default port (1813).</td>
			  </tr>
			<tr>
			  <td colspan="2" class="list" height="12"></td>
			</tr>
			<tr>
				<td colspan="2" valign="top" class="optsect_t2">Reauthentication</td>
			</tr>
			<tr>
				<td class="vncell">&nbsp;</td>
				<td class="vtable"><input name="reauthenticate" type="checkbox" id="reauthenticate" value="yes" onClick="enable_change(false)" <?php if($pconfig['reauthenticate']) echo "checked"; ?>>
			  <strong>Reauthenticate connected users every minute</strong><br>
			  If reauthentication is enabled, Access-Requests will be sent to the RADIUS server for each user that is
			  logged in every minute. If an Access-Reject is received for a user, that user is disconnected from the captive portal immediately.</td>
			</tr>
			<tr>
			  <td class="vncell" valign="top">Accounting updates</td>
			  <td class="vtable">
			  <input name="reauthenticateacct" type="radio" value="" <?php if(!$pconfig['reauthenticateacct']) echo "checked"; ?>> no accounting updates<br>
			  <input name="reauthenticateacct" type="radio" value="stopstart" <?php if($pconfig['reauthenticateacct'] == "stopstart") echo "checked"; ?>> stop/start accounting<br>
			  <input name="reauthenticateacct" type="radio" value="interimupdate" <?php if($pconfig['reauthenticateacct'] == "interimupdate") echo "checked"; ?>> interim update
			  </td>
			</tr>
			<tr>
			  <td colspan="2" class="list" height="12"></td>
			</tr>
			<tr>
				<td colspan="2" valign="top" class="optsect_t2">RADIUS MAC authentication</td>
			</tr>
			<tr>
				<td class="vncell">&nbsp;</td>
				<td class="vtable">
				<input name="radmac_enable" type="checkbox" id="radmac_enable" value="yes" onClick="enable_change(false)" <?php if ($pconfig['radmac_enable']) echo "checked"; ?>><strong>Enable RADIUS MAC authentication</strong><br>
				If this option is enabled, the captive portal will try to authenticate users by sending their MAC address as the username and the password
				entered below to the RADIUS server.</td>
			</tr>
			<tr>
				<td class="vncell">Shared secret</td>
				<td class="vtable"><input name="radmac_secret" type="text" class="formfld" id="radmac_secret" size="16" value="<?=htmlspecialchars($pconfig['radmac_secret']);?>"></td>
			</tr>
			<tr>
			  <td colspan="2" class="list" height="12"></td>
			</tr>
			<tr>
				<td colspan="2" valign="top" class="optsect_t2">RADIUS options</td>
			</tr>
			<tr>
				<td class="vncell" valign="top">Session-Timeout</td>
				<td class="vtable"><input name="radiussession_timeout" type="checkbox" id="radiussession_timeout" value="yes" <?php if ($pconfig['radiussession_timeout']) echo "checked"; ?>><strong>Use RADIUS Session-Timeout attributes</strong><br>
				When this is enabled, clients will be disconnected after the amount of time retrieved from the RADIUS Session-Timeout attribute.</td>
			</tr>
			<tr>
				<td class="vncell" valign="top">Type</td>
				<td class="vtable"><select name="radiusvendor" id="radiusvendor">
				<option>default</option>
				<?php 
				$radiusvendors = array("cisco");
				foreach ($radiusvendors as $radiusvendor){
					if ($pconfig['radiusvendor'] == $radiusvendor)
						echo "<option selected value=\"$radiusvendor\">$radiusvendor</option>\n";
					else
						echo "<option value=\"$radiusvendor\">$radiusvendor</option>\n";
				}
				?></select><br>
				If RADIUS type is set to Cisco, in RADIUS requests (Authentication/Accounting) the value of Calling-Station-Id will be set to the client's IP address and
				the Called-Station-Id to the client's MAC address. Default behaviour is Calling-Station-Id = client's MAC address and Called-Station-Id = m0n0wall's WAN MAC address.</td>
			</tr>
            <tr>
                <td class="vncell" valign="top">MAC address format</td>
                <td class="vtable">
                <select name="radmac_format" id="radmac_format">
                <option>default</option>
                <?php
                $macformats = array("singledash","ietf","cisco","unformatted");
                foreach ($macformats as $macformat) {
                    if ($pconfig['radmac_format'] == $macformat)
                        echo "<option selected value=\"$macformat\">$macformat</option>\n";
                    else
                        echo "<option value=\"$macformat\">$macformat</option>\n";
                }
                ?>
                </select></br>
                This option changes the MAC address format used in the whole RADIUS system. Change this if you also
                need to change the username format for RADIUS MAC authentication.<br>
                default: 00:11:22:33:44:55<br>
                singledash: 001122-334455<br>
                ietf: 00-11-22-33-44-55<br>
                cisco: 0011.2233.4455<br>
                unformatted: 001122334455
            </tr>
		</table>
	</tr>
	<tr>
      <td valign="top" class="vncell">HTTPS login</td>
      <td class="vtable">
        <input name="httpslogin_enable" type="checkbox" class="formfld" id="httpslogin_enable" value="yes" <?php if($pconfig['httpslogin_enable']) echo "checked"; ?>>
        <strong>Enable HTTPS login</strong><br>
    If enabled, the username and password will be transmitted over an HTTPS connection to protect against eavesdroppers. A server name, certificate and matching private key must also be specified below.</td>
	  </tr>
	<tr>
      <td valign="top" class="vncell">HTTPS server name </td>
      <td class="vtable">
        <input name="httpsname" type="text" class="formfld" id="httpsname" size="30" value="<?=htmlspecialchars($pconfig['httpsname']);?>"><br>
    This name will be used in the form action for the HTTPS POST and should match the Common Name (CN) in your certificate (otherwise, the client browser will most likely display a security warning). Make sure captive portal clients can resolve this name in DNS. </td>
	  </tr>
	<tr>
      <td valign="top" class="vncell">HTTPS certificate</td>
      <td class="vtable">
        <textarea name="cert" cols="65" rows="7" id="cert" class="formpre"><?=htmlspecialchars($pconfig['cert']);?></textarea>
        <br>
    Paste a signed certificate in X.509 PEM format here.</td>
	  </tr>
	<tr>
      <td valign="top" class="vncell">HTTPS private key</td>
      <td class="vtable">
        <textarea name="key" cols="65" rows="7" id="key" class="formpre"><?=htmlspecialchars($pconfig['key']);?></textarea>
        <br>
    Paste an RSA private key in PEM format here.</td>
	  </tr>
	<tr> 
	  <td width="22%" valign="top" class="vncellreq">Portal page contents</td>
	  <td width="78%" class="vtable">    
		<?=$mandfldhtml;?><input type="file" name="htmlfile" class="formfld" id="htmlfile"><br>
		<?php if ($config['captiveportal']['page']['htmltext']): ?>
		<a href="?act=viewhtml" target="_blank">View current page</a>                      
		  <br>
		  <br>
		<?php endif; ?>
		  Upload an HTML file for the portal page here (leave blank to keep the current one). Make sure to include a form (POST to &quot;$PORTAL_ACTION$&quot;)
with a submit button (name=&quot;accept&quot;) and a hidden field with name=&quot;redirurl&quot; and value=&quot;$PORTAL_REDIRURL$&quot;.
Include the &quot;auth_user&quot; and &quot;auth_pass&quot; input fields if authentication is enabled, otherwise it will always fail.
Example code for the form:<br>
		  <br>
		  <tt>&lt;form method=&quot;post&quot; action=&quot;$PORTAL_ACTION$&quot;&gt;<br>
		  &nbsp;&nbsp;&nbsp;&lt;input name=&quot;auth_user&quot; type=&quot;text&quot;&gt;<br>
		  &nbsp;&nbsp;&nbsp;&lt;input name=&quot;auth_pass&quot; type=&quot;password&quot;&gt;<br>
		  &nbsp;&nbsp;&nbsp;&lt;input name=&quot;redirurl&quot; type=&quot;hidden&quot; value=&quot;$PORTAL_REDIRURL$&quot;&gt;<br>
&nbsp;&nbsp;&nbsp;&lt;input name=&quot;accept&quot; type=&quot;submit&quot; value=&quot;Continue&quot;&gt;<br>
		  &lt;/form&gt;</tt></td>
	</tr>
	<tr>
	  <td width="22%" valign="top" class="vncell">Authentication<br>
		error page<br>
		contents</td>
	  <td class="vtable">
		<input name="errfile" type="file" class="formfld" id="errfile"><br>
		<?php if ($config['captiveportal']['page']['errtext']): ?>
		<a href="?act=viewerrhtml" target="_blank">View current page</a>                      
		  <br>
		  <br>
		<?php endif; ?>
The contents of the HTML file that you upload here are displayed when an authentication error occurs.
You may include &quot;$PORTAL_MESSAGE$&quot;, which will be replaced by the error or reply messages from the RADIUS server, if any.
You may also include a new login form in the error page to allow the user to attempt another login directly.</td>
	</tr>
	<tr> 
	  <td width="22%" valign="top">&nbsp;</td>
	  <td width="78%"> 
		<input name="Submit" type="submit" class="formbtn" value="Save" onClick="enable_change(true)"> 
	  </td>
	</tr>
	<tr> 
	  <td width="22%" valign="top">&nbsp;</td>
	  <td width="78%"><span class="vexpl"><span class="red"><strong>Note:<br>
		</strong></span>Changing any settings on this page will disconnect all clients! Don't forget to enable the DHCP server on your captive portal interface! Make sure that the default/maximum DHCP lease time is higher than the timeout entered on this page. Also, the DNS forwarder needs to be enabled for DNS lookups by unauthenticated clients to work. </span></td>
	</tr>
  </table>
  </td>
  </tr>
  </table>
</form>
<script language="JavaScript">
<!--
enable_change(false);
//-->
</script>
<?php include("fend.inc"); ?>
