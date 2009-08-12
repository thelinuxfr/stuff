#!/usr/local/bin/php
<?php
/*
	$Id: vpn_ipsec_mobile.php 72 2006-02-10 11:13:01Z jdegraeve $
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

$pgtitle = array(gettext("VPN"),gettext("IPsec"),gettext("Mobile clients"));

if (!is_array($config['ipsec']['mobileclients'])) {
	$config['ipsec']['mobileclients'] = array();
}
$a_ipsec = &$config['ipsec']['mobileclients'];

if (count($a_ipsec) == 0) {
	/* defaults */
	$pconfig['p1mode'] = "aggressive";
	$pconfig['p1myidentt'] = "myaddress";
	$pconfig['p1ealgo'] = "3des";
	$pconfig['p1halgo'] = "sha1";
	$pconfig['p1dhgroup'] = "2";
	$pconfig['p1authentication_method'] = "pre_shared_key";
	$pconfig['p2proto'] = "esp";
	$pconfig['p2ealgos'] = explode(",", "3des,blowfish,cast128,rijndael");
	$pconfig['p2halgos'] = explode(",", "hmac_sha1,hmac_md5");
	$pconfig['p2pfsgroup'] = "0";
} else {
	$pconfig['enable'] = isset($a_ipsec['enable']);
	$pconfig['p1mode'] = $a_ipsec['p1']['mode'];
		
	if (isset($a_ipsec['p1']['myident']['myaddress']))
		$pconfig['p1myidentt'] = 'myaddress';
	else if (isset($a_ipsec['p1']['myident']['address'])) {
		$pconfig['p1myidentt'] = 'address';
		$pconfig['p1myident'] = $a_ipsec['p1']['myident']['address'];
	} else if (isset($a_ipsec['p1']['myident']['fqdn'])) {
		$pconfig['p1myidentt'] = 'fqdn';
		$pconfig['p1myident'] = $a_ipsec['p1']['myident']['fqdn'];
	} else if (isset($a_ipsec['p1']['myident']['ufqdn'])) {
		$pconfig['p1myidentt'] = 'user_fqdn';
		$pconfig['p1myident'] = $a_ipsec['p1']['myident']['ufqdn'];
 	}
	
	$pconfig['p1ealgo'] = $a_ipsec['p1']['encryption-algorithm'];
	$pconfig['p1halgo'] = $a_ipsec['p1']['hash-algorithm'];
	$pconfig['p1dhgroup'] = $a_ipsec['p1']['dhgroup'];
	$pconfig['p1lifetime'] = $a_ipsec['p1']['lifetime'];
	$pconfig['p1authentication_method'] = $a_ipsec['p1']['authentication_method'];
	$pconfig['p1cert'] = base64_decode($a_ipsec['p1']['cert']);
	$pconfig['p1privatekey'] = base64_decode($a_ipsec['p1']['private-key']);
	$pconfig['p2proto'] = $a_ipsec['p2']['protocol'];
	$pconfig['p2ealgos'] = $a_ipsec['p2']['encryption-algorithm-option'];
	$pconfig['p2halgos'] = $a_ipsec['p2']['hash-algorithm-option'];
	$pconfig['p2pfsgroup'] = $a_ipsec['p2']['pfsgroup'];
	$pconfig['p2lifetime'] = $a_ipsec['p2']['lifetime'];
}

if ($_POST) {
	unset($input_errors);
	$pconfig = $_POST;

	/* input validation */
	$reqdfields = explode(" ", "p2ealgos p2halgos");
	$reqdfieldsn = explode(",", "P2 Encryption Algorithms,P2 Hash Algorithms");
	
	do_input_validation($_POST, $reqdfields, $reqdfieldsn, &$input_errors);
	
	if ($_POST['p1authentication_method']== "rsasig") {
		if (!strstr($_POST['p1cert'], "BEGIN CERTIFICATE") || !strstr($_POST['p1cert'], "END CERTIFICATE"))
			$input_errors[] = "This certificate does not appear to be valid.";
		if (!strstr($_POST['p1privatekey'], "BEGIN RSA PRIVATE KEY") || !strstr($_POST['p1privatekey'], "END RSA PRIVATE KEY"))
			$input_errors[] = "This key does not appear to be valid.";	
	}
	
	if (($_POST['p1lifetime'] && !is_numeric($_POST['p1lifetime']))) {
		$input_errors[] = "The P1 lifetime must be an integer.";
	}
	if (($_POST['p2lifetime'] && !is_numeric($_POST['p2lifetime']))) {
		$input_errors[] = "The P2 lifetime must be an integer.";
	}
	if ((($_POST['p1myidentt'] == "address") && !is_ipaddr($_POST['p1myident']))) {
		$input_errors[] = "A valid IP address for 'My identifier' must be specified.";
	}
	if ((($_POST['p1myidentt'] == "fqdn") && !is_domain($_POST['p1myident']))) {
		$input_errors[] = "A valid domain name for 'My identifier' must be specified.";
	}
	if ($_POST['p1myidentt'] == "user_fqdn") {
		$ufqdn = explode("@",$_POST['p1myident']);
		if (!is_domain($ufqdn[1])) 
			$input_errors[] = "A valid User FQDN in the form of user@my.domain.com for 'My identifier' must be specified.";
	}
	
	if ($_POST['p1myidentt'] == "myaddress")
		$_POST['p1myident'] = "";

	if (!$input_errors) {
		$ipsecent = array();
		$ipsecent['enable'] = $_POST['enable'] ? true : false;
		$ipsecent['p1']['mode'] = $_POST['p1mode'];
		
		$ipsecent['p1']['myident'] = array();
		switch ($_POST['p1myidentt']) {
			case 'myaddress':
				$ipsecent['p1']['myident']['myaddress'] = true;
				break;
			case 'address':
				$ipsecent['p1']['myident']['address'] = $_POST['p1myident'];
				break;
			case 'fqdn':
				$ipsecent['p1']['myident']['fqdn'] = $_POST['p1myident'];
				break;
			case 'user_fqdn':
				$ipsecent['p1']['myident']['ufqdn'] = $_POST['p1myident'];
				break;
		}
		
		$ipsecent['p1']['encryption-algorithm'] = $_POST['p1ealgo'];
		$ipsecent['p1']['hash-algorithm'] = $_POST['p1halgo'];
		$ipsecent['p1']['dhgroup'] = $_POST['p1dhgroup'];
		$ipsecent['p1']['lifetime'] = $_POST['p1lifetime'];
		$ipsecent['p1']['private-key'] = base64_encode($_POST['p1privatekey']);
		$ipsecent['p1']['cert'] = base64_encode($_POST['p1cert']);
		$ipsecent['p1']['authentication_method'] = $_POST['p1authentication_method'];
		$ipsecent['p2']['protocol'] = $_POST['p2proto'];
		$ipsecent['p2']['encryption-algorithm-option'] = $_POST['p2ealgos'];
		$ipsecent['p2']['hash-algorithm-option'] = $_POST['p2halgos'];
		$ipsecent['p2']['pfsgroup'] = $_POST['p2pfsgroup'];
		$ipsecent['p2']['lifetime'] = $_POST['p2lifetime'];
		
		$a_ipsec = $ipsecent;
		
		write_config();
		touch($d_ipsecconfdirty_path);
		
		header("Location: vpn_ipsec_mobile.php");
		exit;
	}
}
?>
<?php include("fbegin.inc"); ?>
<script language="JavaScript">
<!--
function methodsel_change() {
	switch (document.iform.p1authentication_method.selectedIndex) {
		case 1:	/* rsa */
			document.iform.p1privatekey.disabled = 0;
			document.iform.p1cert.disabled = 0;
			break;
		default: /* pre-shared */
			document.iform.p1privatekey.disabled = 1;
			document.iform.p1cert.disabled = 1;
			break;
	}
}
//-->
</script>
<form action="vpn_ipsec.php" method="post">
<?php if ($input_errors) print_input_errors($input_errors); ?>
<?php if (file_exists($d_ipsecconfdirty_path)): ?><p>
<?php print_info_box_np("The IPsec tunnel configuration has been changed.<br>You must apply the changes in order for them to take effect.");?><br>
<input name="apply" type="submit" class="formbtn" id="apply" value="Apply changes"></p>
<?php endif; ?>
</form>

<form action="vpn_ipsec_mobile.php" method="post" name="iform" id="iform">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr><td class="tabnavtbl">
  <ul id="tabnav">
				<li class="tabinact"><a href="vpn_ipsec.php" title="<?=gettext("Reload page");?>"><span><?=gettext("Tunnels");?></span></a></li>
				<li class="tabact"><a href="vpn_ipsec_mobile.php"><span><?=gettext("Mobile clients");?></span></a></li>
				<li class="tabinact"><a href="vpn_ipsec_keys.php"><span><?=gettext("Pre-shared keys");?></span></a></li>
				<li class="tabinact"><a href="vpn_ipsec_ca.php"><span><?=gettext("CAs");?></span></a></li>    
  </ul>
  </td></tr>
  <tr> 
    <td class="tabcont">
              <table width="100%" border="0" cellpadding="6" cellspacing="0">
			  <tr> 
                        <td width="22%" valign="top">&nbsp;</td>
                        <td width="78%"> 
                    <input name="enable" type="checkbox" id="enable" value="yes" <?php if ($pconfig['enable']) echo "checked"; ?>>
                    <strong>Allow mobile clients</strong></td>
                </tr>
                <tr> 
                  <td colspan="2" valign="top" class="listtopic">Phase 1 proposal 
                    (Authentication)</td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">Negotiation mode</td>
                        <td width="78%" class="vtable">
					<select name="p1mode" class="formfld">
                      <?php $modes = explode(" ", "main aggressive"); foreach ($modes as $mode): ?>
                      <option value="<?=$mode;?>" <?php if ($mode == $pconfig['p1mode']) echo "selected"; ?>> 
                      <?=htmlspecialchars($mode);?>
                      </option>
                      <?php endforeach; ?>
                    </select> <br> <span class="vexpl">Aggressive is faster, but 
                    less secure.</span></td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">My identifier</td>
                        <td width="78%" class="vtable">
					<select name="p1myidentt" class="formfld">
                      <?php foreach ($my_identifier_list as $mode => $modename): ?>
                      <option value="<?=$mode;?>" <?php if ($mode == $pconfig['p1myidentt']) echo "selected"; ?>> 
                      <?=htmlspecialchars($modename);?>
                      </option>
                      <?php endforeach; ?>
                    </select> <input name="p1myident" type="text" class="formfld" id="p1myident" size="30" value="<?=$pconfig['p1myident'];?>"> 
                  </td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">Encryption algorithm</td>
                        <td width="78%" class="vtable">
					<select name="p1ealgo" class="formfld">
                      <?php foreach ($p1_ealgos as $algo => $algoname): ?>
                      <option value="<?=$algo;?>" <?php if ($algo == $pconfig['p1ealgo']) echo "selected"; ?>> 
                      <?=htmlspecialchars($algoname);?>
                      </option>
                      <?php endforeach; ?>
                    </select> <br> <span class="vexpl">Must match the setting 
                    chosen on the remote side. </span></td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">Hash algorithm</td>
                        <td width="78%" class="vtable">
					<select name="p1halgo" class="formfld">
                      <?php foreach ($p1_halgos as $algo => $algoname): ?>
                      <option value="<?=$algo;?>" <?php if ($algo == $pconfig['p1halgo']) echo "selected"; ?>> 
                      <?=htmlspecialchars($algoname);?>
                      </option>
                      <?php endforeach; ?>
                    </select> <br> <span class="vexpl">Must match the setting 
                    chosen on the remote side. </span></td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">DH key group</td>
                        <td width="78%" class="vtable">
					<select name="p1dhgroup" class="formfld">
                      <?php $keygroups = explode(" ", "1 2 5"); foreach ($keygroups as $keygroup): ?>
                      <option value="<?=$keygroup;?>" <?php if ($keygroup == $pconfig['p1dhgroup']) echo "selected"; ?>> 
                      <?=htmlspecialchars($keygroup);?>
                      </option>
                      <?php endforeach; ?>
                    </select> <br> <span class="vexpl"><em>1 = 768 bit, 2 = 1024 
                    bit, 5 = 1536 bit</em><br>
                    Must match the setting chosen on the remote side. </span></td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncell">Lifetime</td>
                        <td width="78%" class="vtable"> 
                    <input name="p1lifetime" type="text" class="formfld" id="p1lifetime" size="20" value="<?=$pconfig['p1lifetime'];?>">
                    seconds</td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">Authentication method</td>
                  <td width="78%" class="vtable">
					<select name="p1authentication_method" class="formfld" onChange="methodsel_change()">
                      <?php foreach ($p1_authentication_methods as $method => $methodname): ?>
                      <option value="<?=$method;?>" <?php if ($method == $pconfig['p1authentication_method']) echo "selected"; ?>> 
                      <?=htmlspecialchars($methodname);?>
                      </option>
                      <?php endforeach; ?>
                    </select> <br> <span class="vexpl">Must match the setting 
                    chosen on the remote side. </span></td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">Certificate</td>
                  <td width="78%" class="vtable"> 
                    <textarea name="p1cert" cols="65" rows="7" id="p1cert" class="formpre"><?=htmlspecialchars($pconfig['p1cert']);?></textarea>
                    <br> 
                    Paste a certificate in X.509 PEM format here.</td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">Key</td>
                  <td width="78%" class="vtable"> 
                    <textarea name="p1privatekey" cols="65" rows="7" id="p1privatekey" class="formpre"><?=htmlspecialchars($pconfig['p1privatekey']);?></textarea>
                    <br> 
                    Paste an RSA private key in PEM format here.</td>
                </tr>
                <tr> 
                  <td colspan="2" class="list" height="12"></td>
                </tr>
                <tr> 
                  <td colspan="2" valign="top" class="listtopic">Phase 2 proposal 
                    (SA/Key Exchange)</td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">Protocol</td>
                        <td width="78%" class="vtable">
					<select name="p2proto" class="formfld">
                      <?php foreach ($p2_protos as $proto => $protoname): ?>
                      <option value="<?=$proto;?>" <?php if ($proto == $pconfig['p2proto']) echo "selected"; ?>> 
                      <?=htmlspecialchars($protoname);?>
                      </option>
                      <?php endforeach; ?>
                    </select> <br> <span class="vexpl">ESP is encryption, AH is 
                    authentication only </span></td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">Encryption algorithms</td>
                        <td width="78%" class="vtable"> 
                          <?php foreach ($p2_ealgos as $algo => $algoname): ?>
                    <input type="checkbox" name="p2ealgos[]" value="<?=$algo;?>" <?php if (in_array($algo, $pconfig['p2ealgos'])) echo "checked"; ?>> 
                    <?=htmlspecialchars($algoname);?>
                    <br> 
                    <?php endforeach; ?>
                    <br>
                    Hint: use 3DES for best compatibility or if you have a hardware 
                    crypto accelerator card. Blowfish is usually the fastest in 
                    software encryption. </td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">Hash algorithms</td>
                        <td width="78%" class="vtable"> 
                          <?php foreach ($p2_halgos as $algo => $algoname): ?>
                    <input type="checkbox" name="p2halgos[]" value="<?=$algo;?>" <?php if (in_array($algo, $pconfig['p2halgos'])) echo "checked"; ?>> 
                    <?=htmlspecialchars($algoname);?>
                    <br> 
                    <?php endforeach; ?>
                  </td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">PFS key group</td>
                        <td width="78%" class="vtable">
					<select name="p2pfsgroup" class="formfld">
                      <?php foreach ($p2_pfskeygroups as $keygroup => $keygroupname): ?>
                      <option value="<?=$keygroup;?>" <?php if ($keygroup == $pconfig['p2pfsgroup']) echo "selected"; ?>> 
                      <?=htmlspecialchars($keygroupname);?>
                      </option>
                      <?php endforeach; ?>
                    </select> <br> <span class="vexpl"><em>1 = 768 bit, 2 = 1024 
                    bit, 5 = 1536 bit</em></span></td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncell">Lifetime</td>
                        <td width="78%" class="vtable"> 
                    <input name="p2lifetime" type="text" class="formfld" id="p2lifetime" size="20" value="<?=$pconfig['p2lifetime'];?>">
                    seconds</td>
                </tr>
                <tr> 
                  <td width="22%" valign="top">&nbsp;</td>
                  <td width="78%"> 
                    <input name="Submit" type="submit" class="formbtn" value="Save">
                  </td>
                </tr>
              </table>
			 </td>
			</tr>
		</table>
</form>
<script language="JavaScript">
<!--
methodsel_change();
//-->
</script>
<?php include("fend.inc"); ?>
